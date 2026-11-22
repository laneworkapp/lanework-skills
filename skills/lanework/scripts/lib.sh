#!/bin/bash
# lib.sh: board helpers shared by every skill's scripts. Source it; never run it.
# From a sibling skill: . "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# flat_str <s>: a title on one line: each CRLF, CR and LF becomes one space. Markdown headings use it as is.
flat_str() { local s="${1//$'\r\n'/ }"; s="${s//$'\n'/ }"; printf '%s' "${s//$'\r'/ }"; }

# title_str <s>: a title's text for use inside double quotes (no outer quotes, so a prefix like "Q3: " can precede it):
# flat_str, then backslash and quote are escaped. Every title a script writes goes through it.
title_str() { local s; s="$(flat_str "$1")"; s="${s//\\/\\\\}"; printf '%s' "${s//\"/\\\"}"; }

# merge_kinds <list> <have> <new>: a repeated --labels. Appends <new>'s kinds to <list> (comma list; <have> non-empty once a --labels was given),
# skipping a kind an earlier flag already named. An empty name is kept, so found-board.sh rejects it.
merge_kinds() {
  local out="$1" have="$2" rest="$3," k
  while [ -n "$rest" ]; do
    k="${rest%%,*}"; rest="${rest#*,}"
    if [ -n "$k" ]; then case ",$1," in *",$k,"*) continue ;; esac; fi
    if [ -n "$have" ]; then out="$out,$k"; else out="$k"; have=1; fi
  done
  printf '%s' "$out"
}

# require_model <script> <usage>: MODEL from --model, else CLAUDE_MODEL; exit 2 with the usage line when neither. Never stamps a guess.
require_model() {
  MODEL="${MODEL:-${CLAUDE_MODEL:-}}"
  [ -n "$MODEL" ] || { printf '%s: no model: pass --model <your model> or set CLAUDE_MODEL\nusage: %s\n' "$1" "$2" >&2; exit 2; }
}

# need_value "$@": call as the first line of a flag's case arm; no second argument, or an empty one -> "<script>: <flag> needs a value", the usage, exit 2.
need_value() {
  [ $# -ge 2 ] && [ -n "$2" ] || { printf '%s: %s needs a value\nusage: %s\n' "$(basename "$0")" "$1" "${USAGE:-}" >&2; exit 2; }
}

# fm_value <file> <key>: raw scalar of a top-level frontmatter key.
fm_value() {
  awk -v key="$2" '
    NR==1 && $0=="---" { fm=1; next }
    fm && $0=="---" { exit }
    fm { n = index($0, ":"); if (n && substr($0, 1, n-1) == key) { v = substr($0, n+1); sub(/^[ \t]+/, "", v); print v; exit } }
  ' "$1"
}

strip_quotes() { local s="$1"; s="${s%\"}"; s="${s#\"}"; printf '%s' "$s"; }

# lane_by_title <board> <title>: path of the lane with that title.
lane_by_title() {
  local d
  for d in "$1"/*/; do
    d="${d%/}"
    [ -f "$d/index.md" ] || continue
    [ "$(fm_value "$d/index.md" kind)" = lane ] || continue
    [ "$(strip_quotes "$(fm_value "$d/index.md" title)")" = "$2" ] && { printf '%s' "$d"; return 0; }
  done
  return 1
}

# next_order <lane>: bottom of the lane (max order + 1024, or 1024 when empty).
next_order() {
  local f o max=""
  for f in "$1"/*/index.md; do
    [ -f "$f" ] || continue
    o=$(fm_value "$f" order)
    case "$o" in ''|*[!0-9.-]*) continue ;; esac
    if [ -z "$max" ] || awk -v a="$o" -v b="$max" 'BEGIN{exit !(a>b)}'; then max="$o"; fi
  done
  if [ -z "$max" ]; then echo 1024; else awk -v m="$max" 'BEGIN{print m+1024}'; fi
}

