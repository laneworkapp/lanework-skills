#!/usr/bin/env python3
# heal-board.py: repair the known kinds of board damage. Python 3, standard library only.
"""heal-board.py: find and repair the known kinds of damage on a Lanework board.

    heal-board.py <board> [--apply --model M [--name N] [--session S]] [--global FILE] [--ignore-board-copy]

Dry run by default: one line per repair, `<file>: <code> <what>`, nothing written.
`--apply` writes each repaired file (staged outside the board, then moved in). No `modified`
is restamped: a heal is upkeep, not an edit (the app's own heal rule). `--name`/`--model`
sign the records a heal posts. Idempotent: a second run finds nothing.

Definitions healed against: the built-in `text` kind, plus the board's own
`config.labels`, plus `--global FILE`'s `config.default-labels` when given. The
machine-level config is read only through `--global`.

Repairs (the board's agent guide, then the app's LabelHealing / lanework-migrate-labels where the guide is silent):
  definition        a `config.labels` entry in a retired spelling: `kind:` for `type:`, a bare `glyph:`,
                    the retired `default` kind, `value:` or a bare string in `values`
  added-definition  a `priority`/`component` kind the board's cards use and its vocabulary lacks
                    (the machine's definition with --global, else the suggested one)
  bare-labels       `labels: <scalar>`, or a bare string entry
  string-kind       an entry's `kind: <name>` where the kind object belongs
  text-kind         a free label with no `kind`, or the retired `default` kind
  bare-glyph        a bare `glyph:` on an entry or its kind where `icon` belongs
  root-key          a reserved root `priority:`/`component:` key moved into `labels`
  root-key-dropped  the same key, dropped: `labels` already carries an entry of that kind (it wins)
  stale-label       a recognised entry whose stamps disagree with the current definition
  single-kind       several entries of a `single` kind: the first in file order stays
  bare-stamp        `created`/`modified` as a bare timestamp, or `by` as a bare name
  bare-icon         `icon: <glyph>` and `iconColor:` folded into the `icon` mapping (the mapping wins)
  retired-key       `modified-by`: folded into `modified.by` when that has none; dropped when it
                    names the same; else dropped with the name kept in a record on the card
  title-quote       a `title` that is not double-quoted, or that carries a line break

Never touched: `.trash/`, `comments/.draft`, `comments/.trash`, any key or entry not named
above, and a foreign entry's stamps (a kind the definitions don't name, or a closed kind's
unlisted value). The single-kind reduction counts every entry of a defined single kind,
an unlisted value included, as the app's does.
A missing `by` is not damage: it says the owner wrote the file, so no heal invents one.
A repair that drops a fact (single-kind, root-key-dropped, retired-key) posts a comment on
the card, signed as the running agent, quoting what was dropped; it posts before the file
is rewritten. Listed as `skip`, never rewritten: a file that can't be read or parsed, a title
carrying ` #` (YAML reads the rest as a comment: quote it by hand), a title that isn't a scalar.

Known limitations: a rewritten `labels` list or `config` comes back with every string
double-quoted and in the guide's flow-or-block length rule, untouched entries included; a
whole-number float in it comes back as an integer (`2.0` as `2`), as the app's emitter does.
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid
from datetime import datetime, timezone

RESERVED_NAMES = {"healer", "shortcuts", "tracker"}
FLOW_LIMIT = 120
TEXT_KIND = {"type": "text", "text": "Text", "icon": {"glyph": "tag"}}
SUGGESTED = [
    {"type": "priority", "text": "Priority", "icon": {"glyph": "flag"}, "single": True, "values": [
        {"text": "Urgent", "rank": 0, "color": "#C8283C", "icon": {"glyph": "exclamationmark.2"}},
        {"text": "High", "rank": 1, "color": "#E07A1F", "icon": {"glyph": "exclamationmark"}},
        {"text": "Medium", "rank": 2},
        {"text": "Low", "rank": 3, "icon": {"glyph": "arrow.down"}}]},
    {"type": "component", "text": "Component", "color": "aluminum", "icon": {"glyph": "puzzlepiece"}, "single": True},
]
RESERVED_KINDS = ("priority", "component")
LABEL_KEYS = ("text", "rank", "color", "icon", "kind")
KIND_KEYS = ("type", "text", "color", "icon")


class ParseError(Exception):
    pass


# ---------------------------------------------------------------- YAML subset: read

class Plain(str):
    """A plain (unquoted) scalar that stayed a string: kept apart so re-emission can tell."""


def scalar(text):
    t = text.strip()
    if t in ("", "~", "null", "Null", "NULL"):
        return None
    if t in ("true", "True", "TRUE"):
        return True
    if t in ("false", "False", "FALSE"):
        return False
    if re.fullmatch(r"[-+]?[0-9]+", t):
        return int(t)
    if re.fullmatch(r"[-+]?([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][-+]?[0-9]+)?", t):
        return float(t)
    return Plain(t)


def read_double(text, i):
    """text[i] == '"'. Returns (value, index after the closing quote)."""
    out, i = [], i + 1
    esc = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\", "/": "/", "0": "\0", " ": " "}
    while i < len(text):
        ch = text[i]
        if ch == '"':
            return "".join(out), i + 1
        if ch == "\\":
            nxt = text[i + 1] if i + 1 < len(text) else ""
            if nxt in esc:
                out.append(esc[nxt]); i += 2; continue
            if nxt == "u":
                out.append(chr(int(text[i + 2:i + 6], 16))); i += 6; continue
            raise ParseError("bad escape")
        out.append(ch); i += 1
    raise ParseError("unclosed double quote")


def read_single(text, i):
    out, i = [], i + 1
    while i < len(text):
        if text[i] == "'":
            if text[i + 1:i + 2] == "'":
                out.append("'"); i += 2; continue
            return "".join(out), i + 1
        out.append(text[i]); i += 1
    raise ParseError("unclosed single quote")


class Flow:
    def __init__(self, text):
        self.t, self.i = text, 0

    def ws(self):
        while self.i < len(self.t) and self.t[self.i] in " \t\r\n":
            self.i += 1

    def value(self, in_map_key=False):
        self.ws()
        ch = self.t[self.i:self.i + 1]
        if ch == "{":
            return self.mapping()
        if ch == "[":
            return self.sequence()
        if ch == '"':
            v, self.i = read_double(self.t, self.i); return v
        if ch == "'":
            v, self.i = read_single(self.t, self.i); return v
        start = self.i
        while self.i < len(self.t):
            c = self.t[self.i]
            if c in ",]}":
                break
            if c == ":" and (self.i + 1 >= len(self.t) or self.t[self.i + 1] in " \t,]}") and in_map_key:
                break
            self.i += 1
        return scalar(self.t[start:self.i])

    def mapping(self):
        self.i += 1; out = {}
        while True:
            self.ws()
            if self.t[self.i:self.i + 1] == "}":
                self.i += 1; return out
            k = self.value(in_map_key=True)
            self.ws()
            if self.t[self.i:self.i + 1] != ":":
                raise ParseError("flow mapping: expected ':'")
            self.i += 1
            v = self.value()
            out[str(k)] = v
            self.ws()
            ch = self.t[self.i:self.i + 1]
            if ch == ",":
                self.i += 1
            elif ch != "}":
                raise ParseError("flow mapping: expected ',' or '}'")

    def sequence(self):
        self.i += 1; out = []
        while True:
            self.ws()
            if self.t[self.i:self.i + 1] == "]":
                self.i += 1; return out
            out.append(self.value())
            self.ws()
            ch = self.t[self.i:self.i + 1]
            if ch == ",":
                self.i += 1
            elif ch != "]":
                raise ParseError("flow sequence: expected ',' or ']'")


def inline(text):
    """One value written after `key:` (flow collections may continue over following lines)."""
    t = text.strip()
    if not t:
        return None
    if t[0] in "{[\"'":
        f = Flow(t)
        v = f.value()
        rest = t[f.i:].strip()
        if rest and not rest.startswith("#"):
            raise ParseError("trailing text after value")
        return v
    if " #" in t:
        t = t.split(" #", 1)[0]
    return scalar(t)


def indent(line):
    return len(line) - len(line.lstrip(" "))


def split_key(text):
    """`key: rest` -> (key, rest), or None."""
    if text[:1] in "\"'":
        k, j = (read_double if text[0] == '"' else read_single)(text, 0)
        if text[j:j + 1] != ":":
            return None
        return k, text[j + 1:]
    m = re.match(r"([^:#{}\[\],][^:]*?):(?:\s|$)", text)
    if not m:
        return None
    return m.group(1).strip(), text[m.end():] if m.end() <= len(text) else ""


def block(lines, i, ind):
    """Parse a block node whose lines start at lines[i] with indentation `ind`. Returns (value, next i)."""
    first = lines[i][ind:]
    if first.startswith("- ") or first == "-":
        out = []
        while i < len(lines) and indent(lines[i]) == ind and lines[i][ind:ind + 1] == "-":
            body = lines[i][ind + 1:]
            sub = len(body) - len(body.lstrip(" "))
            child_ind = ind + 1 + sub
            content = body.strip()
            if not content:
                j = i + 1
                if j < len(lines) and indent(lines[j]) > ind:
                    v, i = block(lines, j, indent(lines[j]))
                else:
                    v, i = None, i + 1
                out.append(v); continue
            if split_key(content) and content[0] not in "{[":
                # a mapping opening on the dash line: re-indent it as its own block
                sub_lines = [" " * child_ind + content]
                j = i + 1
                while j < len(lines) and indent(lines[j]) >= child_ind and not (indent(lines[j]) == ind and lines[j][ind] == "-"):
                    sub_lines.append(lines[j]); j += 1
                v, _ = block(sub_lines, 0, child_ind)
                out.append(v); i = j; continue
            j = i + 1
            text = content
            while j < len(lines) and indent(lines[j]) > ind:
                text += " " + lines[j].strip(); j += 1
            out.append(inline(text)); i = j
        return out, i
    out = {}
    while i < len(lines) and indent(lines[i]) == ind:
        kv = split_key(lines[i][ind:])
        if kv is None:
            raise ParseError("expected key: " + lines[i].strip())
        k, rest = kv
        j = i + 1
        if rest.strip() == "" or rest.strip().startswith("#"):
            if j < len(lines) and (indent(lines[j]) > ind or (indent(lines[j]) == ind and lines[j][ind:ind + 1] == "-")):
                v, j = block(lines, j, indent(lines[j]))
            else:
                v = None
        else:
            text = rest
            while j < len(lines) and indent(lines[j]) > ind:
                text += " " + lines[j].strip(); j += 1
            v = inline(text)
        out[k] = v; i = j
    return out, i


# ---------------------------------------------------------------- YAML subset: write

PLAIN_OK = re.compile(r"[A-Za-z][A-Za-z0-9._/-]*")
TIMESTAMP = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9:.]+(Z|[+-][0-9:]+)?)?")


def emit_str(s, plain_ok=False):
    if plain_ok and (TIMESTAMP.fullmatch(s) or (PLAIN_OK.fullmatch(s) and not isinstance(scalar(s), (bool, type(None))))):
        return s
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") + '"'


def emit_scalar(v, plain_ok=False):
    if v is None:
        return "null"
    if v is True:
        return "true"
    if v is False:
        return "false"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        return str(int(v)) if v.is_integer() else repr(v)
    return emit_str(str(v), plain_ok)


def flow(v, plain_ok=False):
    if isinstance(v, dict):
        return "{" + ", ".join(emit_str(k, True) + ": " + flow(x, plain_ok) for k, x in v.items()) + "}"
    if isinstance(v, list):
        return "[" + ", ".join(flow(x, plain_ok) for x in v) + "]"
    return emit_scalar(v, plain_ok)


def emit_key(key, v, ind=0):
    """`key: value` lines: one flow line while it fits FLOW_LIMIT, else an indented block (the guide's rule)."""
    pad = " " * ind
    one = pad + emit_str(key, True) + ": " + flow(v)
    if not isinstance(v, (dict, list)) or len(one) <= FLOW_LIMIT or not v:
        return [one]
    out = [pad + emit_str(key, True) + ":"]
    if isinstance(v, dict):
        for k, x in v.items():
            out += emit_key(k, x, ind + 2)
    else:
        for x in v:
            out += emit_item(x, ind + 2)
    return out


def emit_item(x, ind):
    pad = " " * ind
    if isinstance(x, dict) and x and len(pad + "- " + flow(x)) > FLOW_LIMIT:
        lines = []
        for n, (k, y) in enumerate(x.items()):
            sub = emit_key(k, y, ind + 2)
            if n == 0:
                sub[0] = pad + "- " + sub[0][ind + 2:]
            lines += sub
        return lines
    if isinstance(x, list) and x and len(pad + "- " + flow(x)) > FLOW_LIMIT:
        return [pad + "-"] + [l for y in x for l in emit_item(y, ind + 2)]
    return [pad + "- " + flow(x)]


def emit_stamp(key, v):
    return (key + ":" + (" " * max(1, 10 - len(key) - 1))) + flow(v, plain_ok=True)


# ---------------------------------------------------------------- frontmatter document

class Doc:
    def __init__(self, path):
        self.path = path
        with open(path, "rb") as f:
            raw = f.read()
        self.raw = raw
        text = raw.decode("utf-8")
        self.nl = "\r\n" if "\r\n" in text.split("\n", 1)[0] + "\n" else "\n"
        lines = text.split(self.nl)
        if not lines or lines[0].rstrip() != "---":      # column 0, as the app and the validator read it
            raise ParseError("no frontmatter")
        self.head = lines[0]
        end = next((k for k in range(1, len(lines)) if lines[k].rstrip() == "---"), None)
        if end is None:
            raise ParseError("frontmatter never closes")
        self.fm = lines[1:end]
        self.rest = lines[end:]          # closing --- and the body, untouched
        self.spans = []                  # [key, [lines]]
        for line in self.fm:
            kv = split_key(line) if line[:1] not in (" ", "\t", "-", "#", "") else None
            if kv and indent(line) == 0:
                self.spans.append([kv[0], [line]])
            elif self.spans:
                self.spans[-1][1].append(line)
            else:
                self.spans.append([None, [line]])
        # a column-0 comment (and blank) run that ends a span is a span of its own, never a value's
        split = []
        for k, ls in self.spans:
            n = len(ls)
            while n > 1 and (ls[n - 1][:1] == "#" or not ls[n - 1].strip()):
                n -= 1
            split.append([k, ls[:n]])
            if n < len(ls):
                split.append([None, ls[n:]])
        self.spans = split

    def has(self, key):
        return any(k == key for k, _ in self.spans)

    def raw_lines(self, key):
        return next((ls for k, ls in self.spans if k == key), None)

    def get(self, key):
        ls = self.raw_lines(key)
        if ls is None:
            return None
        v, _ = block([l for l in ls if l.strip() and not l.lstrip().startswith("#")], 0, 0)
        return v[key]

    def set(self, key, lines):
        for span in self.spans:
            if span[0] == key:
                span[1] = lines; return
        # new key: before the stamps, else at the end
        at = next((n for n, (k, _) in enumerate(self.spans) if k in ("created", "modified")), len(self.spans))
        self.spans.insert(at, [key, lines])

    def remove(self, key):
        self.spans = [s for s in self.spans if s[0] != key]

    def text(self):
        fm = [l for _, ls in self.spans for l in ls]
        return self.nl.join([self.head] + fm + self.rest)


# ---------------------------------------------------------------- labels: the model

def canon(s):
    return str(s).strip().lower()


def is_text(v):
    return isinstance(v, str) and v.strip() != ""


def kind_quartet(defn):
    return {k: defn[k] for k in KIND_KEYS if defn.get(k) is not None}


def fold_glyph(m):
    """A bare `glyph:` folded into `icon` (LegacySpelling.foldingGlyph). None when nothing to fold."""
    if "glyph" not in m or not isinstance(m["glyph"], str):
        return None
    out = {}
    icon = m.get("icon")
    for k, v in m.items():
        if k == "glyph":
            if "icon" not in m:
                out["icon"] = {"glyph": v}
            continue
        if k == "icon" and isinstance(icon, dict) and "glyph" not in icon:
            v = dict({"glyph": m["glyph"]}, **icon)
        out[k] = v
    return out


def rename_default(m):
    """`type: default` -> `type: text` (and the retired display name `Label` -> `Text`)."""
    if not (isinstance(m, dict) and isinstance(m.get("type"), str) and canon(m["type"]) == "default"):
        return None
    out = dict(m)
    out["type"] = "text"
    if out.get("text") == "Label":
        out["text"] = "Text"
    return out


def rename_key(m, old, new):
    return {(new if k == old else k): v for k, v in m.items()}


def normalize_definition(e):
    """One config.labels entry in the current spelling. Returns (entry, changed)."""
    if not isinstance(e, dict):
        return e, False
    m, changed = dict(e), False
    if "type" not in m and isinstance(m.get("kind"), str):
        m, changed = rename_key(m, "kind", "type"), True
    f = fold_glyph(m)
    if f is not None:
        m, changed = f, True
    r = rename_default(m)
    if r is not None:
        m, changed = r, True
    if isinstance(m.get("values"), list):
        vals = []
        for v in m["values"]:
            if is_text(v):
                vals.append({"text": v}); changed = True; continue
            if isinstance(v, dict):
                if "text" not in v and isinstance(v.get("value"), str):
                    v = rename_key(v, "value", "text"); changed = True
                f = fold_glyph(v)
                if f is not None:
                    v = f; changed = True
            vals.append(v)
        m["values"] = vals
    return m, changed


def definitions_of(entries):
    """Parsed, normalized entries -> {canonical type: defn}, in order."""
    out = {}
    for e in entries or []:
        if not (isinstance(e, dict) and is_text(e.get("type"))):
            continue
        d = {k: e.get(k) for k in KIND_KEYS}
        d["single"] = e.get("single") is True
        d["closed"] = "values" in e
        vals = []
        for n, v in enumerate(e.get("values") or [] if isinstance(e.get("values"), list) else []):
            if isinstance(v, dict) and is_text(v.get("text")):
                v = dict(v)
                if not isinstance(v.get("rank"), (int, float)) or isinstance(v.get("rank"), bool):
                    v["rank"] = n + 1
                vals.append(v)
        d["values"] = vals
        out[canon(e["type"])] = d
    return out


def entry_of(item):
    """A readable label entry: a mapping with a `text` and a `kind` mapping naming a `type`."""
    return isinstance(item, dict) and is_text(item.get("text")) and isinstance(item.get("kind"), dict) \
        and is_text(item["kind"].get("type"))


def num(v):
    return float(v) if isinstance(v, (int, float)) and not isinstance(v, bool) else v


def spelled(n):
    words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    return words[n] if 0 <= n < len(words) else str(n)


def same(a, b):
    """LabelValue equality: the five known keys, ranks compared as numbers."""
    for k in LABEL_KEYS:
        x, y = a.get(k), b.get(k)
        if k == "rank":
            x, y = num(x), num(y)
        if x != y:
            return False
    return True


def definition_for(label, defs):
    t = canon(label["kind"]["type"])
    if t in defs:
        return defs[t]
    if t == "text":
        return dict(TEXT_KIND, single=False, closed=False, values=[])
    return None


def matched(label, d):
    return next((v for v in d["values"] if canon(v["text"]) == canon(label["text"])), None)


def flattened(label, defs):
    """LabelKindRoster.flattened: resolve the stamps against the definition; foreign comes back as is."""
    d = definition_for(label, defs)
    if d is None:
        return label
    m = matched(label, d) or {}
    out = {"text": m.get("text", label["text"])}
    rank = (m.get("rank") if m.get("rank") is not None else label.get("rank")) if d["closed"] else None
    color = m.get("color") or d.get("color") or label.get("color")
    icon = m.get("icon") or label.get("icon")
    if rank is not None:
        out["rank"] = rank
    if color is not None:
        out["color"] = color
    if icon is not None:
        out["icon"] = icon
    out["kind"] = kind_quartet(d)
    for k, v in label.items():               # unknown subkeys ride along after the five
        if k not in LABEL_KEYS:
            out[k] = v
    return out


def recognised(label, defs):
    d = definition_for(label, defs)
    return d is not None and (not d["closed"] or matched(label, d) is not None)


def normalize_entry(item):
    """LegacySpelling.normalizedLabelEntry. Returns (entry, [codes])."""
    if is_text(item):
        return {"text": item, "kind": {"type": "text"}}, ["bare-labels", "text-kind"]
    if not isinstance(item, dict):
        return item, []
    m, codes = dict(item), []
    if "text" not in m and isinstance(m.get("value"), str):
        m = rename_key(m, "value", "text"); codes.append("bare-labels")
    f = fold_glyph(m)
    if f is not None:
        m = f; codes.append("bare-glyph")
    if isinstance(m.get("kind"), dict):
        f = fold_glyph(m["kind"])
        if f is not None:
            m["kind"] = f; codes.append("bare-glyph")
    if isinstance(m.get("kind"), str) and m["kind"].strip():
        name = m["kind"].strip()
        m["kind"] = {"type": "text"} if canon(name) == "default" else {"type": canon(name) if canon(name) in RESERVED_KINDS else name}
        codes.append("string-kind")
    if isinstance(m.get("kind"), dict):
        r = rename_default(m["kind"])
        if r is not None:
            m["kind"] = r; codes.append("text-kind")
    elif "kind" not in m and is_text(m.get("text")):
        m["kind"] = {"type": "text"}; codes.append("text-kind")
    return (m if codes else item), codes


# ---------------------------------------------------------------- one document's heal

class Heal:
    def __init__(self, board, defs):
        self.board, self.defs = board, defs
        self.repairs = []      # (relpath, code, detail)
        self.skips = []
        self.writes = []       # (path, new text)
        self.records = []      # (card dir, comment body)

    def rel(self, path):
        return os.path.relpath(path, self.board)

    def note(self, path, code, detail):
        self.repairs.append((self.rel(path), code, detail))

    def heal_title(self, doc):
        ls = doc.raw_lines("title")
        if not ls:
            return False
        cont = [l.strip() for l in ls[1:] if l.strip()]
        rest = " ".join([ls[0].split(":", 1)[1].strip()] + cont)   # a scalar over several lines folds to one
        if not rest:
            return False
        folded = "continuation folded onto one line, " if cont else ""
        if rest.startswith('"'):
            try:
                v, j = read_double(rest, 0)
            except ParseError:
                self.skips.append((self.rel(doc.path), "title quote never closes: fix by hand"))
                return False
            if rest[j:].strip() or not (cont or re.search(r"[\r\n]", v)):
                return False
            new = re.sub(r"\r\n|\n|\r", " ", v)
            why = "line break flattened" if not cont else "one line"
        elif rest.startswith("'"):
            try:
                new, _ = read_single(rest, 0)
            except ParseError:
                return False
            why = "single quotes"
        elif rest[0] in "{[|>":
            self.skips.append((self.rel(doc.path), "title is not a scalar: fix by hand"))
            return False
        elif re.search(r"\s#", rest):
            self.skips.append((self.rel(doc.path), "title carries ` #`, which YAML reads as a comment: quote it by hand"))
            return False
        else:
            new, why = rest, "unquoted"
        doc.set("title", ["title: " + emit_str(new)])
        self.note(doc.path, "title-quote", folded + why + ": " + emit_str(new))
        return True

    def heal_stamps(self, doc):
        changed = False
        for key in ("created", "modified"):
            if not doc.has(key):
                continue
            try:
                v = doc.get(key)
            except ParseError:
                continue
            new = v
            if isinstance(v, str) and TIMESTAMP.fullmatch(v):
                new = {"at": v}
            elif isinstance(v, dict) and is_text(v.get("by")):
                new = dict(v); new["by"] = {"name": v["by"]}
            if new is not v:
                doc.set(key, [emit_stamp(key, new)])
                self.note(doc.path, "bare-stamp", key + " written as the mapping")
                changed = True
        return changed

    def heal_retired_keys(self, doc, facts):
        """The flat `icon: <glyph>` / `iconColor:` pair into the mapping (the mapping wins per property),
        and `modified-by` folded into `modified.by` (the map wins where both say something)."""
        changed = False
        icon = doc.get("icon") if doc.has("icon") else None
        color = doc.get("iconColor") if doc.has("iconColor") else None
        if is_text(icon) or (doc.has("iconColor") and (icon is None or isinstance(icon, dict))):
            new = {"glyph": icon} if is_text(icon) else dict(icon or {})
            if is_text(color) and "color" not in new:
                new["color"] = color
            if new:
                doc.set("icon", emit_key("icon", new))
            else:
                doc.remove("icon")
            doc.remove("iconColor")
            self.note(doc.path, "bare-icon", "icon written as the mapping %s" % flow(new))
            changed = True
        if doc.has("modified-by"):
            who = doc.get("modified-by")
            mod = doc.get("modified") if doc.has("modified") else None
            by = mod.get("by") if isinstance(mod, dict) else None
            if not is_text(who):
                self.skips.append((self.rel(doc.path), "modified-by has no reading: left as written"))
                return changed
            if mod is not None and not isinstance(mod, dict):
                return changed                     # a bare stamp: the next run, after bare-stamp, folds it
            if by is None:
                new = dict(mod or {}); new["by"] = {"name": who}
                doc.set("modified", [emit_stamp("modified", new)])
                self.note(doc.path, "retired-key", "modified-by %s folded into modified.by" % emit_str(who))
            elif isinstance(by, dict) and by.get("name") == who:
                self.note(doc.path, "retired-key", "modified-by dropped: modified.by already names %s" % emit_str(who))
            else:
                if card_of(self.board, doc.path) is None:
                    self.skips.append((self.rel(doc.path), "modified-by differs from modified.by, and no card holds a record: left as written"))
                    return changed
                self.note(doc.path, "retired-key", "modified-by %s dropped, kept in a record: modified.by names someone else" % emit_str(who))
                facts.append("`modified-by: %s` in `%s`, because its `modified.by` already names %s, and the map wins." % (
                    who, self.rel(doc.path), flow(by, plain_ok=True)))
            doc.remove("modified-by")
            changed = True
        return changed

    def heal_config(self, doc, added):
        """Board root: config.labels into the current spelling, plus the added definitions."""
        cfg = doc.get("config") if doc.has("config") else None
        if cfg is not None and not isinstance(cfg, dict):
            if added:
                self.skips.append((self.rel(doc.path), "config is not a mapping: definitions not added"))
            return False
        cfg = dict(cfg or {})
        entries = cfg.get("labels")
        changed = False
        if isinstance(entries, list):
            out = []
            for e in entries:
                n, c = normalize_definition(e)
                if c:
                    self.note(doc.path, "definition", "config.labels `%s` into the current spelling" % (n.get("type") if isinstance(n, dict) else n))
                    changed = True
                out.append(n)
            entries = out
        elif entries is not None and added:
            self.skips.append((self.rel(doc.path), "config.labels is not a list: definitions not added"))
            added = []
        for d in added:
            entries = (entries or []) + [d]
            self.note(doc.path, "added-definition", "config.labels gains `%s`, which the board's cards use" % d["type"])
            changed = True
        if not changed:
            return False
        cfg["labels"] = entries
        doc.set("config", emit_key("config", cfg))
        return True

    def heal_labels(self, doc, card_dir):
        changed, dropped_facts = False, []
        raw = doc.get("labels") if doc.has("labels") else None
        items = None
        if isinstance(raw, list):
            items = list(raw)
        elif is_text(raw):
            items = [raw]
            self.note(doc.path, "bare-labels", "labels: %s is a one-entry list" % emit_str(raw))
            changed = True
        elif raw is not None:
            self.skips.append((self.rel(doc.path), "labels is not a list: left as written"))

        # reserved root keys -> labels entries
        for key in RESERVED_KINDS:
            if not doc.has(key):
                continue
            v = doc.get(key)
            if v is None:
                continue
            listed = next((e for e in (items or []) if entry_of(normalize_entry(e)[0]) and canon(normalize_entry(e)[0]["kind"]["type"]) == key), None)
            read = None
            if is_text(v):
                read = flattened({"text": v.strip(), "kind": {"type": key}}, self.defs)
            elif isinstance(v, dict):
                m = rename_key(v, "value", "text") if "text" not in v and isinstance(v.get("value"), str) else dict(v)
                m = fold_glyph(m) or m
                if is_text(m.get("text")):
                    d = self.defs.get(key)
                    read = {k: m[k] for k in ("text", "rank", "color", "icon") if m.get(k) is not None}
                    read["kind"] = kind_quartet(d) if d else {"type": key}
            if listed is not None:
                said = read["text"] if read else flow(v)
                doc.remove(key); changed = True
                self.note(doc.path, "root-key-dropped", "%s: %s dropped, labels already carries %s" % (key, emit_str(said), emit_str(normalize_entry(listed)[0]["text"])))
                dropped_facts.append("`%s: %s` at the card's root, because `labels` already carries a `%s` entry, `%s`; that entry wins." % (key, flow(v), key, normalize_entry(listed)[0]["text"]))
                continue
            if read is None:
                self.skips.append((self.rel(doc.path), "%s has no reading: move it into labels by hand" % key))
                continue
            if raw is not None and items is None:
                self.skips.append((self.rel(doc.path), "%s left in place: labels is not a list" % key))
                continue
            items = (items or []) + [read]
            doc.remove(key); changed = True
            self.note(doc.path, "root-key", "%s: %s moved into labels" % (key, emit_str(read["text"])))

        if items is None:
            return changed, dropped_facts

        # spellings, then stamps
        out = []
        for item in items:
            n, codes = normalize_entry(item)
            if codes:
                f = flattened(n, self.defs) if entry_of(n) else n
                if not entry_of(f):            # nothing readable comes of it: the bytes ride through
                    out.append(item)
                    continue
                what = {"bare-labels": "written as a label map", "string-kind": "kind name written as the kind object",
                        "text-kind": "stamped with the `text` kind", "bare-glyph": "bare glyph folded into icon"}
                for c in dict.fromkeys(codes):
                    if c != "bare-labels" or not is_text(raw):
                        self.note(doc.path, c, "%s %s" % (emit_str(f["text"]), what[c]))
                out.append(f)
                changed = True
                continue
            if entry_of(item) and recognised(item, self.defs):
                f = flattened(item, self.defs)
                if not same(f, item):
                    self.note(doc.path, "stale-label", "%s re-stamped from the %s definition" % (emit_str(item["text"]), item["kind"]["type"]))
                    out.append(f); changed = True
                    continue
            out.append(item)

        # one value of each single kind, the first in file order
        seen, kept, gone = set(), [], {}
        for item in out:
            if entry_of(item):
                t = canon(item["kind"]["type"])
                d = self.defs.get(t)
                if d and d["single"]:
                    if t in seen:
                        gone.setdefault(t, []).append(item); continue
                    seen.add(t)
            kept.append(item)
        if gone:
            changed = True
            for t, went in gone.items():
                first = next(i for i in kept if entry_of(i) and canon(i["kind"]["type"]) == t)
                names = ", ".join("`%s`" % w["text"] for w in went)
                self.note(doc.path, "single-kind", "kept %s of single kind `%s`, dropped %s" % (emit_str(first["text"]), t, names))
                dropped_facts.append("This board defines `%s` as a `single` kind, and this card carried %s of them in `labels`; the first in the list is what remains. Kept `%s`; dropped %s." % (t, spelled(len(went) + 1), first["text"], names))
            dropped_facts.insert(0, "```yaml\n" + "\n".join(doc.raw_lines("labels") or []) + "\n```")
        if changed:
            if kept:
                doc.set("labels", emit_key("labels", kept))
            else:
                doc.remove("labels")
        return changed, dropped_facts

    def heal_file(self, path, role, added=()):
        try:
            doc = Doc(path)
        except (ParseError, UnicodeDecodeError, OSError) as e:
            self.skips.append((self.rel(path), "unreadable: %s" % e)); return
        mark = len(self.repairs)
        changed = self.heal_title(doc)
        try:
            changed = self.heal_stamps(doc) or changed
            facts = []
            changed = self.heal_retired_keys(doc, facts) or changed
            if role == "board":
                changed = self.heal_config(doc, added) or changed
            if role == "card":
                c, more = self.heal_labels(doc, os.path.dirname(path))
                changed = c or changed
                facts += more
        except ParseError as e:
            del self.repairs[mark:]
            self.skips.append((self.rel(path), "frontmatter does not parse (%s): left as written" % e)); return
        if not changed:
            return
        self.writes.append((path, doc.text()))
        if facts:
            self.records.append((card_of(self.board, path), facts))


# ---------------------------------------------------------------- the board walk

UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")


def card_of(board, path):
    """The card folder a document belongs to (a card, its comments, their attachments), or None."""
    parts = os.path.relpath(os.path.dirname(path), board).split(os.sep)
    return os.path.join(board, parts[0], parts[1]) if len(parts) >= 2 and UUID.fullmatch(parts[1]) else None


def uuid_dirs(d):
    try:
        names = sorted(os.listdir(d))
    except OSError:
        return []
    return [os.path.join(d, n) for n in names if UUID.fullmatch(n) and os.path.isfile(os.path.join(d, n, "index.md"))]


def documents(board):
    """(path, role) for every live document; .trash/ and the comment drafts are never walked."""
    yield os.path.join(board, "index.md"), "board"
    for lane in uuid_dirs(board):
        yield os.path.join(lane, "index.md"), "lane"
        for a in uuid_dirs(os.path.join(lane, "attachments")):
            yield os.path.join(a, "index.md"), "attachment"
        for card in uuid_dirs(lane):
            yield os.path.join(card, "index.md"), "card"
            for a in uuid_dirs(os.path.join(card, "attachments")):
                yield os.path.join(a, "index.md"), "attachment"
            for c in uuid_dirs(os.path.join(card, "comments")):
                yield os.path.join(c, "index.md"), "comment"
                for a in uuid_dirs(os.path.join(c, "attachments")):
                    yield os.path.join(a, "index.md"), "attachment"


def config_labels(path, key):
    try:
        cfg = Doc(path).get("config")
    except (OSError, ParseError, UnicodeDecodeError):
        return []
    entries = cfg.get(key) if isinstance(cfg, dict) else None
    return [normalize_definition(e)[0] for e in entries] if isinstance(entries, list) else []


def used_root_kinds(paths):
    used = set()
    for p in paths:
        try:
            doc = Doc(p)
            for k in RESERVED_KINDS:
                if doc.has(k) and doc.get(k) is not None:
                    used.add(k)
            items = doc.get("labels") if doc.has("labels") else None
        except (ParseError, UnicodeDecodeError, OSError):
            continue
        for i in items if isinstance(items, list) else []:
            n = normalize_entry(i)[0]
            if entry_of(n) and canon(n["kind"]["type"]) in RESERVED_KINDS:
                used.add(canon(n["kind"]["type"]))
    return used


def move_in(src, dst, board):
    """Rename a staged file or folder into the board; across volumes, restage beside the board (still outside it) first."""
    try:
        os.replace(src, dst)
    except OSError:
        near = tempfile.mkdtemp(prefix=".lanework-heal-", dir=os.path.dirname(os.path.abspath(board)))
        try:
            shutil.move(src, os.path.join(near, "x"))
            os.replace(os.path.join(near, "x"), dst)
        finally:
            shutil.rmtree(near, ignore_errors=True)


def stage_and_move(board, files):
    """Write each (path, text) to a staging dir outside the board, then rename it into place."""
    stage = tempfile.mkdtemp(prefix="lanework-heal-")
    try:
        for n, (path, text) in enumerate(files):
            tmp = os.path.join(stage, str(n))
            with open(tmp, "w", encoding="utf-8", newline="") as f:
                f.write(text)
            move_in(tmp, path, board)
    finally:
        shutil.rmtree(stage, ignore_errors=True)


def new_id():
    try:
        return subprocess.run(["uuidgen"], capture_output=True, text=True, check=True).stdout.strip().lower()
    except (OSError, subprocess.CalledProcessError):
        return str(uuid.uuid4())


def post_record(board, card_dir, facts, at, by):
    cid = new_id()
    body = "**Healed this card: a repair dropped what is quoted below.**\n\n" + "\n\n".join(facts) + \
        "\n\nRun by `heal-board.py`. Nothing else changed and no `modified` was stamped: a heal is upkeep, not an edit.\n"
    text = "---\nschema: 1\nkind: comment\n" + emit_stamp("created", {"at": at, "by": by}) + "\n" + \
        emit_stamp("modified", {"at": at, "by": by}) + "\n---\n" + body
    stage = tempfile.mkdtemp(prefix="lanework-heal-")
    try:
        os.makedirs(os.path.join(stage, cid))
        with open(os.path.join(stage, cid, "index.md"), "w", encoding="utf-8", newline="") as f:
            f.write(text)
        if not os.path.isfile(os.path.join(card_dir, "index.md")):
            raise SystemExit("card moved during the heal: %s" % card_dir)
        os.makedirs(os.path.join(card_dir, "comments"), exist_ok=True)
        move_in(os.path.join(stage, cid), os.path.join(card_dir, "comments", cid), board)
    finally:
        shutil.rmtree(stage, ignore_errors=True)


def main(argv):
    args = {"apply": False, "name": "claude", "model": None, "session": None, "global": None, "ignore": False, "board": None}
    it = iter(argv)
    for a in it:
        if a == "--apply":
            args["apply"] = True
        elif a in ("--name", "--model", "--session", "--global"):
            args[a[2:]] = next(it, None)
        elif a == "--ignore-board-copy":
            args["ignore"] = True
        elif a in ("-h", "--help"):
            print(__doc__); return 0
        elif args["board"] is None and not a.startswith("-"):
            args["board"] = a
        else:
            print("heal-board: unknown argument %s" % a, file=sys.stderr); return 64
    board = args["board"]
    if not board or not os.path.isfile(os.path.join(board, "index.md")):
        print("usage: heal-board.py <board> [--apply --model M [--name N] [--session S]] [--global FILE]", file=sys.stderr)
        return 64
    board = os.path.abspath(board)
    own = os.path.join(board, ".schema", "bin", "lanework-heal.py")
    if os.path.isfile(own) and os.path.realpath(own) != os.path.realpath(__file__) and not args["ignore"]:
        print("heal-board: this board ships its own heal: python3 %s (it wins; --ignore-board-copy to override)" % emit_str(own), file=sys.stderr)
        return 2
    if args["apply"]:
        if not args["model"]:
            print("heal-board: --apply needs --model (the restamp names who healed)", file=sys.stderr); return 64
        if canon(args["name"] or "") in RESERVED_NAMES or not args["name"]:
            print("heal-board: %s is reserved for the app; sign as yourself" % args["name"], file=sys.stderr); return 64

    glob_entries = config_labels(args["global"], "default-labels") if args["global"] else []
    glob_defs = definitions_of(glob_entries)
    board_index = os.path.join(board, "index.md")
    board_defs = definitions_of(config_labels(board_index, "labels"))
    docs = list(documents(board))
    used = used_root_kinds(p for p, r in docs if r == "card")
    added = []
    for s in SUGGESTED:                      # the machine's definition where --global has one, else the suggested
        if s["type"] in used and s["type"] not in board_defs:
            added.append(next((e for e in glob_entries if isinstance(e, dict) and canon(e.get("type", "")) == s["type"]), s))
    defs = {}
    defs.update(glob_defs)
    defs.update(board_defs)
    defs.update(definitions_of(added))

    at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    by = {"name": args["name"], "kind": "agent", "model": args["model"] or "dry-run"}
    if args["session"]:
        by["session"] = args["session"]
    h = Heal(board, defs)
    for path, role in docs:
        h.heal_file(path, role, added if role == "board" else ())

    for rel, code, detail in h.repairs:
        print("%s: %s %s" % (rel, code, detail))
    for rel, why in h.skips:
        print("skip %s: %s" % (rel, why))
    files = len({p for p, _ in h.writes})
    if args["apply"] and h.writes:
        merged = {}
        for card_dir, facts in h.records:        # one record per card, posted before the files it explains
            merged.setdefault(card_dir, []).extend(facts)
        for card_dir, facts in merged.items():
            post_record(board, card_dir, facts, at, by)
        stage_and_move(board, h.writes)
    print("%d repairs in %d files%s" % (len(h.repairs), files,
          "" if args["apply"] else (" (dry run: --apply to write)" if h.repairs else "")))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
