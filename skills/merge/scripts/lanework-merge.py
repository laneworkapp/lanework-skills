#!/usr/bin/env python3
"""lanework-merge: resolve git merges of Lanework boards. Rules: ../references/rules.md.

usage:
  lanework-merge.py driver [--quiet] <base> <ours> <theirs> <path>   git merge driver (%O %A %B %P)
  lanework-merge.py resolve <repo> [--model M]   placement pass over unmerged board paths, then report
  lanework-merge.py install <repo>               .gitattributes rule + this clone's driver

python3, stdlib only. Self-contained: install copies this file into the clone's git dir.
Merge comments are signed {name: claude, kind: agent, model: M, session: "merge"} when
LANEWORK_MERGE_MODEL (or --model) names the agent's model, else {name: merge, ...}.
"""
import datetime, hashlib, json, os, re, shlex, shutil, subprocess, sys, tempfile, uuid as uuidlib

UUID = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
HEADER = '**Merged two edits to this card.**'
ATTR = '**/*.lanework/** merge=lanework'
SINGLE_KINDS = {'priority', 'component'}          # the guide's suggested definitions are single
OURS_KEYS = {'schema', 'kind', 'id', 'created', 'remote', 'remote-state'}
VERSIONED = {'CLAUDE.md', 'AGENTS.md', '.gitignore'}


def is_uuid(s):
    return bool(UUID.match(s or ''))


def sha(b):
    return hashlib.sha1(b if b is not None else b'\0none').hexdigest()


def now_utc():
    return datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')


# ---------------------------------------------------------------- git

def git(repo, *args, input=None, check=True):
    r = subprocess.run(['git', '-C', repo] + list(args), input=input, capture_output=True)
    if check and r.returncode != 0:
        raise RuntimeError('git %s: %s' % (' '.join(args), r.stderr.decode(errors='replace').strip()))
    return r.stdout


def git_ok(repo, *args):
    return subprocess.run(['git', '-C', repo] + list(args), capture_output=True).returncode == 0


def state_dir(repo):
    d = git(repo, 'rev-parse', '--git-common-dir').decode().strip()
    d = os.path.join(repo, d) if not os.path.isabs(d) else d
    d = os.path.join(d, 'lanework-merge')
    os.makedirs(d, exist_ok=True)
    return d


def rev(repo, name):
    r = subprocess.run(['git', '-C', repo, 'rev-parse', '-q', '--verify', name + '^{commit}'], capture_output=True)
    return r.stdout.decode().strip() if r.returncode == 0 else None


# ---------------------------------------------------------------- paths

def classify(path):
    """Repo-relative path -> dict(board, rel, cls, card, loc, within) or None if not on a board."""
    segs = path.split('/')
    for i, s in enumerate(segs[:-1]):
        if s.endswith('.lanework'):
            board, rel = '/'.join(segs[:i + 1]), segs[i + 1:]
            break
    else:
        return None
    c = {'board': board, 'rel': rel, 'cls': 'other', 'card': None, 'loc': None, 'within': None}
    if rel[0] == '.log':
        c['cls'] = 'log'
    elif rel[0] in VERSIONED or rel[0] == '.schema':
        c['cls'] = 'versioned'
    elif rel == ['index.md']:
        c['cls'] = 'board'
    elif is_uuid(rel[0]) and rel[1:] == ['index.md']:
        c['cls'] = 'lane'
    elif len(rel) >= 3 and is_uuid(rel[0]) and is_uuid(rel[1]):
        c.update(cls='card', card=rel[1], loc=tuple(rel[:2]), within=rel[2:])
    elif rel[0] == '.trash' and len(rel) >= 4 and is_uuid(rel[1]) and is_uuid(rel[2]):
        c.update(cls='card', card=rel[2], loc=tuple(rel[:3]), within=rel[3:])
    elif rel[0] == '.trash' and len(rel) >= 3 and is_uuid(rel[1]):
        c.update(cls='card', card=rel[1], loc=tuple(rel[:2]), within=rel[2:])  # a trashed card, or lane
    return c


def doc_kind(within):
    w = within or []
    if w == ['index.md']:
        return 'card'
    if len(w) == 3 and w[0] == 'comments' and w[2] == 'index.md':
        return 'comment'
    if len(w) in (3, 5) and w[-3] == 'attachments' and w[-1] == 'index.md':
        return 'attachment'
    return None


def is_trash(loc):
    return bool(loc) and loc[0] == '.trash'


# ---------------------------------------------------------------- mini YAML (the frontmatter subset boards use)

class Flow:
    def __init__(self, t):
        self.t, self.i = t, 0

    def ws(self):
        while self.i < len(self.t) and self.t[self.i] in ' \t\r\n':
            self.i += 1

    def peek(self):
        self.ws()
        return self.t[self.i] if self.i < len(self.t) else ''

    def value(self, key=False):
        c = self.peek()
        if c == '{':
            return self.mapping()
        if c == '[':
            return self.seq()
        if c in '"\'':
            return self.quoted()
        start = self.i
        while self.i < len(self.t):
            ch = self.t[self.i]
            if ch in ',]}' or (key and ch == ':'):
                break
            self.i += 1
        return scalar(self.t[start:self.i].strip()) if not key else self.t[start:self.i].strip()

    def quoted(self):
        q, j = self.t[self.i], self.i + 1
        while j < len(self.t):
            if q == '"' and self.t[j] == '\\':
                j += 2
                continue
            if self.t[j] == q:
                if q == "'" and self.t[j + 1:j + 2] == "'":
                    j += 2
                    continue
                break
            j += 1
        raw = self.t[self.i:j + 1]
        self.i = j + 1
        return unquote(raw)

    def mapping(self):
        self.i += 1
        d = {}
        while True:
            c = self.peek()
            if c == '}':
                self.i += 1
                return d
            if c == '':
                raise ValueError('unclosed {')
            k = self.value(key=True)
            if self.peek() != ':':
                raise ValueError('expected :')
            self.i += 1
            d[k] = None if self.peek() in ',}' else self.value()
            if self.peek() == ',':
                self.i += 1

    def seq(self):
        self.i += 1
        out = []
        while True:
            c = self.peek()
            if c == ']':
                self.i += 1
                return out
            if c == '':
                raise ValueError('unclosed [')
            out.append(self.value())
            if self.peek() == ',':
                self.i += 1