# owner_handle <board>: from the guide's "human answers to `@handle`" line; empty + exit 1 if none.
owner_handle() {
  local h=""
  local f; for f in "$1/CLAUDE.md" "$1/AGENTS.md"; do   # the app writes both, byte-identical
    [ -r "$f" ] || continue
    h=$(grep -o 'human answers to `@[^`]*`' "$f" | head -1 | sed 's/.*`@\([^`]*\)`/\1/'); [ -n "$h" ] && break
  done
  printf '%s' "$h"; [ -n "$h" ]
}

# guide_version <board>: N from the `lanework-agent-guide vN` stamp on line 1 of the board's CLAUDE.md; empty + exit 1 if none.
guide_version() {
  local v=""
  local f; for f in "$1/CLAUDE.md" "$1/AGENTS.md"; do   # the app writes both, byte-identical
    [ -r "$f" ] || continue
    v=$(head -1 "$f" | grep -o -E 'lanework-agent-guide v[0-9]+' | grep -o -E '[0-9]+$' || true); [ -n "$v" ] && break
  done
  printf '%s' "$v"; [ -n "$v" ]
}

# ask_handle <board>: whom an ask addresses by default. `anyone` on a board whose guide has `@anyone` (older builds draw no buttons for it),
# else owner_handle (empty + exit 1 if none). A person's handle for a question that is theirs alone is the caller's call, never this one's.
ask_handle() {
  local v; v=$(guide_version "$1" || true)
  if [ -n "$v" ] && [ "$v" -ge 117 ]; then printf anyone; else owner_handle "$1"; fi
}

# cite_enabled <board>: true when the board's guide line is new enough for the builds that draw a card's `cite-as`. Only then does a script
# mint a citation and write a bare title; below it, or with no readable stamp (a board no app has opened), it files as before. ask_handle's gate.
cite_enabled() { local v; v=$(guide_version "$1" || true); [ -n "$v" ] && [ "$v" -ge 117 ]; }

# cite_of <index.md>: the card's `cite-as`, quotes stripped; empty when it has none.
cite_of() { fm_value "$1" cite-as | sed -E "s/[[:space:]]+\$//; s/^[\"']//; s/[\"']\$//"; }

# card_ref <index.md>: what to write between the brackets of a link to the card: its citation, else its title, escaped as link text.
card_ref() {
  local c; c=$(cite_of "$1"); [ -n "$c" ] || c=$(strip_quotes "$(fm_value "$1" title)")
  printf '%s' "$c" | perl -pe 's/\\(.)/$1/g; s/([\\\[\]])/\\$1/g'
}

