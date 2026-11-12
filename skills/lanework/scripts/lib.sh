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
  [ -r "$1/CLAUDE.md" ] && h=$(grep -o 'human answers to `@[^`]*`' "$1/CLAUDE.md" | head -1 | sed 's/.*`@\([^`]*\)`/\1/')
  printf '%s' "$h"; [ -n "$h" ]
}

# by_of <name> <model> [session]: the stamp's `by` mapping.
by_of() {
  if [ -n "${3:-}" ]; then printf '{name: %s, kind: agent, model: %s, session: "%s"}' "$1" "$2" "$3"
  else printf '{name: %s, kind: agent, model: %s}' "$1" "$2"; fi
}

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

# union_lane_defaults <lane> <board> <staged-fm>: a card born by file into <lane> starts with the lane's card-defaults.labels (guide § Frontmatter, lanes).
# Rewrites the staged frontmatter's `labels`: the card's own entries as written, then the lane's that it lacks. A bare name = a free label, a kinded
# entry = stamped from the board's current config.labels (an undefined kind stays as written). A default is dropped when the card has the same text and
# kind (case-insensitive), or its own value of a `single` kind; several lane values of one `single` kind keep one (lowest rank, a ranked entry before an
# unranked, else the first). No card-defaults or no labels in it: the file is left untouched. A card-defaults that is not a mapping, or labels that are
# neither a list nor one name: message on stderr, exit 1, nothing written, by this card's ruling (the app would ignore the value and still make
# the card). A bare number or boolean is the label's text as typed. Unreadable single items are skipped. The heal's label model, loaded by path.
# Run it after `render`, before compact_fm; never on a move.
union_lane_defaults() {
  python3 -B - "$LIB_DIR/heal-board.py" "$1" "$2" "$3" <<'EOF'   # -B: no __pycache__ in the skill tree
import importlib.util, os, sys
spec = importlib.util.spec_from_file_location("heal_board", sys.argv[1]); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
lane, board, staged = sys.argv[2:5]
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
try:
    cfg = hb.Doc(os.path.join(board, "index.md")).get("config")
except (OSError, hb.ParseError, UnicodeDecodeError) as e:
    die("%s: unreadable board: %s" % (board, e))
if isinstance(cfg, dict) and cfg.get("labels") is not None and not isinstance(cfg["labels"], list):
    die("%s: config.labels is not a list" % board)
defs = hb.definitions_of(hb.config_labels(os.path.join(board, "index.md"), "labels"))
doc = hb.Doc(staged)
own = doc.get("labels") if doc.has("labels") else []
if own is None:
    own = []
if not isinstance(own, list):
    die("%s: labels is not a list" % staged)
def key(e):
    return (hb.canon(e["text"]), hb.canon(e["kind"]["type"]))
have, single_have = set(), set()
for item in own:
    n = hb.normalize_entry(item)[0]
    if hb.entry_of(n):
        have.add(key(n))
        d = defs.get(hb.canon(n["kind"]["type"]))
        if d and d["single"]:
            single_have.add(hb.canon(n["kind"]["type"]))
cands, seen, best = [], set(), {}
for item in raw:
    n = hb.normalize_entry(item)[0]
    if not hb.entry_of(n):
        continue
    k, t = key(n), hb.canon(n["kind"]["type"])
    if k in have or k in seen:
        continue
    d = defs.get(t)
    if d and d["single"] and t in single_have:
        continue
    seen.add(k)
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