def unquote(raw):
    if raw[:1] == '"':
        try:
            return json.loads(raw)
        except ValueError:
            return raw[1:-1]
    return raw[1:-1].replace("''", "'")


def scalar(s):
    if s[:1] in '[{':
        return Flow(s).value()
    if s[:1] in '"\'':
        return unquote(s)
    s = re.sub(r'\s+#.*$', '', s)
    if s in ('true', 'false'):
        return s == 'true'
    if s in ('null', '~', ''):
        return None
    if re.match(r'^-?\d+$', s):
        return int(s)
    if re.match(r'^-?\d+\.\d*$', s):
        return float(s)
    return s


def block(items, i, ind):
    """items: [(indent, text)]. Returns (value, next index)."""
    if items[i][1] == '-' or items[i][1].startswith('- '):
        out = []
        while i < len(items) and items[i][0] == ind and (items[i][1] == '-' or items[i][1].startswith('- ')):
            rest = items[i][1][1:].lstrip()
            col = ind + len(items[i][1]) - len(rest)
            if not rest:
                v, i = block(items, i + 1, items[i + 1][0])
            elif re.match(r'^[^\s"\'\[{][^:]*:(\s|$)', rest) or re.match(r'^"[^"]*":(\s|$)', rest):
                sub = [(col, rest)] + [it for it in items[i + 1:]]
                v, j = block(sub, 0, col)
                i = i + j
            else:
                v, i = scalar(rest), i + 1
            out.append(v)
        return out, i
    d = {}
    while i < len(items) and items[i][0] == ind and not items[i][1].startswith('- '):
        m = re.match(r'^("[^"]*"|[^:]+):(?:\s+(.*))?$', items[i][1])
        if not m:
            raise ValueError('bad line: ' + items[i][1])
        k, rest = unquote(m.group(1)) if m.group(1)[:1] == '"' else m.group(1).strip(), (m.group(2) or '').strip()
        i += 1
        if rest:
            if rest[:1] in '[{':  # a flow value may run over indented lines
                while i < len(items) and items[i][0] > ind:
                    rest += ' ' + items[i][1]
                    i += 1
            d[k] = scalar(rest)
        elif i < len(items) and (items[i][0] > ind or (items[i][0] == ind and items[i][1].startswith('- '))):
            d[k], i = block(items, i, items[i][0])
        else:
            d[k] = None
    return d, i


def parse_value(lines):
    """lines of one top-level key (first line 'key: ...'). Returns the value."""
    first = lines[0].split(':', 1)[1].strip()
    rest = [l for l in lines[1:] if l.strip() and not l.strip().startswith('#')]
    if first:
        return scalar(' '.join([first] + [l.strip() for l in rest]))
    if not rest:
        return None
    items = [(len(l) - len(l.lstrip(' ')), l.strip()) for l in rest]
    return block(items, 0, items[0][0])[0]


def dump(v):
    if isinstance(v, dict):
        return '{' + ', '.join('%s: %s' % (dkey(k), dump(x)) for k, x in v.items()) + '}'
    if isinstance(v, list):
        return '[' + ', '.join(dump(x) for x in v) + ']'
    if v is True or v is False:
        return 'true' if v else 'false'
    if v is None:
        return 'null'
    if isinstance(v, (int, float)):
        return repr(v)
    return json.dumps(v, ensure_ascii=False)


def dkey(k):
    return k if re.match(r'^[A-Za-z_][A-Za-z0-9_-]*$', str(k)) else json.dumps(str(k), ensure_ascii=False)


def dump_block(v, ind):
    sp, out = ' ' * ind, []
    if isinstance(v, dict):
        for k, x in v.items():
            if isinstance(x, (dict, list)) and x:
                out.append('%s%s:' % (sp, dkey(k)))
                out += dump_block(x, ind + 2)
            else:
                out.append('%s%s: %s' % (sp, dkey(k), dump(x)))
    else:
        for x in v:
            if isinstance(x, dict) and x:
                sub = dump_block(x, ind + 2)
                sub[0] = sp + '- ' + sub[0][ind + 2:]
                out += sub
            else:
                out.append('%s- %s' % (sp, dump(x)))
    return out


def key_lines(key, v, block_style=False):
    one = '%s: %s' % (key, dump(v))
    if isinstance(v, (dict, list)) and v and (block_style or len(one) > 120):
        if block_style:
            return ['%s:' % key] + dump_block(v, 2)
        return ['%s:' % key] + ['  - ' + dump(x) for x in v] if isinstance(v, list) else ['%s:' % key] + dump_block(v, 2)
    return [one]


# ---------------------------------------------------------------- documents

def split_doc(text):
    """-> (list of (key, [lines]) or None, body). Frontmatter keys keep their raw lines."""
    if not text.startswith('---\n'):
        return None, text
    lines = text.split('\n')
    for j in range(1, len(lines)):
        if lines[j] == '---':
            break
    else:
        return None, text
    entries = []
    for l in lines[1:j]:
        if l and l[0] not in ' \t-#' and ':' in l:
            entries.append((l.split(':', 1)[0].strip(), [l]))
        elif entries:
            entries[-1][1].append(l)
        else:
            entries.append(('#', [l]))
    return entries, '\n'.join(lines[j + 1:])


def join_doc(entries, body):
    return '\n'.join(['---'] + [l for _, ls in entries for l in ls] + ['---']) + '\n' + body


def fm_get(entries, key):
    for k, ls in entries or []:
        if k == key:
            return ls
    return None


def stamp_at(entries, key='modified'):
    ls = fm_get(entries, key)
    m = re.search(r'\bat:\s*"?([0-9][0-9T:.+\-Z]*)', ' '.join(ls)) if ls else None
    if not m:
        return None
    try:
        return datetime.datetime.fromisoformat(m.group(1).replace('Z', '+00:00'))
    except ValueError:
        return None