# next_cite <board> <prefix>: the next citation for a prefix (`Q`, `T`, `ADR`, `PDR`): the highest trailing number over every card, `.trash/`
# flat and in trashed lanes included, plus one. Counts a `cite-as: <prefix><n>` (any case, a trailing `# comment` ignored) and a legacy `<prefix><n>: ` title prefix. Call it as late as possible.
next_cite() {
  local f c t max=0 re_c="^$(printf '%s' "$2" | tr a-z A-Z)([0-9]+)\$" re_t="^$2([0-9]+): "
  for f in "$1"/*/*/index.md "$1"/.trash/*/index.md "$1"/.trash/*/*/index.md; do
    [ -f "$f" ] || continue
    c=$(fm_value "$f" cite-as | sed -E "s/[[:space:]]+#.*\$//; s/[[:space:]]+\$//; s/^[\"']//; s/[\"']\$//" | tr a-z A-Z); t=$(strip_quotes "$(fm_value "$f" title)")
    if [[ "$c" =~ $re_c ]] && [ "$((10#${BASH_REMATCH[1]}))" -gt "$max" ]; then max=$((10#${BASH_REMATCH[1]})); fi   # 10#: a zero-padded number is decimal
    if [[ "$t" =~ $re_t ]] && [ "$((10#${BASH_REMATCH[1]}))" -gt "$max" ]; then max=$((10#${BASH_REMATCH[1]})); fi
  done
  printf '%s%s' "$2" $((max + 1))
}

# stamp_cite <staged frontmatter> <board> <prefix>: a gated filing script renders `cite-as: CITEPENDING`; this scans (next_cite) and fills it in,
# so the scan runs after everything slow and just before the card is written. Prints the citation.
stamp_cite() {   # dies if the prefix gave no citation or the placeholder survived (no `cite-as: CITEPENDING` line to fill)
  local c; [ -n "$3" ] && c=$(next_cite "$2" "$3") || { echo "stamp_cite: no citation for prefix '$3'" >&2; return 1; }
  perl -pi -e "s/^cite-as: CITEPENDING\$/cite-as: $c/" "$1"
  if grep -qx 'cite-as: CITEPENDING' "$1" || ! grep -qxF "cite-as: $c" "$1"; then echo "stamp_cite: $c not stamped into $1" >&2; return 1; fi
  printf '%s' "$c"
}

# yaml_scalar <v>: the one quoting rule for a stamp value; yaml_quote <v>: always double-quoted, \ and " escaped.
# merge/scripts/lanework-merge.py signer() and heal/scripts/heal-descriptors.py scalar() apply the same rule.
yaml_quote() {
  local v=$1 bs='\' dq='"'
  v=${v//"$bs"/"$bs$bs"}; v=${v//"$dq"/"$bs$dq"}; printf '"%s"' "$v"
}
# Bare only when the value reads back as the same string: [A-Za-z0-9._-]+ with at least one letter, not null/true/false/yes/no/on/off (any case)
# and not number-shaped (sign, digits, `1e3`, `0x1F`, `0o17`, `.inf`, `.nan`). Anything else is quoted. Plain ids (`claude`, `claude-fable-5-2`) stay bare.
YAML_NUM='^[-+]?(0[xob][0-9a-f_]+|[0-9._]+(e[-+]?[0-9]+)?|\.?(inf|nan))$'
yaml_scalar() {
  local v=$1 l
  if [[ $v =~ ^[A-Za-z0-9._-]+$ ]] && [[ $v =~ [A-Za-z] ]]; then
    l=$(printf '%s' "$v" | tr 'A-Z' 'a-z')
    case $l in null|true|false|yes|no|on|off) yaml_quote "$v"; return ;; esac
    if [[ $l =~ $YAML_NUM ]]; then yaml_quote "$v"; else printf '%s' "$v"; fi
  else yaml_quote "$v"; fi
}

# by_of <name> <model> [session]: the stamp's `by` mapping. The one writer: name and model through yaml_scalar, session always yaml_quote'd.
by_of() {
  local n m; n=$(yaml_scalar "$1"); m=$(yaml_scalar "$2")
  if [ -n "${3:-}" ]; then printf '{name: %s, kind: agent, model: %s, session: %s}' "$n" "$m" "$(yaml_quote "$3")"
  else printf '{name: %s, kind: agent, model: %s}' "$n" "$m"; fi
}

# stamp_args_ok <name> <model> [session]: call right after require_model. A value that is empty or holds a control character (newline, tab) cannot be
# carried by any quoting: exit 2 "nothing written".
stamp_args_ok() {
  local w v i=0 LC_ALL=C   # bytes: a C1 control (U+0080-U+009F, UTF-8 C2 80-9F) is caught like the ASCII ones
  for w in name model session; do
    i=$((i + 1)); [ $i -le $# ] || break; v=${!i}
    if [ -z "$v" ] && [ "$w" != session ]; then printf '%s: empty --%s; nothing written\n' "$(basename "$0")" "$w" >&2; exit 2; fi
    if [ "$i" = 3 ] && [ -z "$v" ]; then continue; fi
    case "$v" in *[[:cntrl:]]*|*$'\xc2'[$'\x80'-$'\x9f']*) printf '%s: control character in the stamp %s; nothing written\n' "$(basename "$0")" "$w" >&2; exit 2 ;; esac
  done
}

# LEASE_LOST_PREFIX: the fixed opening of the "Lease lost" record. lease.sh writes it; a lint that counts losses greps for it.
LEASE_LOST_PREFIX='**Lease lost**:'

uuid() { uuidgen | tr 'A-Z' 'a-z'; }
now_utc() { date -u ${1:+-v+${1}S} +%FT%TZ; }   # now_utc [seconds-ahead]

# render <template> key value ...: print the template with every {{key}} filled.
# Dies on a {{key}} left unfilled.
render() {
  perl -e '
    my $f = shift; my %v; while (@ARGV) { my $k = shift; $v{$k} = shift; }
    open my $fh, "<", $f or die "render: $f: $!\n"; local $/; my $t = <$fh>;
    $t =~ s/\{\{(\w+)\}\}/exists $v{$1} ? $v{$1} : die "render: {{$1}} unfilled in $f\n"/ge;
    print $t;
  ' "$@"
}

# frontmatter_of <file>: the frontmatter block, both --- lines included.
frontmatter_of() { awk 'NR==1 && $0=="---" {print; fm=1; next} fm {print} fm && $0=="---" {exit}' "$1"; }

# compact_fm <file>: rewrite a staged file's frontmatter collections in the writer's compact form (guide § Frontmatter):
# one flow line while it fits 120 characters, else a block whose entries stay on one line where theirs fit.
# heal-board.py's compact-collection pass, so a script's write is never a heal's next repair. Lines already compact stay.
compact_fm() {
  python3 -B - "$LIB_DIR/heal-board.py" "$1" <<'EOF'   # -B: no __pycache__ in the skill tree
import importlib.util, sys
spec = importlib.util.spec_from_file_location("heal_board", sys.argv[1]); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
path = sys.argv[2]; doc = hb.Doc(path)
if hb.Heal(".", {}).heal_layout(doc):
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(doc.text())
EOF
}

# union_labels [--strict] [--json] <staged-fm> <board> <entry>...: the one label model. Rewrites the staged file's `labels`: the card's own entries as
# written, then each <entry> it lacks, stamped from the board's current config.labels (guide § Frontmatter, labels). An entry is `Text` (a free label) or
# `Text:kind` (the part after the last colon names the kind; `Text:text` for a free label whose text holds a colon); with --json each is one JSON value:
# a string (a free label as is) or a label map. An entry is dropped when the card has the same text and kind (case-insensitive), or its own value of a
# `single` kind; several of one `single` kind keep one (lowest rank, a ranked entry before an unranked, else the first). An undefined kind stays as
# written, in a map. Nothing to add: the file is left untouched. --strict (a caller's own labels, not a lane's defaults): an undefined kind, a value a
# closed kind does not list, or a different value of a `single` kind the card holds (or another entry names) is stderr and
# exit 1, nothing written, the owner's value never overwritten. The heal's label model, loaded by path. Run it before compact_fm.
union_labels() {
  local flags=""
  while [ $# -gt 0 ]; do case "$1" in --strict) flags="${flags}s"; shift ;; --json) flags="${flags}j"; shift ;; *) break ;; esac; done
  python3 -B - "$LIB_DIR/heal-board.py" "$flags" "$@" <<'EOF'   # -B: no __pycache__ in the skill tree
import importlib.util, json, os, sys
spec = importlib.util.spec_from_file_location("heal_board", sys.argv[1]); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
flags, staged, board, args = sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5:]
strict, asjson = "s" in flags, "j" in flags
def die(msg):
    print("union_labels: " + msg, file=sys.stderr); sys.exit(1)
try:
    cfg = hb.Doc(os.path.join(board, "index.md")).get("config")
except (OSError, hb.ParseError, UnicodeDecodeError) as e:
    die("%s: unreadable board: %s" % (board, e))
if isinstance(cfg, dict) and cfg.get("labels") is not None and not isinstance(cfg["labels"], list):
    die("%s: config.labels is not a list" % board)
defs = hb.definitions_of(hb.config_labels(os.path.join(board, "index.md"), "labels"))
raw = []
for a in args:
    if asjson:
        raw.append(json.loads(a)); continue
    text, kind = a, "text"
    if ":" in a:
        text, kind = a.rsplit(":", 1)
    if not text.strip() or not kind.strip():
        die("not a label: %r (Text or Text:kind)" % a)
    t = hb.canon(kind)
    if t != "text" and t not in defs:
        die("%s: undefined kind %r on this board" % (a, kind.strip()))
    raw.append({"text": text.strip(), "kind": {"type": defs[t]["type"] if t in defs else "text"}})
doc = hb.Doc(staged)
own = doc.get("labels") if doc.has("labels") else []
if own is None:
    own = []
if not isinstance(own, list):
    die("%s: labels is not a list" % staged)
def key(e):
    return (hb.canon(e["text"]), hb.canon(e["kind"]["type"]))
have, single_have = set(), {}
for item in own:
    n = hb.normalize_entry(item)[0]
    if hb.entry_of(n):
        have.add(key(n))
        d = defs.get(hb.canon(n["kind"]["type"]))
        if d and d["single"]:
            single_have[hb.canon(n["kind"]["type"])] = n["text"]
cands, seen, best, named = [], set(), {}, {}
for item in raw:
    n = hb.normalize_entry(item)[0]
    if not hb.entry_of(n):   # only a lane's --json item can be unreadable: a spec always builds text and kind
        continue
    k, t = key(n), hb.canon(n["kind"]["type"])
    d = defs.get(t)
    if strict and d and d["closed"] and hb.matched(n, d) is None:
        die("%s is not a value of the closed kind %s" % (n["text"], d["type"]))
    if k in have or k in seen:
        continue
    if d and d["single"] and t in single_have:
        if strict:
            die("the card already has %s of the single kind %s; %s not added" % (single_have[t], t, n["text"]))
        continue
    if strict and d and d["single"] and t in named:
        die("two values of the single kind %s: %s and %s" % (t, named[t], n["text"]))
    seen.add(k)
    if d and d["single"]:
        named[t] = n["text"]
    f = hb.flattened(n, defs)
    cands.append((t, f, bool(d and d["single"])))
    if d and d["single"]:
        cur = best.get(t)
        r = hb.numeric_rank(f.get("rank")); cr = hb.numeric_rank(cur.get("rank")) if cur else None
        if cur is None or (r is not None and (cr is None or r < cr)):
            best[t] = f
added = [f for t, f, single in cands if not single or best[t] is f]
if not added:
    sys.exit(0)
doc.set("labels", hb.emit_key("labels", own + added))
with open(staged, "w", encoding="utf-8", newline="") as fh:
    fh.write(doc.text())
EOF
}

# union_lane_defaults <lane> <board> <staged-fm>: a card born by file into <lane> starts with the lane's card-defaults.labels (guide § Frontmatter, lanes).
# Reads the lane's labels and hands them to union_labels (the merge: own entries first, kinded ones stamped, `single` kinds resolved). No card-defaults or
# no labels in it: the file is left untouched. A card-defaults that is not a mapping, or labels that are neither a list nor one name: message on stderr,
# exit 1, nothing written, by this card's ruling (the app would ignore the value and still make the card). A bare number or boolean is the label's text as
# typed. Unreadable single items are skipped. Run it after `render`, before compact_fm; never on a move.
union_lane_defaults() {
  local out line items=()
  out=$(python3 -B - "$LIB_DIR/heal-board.py" "$1" <<'EOF'   # -B: no __pycache__ in the skill tree
import importlib.util, json, os, sys
spec = importlib.util.spec_from_file_location("heal_board", sys.argv[1]); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
lane = sys.argv[2]
def die(msg):
    print("union_lane_defaults: " + msg, file=sys.stderr); sys.exit(1)
def read_lane(typed):
    # Depends on heal-board.py's `scalar` (it coerces a bare 1.10 to 1.1 and true to True, losing the text) and `Plain`: the lane is read twice,
    # once as the parser gives it, once with `scalar` keeping a bare number or boolean as its text, and only label NAME positions take the second.
    orig = hb.scalar
    if typed:
        hb.scalar = lambda t: hb.Plain(t.strip()) if isinstance(orig(t), (bool, int, float)) else orig(t)
    try:
        return hb.Doc(os.path.join(lane, "index.md")).get("card-defaults")
    finally:
        hb.scalar = orig
def named(n, t):   # the entry as parsed, with its text and kind.type/kind.text taken from the typed read
    if not (isinstance(n, dict) and isinstance(t, dict)):
        return t if isinstance(n, (bool, int, float)) else n
    out = dict(n)
    if "text" in t: out["text"] = t["text"]
    if isinstance(n.get("kind"), dict) and isinstance(t.get("kind"), dict):
        out["kind"] = dict(n["kind"], **{k: t["kind"][k] for k in ("type", "text") if k in t["kind"]})
    return out
try:
    cd, td = read_lane(False), read_lane(True)
except (OSError, hb.ParseError, UnicodeDecodeError) as e:
    die("%s: unreadable lane: %s" % (lane, e))
if isinstance(cd, dict) and isinstance(td, dict) and cd.get("labels") is not None:
    nl, tl = cd["labels"], td.get("labels")
    if isinstance(nl, list) and isinstance(tl, list) and len(nl) == len(tl):
        cd = dict(cd, labels=[named(n, t) for n, t in zip(nl, tl)])
    elif isinstance(nl, (bool, int, float)):
        cd = dict(cd, labels=tl)
if cd is None:
    sys.exit(0)
if not isinstance(cd, dict):
    die("%s: card-defaults is not a mapping" % lane)
raw = cd.get("labels")
if raw is None:
    sys.exit(0)
if hb.is_text(raw):
    raw = [raw]
if not isinstance(raw, list):
    die("%s: card-defaults.labels is neither a list nor one name" % lane)
for item in raw:
    print(json.dumps(item, default=str))
EOF
  ) || return 1
  [ -n "$out" ] || return 0
  while IFS= read -r line; do items+=("$line"); done <<<"$out"
  union_labels --json "$3" "$2" "${items[@]}"
}

# stamp_lines_ok <file> <key>...: the guard for the stamp lines a script wrote. Reads the front matter only (line 2 to the closing ---, trailing
# blanks allowed), keeps each top-level line whose key is listed plus its indented continuation lines, and returns 1 if the kept lines hold `}}}`
# or unequal counts of `{` and `}` outside double-quoted strings (the last guard: by_of quotes what it must). Copied lines and the body legitimately end in `}}}` (a label whose
# kind carries an icon, a JSON example), so never test a whole file.
stamp_lines_ok() {
  local f=$1 keys; shift
  keys=$(IFS='|'; echo "$*")
  awk -v k="$keys" 'NR == 1 { next } /^---[ \t]*$/ { exit }
    /^[^ \t]/ { w = ($0 ~ ("^(" k "):")) }
    w { q = $0; gsub(/"([^"\\]|\\.)*"/, "", q)   # double-quoted values (by_of quotes a value that needs it) may hold any brace
        if (q ~ /[}][}][}]/) bad = 1; o += gsub(/[{]/, "{", q); c += gsub(/[}]/, "}", q) }
    END { exit (bad || o != c) }' "$f"
}

# comment_file <path> <created-at> <by> [in-reply-to] < body: write a comment index.md.
comment_file() {
  {
    printf '%s\n' '---' 'schema: 1' 'kind: comment'
    [ -n "${4:-}" ] && printf 'in-reply-to: %s\n' "$4"
    printf 'created:  {at: %s, by: %s}\n' "$2" "$3"
    printf 'modified: {at: %s, by: %s}\n' "$2" "$3"
    printf '%s\n' '---'
    cat
  } > "$1"
}

# unreadable_files: paths on stdin, one per line. Each that passes [ -r ] prints on stdout; each that fails -> "<script>: could not read <path>"
# on stderr. Returns 2 if any failed.
unreadable_files() {
  local p rc=0
  while IFS= read -r p; do
    if [ -r "$p" ]; then printf '%s\n' "$p"; elif [ ! -e "$p" ]; then :   # moved since find listed it
    else printf '%s: could not read %s\n' "$(basename "$0")" "$p" >&2; rc=2; fi
  done
  return "$rc"
}

# show_name <text>: prints a path, card name or comment id for a one-line finding: tab -> \t, newline -> \n, carriage return -> \r, byte \001 -> \001,
# backslash -> \\ (so a name holding the two characters \t is not read as a tab). Any other name prints as it is. The lints use it on
# everything they print; SHOW_NAME_AWK is the same rule as an awk function (show_name(s)) to splice in front of an awk program.
show_name() {
  local s=$1 b='\'
  s=${s//"$b"/"$b$b"}; s=${s//$'\t'/"${b}t"}; s=${s//$'\n'/"${b}n"}; s=${s//$'\r'/"${b}r"}; s=${s//$'\001'/"${b}001"}
  printf '%s' "$s"
}
SHOW_NAME_AWK='function show_name(s,   o, i, c) {
  o = ""
  for (i = 1; i <= length(s); i++) { c = substr(s, i, 1); o = o (c == "\\" ? "\\\\" : c == "\t" ? "\\t" : c == "\n" ? "\\n" : c == "\r" ? "\\r" : c == "\001" ? "\\001" : c) }
  return o
}
'