def stamp_desc(entries):
    ls = fm_get(entries, 'modified') or fm_get(entries, 'created')
    if not ls:
        return 'unstamped'
    t = ' '.join(ls)
    at = re.search(r'\bat:\s*"?([^,}"]+)', t)
    name = re.search(r'\bname:\s*"?([^,}"]+)', t)
    return '%s, %s' % (at.group(1).strip() if at else 'no time', name.group(1).strip() if name else 'the owner')


def later(eo, et):
    """'theirs' only when theirs carries the strictly later modified stamp; ties go to ours."""
    ao, at = stamp_at(eo) or stamp_at(eo, 'created'), stamp_at(et) or stamp_at(et, 'created')
    if at is not None and (ao is None or at > ao):
        return 'theirs'
    return 'ours'


def label_key(e):
    if not isinstance(e, dict):
        return ('?', str(e).lower())
    k = e.get('kind')
    t = (k.get('type') if isinstance(k, dict) else k) or ''
    return (str(t).lower(), str(e.get('text', '')).lower())


def three_way_list(b, o, t, keyf, win, merge_item=None):
    """3-way set merge: additions from both sides kept, a removal on one side honored."""
    bm, om, tm = ({keyf(x): x for x in l} for l in (b, o, t))
    out, seen = [], set()
    for k in [keyf(x) for x in o] + [keyf(x) for x in t]:
        if k in seen:
            continue
        seen.add(k)
        ib, io, it = k in bm, k in om, k in tm
        if io and it:
            vo, vt, vb = om[k], tm[k], bm.get(k)
            if vo == vt or vt == vb:
                out.append(vo)
            elif vo == vb:
                out.append(vt)
            else:
                out.append(merge_item(vb, vo, vt) if merge_item else (vt if win == 'theirs' else vo))
        elif io:
            if not ib or om[k] != bm[k]:
                out.append(om[k])
        elif it:
            if not ib or tm[k] != bm[k]:
                out.append(tm[k])
    return out


def merge_labels(b, o, t, win, singles):
    b, o, t = (x if isinstance(x, list) else [] for x in (b, o, t))
    kind = lambda e: label_key(e)[0]
    plain = three_way_list([e for e in b if kind(e) not in singles], [e for e in o if kind(e) not in singles],
                           [e for e in t if kind(e) not in singles], label_key, win)
    out = list(plain)
    for s in sorted({kind(e) for e in b + o + t} & singles):
        gb, go, gt = ([e for e in l if kind(e) == s] for l in (b, o, t))
        g = go if (go == gt or gt == gb) else gt if go == gb else (gt if win == 'theirs' else go)
        out += g
    order = {}
    for i, e in enumerate(o + t):
        order.setdefault(label_key(e), i)
    out.sort(key=lambda e: order.get(label_key(e), 1 << 30))
    return out


def merge_config(b, o, t, win):
    b, o, t = (x if isinstance(x, dict) else {} for x in (b, o, t))
    out = {}
    for k in list(o) + [k for k in t if k not in o]:
        vb, vo, vt = b.get(k), o.get(k), t.get(k)
        if vo == vt or vt == vb:
            v = vo
        elif vo == vb:
            v = vt
        elif k == 'labels':
            def merge_kind(kb, ko, kt):
                kb, ko, kt = kb or {}, ko or {}, kt or {}
                m = dict(kt if win == 'theirs' else ko)
                if 'values' in ko or 'values' in kt:
                    m['values'] = three_way_list(kb.get('values') or [], ko.get('values') or [], kt.get('values') or [],
                                                 lambda x: str(x.get('text', '')).lower() if isinstance(x, dict) else str(x).lower(), win)
                return m
            v = three_way_list(vb or [], vo or [], vt or [],
                               lambda x: str(x.get('type', '')).lower() if isinstance(x, dict) else str(x).lower(), win, merge_kind)
        else:
            v = vt if win == 'theirs' else vo
        if k in o or k in t:
            if not (v is None and (k not in o or k not in t)):
                out[k] = v
    return out


def fence(text):
    n = max([3] + [len(m) + 1 for m in re.findall(r'`{3,}', text)])
    return '`' * n + 'markdown\n' + text.rstrip('\n') + '\n' + '`' * n


def merge_doc(base, ours, theirs, kind, singles):
    """-> (text, losses, win). losses: [{'line', 'label'?, 'text'?}]"""
    if ours == theirs:
        return ours, [], 'ours'
    eo, bo = split_doc(ours)
    et, bt = split_doc(theirs)
    if not base:
        what = {'card': 'This card', 'comment': 'A comment', 'attachment': 'An attachment'}.get(kind, 'This file')
        return ours, [{'line': '%s was added on both sides under one id: ours kept, the other side\'s copy is below.' % what,
                       'label': 'The other side\'s copy', 'text': bt if et is not None else theirs}], 'ours'
    eb, bb = split_doc(base)
    if eo is None or et is None or eb is None:
        if base == ours:
            return theirs, [], 'theirs'
        if base == theirs:
            return ours, [], 'ours'
        return ours, [{'line': 'An unreadable file was changed on both sides: ours kept, the other side\'s is below.',
                       'label': 'The other side\'s file', 'text': theirs}], 'ours'
    win = later(eo, et)
    losses, out = [], []
    keys = [k for k, _ in eo] + [k for k, _ in et if fm_get(eo, k) is None]
    for k in keys:
        lb, lo, lt = fm_get(eb, k), fm_get(eo, k), fm_get(et, k)
        rb, ro, rt = ('\n'.join(x) if x else None for x in (lb, lo, lt))
        if ro == rt or rt == rb:
            pick = lo
        elif ro == rb:
            pick = lt
        elif k in OURS_KEYS or k == '#':
            pick = lo
        elif k == 'labels' and lo and lt:
            try:
                v = merge_labels(parse_value(lb) if lb else [], parse_value(lo), parse_value(lt), win, singles)
                pick = key_lines('labels', v) if v else None
            except (ValueError, IndexError):
                pick = lt if win == 'theirs' else lo
        elif k == 'config' and kind == 'board' and lo and lt:
            try:
                v = merge_config(parse_value(lb) if lb else {}, parse_value(lo), parse_value(lt), win)
                pick = key_lines('config', v, block_style=True) if v else None
            except (ValueError, IndexError):
                pick = lt if win == 'theirs' else lo
        else:
            pick = lt if win == 'theirs' else lo
            if k == 'title' and lo and lt:
                lost = parse_value(lo if win == 'theirs' else lt)
                kept = parse_value(pick)
                losses.append({'line': 'Title: kept "%s"; the other side\'s was "%s".' % (kept, lost)})
        if pick:
            out.append((k, pick))
    if bo == bt or bt == bb:
        body = bo
    elif bo == bb:
        body = bt
    else:
        body = bt if win == 'theirs' else bo
        lost_e, lost_b = (eo, bo) if win == 'theirs' else (et, bt)
        kept_e = et if win == 'theirs' else eo
        noun = 'comment' if kind == 'comment' else 'body'
        losses.append({'line': 'The %s: kept the later edit (%s); the earlier (%s) is below.' % (
            noun, stamp_desc(kept_e), stamp_desc(lost_e)),
            'label': 'The earlier %s' % noun, 'text': lost_b})
    return join_doc(out, body), losses, win


def board_singles(repo, board):
    s = set(SINGLE_KINDS)
    try:
        e, _ = split_doc(open(os.path.join(repo, board, 'index.md'), encoding='utf-8').read())
        cfg = parse_value(fm_get(e, 'config')) if fm_get(e, 'config') else {}
        for k in (cfg or {}).get('labels') or []:
            if isinstance(k, dict) and k.get('single') is True and k.get('type'):
                s.add(str(k['type']).lower())
    except (OSError, ValueError, IndexError, AttributeError):
        pass
    return s


def version_of(data):
    head = (data or b'')[:400].decode('utf-8', 'replace').split('\n')[:3]
    for l in head:
        m = re.search(r'lanework-[a-z-]+ v(\d+)', l)
        if m:
            return int(m.group(1))
    return -1


def merge_bytes(repo, c, b, o, t):
    """-> (bytes, losses, extras {within-path: bytes}, win). b/o/t are bytes or None."""
    if o == t:
        return o, [], {}, 'ours'
    if o == b:
        return t, [], {}, 'theirs'
    if t == b:
        return o, [], {}, 'ours'
    if c['cls'] == 'versioned':
        return (t, [], {}, 'theirs') if version_of(t) > version_of(o) else (o, [], {}, 'ours')
    if c['cls'] == 'log':
        lines = []
        for x in (o or b'', t or b''):
            for l in x.decode('utf-8', 'replace').split('\n'):
                if l and l not in lines:
                    lines.append(l)
        head = [l for l in lines if l.startswith('#')]
        rest = sorted([l for l in lines if not l.startswith('#')], key=lambda l: l.split(' ', 1)[0])
        return ('\n'.join(head + rest) + '\n').encode(), [], {}, 'ours'
    kind = {'board': 'board', 'lane': 'lane'}.get(c['cls']) or doc_kind(c['within'])
    if kind and o is not None and t is not None:
        try:
            so, st = o.decode('utf-8'), t.decode('utf-8')
            sb = b.decode('utf-8') if b else ''
        except UnicodeDecodeError:
            kind = None
        else:
            crlf = '\r\n' in so
            n = lambda s: s.replace('\r\n', '\n')
            text, losses, win = merge_doc(n(sb), n(so), n(st), kind, board_singles(repo, c['board']))
            if crlf:
                text = text.replace('\n', '\r\n')
            if kind == 'comment':
                for l in losses:
                    l['line'] = 'Comment %s: %s' % (c['within'][1][:8], l['line'].replace('The comment: ', ''))
                    if 'label' in l:
                        l['label'] = '%s, comment %s' % (l['label'], c['within'][1][:8])
            return text.encode('utf-8'), losses, {}, win
    w = c['within'] or []
    if w and w[-1].startswith('blob') and 'attachments' in w and o is not None and t is not None:
        name = w[-1]
        ext = name[4:]  # '.png' or ''
        extra = '/'.join(w[:-1] + ['blob.theirs' + ext])
        return o, [{'line': 'Attachment %s: kept ours; the other side\'s file is `%s`.' % (w[-2][:8], extra)}], {extra: t}, 'ours'
    if w and w[-1].startswith('thumb.'):
        return o, [], {}, 'ours'
    if o is None or t is None:
        return (o if o is not None else t), [], {}, 'ours'
    return o, [{'line': 'File `%s`: changed on both sides, ours kept.' % '/'.join(c['rel'])}], {}, 'ours'


# ---------------------------------------------------------------- merge comments and the ledger

def signer(model):
    model = model or os.environ.get('LANEWORK_MERGE_MODEL')
    if model:
        return '{name: claude, kind: agent, model: %s, session: "merge"}' % model
    return '{name: merge, kind: agent, session: "merge"}'


def is_merge_comment(text):
    return 'session: "merge"' in text.split('\n---', 2)[0] + text[:600] and HEADER in text


def render_losses(losses):
    lines = ['- ' + l['line'] for l in losses]
    blocks = []
    for l in losses:
        if 'text' in l:
            blocks += ['', '%s:' % l['label'], '', fence(l['text'])]
    return lines, blocks


def in_head(repo, path):
    return git_ok(repo, 'cat-file', '-e', 'HEAD:' + path)


def write_atomic(repo, path, data):
    full = os.path.join(repo, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=state_dir(repo))
    with os.fdopen(fd, 'wb') as f:
        f.write(data)
    os.replace(tmp, full)