# board_index_files <dir> <outfile>: writes every readable index.md under <dir> (not .dot or attachments folders), NUL-separated, to <outfile>
# (a shell variable cannot hold NULs, and a name may hold a newline). Symlinked folders, lanes and cards included, are followed (find -L; a symlink loop is skipped by find without a message, exit 0), spelled as
# the caller wrote <dir>. A card reachable under two spellings (a lane that is a symlink to a sibling lane) is listed once, under the first spelling
# in sort order; checked only when the board holds a symlink. Anything it could not read (a folder find cannot enter, an index.md that fails [ -r ]) ->
# "<script>: could not read <path>" on stderr and return 2; the readable paths are still written. The lints finish their findings, then exit 2 on that.
board_index_files() {
  local err rc=0 l p pre=""
  local d=$1 o=$2; case "$d" in -*) d=./$d; pre=./ ;; esac   # find reads a leading - as an option; the prefix is stripped from every path printed
  err=$(mktemp "${TMPDIR:-/tmp}/lw-find.XXXXXX") || return 2
  : > "$o"
  find -L "$d" -mindepth 1 \( -name '.*' -o -name attachments \) -prune -o -type f -name index.md -print0 2>"$err" \
    | while IFS= read -r -d '' p; do
        if [ -r "$p" ]; then printf '%s\0' "${p#"$pre"}" >> "$o"
        elif [ -e "$p" ]; then printf '%s: could not read %s\n' "$(basename "$0")" "${p#"$pre"}" >&2; echo x >> "$err.bad"
        fi   # else: moved since find listed it
      done
  [ ! -e "$err.bad" ] || { rm -f "$err.bad"; rc=2; }
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    l=${l#find: }; l=${l%: *}; l=${l#"$pre"}
    printf '%s: could not read %s\n' "$(basename "$0")" "$l" >&2; rc=2
  done < "$err"
  rm -f "$err"
  if [ -s "$o" ] && [ -n "$(find -H "$d" -mindepth 1 -type l -print -quit 2>/dev/null)" ]; then   # a symlink somewhere: keep one spelling per physical folder
    local q f n1 n2 tmp="$o.dedupe"
    sort -z "$o" > "$tmp.s"
    while IFS= read -r -d '' q; do printf '%s\0' "${pre}${q%/*}"; done < "$tmp.s" | xargs -0 realpath 2>/dev/null | awk '{ print (seen[$0]++) ? 0 : 1 }' > "$tmp.f"   # one pass; 1 = first of its real folder
    n1=$(tr -cd '\0' < "$tmp.s" | wc -c); n2=$(wc -l < "$tmp.f")
    if [ "$n1" -eq "$n2" ]; then
      while IFS= read -r -d '' q <&3 && IFS= read -r f <&4; do [ "$f" = 1 ] && printf '%s\0' "$q"; done 3< "$tmp.s" 4< "$tmp.f" > "$tmp"
    else   # a newline in a name shifts realpath's lines (or a path vanished): one folder at a time
      local seen=$'\n' ph
      while IFS= read -r -d '' q; do
        ph=$(cd -- "${pre}${q%/*}" >/dev/null 2>&1 && pwd -P; echo x); ph=$(show_name "${ph%x}")
        case "$seen" in *$'\n'"$ph"$'\n'*) continue ;; esac
        seen="$seen$ph"$'\n'; printf '%s\0' "$q"
      done < "$tmp.s" > "$tmp"
    fi
    mv "$tmp" "$o"; rm -f "$tmp.s" "$tmp.f"
  fi
  return "$rc"
}