def post_losses(repo, card_path, losses, model):
    """Add losses to this operation's merge comment on the card (one per card). -> its path."""
    cdir = os.path.join(repo, card_path, 'comments')
    if os.path.isdir(cdir):
        for cid in sorted(os.listdir(cdir)):
            p = '%s/comments/%s/index.md' % (card_path, cid)
            fp = os.path.join(repo, p)
            if is_uuid(cid) and os.path.isfile(fp) and not in_head(repo, p):
                text = open(fp, encoding='utf-8').read()
                if is_merge_comment(text):
                    fm_end = text.index('\n---\n', 3) + 5
                    head, body = text[:fm_end], text[fm_end:].rstrip('\n').split('\n')
                    k = 2
                    while k < len(body) and body[k].startswith('- '):
                        k += 1
                    new, blocks = render_losses(losses)
                    body = body[:k] + new + body[k:] + blocks
                    write_atomic(repo, p, (head + '\n'.join(body) + '\n').encode())
                    return p
    cid = str(uuidlib.uuid4())
    at, by = now_utc(), signer(model)
    lines, blocks = render_losses(losses)
    text = '\n'.join(['---', 'schema: 1', 'kind: comment', 'created:  {at: %s, by: %s}' % (at, by),
                      'modified: {at: %s, by: %s}' % (at, by), '---', HEADER, ''] + lines + blocks) + '\n'
    stage = tempfile.mkdtemp(dir=state_dir(repo))
    with open(os.path.join(stage, 'index.md'), 'w', encoding='utf-8') as f:
        f.write(text)
    os.makedirs(cdir, exist_ok=True)
    os.rename(stage, os.path.join(cdir, cid))
    return '%s/comments/%s/index.md' % (card_path, cid)


def ledger_path(repo):
    return os.path.join(state_dir(repo), 'ledger.jsonl')


def ledger_read(repo):
    try:
        return [json.loads(l) for l in open(ledger_path(repo), encoding='utf-8') if l.strip()]
    except OSError:
        return []


def ledger_add(repo, entry):
    with open(ledger_path(repo), 'a', encoding='utf-8') as f:
        f.write(json.dumps(entry) + '\n')


def ledger_write(repo, entries):
    with open(ledger_path(repo), 'w', encoding='utf-8') as f:
        for e in entries:
            f.write(json.dumps(e) + '\n')


def store_blob(repo, data):
    p = os.path.join(state_dir(repo), 'blobs')
    os.makedirs(p, exist_ok=True)
    name = sha(data)
    with open(os.path.join(p, name), 'wb') as f:
        f.write(data)
    return name


def load_blob(repo, name):
    return open(os.path.join(state_dir(repo), 'blobs', name), 'rb').read()


# ---------------------------------------------------------------- driver

def created_of(data):
    try:
        e, _ = split_doc(data.decode('utf-8').replace('\r\n', '\n'))
    except UnicodeDecodeError:
        return None
    ls = fm_get(e, 'created')
    return ' '.join(ls).split(':', 1)[1].strip() if ls else None


def foreign(b, o, t):
    """True when the three sides are not one document: `created` is written once and never changes."""
    cb = created_of(b)
    return cb is not None and any(created_of(x) not in (None, cb) for x in (o, t))


def cmd_driver(argv):
    quiet = '--quiet' in argv
    argv = [a for a in argv if a != '--quiet']
    fb, fo, ft, path = argv[:4]
    repo = os.getcwd()
    rd = lambda f: open(f, 'rb').read()
    b, o, t = rd(fb), rd(fo), rd(ft)
    c = classify(path)
    try:
        if c is None:
            return 1
        if b and foreign(b, o, t):
            # git paired two different cards by similarity (a delete and an add): never merge those.
            sys.stderr.write('lanework-merge: %s: paired with another card by rename detection; left for the pass\n' % path)
            return 1
        data, losses, extras, win = merge_bytes(repo, c, b or None, o, t)
        with open(fo, 'wb') as f:
            f.write(data)
        if quiet:
            return 0
        rc = 0
        card_path = '/'.join([c['board']] + list(c['loc'])) if c['loc'] else None
        here = card_path and os.path.isfile(os.path.join(repo, card_path, 'index.md'))
        if c['cls'] == 'card' and is_trash(c['loc']) and c['within'] == ['index.md']:
            # The pass decides a trash against a later edit: no markers, but stop the merge for it.
            if (here and win == 'theirs') or (not here and win == 'ours'):
                rc = 1
        if losses or extras:
            entry = {'board': c['board'], 'card': c['card'], 'within': '/'.join(c['within'] or c['rel']),
                     'o': sha(o), 't': sha(t), 'losses': losses, 'placed': False, 'blobs': {}}
            if c['cls'] == 'card' and here and rc == 0:
                for w, data2 in extras.items():
                    write_atomic(repo, card_path + '/' + w, data2)
                if losses:
                    post_losses(repo, card_path, losses, None)
                entry['placed'] = True
            else:
                entry['blobs'] = {w: store_blob(repo, d) for w, d in extras.items()}
                if c['cls'] == 'card' and rc == 0:
                    sys.stderr.write('lanework-merge: %s: merge comment pending; run merge-board.sh\n' % path)
            ledger_add(repo, entry)
        return rc
    except Exception as e:  # never leave a half merge: ours, flagged as a conflict for the pass
        sys.stderr.write('lanework-merge: %s: %s\n' % (path, e))
        with open(fo, 'wb') as f:
            f.write(o)
        return 1


# ---------------------------------------------------------------- the pass

class Trees:
    def __init__(self, repo):
        self.repo, self.cache = repo, {}

    def files(self, r, board):
        if r is None:
            return {}
        k = (r, board)
        if k not in self.cache:
            out = git(self.repo, 'ls-tree', '-r', '-z', '--full-tree', r, '--', board)
            d = {}
            for rec in out.split(b'\0'):
                if rec:
                    meta, p = rec.split(b'\t', 1)
                    mode, _, objsha = meta.decode().split()
                    d[p.decode()] = (mode, objsha)
            self.cache[k] = d
        return self.cache[k]

    def card(self, r, board, card):
        """-> (loc tuple or None, {within: (mode, sha)})"""
        locs = {}
        for p, v in self.files(r, board).items():
            c = classify(p)
            if c and c['cls'] == 'card' and c['card'] == card:
                locs.setdefault(c['loc'], {})['/'.join(c['within'])] = v
        if not locs:
            return None, {}
        loc = sorted(locs, key=lambda l: ('index.md' not in locs[l], len(l)))[0]
        return loc, locs[loc]

    def blob(self, objsha):
        return git(self.repo, 'cat-file', 'blob', objsha) if objsha else None


def op_state(repo):
    gd = git(repo, 'rev-parse', '--git-dir').decode().strip()
    gd = gd if os.path.isabs(gd) else os.path.join(repo, gd)
    for name, how in (('MERGE_HEAD', 'merge'), ('REBASE_HEAD', 'rebase'), ('CHERRY_PICK_HEAD', 'cherry-pick')):
        if os.path.exists(os.path.join(gd, name)):
            theirs = rev(repo, name)
            if how == 'merge':
                r = subprocess.run(['git', '-C', repo, 'merge-base', 'HEAD', theirs], capture_output=True)
                base = r.stdout.decode().strip() or None
            else:
                base = rev(repo, theirs + '^')
            return how, base, theirs
    return None, None, None


def unmerged(repo):
    out = {}
    for rec in git(repo, 'ls-files', '-u', '-z').split(b'\0'):
        if rec:
            meta, p = rec.split(b'\t', 1)
            mode, objsha, stage = meta.decode().split()
            out.setdefault(p.decode(), {})[int(stage)] = (mode, objsha)
    return out


def title_of(text):
    e, _ = split_doc(text or '')
    ls = fm_get(e, 'title')
    try:
        return str(parse_value(ls)) if ls else 'untitled'
    except (ValueError, IndexError):
        return 'untitled'


def lane_title(repo, board, lane):
    if lane == '.trash':
        return 'the trash'
    try:
        return title_of(open(os.path.join(repo, board, lane, 'index.md'), encoding='utf-8').read())
    except OSError:
        return lane[:8]


def remove_paths(repo, paths):
    for p in paths:
        git(repo, 'rm', '-q', '--cached', '-f', '--ignore-unmatch', '--', p)
        fp = os.path.join(repo, p)
        if os.path.isfile(fp):
            os.remove(fp)


def prune(repo, d):
    """Remove empty dirs bottom-up under repo/d (a card folder left behind)."""
    full = os.path.join(repo, d)
    if not os.path.isdir(full):
        return
    for root, dirs, files in os.walk(full, topdown=False):
        if not os.listdir(root):
            os.rmdir(root)


def process_card(repo, trees, revs, board, card, ledger, model, notes):
    base, ours, theirs = revs
    (lb, fb), (lo, fo), (lt, ft) = (trees.card(r, board, card) for r in revs)
    get = lambda f, w: trees.blob(f[w][1]) if w in f else None
    io, it = get(fo, 'index.md'), get(ft, 'index.md')
    eo = split_doc(io.decode('utf-8', 'replace'))[0] if io else None
    et = split_doc(it.decode('utf-8', 'replace'))[0] if it else None
    win = later(eo, et) if (eo and et) else 'ours'
    locs = {'ours': lo, 'theirs': lt}
    losses = []
    title = title_of((io or it or b'').decode('utf-8', 'replace'))
    # placement
    if lo is None and lt is None:
        L = None
    elif lo is None or lt is None:
        side = 'ours' if lo else 'theirs'
        present = fo if lo else ft
        if lb is None or present != fb:
            L = locs[side]
            if lb is not None:
                losses.append({'line': 'The other side deleted this card for good; the edited card is kept.'})
        else:
            L = None
    elif lo == lt:
        L = lo
    elif lo == lb or lt == lb:
        mover = 'theirs' if lo == lb else 'ours'
        other = 'ours' if mover == 'theirs' else 'theirs'
        L = locs[mover]
        other_changed = (fo if other == 'ours' else ft) != fb
        if is_trash(L) and not is_trash(lb) and other_changed:
            L = locs[win]
    else:
        L = locs[win]
    if L and len(L) == 2 and not is_trash(L) and not os.path.isfile(os.path.join(repo, board, L[0], 'index.md')):
        if os.path.isfile(os.path.join(repo, board, '.trash', L[0], 'index.md')):
            L = ('.trash', L[0], card)
        else:
            L = lo or lt
    old = [l for l in {lb, lo, lt} if l]
    old_dirs = ['/'.join([board] + list(l)) for l in old]
    final_dir = '/'.join([board] + list(L)) if L else None
    # content
    files, extras = {}, {}
    if L:
        for w in sorted(set(fb) | set(fo) | set(ft)):
            vb, vo, vt = fb.get(w), fo.get(w), ft.get(w)
            if vo == vt or vt == vb:
                pick = ('o', vo)
            elif vo == vb:
                pick = ('t', vt)
            else:
                pick = None
            if pick:
                if pick[1]:
                    files[w] = (pick[1][0], trees.blob(pick[1][1]))
                continue
            b, o, t = (trees.blob(v[1]) if v else None for v in (vb, vo, vt))
            if o is None or t is None:  # deleted on one side, changed on the other: keep the change
                files[w] = (vo or vt)[0], (o if o is not None else t)
                continue
            c = classify('/'.join([board] + list(L) + w.split('/')))
            data, ls, ex, _ = merge_bytes(repo, c, b, o, t)
            files[w] = ((vo or vt)[0], data)
            extras.update(ex)
            hit = [e for e in ledger if e.get('card') == card and e['within'] == w and e['o'] == sha(o) and e['t'] == sha(t)]
            for e in hit:
                e['consumed'] = True
            if ls and not any(e['placed'] for e in hit):
                losses += ls
    for e in ledger:  # pending driver losses for this card
        if e.get('card') == card and e['board'] == board and not e['placed'] and not e.get('consumed'):
            e['consumed'] = True
            losses += e['losses']
            for w, name in e.get('blobs', {}).items():
                extras[w] = load_blob(repo, name)
    # move untracked strays (driver comments, drafts) to the final folder
    tracked = set(git(repo, 'ls-files', '-z', '--', *old_dirs).decode().split('\0')) if old_dirs else set()
    strays = []
    for d in old_dirs:
        full = os.path.join(repo, d)
        for root, _, fs in os.walk(full):
            for f in fs:
                p = os.path.relpath(os.path.join(root, f), repo)
                if p not in tracked:
                    strays.append((d, p))
    remove_paths(repo, sorted(tracked - {''}))
    added = []
    if final_dir:
        for d, p in strays:
            dst = final_dir + p[len(d):]
            if dst != p and not os.path.exists(os.path.join(repo, dst)):
                os.makedirs(os.path.dirname(os.path.join(repo, dst)), exist_ok=True)
                os.rename(os.path.join(repo, p), os.path.join(repo, dst))
            if is_merge_artifact(repo, dst):
                added.append(dst)
        for w in ['index.md'] + sorted(k for k in files if k != 'index.md'):
            if w in files:
                mode, data = files[w]
                p = final_dir + '/' + w
                write_atomic(repo, p, data)
                if mode == '100755':
                    os.chmod(os.path.join(repo, p), 0o755)
                added.append(p)
        for w, data in extras.items():
            write_atomic(repo, final_dir + '/' + w, data)
            added.append(final_dir + '/' + w)
        if losses:
            added.append(post_losses(repo, final_dir, losses, model))
        git(repo, 'add', '-f', '--', *sorted(set(added)))
    for d in old_dirs:
        if d != final_dir:
            prune(repo, d)
    if 'index.md' in files:
        title = title_of(files['index.md'][1].decode('utf-8', 'replace'))
    where = 'gone' if not L else lane_title(repo, board, L[0]) if not is_trash(L) else 'the trash'
    if lo and lt and lo != lt:
        notes['placed'].append('"%s" to %s' % (title, where))
    if losses:
        notes['comments'].append('"%s" (%s)' % (title, '; '.join(l['line'] for l in losses)))
    return final_dir


def is_merge_artifact(repo, p):
    fp = os.path.join(repo, p)
    if re.search(r'/blob\.theirs(\.[^/]*)?$', p):
        return True
    if re.search(r'/comments/[0-9a-f-]{36}/index\.md$', p) and os.path.isfile(fp):
        try:
            return is_merge_comment(open(fp, encoding='utf-8').read())
        except (OSError, UnicodeDecodeError):
            return False
    return False


def find_card_dir(repo, board, card):
    root = os.path.join(repo, board)
    for cand in [os.path.join(root, l, card) for l in os.listdir(root)] + \
            [os.path.join(root, '.trash', l, card) for l in (os.listdir(os.path.join(root, '.trash')) if os.path.isdir(os.path.join(root, '.trash')) else [])] + \
            [os.path.join(root, '.trash', card)]:
        if os.path.isfile(os.path.join(cand, 'index.md')):
            return os.path.relpath(cand, repo)
    return None


def refresh_install(repo):
    d = git(repo, 'config', '--get', 'merge.lanework.driver', check=False).decode()
    dst = os.path.join(state_dir(repo), 'lanework-merge.py')
    if d and os.path.isfile(dst) and open(dst, 'rb').read() != open(__file__, 'rb').read() \
            and os.path.abspath(__file__) != os.path.abspath(dst):
        shutil.copy2(__file__, dst)


def cmd_resolve(argv):
    repo = os.path.abspath(argv[0])
    model = argv[argv.index('--model') + 1] if '--model' in argv else None
    repo = git(repo, 'rev-parse', '--show-toplevel').decode().strip()
    refresh_install(repo)
    how, base, theirs = op_state(repo)
    revs = (base, 'HEAD', theirs)
    trees = Trees(repo)
    ledger = ledger_read(repo)
    notes = {'placed': [], 'comments': [], 'leftover': [], 'lost': [], 'paths': 0}
    um = {p: s for p, s in unmerged(repo).items() if classify(p)}
    boards = {classify(p)['board'] for p in um} | {e['board'] for e in ledger}
    cards, others = {}, []
    if how and base:
        by_sha = {}
        for p in um:
            if 1 in um[p] and classify(p)['cls'] == 'card':
                by_sha[um[p][1][1]] = classify(p)['card']
        if by_sha:  # a card git paired with another by similarity: its base side is a card of its own
            for board in {classify(p)['board'] for p in um}:
                for p, v in trees.files(base, board).items():
                    c = classify(p)
                    if v[1] in by_sha and c and c['cls'] == 'card' and c['card'] != by_sha[v[1]]:
                        cards.setdefault((board, c['card']), []).append(p)
    for p in sorted(um):
        c = classify(p)
        if c['cls'] == 'card' and how:
            kinds = [x for x in (trees.card(r, c['board'], c['card'])[1].get('index.md') for r in revs if r) if x]
            if any(re.search(rb'^kind:\s*"?lane', trees.blob(k[1]), re.M) for k in kinds):
                others.append(p)
            else:
                cards.setdefault((c['board'], c['card']), []).append(p)
        else:
            others.append(p)
    notes['paths'] = len(um)
    for p in others:  # lanes, board files, guide, schema, log: content merge, else ours
        s, c = um[p], classify(p)
        if 2 in s and 3 in s:
            b = trees.blob(s[1][1]) if 1 in s else None
            data, ls, _, _ = merge_bytes(repo, c, b, trees.blob(s[2][1]), trees.blob(s[3][1]))
            write_atomic(repo, p, data)
            git(repo, 'add', '-f', '--', p)
            for l in ls:
                notes['lost'].append((p, l))
        elif 2 in s:
            write_atomic(repo, p, trees.blob(s[2][1]))
            git(repo, 'add', '-f', '--', p)
            notes['leftover'].append(p)
        else:
            remove_paths(repo, [p])
            notes['leftover'].append(p)
    for (board, card) in cards:
        process_card(repo, trees, revs, board, card, ledger, model, notes)
    for e in ledger:  # driver losses whose card the pass didn't touch
        if e.get('consumed') or e['placed']:
            continue
        e['consumed'] = True
        if not e.get('card'):
            notes['lost'] += [(e['board'] + '/' + e['within'], l) for l in e['losses']]
            continue
        d = find_card_dir(repo, e['board'], e['card'])
        if not d:
            notes['lost'] += [(e['board'] + '/' + e['within'], l) for l in e['losses']]
            continue
        add = []
        for w, name in e.get('blobs', {}).items():
            write_atomic(repo, d + '/' + w, load_blob(repo, name))
            add.append(d + '/' + w)
        if e['losses']:
            add.append(post_losses(repo, d, e['losses'], model))
            notes['comments'].append('"%s" (%s)' % (title_of(open(os.path.join(repo, d, 'index.md'), encoding='utf-8').read()),
                                                    '; '.join(l['line'] for l in e['losses'])))
        git(repo, 'add', '-f', '--', *add)
    for e in ledger:
        if e['placed'] and not e.get('consumed') and e.get('card'):
            e['consumed'] = True
            d = find_card_dir(repo, e['board'], e['card'])
            t = title_of(open(os.path.join(repo, d, 'index.md'), encoding='utf-8').read()) if d else e['card'][:8]
            notes['comments'].append('"%s" (%s)' % (t, '; '.join(l['line'] for l in e['losses'])))
    # stage this operation's merge artifacts anywhere on the touched boards
    for board in sorted(boards):
        out = git(repo, 'status', '--porcelain=v1', '-z', '-uall', '--', board).decode()
        arts = [r[3:] for r in out.split('\0') if r.startswith('?? ') and is_merge_artifact(repo, r[3:])]
        if arts:
            git(repo, 'add', '-f', '--', *arts)
    if notes['lost']:
        lost = os.path.join(state_dir(repo), 'lost-%s.md' % now_utc().replace(':', ''))
        with open(lost, 'w', encoding='utf-8') as f:
            for p, l in notes['lost']:
                f.write('## %s\n\n%s\n\n%s\n\n' % (p, l['line'], fence(l['text']) if 'text' in l else ''))
        notes['lost_file'] = lost
    done = os.path.join(state_dir(repo), 'ledger.done.jsonl')
    with open(done, 'a', encoding='utf-8') as f:
        for e in ledger:
            f.write(json.dumps(e) + '\n')
    ledger_write(repo, [])
    # validate
    vals, bad = [], False
    for board in sorted(boards):
        v = os.path.join(repo, board, '.schema', 'bin', 'lanework-validate.py')
        if not os.path.isfile(v):
            vals.append('%s has no validator' % os.path.basename(board))
            continue
        r = subprocess.run([sys.executable, v, os.path.join(repo, board)], capture_output=True, text=True)
        out = r.stdout + r.stderr
        ok = r.returncode == 0 and 'DEPRECATED' not in out
        bad |= not ok
        n = re.search(r'documents\s+(\d+)', out)
        vals.append('%s %s (%s documents)' % (os.path.basename(board), 'validates' if ok else 'FAILS validation',
                                             n.group(1) if n else '?'))
        if not ok:
            sys.stderr.write(out)
    left = [p for p in unmerged(repo) if classify(p)]
    other = [p for p in unmerged(repo) if not classify(p)]
    # report: one paragraph
    s = []
    if not how and not notes['comments'] and not notes['paths']:
        s.append('No merge, rebase or cherry-pick in progress and nothing pending: nothing to resolve.')
    else:
        s.append('Board merge%s: %d unmerged board path%s resolved.' % (' (%s)' % how if how else '', notes['paths'], '' if notes['paths'] == 1 else 's'))
        if notes['placed']:
            s.append('Placed by the later stamp: %s.' % ', '.join(notes['placed']))
        if notes['comments']:
            s.append('Merge comments on %d card%s: %s.' % (len(notes['comments']), '' if len(notes['comments']) == 1 else 's', '; '.join(notes['comments'])))
        else:
            s.append('Nothing was lost, so no merge comment.')
        if notes['leftover']:
            s.append('Kept ours for %s.' % ', '.join(notes['leftover']))
        if notes.get('lost_file'):
            s.append('Text lost from lane or board files is kept in %s.' % notes['lost_file'])
    if vals:
        s.append(' '.join(v + '.' for v in vals))
    if other:
        s.append('Conflicts outside any board are left for you: %s.' % ', '.join(other))
    if how:
        s.append('Nothing is committed: %s.' % ('commit the merge' if how == 'merge' else 'run git %s --continue' % how))
    print(' '.join(s))
    return 1 if (left or bad) else 0


# ---------------------------------------------------------------- install

def cmd_install(argv):
    repo = git(os.path.abspath(argv[0]), 'rev-parse', '--show-toplevel').decode().strip()
    dst = os.path.join(state_dir(repo), 'lanework-merge.py')
    if os.path.abspath(__file__) != os.path.abspath(dst):
        shutil.copy2(__file__, dst)
    py = shlex.quote(sys.executable or 'python3')
    git(repo, 'config', 'merge.lanework.name', 'Lanework board merge')
    git(repo, 'config', 'merge.lanework.driver', '%s %s driver %%O %%A %%B %%P' % (py, shlex.quote(dst)))
    git(repo, 'config', 'merge.lanework.recursive', 'lanework-inner')
    git(repo, 'config', 'merge.lanework-inner.name', 'Lanework board merge, inner merge base')
    git(repo, 'config', 'merge.lanework-inner.driver', '%s %s driver --quiet %%O %%A %%B %%P' % (py, shlex.quote(dst)))
    ga = os.path.join(repo, '.gitattributes')
    cur = open(ga, encoding='utf-8').read() if os.path.isfile(ga) else ''
    if ATTR in cur.split('\n'):
        print('driver installed in this clone; .gitattributes already carries the rule')
    else:
        with open(ga, 'a', encoding='utf-8') as f:
            f.write(('' if not cur or cur.endswith('\n') else '\n') + ATTR + '\n')
        print('driver installed in this clone; added the rule to .gitattributes: commit it so it travels')
    return 0


def main(argv):
    if not argv or argv[0] not in ('driver', 'resolve', 'install') or len(argv) < 2:
        sys.stderr.write(__doc__)
        return 2
    return {'driver': cmd_driver, 'resolve': cmd_resolve, 'install': cmd_install}[argv[0]](argv[1:])


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
