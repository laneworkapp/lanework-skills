#!/bin/bash
# smoke.sh: run every skill script against throwaway boards; validate with a board's schema.
# usage: tests/smoke.sh [<scratch dir>]   (default: a fresh mktemp dir, removed on success)
# The validator is borrowed from the Skills Pipeline board's app-installed .schema/.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; SK="$ROOT/skills"
VAL="$ROOT/Boards/Skills Pipeline.lanework/.schema"
T="${1:-$(mktemp -d "${TMPDIR:-/tmp}/lanework-smoke.XXXXXX")}"
pass=0
ok() { pass=$((pass+1)); echo "ok $pass - $1"; }
validate() {
  local out; out=$(python3 "$VAL/bin/lanework-validate.py" --schema "$VAL" "$1")
  grep -q '^failures    0 ' <<<"$out" && ! grep -q DEPRECATED <<<"$out" || { echo "$out"; return 1; }
  grep -o 'documents   [0-9]*' <<<"$out"
}

# flowed <file>: the frontmatter's config and labels, each on one unquoted flow line (a "#" string quoted), whatever
# layout the compact form gave them, so a check can grep a catalog row or a template's entry as written there
flowed() { python3 - "$1" <<'PY'
import sys, yaml
d = yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])
def f(v):
    if isinstance(v, dict): return "{" + ", ".join("%s: %s" % (k, f(x)) for k, x in v.items()) + "}"
    if isinstance(v, list): return "[" + ", ".join(f(x) for x in v) + "]"
    if isinstance(v, bool): return "true" if v else "false"
    return '"%s"' % v if str(v).startswith("#") else str(v)
for k in ("config", "labels"):
    if k in d: print("%s: %s" % (k, f(d[k])))
PY
}
# same_doc <a> <b>: the same frontmatter values (id and stamps aside) and the same body, whatever the layout
same_doc() { python3 - "$1" "$2" <<'PY'
import sys, yaml
def read(p):
    _, fm, body = open(p).read().split("---\n", 2)
    d = yaml.safe_load(fm)
    for k in ("id", "created", "modified"): d.pop(k, None)
    return d, body
a, b = read(sys.argv[1]), read(sys.argv[2])
sys.exit(0 if a == b else 1)
PY
}

for s in "$SK"/*/scripts/*.sh "$ROOT"/scripts/*.sh; do case "$(head -1 "$s")" in *zsh*) zsh -n "$s" ;; *) bash -n "$s" ;; esac; done
for s in "$SK"/*/scripts/*.py; do [ -e "$s" ] || continue; python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])' "$s"; done
ok "syntax check on every script, by its shebang"

# names: the racing names and the retired dispatch are gone; no skill folder or plugin.json entry may carry them
for n in pitlane pitwall dispatch; do
  [ ! -e "$SK/$n" ] || { echo "skill folder skills/$n still exists (renamed to work and watch, or retired)"; exit 1; }
  if grep -q "\"./skills/$n\"" "$ROOT/.claude-plugin/plugin.json"; then echo "plugin.json still lists skills/$n"; exit 1; fi
done
! grep -q dispatch "$ROOT/.claude-plugin/plugin.json" || { echo "plugin.json still names dispatch"; exit 1; }
ok "no skill folder or plugin.json entry is named pitlane, pitwall or dispatch"

# folder convention: Lanework/ first, then Boards/, then legacy Pitlane/; the legacy name lives only in finding.md
hits=$(grep -rn Pitlane "$SK" || true)
[ -z "$hits" ] || [ -z "$(grep -v '^[^:]*/lanework/references/finding\.md:[0-9]*:.*legacy' <<<"$hits")" ] \
  || { echo "Pitlane named outside finding.md's legacy entry:"; echo "$hits"; exit 1; }
F="$SK/lanework/references/finding.md"
l=$(grep -n 'Lanework/' "$F" | head -1 | cut -d: -f1); b=$(grep -n 'Boards/' "$F" | head -1 | cut -d: -f1)
[ -n "$l" ] && [ -n "$b" ] && [ "$l" -lt "$b" ] || { echo "finding.md must name Lanework/ before Boards/"; exit 1; }
[ "$(grep -o 'for f in [A-Za-z ]*;' "$F" | head -1)" = "for f in Lanework Boards Pitlane;" ] || { echo "finding.md's find loop must run Lanework Boards Pitlane in that order"; exit 1; }
ok "legacy folder name only in finding.md, which lists Lanework/ first, in the table and the find loop"

# fm_parses <file>: the frontmatter parses as YAML (a mapping)
fm_parses() { python3 -c 'import sys, yaml; d = yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1]); sys.exit(not isinstance(d, dict))' "$1" 2>/dev/null; }

# lanework: pipeline founding + reading
P="$T/Acme Pipeline.lanework"
"$SK/lanework/scripts/found-board.sh" "$P" --index "$SK/lanework/templates/pipeline-index.md" \
  --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Acme --var verified='`make check`' --model smoke >/dev/null
[ "$("$SK/lanework/scripts/read-board.sh" "$P" | grep -c '^== ')" -eq 8 ]; ok "pipeline founded, 8 lanes read"
grep -q 'Verified means\*\* `make check`, run on the current head' "$P/index.md"; ok "pipeline vars rendered"
lane_of() { grep -l "^title: \"$2\"$" "$1"/*/index.md; }
[ "$(grep -x 'icon: .*' "$(lane_of "$P" Issues)")" = 'icon: {glyph: exclamationmark.triangle, color: carnation}' ] && [ "$(grep '^icon:' "$(lane_of "$P" Ideas)")" = 'icon: {glyph: lightbulb}' ] \
  && [ "$(grep -l '^icon: ' "$P"/*/index.md | grep -c .)" -eq 8 ]; ok "pipeline lanes carry their template icons (Issues tinted, Ideas plain, all 8 set)"
validate "$P" >/dev/null; ok "pipeline board validates"
L=$(grep -l '^title: "Ideas"$' "$P"/*/index.md); if grep -q '^collapsed:' "$L"; then exit 1; fi
tail -1 "$L" | grep -q '^The inbox and triage queue'
ok "empty collapsed cell keeps the lane body in place"
for k in design-loop:6 datapoint:5; do
  B="$T/${k%:*}.lanework"; sed 's/<SF Symbol>/square.grid.2x2/; s/^<.*>$/Test board./; s/^- <.*>$/- Test rule./' "$SK/lanework/templates/index.md" > "$T/idx.md"
  "$SK/lanework/scripts/found-board.sh" "$B" --index "$T/idx.md" --lanes "$SK/lanework/templates/${k%:*}-lanes.md" --model smoke >/dev/null
  [ "$("$SK/lanework/scripts/read-board.sh" "$B" | grep -c '^== ')" -eq "${k#*:}" ]; validate "$B" >/dev/null
done; ok "design-loop (6 lanes) and datapoint (5) founded from templates, validate"
L=$(grep -l '^title: "Dead ends"$' "$T/design-loop.lanework"/*/index.md); grep -q '^collapsed: true$' "$L"; tail -1 "$L" | grep -q '^Directions th'
grep -qx 'icon: {glyph: xmark.circle}' "$L" && [ "$(grep -l '^icon: ' "$T"/design-loop.lanework/*/index.md | grep -c .)" -eq 6 ]
if grep -q "^icon:" "$T"/datapoint.lanework/*/index.md; then exit 1; fi
ok "collapsed: yes lane starts collapsed with its body; design-loop lanes carry icons, datapoint lanes none"
X="$T/broken.lanework"; cp -R "$P" "$X"; f=$(ls "$X"/*/index.md | head -1); sed -i '' 's/^title: .*/title: a: b/' "$f"
if validate "$X" >/dev/null 2>&1; then echo "validator passed a broken board"; exit 1; fi; ok "validator control: a bare-colon title fails"
if "$SK/lanework/scripts/found-board.sh" "$P" --index "$SK/lanework/templates/pipeline-index.md" \
  --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x --model smoke 2>/dev/null; then exit 1; fi
ok "refuses a non-empty board folder"

# lanework: heal-board, one card per kind of damage, on a board with no .schema/
H="$T/Damaged.lanework"; HL="$H/aaaa0000-0000-4000-8000-000000000001"; HEAL="$SK/lanework/scripts/heal-board.py"
STAMP='{at: 2026-10-01T00:00:00Z, by: {name: claude, kind: agent, model: test}}'
mkdir -p "$HL"
cat > "$H/index.md" <<EOF
---
schema: 1
kind: board
title: "Damaged"
id: aaaa0000-0000-4000-8000-000000000000
config:
  show-card-body: 3
  labels:
    - kind: status
      text: Status
      glyph: circle
      single: true
      values: [{text: Open, rank: 1, color: fern}, {value: Closed, rank: 2}]
    - {type: default, text: Label, icon: {glyph: tag}}
    - {type: priority, text: Priority, icon: {glyph: flag}, single: true, values: [{text: Urgent, rank: 0, color: "#C8283C"}, {text: High, rank: 1, color: "#E07A1F", icon: {glyph: exclamationmark}}, {text: Medium, rank: 2}, {text: Low, rank: 3}]}
created:  $STAMP
modified: $STAMP
---
Board body.
EOF
printf -- '---\nschema: 1\nkind: lane\ntitle: "Ideas"\norder: 1024\ncreated:  %s\nmodified: %s\n---\nLane body.\n' "$STAMP" "$STAMP" > "$HL/index.md"
hcard() { mkdir -p "$HL/$1"; { printf -- '---\nschema: 1\nkind: card\n'; cat; printf -- '---\nBody of %s.\n' "$1"; } > "$HL/$1/index.md"; }
hcard c0000000-0000-4000-8000-000000000001 <<EOF
title: "Stale stamp"
labels: [{text: open, rank: 5, color: red, kind: {type: status, text: Status}}]
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000002 <<EOF
title: "Two of a single kind"
labels: [{text: Closed, rank: 2, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Open, rank: 1, color: fern, kind: {type: status, text: Status, icon: {glyph: circle}}}]
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-00000000000e <<EOF
title: "Single kind, the reader's pick"
labels: [{text: Mud, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Zed, rank: 2, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Zed, rank: 1, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Yak, rank: 2, kind: {type: status, text: Status, icon: {glyph: circle}}}]
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-00000000000f <<EOF
title: "Single kind, a quoted rank beats a number"
labels: [{text: Aaa, rank: 3, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Bbb, rank: "1", kind: {type: status, text: Status, icon: {glyph: circle}}}]
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000000 <<EOF
title: "Single kind, a quoted rank beats no rank"
labels: [{text: Mud, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Nib, rank: "2", kind: {type: status, text: Status, icon: {glyph: circle}}}]
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000003 <<EOF
title: "Bare scalar labels"
labels: bug
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000004 <<EOF
title: "String kind"
labels: [{text: closed, kind: status}]
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000005 <<EOF
title: "Root keys"
priority: High
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-00000000000b <<EOF
title: "Root key as a mapping"
priority: {text: High, rank: 1}
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000006 <<EOF
title: "Root key under an entry"
labels: [{text: Low, rank: 3, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]
priority: {text: Urgent, rank: 0}
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000007 <<EOF
title: "Free labels"
labels: [{text: bug}, {text: ux, kind: {type: default, text: Label}}, {text: star, glyph: star, kind: {type: text}}]
created:  $STAMP
modified: $STAMP
modified-by: someone
EOF
hcard c0000000-0000-4000-8000-000000000008 <<EOF
title: Fix: the thing
icon: star
iconColor: fern
created:  {at: 2026-10-01T00:00:00Z, by: claude}
modified: 2026-10-01T00:00:00Z
modified-by: claude
EOF
mkdir -p "$HL/c0000000-0000-4000-8000-000000000008/comments/d0000000-0000-4000-8000-000000000001"
printf -- '---\nschema: 1\nkind: comment\ncreated:  %s\nmodified: %s\n---\nA clean comment.\n' "$STAMP" "$STAMP" \
  > "$HL/c0000000-0000-4000-8000-000000000008/comments/d0000000-0000-4000-8000-000000000001/index.md"
hcard c0000000-0000-4000-8000-00000000000a <<EOF
title: "A long title
  over two lines"
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-00000000000c <<EOF
title: Plain title
# a yaml comment the owner left
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-00000000000d <<EOF
title: Fix #12 bug
created:  $STAMP
modified: $STAMP
EOF
hcard c0000000-0000-4000-8000-000000000009 <<EOF
title: "Clean, with a foreign entry"
labels:
  - {text: Weird, rank: 9, kind: {type: alien, text: Alien}}
  - {text: bug, kind: {type: text, text: Text, icon: {glyph: tag}}}
project: x
created:  $STAMP
modified: $STAMP
EOF
cp -R "$H" "$T/heal-seed"
sum() { find "$1" -type f -print0 | sort -z | xargs -0 shasum | shasum; }
if validate "$H" >/dev/null 2>&1; then echo "seeded damage passed the validator"; exit 1; fi
S0=$(sum "$H"); O=$("$HEAL" "$H")
for k in stale-label single-kind bare-labels string-kind root-key root-key-dropped text-kind bare-glyph bare-stamp title-quote definition bare-icon retired-key; do   # added-definition: the Solo case below
  grep -q " $k " <<<"$O" || { echo "dry run did not list $k:"; echo "$O"; exit 1; }
done
[ "$S0" = "$(sum "$H")" ]; ok "heal dry run lists every kind of damage and writes nothing"
"$HEAL" "$H" --apply --name fixer --model test >/dev/null; validate "$H" >/dev/null
hfail() { echo "heal check failed: $1"; exit 1; }
c() { sed -n '2,/^---$/p' "$HL/c0000000-0000-4000-8000-00000000000$1/index.md"; }
c 1 | grep -qF 'labels: [{text: "Open", rank: 1, color: "fern", kind: {type: "status", text: "Status", icon: {glyph: "circle"}}}]' || hfail stale-label
c f | grep -q '^labels: \[{text: "Bbb"' && ! c f | grep -q Aaa && grep -q 'Kept `Bbb`; dropped `Aaa`' "$HL"/c*0f/comments/*/index.md || hfail single-kind-quoted-rank
c 0 | grep -q '^labels: \[{text: "Nib"' && ! c 0 | grep -q Mud && grep -q 'Kept `Nib`; dropped `Mud`' "$HL"/c*00/comments/*/index.md || hfail single-kind-quoted-vs-unranked
c 2 | grep -q '^labels: \[{text: "Open"' && ! c 2 | grep -q Closed && grep -q 'Kept `Open`; dropped `Closed`' "$HL"/c*02/comments/*/index.md || hfail single-kind
c e | grep -q '^labels: \[{text: "Zed", rank: 2' && ! c e | grep -q 'Mud\|Yak\|rank: 1' && grep -q 'Kept `Zed`; dropped `Mud`, `Zed`, `Yak`' "$HL"/c*0e/comments/*/index.md || hfail single-kind-reader-pick
c 3 | grep -qF 'labels: [{text: "bug", kind: {type: "text", text: "Text", icon: {glyph: "tag"}}}]' || hfail bare-labels
c 4 | grep -qF '{text: "Closed", rank: 2, kind: {type: "status"' || hfail string-kind
for p in 'text: "High"' 'rank: 1' 'color: "#E07A1F"' 'glyph: "exclamationmark"' 'type: "priority"'; do
  c 5 | grep -qF "$p" || hfail "root-key ($p)"; done
flowed "$HL/c0000000-0000-4000-8000-00000000000b/index.md" | grep -qF 'labels: [{text: High, rank: 1, color: "#E07A1F", icon: {glyph: exclamationmark}, kind: {type: priority' && grep -q 'c0000000-0000-4000-8000-00000000000b/index.md: root-key ' <<<"$O" || hfail root-key-mapping
! c 5 | grep -q '^priority:' && ! c b | grep -q '^priority:' && ! c 6 | grep -q '^priority:' && c 6 | grep -q 'text: "Low"' && ! c 6 | grep -q Urgent \
  && grep -q 'because `labels` already carries a `priority` entry, `Low`' "$HL"/c*06/comments/*/index.md || hfail root-key-dropped
c 7 | grep -qF '{text: "ux", kind: {type: "text"' && c 7 | grep -qF '{text: "star", icon: {glyph: "star"}, kind:' && ! c 7 | grep -q default || hfail text-kind/bare-glyph
c 8 | grep -qxF 'title: "Fix: the thing"' && c 8 | grep -qF 'created:  {at: 2026-10-01T00:00:00Z, by: {name: claude}}' || hfail title-quote/bare-stamp
c 8 | grep -qxF 'modified: {at: 2026-10-01T00:00:00Z, by: {name: claude}}' || hfail retired-key-fold
c 8 | grep -qxF 'icon: {glyph: "star", color: "fern"}' && ! c 8 | grep -q 'iconColor\|modified-by' || hfail bare-icon/retired-key
! c 7 | grep -q modified-by && grep -q 'modified-by: someone' "$HL"/c*07/comments/*/index.md || hfail retired-key-record
for n in 1 2 3 4 5 6 7 a; do c $n | grep -qxF "modified: $STAMP" || hfail "no restamp on card $n"; done
c c | grep -qxF 'title: "Plain title"' && c c | grep -qxF '# a yaml comment the owner left' || hfail comment-line
for n in 1 5; do f="${HL##*/}/c0000000-0000-4000-8000-00000000000$n/index.md"
  [ "$(awk 'n>=2{print} /^---$/{n++}' "$H/$f")" = "$(awk 'n>=2{print} /^---$/{n++}' "$T/heal-seed/$f")" ] || hfail "body of card $n"; done
c a | grep -qxF 'title: "A long title over two lines"' || hfail title-fold
sed -n '/^config:/,/^created:/p' "$H/index.md" | grep -q 'type: "priority"' && ! grep -q 'component' "$H/index.md" && ! grep -q 'default\|glyph: circle$\|value:' "$H/index.md" || hfail definition
ok "heal --apply repairs each one and the board validates with no DEPRECATED line"
grep -q "^modified: $STAMP$" "$HL"/c*08/comments/d*/index.md && grep -q 'type: alien' "$HL"/c*09/index.md && grep -q '^project: x$' "$HL"/c*09/index.md && grep -q "^modified: $STAMP$" "$HL"/c*09/index.md \
  && grep -q "^modified: $STAMP$" "$HL/index.md" && grep -q "^modified: $STAMP$" "$H/index.md" \
  && cmp -s "$HL"/c*0d/index.md "$T/heal-seed/${HL##*/}"/c*0d/index.md && grep -q '^skip .*c0000000-0000-4000-8000-00000000000d.* #' <<<"$O" || hfail untouched
ok "heal leaves a clean card, a foreign entry, an unknown key, a \` #\` title and every stamp as written"
S1=$(sum "$H"); O=$("$HEAL" "$H" --apply --name fixer --model test); [ "$S1" = "$(sum "$H")" ] && grep -q '^0 repairs' <<<"$O" || { echo "$O"; exit 1; }
ok "a second heal --apply changes nothing"
HG="$T/Global.lanework"; cp -R "$T/heal-seed" "$HG"; printf -- '---\nschema: 1\nkind: config\nconfig:\n  default-labels: []\n---\n' > "$T/machine-config.md"; SG=$(sum "$HG")
RC=0; "$HEAL" "$HG" --apply --name fixer --model test --global "$T/machine-config.md" 2>/dev/null || RC=$?
[ "$RC" = 64 ] && [ "$SG" = "$(sum "$HG")" ] || { echo "--global: exit $RC, board changed or not"; exit 1; }
ok "heal-board no longer takes --global: exit 64, the damaged board untouched"
# a block scalar holding an indented `---` (outside the validator's dialect, so a board of its own)
H3="$T/Block.lanework"; HL3="$H3/aaaa0000-0000-4000-8000-000000000001"; mkdir -p "$HL3"
cp "$H/index.md" "$H3/index.md"; cp "$HL/index.md" "$HL3/index.md"; HLs="$HL"; HL="$HL3"
hcard c0000000-0000-4000-8000-00000000000b <<EOF
title: Block scalar, damage below it
notes: |
  line one
  ---
  more
labels: bug
created:  $STAMP
modified: $STAMP
EOF
HL="$HLs"; cp "$HL3"/c*0b/index.md "$T/block-seed.md"
"$HEAL" "$H3" --apply --name fixer --model test >/dev/null; F3=$(ls "$HL3"/c*0b/index.md)
grep -qxF 'title: "Block scalar, damage below it"' "$F3" && grep -qF 'labels: [{text: "bug"' "$F3" && [ "$(grep -c '^modified:' "$F3")" = 1 ] \
  && [ "$(sed -n '/^notes: |$/,/^  more$/p' "$F3")" = "$(printf 'notes: |\n  line one\n  ---\n  more')" ] \
  && [ "$(awk 'n>=2{print} /^---$/{n++}' "$F3")" = "$(awk 'n>=2{print} /^---$/{n++}' "$T/block-seed.md")" ] || hfail block-scalar
ok "an indented --- inside a block scalar does not end the frontmatter; the labels below it heal"
H2="$T/Damaged copy.lanework"; cp -R "$T/heal-seed" "$H2"; cp -R "$VAL" "$H2/.schema"
rm -f "$H2/.schema/bin/lanework-heal.py"   # this case tests the skill's heal against the board's validator; the board-heal case is next
"$HEAL" "$H2" --apply --name fixer --model test >/dev/null
V=$(python3 "$H2/.schema/bin/lanework-validate.py" "$H2"); grep -q '^failures    0 ' <<<"$V" && ! grep -q DEPRECATED <<<"$V" || { echo "$V"; exit 1; }
ok "a board with its own .schema/ heals the same, against its own validator"
cp -R "$VAL" "$H/.schema"; touch "$H/.schema/bin/lanework-heal.py"
if "$HEAL" "$H" 2>/dev/null; then echo "skill copy ran where the board ships its own"; exit 1; fi
ok "heal defers to the board's own .schema/bin/lanework-heal.py"

# heal-board compact-collection (the board heal's H17): one card per layout case
layout_board() {
  local B="$1" L="$1/aaaa0000-0000-4000-8000-0000000000a1"; mkdir -p "$L"
  printf -- '---\nschema: 1\nkind: board\ntitle: "Layout"\nid: aaaa0000-0000-4000-8000-0000000000a0\nconfig:   # the owner'"'"'s note\n  show-card-body: 3\ncreated:  %s\nmodified: %s\n---\nBody.\n' "$STAMP" "$STAMP" > "$B/index.md"
  printf -- '---\nschema: 1\nkind: lane\ntitle: "Lane"\norder: 1024\ncreated:  %s\nmodified: %s\n---\nLane.\n' "$STAMP" "$STAMP" > "$L/index.md"
  lcard() { mkdir -p "$L/$1"; { printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\norder: 1024\n' "$2"; cat; printf -- '---\nBody.\n'; } > "$L/$1/index.md"; }
  lcard c0000000-0000-4000-8000-0000000000a1 "Verbose labels" <<EOF
labels:
  - text: "Low"
    kind:
      type: "text"
      text: "Text"
      icon: {glyph: "tag"}
created:  $STAMP
modified: $STAMP
EOF
  lcard c0000000-0000-4000-8000-0000000000a2 "Stamp over lines" <<EOF
created:
  at: 2026-10-01T00:00:00Z
  by: {name: claude, kind: agent, model: "on", session: "Yes"}
modified: $STAMP
EOF
  lcard c0000000-0000-4000-8000-0000000000a3 "Comment inside" <<EOF
labels:
  # kept as written
  - {text: "a", kind: {type: "text", text: "Text", icon: {glyph: "tag"}}}
created:  $STAMP
modified: $STAMP
EOF
  lcard c0000000-0000-4000-8000-0000000000a4 "Block scalar" <<EOF
notes: |
  one
  two
created:  $STAMP
modified: $STAMP
EOF
  lcard c0000000-0000-4000-8000-0000000000a5 "Already compact" <<EOF
labels: [{text: "a", kind: {type: "text", text: "Text", icon: {glyph: "tag"}}}]   # trailing note
created:  $STAMP
modified: $STAMP
EOF
  lcard c0000000-0000-4000-8000-0000000000a6 "Plain time in a collection" <<EOF
waiting:
  for: rzen
  since: 2026-10-01T00:00:00Z
  comment: "c0000000-0000-4000-8000-0000000000ff"
created:  $STAMP
modified: $STAMP
EOF
}
HY="$T/Layout.lanework"; layout_board "$HY"; cp -R "$HY" "$T/layout-seed"; HYL="$HY/aaaa0000-0000-4000-8000-0000000000a1"
O=$("$HEAL" "$HY")
for w in 'index.md: compact-collection config written in the compact form, 2 lines to 1' \
  'c0000000-0000-4000-8000-0000000000a1/index.md: compact-collection labels written in the compact form, 6 lines to 1' \
  'c0000000-0000-4000-8000-0000000000a2/index.md: compact-collection created written in the compact form, 3 lines to 1' \
  'c0000000-0000-4000-8000-0000000000a6/index.md: compact-collection waiting written in the compact form, 4 lines to 1' \
  '^4 repairs in 4 files'; do grep -q -- "$w" <<<"$O" || { echo "compact-collection dry run lacks: $w"; echo "$O"; exit 1; }; done
"$HEAL" "$HY" --apply --name fixer --model test >/dev/null
grep -qxF "config: {show-card-body: 3}   # the owner's note" "$HY/index.md" \
  && grep -qxF 'labels: [{text: "Low", kind: {type: "text", text: "Text", icon: {glyph: "tag"}}}]' "$HYL"/c*a1/index.md \
  && grep -qxF 'created:  {at: 2026-10-01T00:00:00Z, by: {name: claude, kind: agent, model: "on", session: "Yes"}}' "$HYL"/c*a2/index.md \
  && grep -qxF 'waiting: {for: "rzen", since: 2026-10-01T00:00:00Z, comment: "c0000000-0000-4000-8000-0000000000ff"}' "$HYL"/c*a6/index.md \
  || { cat "$HY/index.md" "$HYL"/c*a[126]/index.md; echo "compact-collection: wrong rewrite"; exit 1; }
for c in a3 a4 a5; do cmp -s "$HYL"/c*$c/index.md "$T/layout-seed/${HYL##*/}"/c*$c/index.md || { echo "compact-collection touched card $c"; exit 1; }; done
grep -q '^0 repairs' <<<"$("$HEAL" "$HY")" || { echo "compact-collection: not idempotent"; exit 1; }
for f in "$HY/index.md" "$HYL"/c*a[12356]/index.md; do v=$(python3 "$VAL/bin/lanework-validate.py" --schema "$VAL" "$f") && ! grep -q 'FAIL\|DEPRECATED' <<<"$v" || { echo "compact-collection: $f fails validation: $v"; exit 1; }; done   # a4: a block scalar, outside the validator's dialect
ok "heal: a list or mapping in another layout is rewritten compact, key-line comment kept; a comment inside, a block scalar, a compact key left alone"
HZ="$T/Layout board-heal.lanework"; cp -R "$T/layout-seed" "$HZ"; python3 "$VAL/bin/lanework-heal.py" "$HZ" --apply --name fixer --model test >/dev/null
diff <(cd "$HY" && find . -type f | sort | xargs sed -E 's/^(created|modified): +/\1: /') \
  <(cd "$HZ" && find . -type f | sort | xargs sed -E 's/^(created|modified): +/\1: /') >/dev/null \
  || { echo "skill heal and the board's lanework-heal.py disagree on compact-collection"; exit 1; }
ok "heal's compact-collection matches the board's own heal (H17) byte for byte, stamp spacing aside"

# discovery: found, file, settle, park
D="$T/Sync: v2 Discovery.lanework"
"$SK/discovery/scripts/found-discovery-board.sh" "$D" --model smoke >/dev/null
grep -q '^title: "Sync: v2 Discovery"$' "$D/index.md" && grep -q '^Discovery on Sync: v2:' <(sed -n '/^# /,$p' "$D/index.md" | sed -n 3p)
[ "$(grep -l '^icon: ' "$D"/*/index.md | grep -c .)" -eq 6 ] && grep -qx 'icon: {glyph: questionmark.bubble, color: smokey-tangerine}' "$(grep -l '^title: "Asked"$' "$D"/*/index.md)"
ok "discovery founded; colon title quoted; topic rendered; lanes carry icons"
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/q1.md"
printf 'Where does it run?\n\n## Options\n\n- A: app\n- B: service\n\n## Recommended\n\nA. No server.\n' > "$T/q2.md"
O1=$("$SK/discovery/scripts/file-question.sh" "$D" "Pricing" --round 1 --body "$T/q1.md" --model smoke 2>&1)
O2=$("$SK/discovery/scripts/file-question.sh" "$D" "Engine: placement" --round 1 --body "$T/q2.md" --depends "[Q1](lanework://x/y)" --model smoke 2>&1)
grep -q 'lint-ask warning\|warning: no lint-ask.sh' <<<"$O1$O2" && { echo "$O1$O2"; exit 1; }
C1=$(head -1 <<<"$O1" | sed 's#.*/##'); A1=$(sed -n 's/^ask comment //p' <<<"$O1"); C2=$(head -1 <<<"$O2" | sed 's#.*/##')
grep -q '^title: "Q2: Engine: placement"$' "$D"/*/"$C2"/index.md; ok "Q1, Q2 filed, numbered, asks lint clean"
printf '**2026-09-27**: A, as recommended.\n' > "$T/r1.md"; printf '**Owner answered in chat.** "A."\n' > "$T/rec.md"
# several people, past 120 characters: the compact form writes waiting as a block (lanework/scripts/lib.sh compact_fm, the heal's H17)
CF1="$(ls "$D"/*/"$C1"/index.md)"; perl -0pi -e 's/^waiting: \{for: [^,]*, since: ([^,]*), comment: ([^}]*)\}\n/waiting:\n  for: [owner, bobsmith, carol, dave]\n  since: $1\n  comment: $2\n/m' "$CF1"; grep -q '^  for: \[owner, bobsmith, carol, dave\]$' "$CF1"
"$SK/discovery/scripts/settle-question.sh" "$D" "$C1" --ruling "$T/r1.md" --record "$T/rec.md" --reply "$A1" --model smoke >/dev/null
"$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --model smoke >/dev/null
CF1="$(ls "$D"/*/"$C1"/index.md)"; { ! grep -q -E '^(waiting:|  (for|since|comment):)' "$CF1" && fm_parses "$CF1" && grep -q "in-reply-to: $A1" "$D"/*/"$C1"/comments/*/index.md; } \
  || { echo "settle-question left waiting, or its block lines, or a frontmatter that does not parse:"; head -12 "$CF1"; exit 1; }
ok "settled with chat record in reply to the ask, a block-form list waiting dropped whole; parked"
validate "$D" >/dev/null; ok "discovery board validates"

# discovery: Decisions lane founded in order, record + status kinds declared, file-record.sh files ADR and PDR cards
lane_order() { sed -n 's/^order: //p' "$(grep -l "^title: \"$1\"\$" "$D"/*/index.md | head -1)"; }
[ "$(lane_order Settled)" = 4096 ] && [ "$(lane_order Decisions)" = 4608 ] && [ "$(lane_order Parked)" = 5120 ] || { echo "Decisions lane missing or out of order"; exit 1; }
ok "Decisions lane founded at 4608, between Settled and Parked"
DF=$(flowed "$D/index.md"); { grep -q '{type: round, text: Round, single: true}' <<<"$DF" &&
  grep -q '{type: record, text: Record, single: true, values: \[{text: ADR, rank: 1}, {text: PDR, rank: 2}\]}' <<<"$DF" &&
  grep -q '{type: status, text: Status, single: true, values: \[{text: accepted, rank: 1}, {text: deprecated, rank: 2}, {text: superseded, rank: 3}\]}' <<<"$DF"; } || { echo "record/status label kinds missing from config.labels"; exit 1; }
ok "board config declares the round, record and status label kinds"
printf 'Is sync metered [beta]?\n\n## Options\n\n- A: no\n- B: yes\n\n## Recommended\n\nA. Simple.\n' > "$T/q3.md"
O3=$("$SK/discovery/scripts/file-question.sh" "$D" "Metering" --round 2 --body "$T/q3.md" --model smoke 2>&1)
C3=$(head -1 <<<"$O3" | sed 's#.*/##')
printf 'Sync is free for every user, because a paid tier would split the support load.\n\n## Considered options\n\n- Paid tier: rejected.\n' > "$T/adr.md"
printf 'Sync ships in the base app.\n' > "$T/pdr.md"
R1=$("$SK/discovery/scripts/file-record.sh" "$D" "$C3" --record ADR --title 'Sync engine: C:\sync "v2"
second line' --body "$T/adr.md" --model smoke)
R2=$("$SK/discovery/scripts/file-record.sh" "$D" "$C3" --record PDR --title "Sync is free" --body "$T/pdr.md" --model smoke)
BID=$(sed -n 's/^id: //p' "$D/index.md")
K1=$(head -1 <<<"$R1" | sed 's#.*/##'); K2=$(head -1 <<<"$R2" | sed 's#.*/##')
[ "$(head -1 <<<"$R1")" = "lanework://$BID/$K1" ] || { echo "no link printed: $R1"; exit 1; }
DEC=$(dirname "$(ls -d "$D"/*/"$K1")")
n1="$DEC/$K1/index.md"; n2="$DEC/$K2/index.md"
{ [ "$(grep -m1 '^title:' "$DEC/index.md")" = 'title: "Decisions"' ] &&
  [ "$(grep -m1 '^title:' "$n1")" = 'title: "ADR: Sync engine: C:\\sync \"v2\" second line"' ] &&
  [ "$(grep -m1 '^title:' "$n2")" = 'title: "PDR: Sync is free"' ]; } || { echo "cards not filed into Decisions with prefixed, escaped, one-line titles"; exit 1; }
{ grep -qx 'labels: \[{text: ADR, rank: 1, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}\]' <(flowed "$n1") &&
  grep -qx 'labels: \[{text: PDR, rank: 2, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}\]' <(flowed "$n2"); } || { echo "record/status labels not flattened"; exit 1; }
[ "$(awk '/^---$/ { n++; next } n == 2 && NF { print; exit }' "$n1")" = "Question: [Q3: Metering](lanework://$BID/$C3)" ] || { echo "line 1 does not link the question"; exit 1; }
grep -qx 'Sync is free for every user, because a paid tier would split the support load.' "$n1" && grep -qx -- '- Paid tier: rejected.' "$n1" || { echo "--body did not land in the card"; exit 1; }
[ "$(sed -n 's/^order: //p' "$n2")" -gt "$(sed -n 's/^order: //p' "$n1")" ] || { echo "second card not at the bottom"; exit 1; }
! grep -q '^waiting:' "$n1" || { echo "record card carries waiting"; exit 1; }
ok "file-record.sh filed one ADR and one PDR card in Decisions: title escaped, labels flattened, line 1 links the question, body lands, bottom order"
printf '**2026-09-27**: A.\nADR: [ADR: Sync engine](%s)\nPDR: [PDR: Sync is free](%s)\n' "$(head -1 <<<"$R1")" "$(head -1 <<<"$R2")" > "$T/r3.md"
"$SK/discovery/scripts/settle-question.sh" "$D" "$C3" --ruling "$T/r3.md" --model smoke >/dev/null
SETTLED=$(grep -l '^title: "Settled"$' "$D"/*/index.md | sed 's#/index.md$##')
[ -f "$SETTLED/$C3/index.md" ] &&
  grep -q "^ADR: \[ADR: Sync engine\]($(head -1 <<<"$R1"))\$" "$D"/*/"$C3"/index.md || { echo "settled ruling does not carry the record link"; exit 1; }
ok "record filed before settling; the Settled question's ruling links both cards"
validate "$D" >/dev/null; ok "discovery board validates with the record cards"
for bad in "$C3" .. "$K1" 0000; do
  if "$SK/discovery/scripts/file-record.sh" "$D" "$bad" --record ADR --title x --body "$T/adr.md" --model smoke 2>/dev/null; then echo "accepted question id: $bad"; exit 1; fi
done
O4=$("$SK/discovery/scripts/file-question.sh" "$D" "Open one" --round 2 --body "$T/q3.md" --model smoke 2>&1); C4=$(head -1 <<<"$O4" | sed 's#.*/##')
if "$SK/discovery/scripts/file-record.sh" "$D" "$C4" --record NOPE --title x --body "$T/adr.md" --model smoke 2>/dev/null; then echo "accepted a bad record kind"; exit 1; fi
[ "$(ls -d "$DEC"/*/ | wc -l)" -eq 2 ] || { echo "a refused call wrote a card"; exit 1; }
ok "file-record.sh refuses a settled question, a path, a record card, a short id, and a record kind that is not ADR or PDR"

# discovery: a question title with a backslash, a quote and a newline round-trips and validates
printf 'Is it escaped?\n\n## Options\n\n- A: yes\n- B: no\n\n## Recommended\n\nA. Simple.\n' > "$T/q5.md"
O5=$("$SK/discovery/scripts/file-question.sh" "$D" 'C:\path "x"
tail' --round 2 --body "$T/q5.md" --model smoke 2>&1); C5=$(head -1 <<<"$O5" | sed 's#.*/##')
grep -qxF 'title: "Q5: C:\\path \"x\" tail"' "$D"/*/"$C5"/index.md || { echo "question title not escaped:"; grep -m1 '^title:' "$D"/*/"$C5"/index.md; exit 1; }
validate "$D" >/dev/null; ok "file-question.sh: a title with a backslash, a quote and a newline round-trips and the board validates"

# discovery: file-record.sh --supersedes states a supersedes relation on the new card, never touches the old one
FR="$SK/discovery/scripts/file-record.sh"
SQ() { "$SK/discovery/scripts/file-question.sh" "$D" "$1" --round 2 --body "$T/q3.md" --model smoke 2>&1 | head -1 | sed 's#.*/##'; }
SQ1=$(SQ "Supersede one"); SQ2=$(SQ "Supersede two"); SQ3=$(SQ "Supersede three"); SQ4=$(SQ "Supersede bad")
OLD1="$K1"; OLD2="$K2"
sum_old=$(cksum < "$DEC/$OLD1/index.md")
n_before=$(ls -d "$DEC"/*/ | wc -l)
for bad in "$SQ4" "${OLD1%%-*}" "00000000-0000-4000-8000-000000000000" "$DEC/$OLD1" "$(tr a-f A-F <<<"$OLD1")"; do
  if "$FR" "$D" "$SQ1" --record ADR --title x --body "$T/adr.md" --supersedes "$OLD1" --supersedes "$bad" --model smoke 2>/dev/null; then echo "accepted bad --supersedes: $bad"; exit 1; fi
  [ "$(ls -d "$DEC"/*/ | wc -l)" -eq "$n_before" ] || { echo "refused --supersedes $bad wrote a card"; exit 1; }
done
SR1=$("$FR" "$D" "$SQ1" --record ADR --title "Sync is paid again" --body "$T/adr.md" --supersedes "$OLD1" --model smoke)
[ "$(wc -l <<<"$SR1" | tr -d ' ')" = 1 ] || { echo "stdout is not one line: $SR1"; exit 1; }
SK1=$(sed 's#.*/##' <<<"$SR1")
rels=("$DEC/$SK1"/relations/*/index.md)
[ "${#rels[@]}" -eq 1 ] && [ -f "${rels[0]}" ] || { echo "expected exactly one relation"; exit 1; }
{ grep -qx 'schema: 1' "${rels[0]}" && grep -qx 'kind: relation' "${rels[0]}" && grep -qx 'rel: supersedes' "${rels[0]}" &&
  grep -qx "to: lanework://$BID/$OLD1" "${rels[0]}" && grep -Eq "^created: \{at: [^,]+, by: \{.+\}\}\$" "${rels[0]}"; } || { echo "relation shape wrong:"; cat "${rels[0]}"; exit 1; }
[[ "$(basename "$(dirname "${rels[0]}")")" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]] || { echo "relation dir is not a lowercase uuid"; exit 1; }
[ "$(cksum < "$DEC/$OLD1/index.md")" = "$sum_old" ] && [ ! -e "$DEC/$OLD1/relations" ] || { echo "old card was touched"; exit 1; }
validate "$D" >/dev/null
SR2=$("$FR" "$D" "$SQ2" --record ADR --title "Sync is paid, twice" --body "$T/adr.md" --supersedes "$OLD1" --supersedes "$OLD2" --model smoke)
SK2=$(sed 's#.*/##' <<<"$SR2")
[ "$(ls -d "$DEC/$SK2"/relations/*/ | wc -l)" -eq 2 ] && [ "$(cat "$DEC/$SK2"/relations/*/index.md | grep -c '^rel: supersedes$')" -eq 2 ] || { echo "two --supersedes did not give two relations"; exit 1; }
validate "$D" >/dev/null
ok "file-record.sh --supersedes writes one supersedes relation per target on the new card, refuses question/short/unknown/malformed targets with nothing written, leaves the old card untouched"

# a model is required: each of the four scripts, no --model and no CLAUDE_MODEL, exits 2 and writes nothing
S2=$(sum "$D"); NB="$T/NoModel.lanework"; printf 'r\n' > "$T/rl.md"
refused() { local n="$1"; shift; local rc=0; env -u CLAUDE_MODEL "$@" >/dev/null 2>"$T/err.txt" || rc=$?
  [ "$rc" -eq 2 ] && grep -q "usage" "$T/err.txt" || { echo "$n: want exit 2 with usage, got $rc"; cat "$T/err.txt"; exit 1; }; }
refused file-question "$SK/discovery/scripts/file-question.sh" "$D" "Nomodel" --round 2 --body "$T/q5.md"
refused settle-question "$SK/discovery/scripts/settle-question.sh" "$D" "$C4" --ruling "$T/r1.md"
refused file-record "$SK/discovery/scripts/file-record.sh" "$D" "$C4" --record ADR --title x --body "$T/adr.md"
refused found-board "$SK/lanework/scripts/found-board.sh" "$NB" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x
refused found-discovery-board "$SK/discovery/scripts/found-discovery-board.sh" "$NB"
[ "$S2" = "$(sum "$D")" ] && [ ! -e "$NB" ] || { echo "a refused call wrote something"; exit 1; }
ok "file-question, settle-question, file-record, found-board and found-discovery-board exit 2 with usage and write nothing when no model is given"

# the model comes from --model, else CLAUDE_MODEL, and --model wins
FB="$SK/lanework/scripts/found-board.sh"; FA=(--index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x)
CLAUDE_MODEL=envmodel "$FB" "$T/EnvModel.lanework" "${FA[@]}" >/dev/null
CLAUDE_MODEL=envmodel "$FB" "$T/FlagModel.lanework" "${FA[@]}" --model flagmodel >/dev/null
grep -q 'model: envmodel' "$T/EnvModel.lanework/index.md" && grep -q 'model: flagmodel' "$T/FlagModel.lanework/index.md" && ! grep -q 'model: envmodel' "$T/FlagModel.lanework/index.md" \
  || { echo "model not taken from CLAUDE_MODEL, or --model did not win"; exit 1; }
ok "found-board.sh stamps CLAUDE_MODEL when no --model is given, and --model wins over it"

# a hostile board title and lane title go through title_str and the board validates
printf '| order | title | collapsed | icon | body |\n|---|---|---|---|---|\n| 1024 | L\\x "q" | | | Body. |\n' > "$T/hostile-lanes.md"
"$FB" "$T/Hostile.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$T/hostile-lanes.md" --var project=x --var verified=x --model smoke \
  --title 'a\b "c"
d' >/dev/null
grep -qxF 'title: "a\\b \"c\" d"' "$T/Hostile.lanework/index.md" && grep -qxF 'title: "L\\x \"q\""' "$T/Hostile.lanework"/*/index.md \
  || { echo "hostile titles not escaped:"; grep -h '^title:' "$T/Hostile.lanework/index.md" "$T/Hostile.lanework"/*/index.md; exit 1; }
validate "$T/Hostile.lanework" >/dev/null; ok "found-board.sh: a board and lane title with a backslash, a quote and a newline are escaped and the board validates"
# a line break in a board title (LF, CR, CRLF) leaves the body heading on one line, words joined by one space
for brk in $'\n' $'\r' $'\r\n'; do
  rm -rf "$T/Brk.lanework" "$T/Brk Discovery.lanework"
  "$FB" "$T/Brk.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x --model smoke --title "one${brk}two" >/dev/null
  "$SK/discovery/scripts/found-discovery-board.sh" "$T/Brk Discovery.lanework" "uno${brk}dos" --model smoke >/dev/null
  for pair in "Brk.lanework:one two" "Brk Discovery.lanework:uno dos"; do
    f="$T/${pair%%:*}/index.md"
    [ "$(grep -c '^# ' "$f")" -eq 1 ] && grep -qxF "# ${pair#*:}" "$f" && grep -qxF "title: \"${pair#*:}\"" "$f" \
      || { echo "title with a line break (${#brk} byte) in ${pair%%:*}:"; sed -n '/^---$/,$p' "$f" | head -14; exit 1; }
  done
  grep -q '^Discovery on uno dos: its problem' "$T/Brk Discovery.lanework/index.md" || { echo "discovery topic line split by a line break"; exit 1; }
  validate "$T/Brk.lanework" >/dev/null; validate "$T/Brk Discovery.lanework" >/dev/null
done
ok "found-board.sh and found-discovery-board.sh: a board title with LF, CR or CRLF founds a single '# title' heading and a matching frontmatter title, words joined by one space, and validates"
# a hostile title cannot start a body section; a title blank once flattened is refused
rm -rf "$T/Evil Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$T/Evil Discovery.lanework" $'Evil\n## X Discovery' --model smoke >/dev/null
! grep -q '^## X' "$T/Evil Discovery.lanework/index.md" && grep -q '^Discovery on Evil ## X: its problem' "$T/Evil Discovery.lanework/index.md" \
  && grep -qxF '# Evil ## X Discovery' "$T/Evil Discovery.lanework/index.md" && validate "$T/Evil Discovery.lanework" >/dev/null \
  || { echo "hostile title leaked a body heading:"; sed -n '/^---$/,$p' "$T/Evil Discovery.lanework/index.md" | head -14; exit 1; }
rm -rf "$T/Evil.lanework" "$T/Blank.lanework"; "$FB" "$T/Evil.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x --model smoke --title $'Evil\n## X' >/dev/null
! grep -q '^## X' "$T/Evil.lanework/index.md" && grep -qxF '# Evil ## X' "$T/Evil.lanework/index.md" || { echo "pipeline title leaked a section"; exit 1; }
for blank in $'\n' $' \r\n ' '   '; do
  rm -rf "$T/Blank.lanework"; rc=0
  "$FB" "$T/Blank.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x --model smoke --title "$blank" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ] && [ ! -e "$T/Blank.lanework" ] || { echo "blank title: rc=$rc"; exit 1; }
done
ok "a title with a line break and a '## ' cannot open a body section (heading and the discovery topic line stay on one line); a title blank once flattened exits 2 and writes nothing"

# plan: found, file, claim, resolve, unblock, out of scope, frontier, records from Working
PS="$SK/plan/scripts"; PL="$T/Sync: v2 Plan.lanework"
"$PS/found-plan-board.sh" "$PL" --model smoke >/dev/null
grep -q '^title: "Sync: v2 Plan"$' "$PL/index.md" && grep -q '^A plan for Sync: v2:' "$PL/index.md" && ! grep -q '{{' "$PL/index.md" || { echo "plan board title or topic not rendered"; exit 1; }
[ "$(grep -l '^icon: ' "$PL"/*/index.md | grep -c .)" -eq 7 ] && grep -qx 'collapsed: true' "$(grep -l '^title: "Out of scope"$' "$PL"/*/index.md)" || { echo "plan lanes missing icons or Out of scope not collapsed"; exit 1; }
[ "$(python3 -c 'import sys,yaml; print(",".join(e["type"] for e in yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["config"]["labels"]))' "$PL/index.md")" = ticket,record,status ] || { echo "plan board config.labels is not ticket,record,status"; exit 1; }
validate "$PL" >/dev/null; ok "plan board founded: colon title quoted, topic rendered, 7 lanes with icons, ticket/record/status kinds, validates"
rm -rf "$T/PL2.lanework"; "$PS/found-plan-board.sh" "$T/PL2.lanework" --labels priority --labels priority,size --model smoke >/dev/null
[ "$(python3 -c 'import sys,yaml; print(",".join(e["type"] for e in yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["config"]["labels"]))' "$T/PL2.lanework/index.md")" = ticket,priority,size,record,status ] || { echo "plan --labels not spliced after ticket"; exit 1; }
validate "$T/PL2.lanework" >/dev/null
for bad in ticket '""' nonsense; do rm -rf "$T/PL3.lanework"; rc=0; eval "\"\$PS/found-plan-board.sh\" \"\$T/PL3.lanework\" --labels $bad --model smoke" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ] && [ ! -e "$T/PL3.lanework" ] || { echo "plan --labels $bad: rc=$rc"; exit 1; }; done
ok "found-plan-board.sh --labels adds catalog kinds after ticket; a kind outside the catalog or an empty list exits 2 and writes nothing"
PBID=$(sed -n 's/^id: //p' "$PL/index.md"); plane() { sed -n 's/^title: "\(.*\)"$/\1/p' "$(dirname "$(ls -d "$PL"/*/"$1")")/index.md"; }
printf 'Where does the engine run?\n' > "$T/t.md"
TO1=$("$PS/file-ticket.sh" "$PL" "Engine: placement" --type grilling --body "$T/t.md" --model smoke); TL1=$(head -1 <<<"$TO1"); T1=${TL1##*/}
TO2=$("$PS/file-ticket.sh" "$PL" "Rate limits" --type research --body "$T/t.md" --model smoke); TL2=$(head -1 <<<"$TO2"); T2=${TL2##*/}
TO3=$("$PS/file-ticket.sh" "$PL" 'Both [x] "q"' --type task --body "$T/t.md" --depends "$TL1" --depends "$TL2" --model smoke); T3=$(head -1 <<<"$TO3" | sed 's#.*/##')
TO4=$("$PS/file-ticket.sh" "$PL" "After one" --type prototype --body "$T/t.md" --depends "$TL1" --why "**Waits on the engine.**" --model smoke); T4=$(head -1 <<<"$TO4" | sed 's#.*/##')
{ [ "$(plane "$T1")" = Frontier ] && [ "$(plane "$T2")" = Frontier ] && [ "$(plane "$T3")" = Blocked ] && [ "$(plane "$T4")" = Blocked ] &&
  grep -q '^T3 -> Blocked$' <<<"$TO3" && grep -q '^short id ' <<<"$TO1" && [ "$TL1" = "lanework://$PBID/$T1" ]; } || { echo "tickets not landed Frontier/Blocked by dependency: $TO1 $TO3"; exit 1; }
TF3="$(ls "$PL"/*/"$T3"/index.md)"
{ grep -qxF 'title: "T3: Both [x] \"q\""' "$TF3" && grep -qx 'labels: \[{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}\]' "$TF3" &&
  grep -qxF -- "- [T1: Engine: placement]($TL1)" "$TF3" && grep -qxF -- "- [T2: Rate limits]($TL2)" "$TF3" && grep -qx '## Depends on' "$TF3" &&
  grep -qx '\*\*Charted.\*\*' "$(ls "$PL"/*/"$T1"/comments/*/index.md)" && grep -qx '\*\*Waits on the engine.\*\*' "$(ls "$PL"/*/"$T4"/comments/*/index.md)"; } || { echo "ticket card shape wrong:"; cat "$TF3"; exit 1; }
validate "$PL" >/dev/null; [ "$(python3 "$SK/lanework/scripts/heal-board.py" "$PL" | tail -1)" = "0 repairs in 0 files" ] || { echo "heal-board finds repairs on fresh tickets"; exit 1; }
ok "file-ticket.sh mints T1..T4, flattened Ticket label, Depends on as named links, Frontier when free and Blocked while a dependency is open; validates, heal finds nothing"
S3=$(sum "$PL")
for dep in "lanework://other/$T1" "[T1]($TL1)" "lanework://$PBID/00000000-0000-4000-8000-000000000000"; do
  if "$PS/file-ticket.sh" "$PL" "Bad" --type grilling --body "$T/t.md" --depends "$dep" --model smoke 2>/dev/null; then echo "accepted bad dependency $dep"; exit 1; fi
done
if "$PS/file-ticket.sh" "$PL" "Bad" --type nope --body "$T/t.md" --model smoke 2>/dev/null; then echo "accepted a bad type"; exit 1; fi
[ "$S3" = "$(sum "$PL")" ] || { echo "a refused file-ticket wrote something"; exit 1; }
ok "file-ticket.sh refuses another board's link, a non-link, a missing card and a bad type, writing nothing"
if "$PS/claim-ticket.sh" "$PL" "$T3" --model smoke 2>"$T/err.txt"; then echo "claimed a Blocked ticket"; exit 1; fi
grep -q 'is in Blocked, not Frontier' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
"$PS/claim-ticket.sh" "$PL" "$T1" --model smoke --session s1 >/dev/null
[ "$(plane "$T1")" = Working ] && grep -qx '\*\*Claimed\*\* by claude, session s1.' "$PL"/*/"$T1"/comments/*/index.md || { echo "claim did not move to Working with a Claimed comment"; exit 1; }
grep -q 'modified: {at: .*, by: {name: claude, kind: agent, model: smoke, session: "s1"}}' "$(ls "$PL"/*/"$T1"/index.md)" || { echo "claim did not restamp modified"; exit 1; }
if "$PS/claim-ticket.sh" "$PL" "$T1" --model smoke 2>"$T/err.txt"; then echo "claimed a Working ticket twice"; exit 1; fi
grep -q 'is in Working, not Frontier' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if "$PS/resolve-ticket.sh" "$PL" "$T2" --resolution "$T/t.md" --model smoke 2>/dev/null; then echo "resolved an unclaimed ticket"; exit 1; fi
ok "claim-ticket.sh moves Frontier to Working with a Claimed comment and a restamp; refuses a Blocked or already-claimed ticket; resolve refuses an unclaimed one"
# a Working ticket wearing waiting loses it on resolve; one of two deps resolved keeps T3 Blocked, unblocks T4
WBLOCK='waiting:\n  for: [rzen, bobsmith, carol, dave]\n  since: 2026-10-10T00:00:00Z\n  comment: 11111111-1111-4111-8111-111111111111'   # past 120 characters: a block (awk -v reads the \n)
TF1="$(ls "$PL"/*/"$T1"/index.md)"; awk -v w="$WBLOCK" '{print} /^order:/ {print w}' "$TF1" > "$T/w.md"; mv "$T/w.md" "$TF1"; grep -q '^  for: \[rzen, bobsmith' "$TF1"
printf '**2026-10-10**: In the app, as recommended. "Yes."\n' > "$T/res1.md"
RO1=$("$PS/resolve-ticket.sh" "$PL" "$T1" --resolution "$T/res1.md" --model smoke)
TF1="$(ls "$PL"/*/"$T1"/index.md)"
{ [ "$(plane "$T1")" = Resolved ] && ! grep -q -E '^(waiting:|  (for|since|comment):)' "$TF1" && fm_parses "$TF1" && grep -qx '## Resolution' "$TF1" && grep -qF '"Yes."' "$TF1" &&
  [ "$(plane "$T4")" = Frontier ] && [ "$(plane "$T3")" = Blocked ] && grep -qx 'unblocked T4' <<<"$RO1" && ! grep -q 'unblocked T3' <<<"$RO1" && [ "$(tail -1 <<<"$RO1")" = "$TL1" ]; } || { echo "resolve/unblock wrong: $RO1"; exit 1; }
"$PS/claim-ticket.sh" "$PL" "$T2" --model smoke >/dev/null
RO2=$("$PS/resolve-ticket.sh" "$PL" "$T2" --resolution "$T/res1.md" --model smoke)
[ "$(plane "$T3")" = Frontier ] && grep -qx 'unblocked T3' <<<"$RO2" || { echo "T3 not unblocked once both deps resolved: $RO2"; exit 1; }
[ "$(sed -n 's/^order: //p' "$(ls "$PL"/*/"$T3"/index.md)")" -gt "$(sed -n 's/^order: //p' "$(ls "$PL"/*/"$T4"/index.md)")" ] || { echo "unblocked ticket not at the bottom of Frontier"; exit 1; }
validate "$PL" >/dev/null; ok "resolve-ticket.sh appends the resolution, drops a block-form list waiting whole, moves to Resolved; unblocks exactly the tickets whose deps are all Resolved (two deps: only after both), to the bottom of Frontier"
# out of scope: from Frontier; a new ticket depending on it is refused; Resolved can't go out of scope
printf '**2026-10-10**: Out of scope: past the destination.\n' > "$T/oos.md"
"$PS/resolve-ticket.sh" "$PL" "$T4" --resolution "$T/oos.md" --to out-of-scope --model smoke >/dev/null
[ "$(plane "$T4")" = "Out of scope" ] || { echo "out-of-scope did not move the ticket"; exit 1; }
if "$PS/file-ticket.sh" "$PL" "Needs four" --type grilling --body "$T/t.md" --depends "lanework://$PBID/$T4" --model smoke 2>"$T/err.txt"; then echo "accepted an out-of-scope dependency"; exit 1; fi
grep -q 'is Out of scope: rule this ticket out too, or drop the dependency' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if "$PS/resolve-ticket.sh" "$PL" "$T1" --resolution "$T/oos.md" --to out-of-scope --model smoke 2>/dev/null; then echo "moved a Resolved ticket out of scope"; exit 1; fi
ok "resolve-ticket.sh --to out-of-scope moves a Frontier ticket; file-ticket.sh refuses a dependency on it; a Resolved ticket can't go out of scope"
# frontier.sh: lists in order, blocked deps shown; drift warned on stderr, exit 0
TO5=$("$PS/file-ticket.sh" "$PL" "Five" --type grilling --body "$T/t.md" --depends "lanework://$PBID/$T3" --model smoke); T5=$(head -1 <<<"$TO5" | sed 's#.*/##')
FO=$("$PS/frontier.sh" "$PL" 2>"$T/drift.txt")
{ [ "$(grep -c '^== ' <<<"$FO")" -eq 3 ] && grep -q "^T3: Both \[x\] \"q\"  \[${T3:0:8}\](lanework://$PBID/$T3)\$" <<<"$FO" && grep -qx '    waits on T3: Both \[x\] "q" (Frontier)' <<<"$FO" && [ ! -s "$T/drift.txt" ]; } || { echo "frontier.sh output wrong:"; echo "$FO"; cat "$T/drift.txt"; exit 1; }
TF5="$(ls "$PL"/*/"$T5"/index.md)"; printf -- '- [T4](lanework://%s/%s)\n' "$PBID" "$T4" >> "$TF5"
BL=$(dirname "$(dirname "$TF5")"); FR=$(dirname "$(dirname "$(ls "$PL"/*/"$T3"/index.md)")")
mv "$FR/$T3" "$BL/$T3"   # hand-made drift: T3 Blocked with every dep Resolved; T5 depends on an out-of-scope card
"$PS/frontier.sh" "$PL" >/dev/null 2>"$T/drift.txt" || { echo "frontier.sh exited non-zero"; exit 1; }
grep -q 'drift: T3: Both \[x\] "q" is Blocked but every dependency is Resolved' "$T/drift.txt" && grep -q 'drift: T5: Five depends on T4: After one, which is Out of scope' "$T/drift.txt" || { echo "drift not warned:"; cat "$T/drift.txt"; exit 1; }
mv "$BL/$T3" "$FR/$T3"
ok "frontier.sh prints Frontier, Blocked with open deps, Working; warns on a Blocked ticket with every dep Resolved and a dep on an Out of scope card; exits 0"
# records from Working: file-record.sh --from Working; default (Asked) refuses on a plan board
"$PS/claim-ticket.sh" "$PL" "$T3" --model smoke >/dev/null
printf 'Engine in the app.\n' > "$T/adrp.md"
PR=$("$SK/discovery/scripts/file-record.sh" "$PL" "$T3" --record ADR --title "Engine in the app" --body "$T/adrp.md" --from Working --model smoke)
PK=${PR##*/}; PKF="$(ls "$PL"/*/"$PK"/index.md)"
[ "$(plane "$PK")" = Decisions ] && [ "$(awk '/^---$/ { n++; next } n == 2 && NF { print; exit }' "$PKF")" = "Question: [T3: Both \[x\] \"q\"](lanework://$PBID/$T3)" ] || { echo "plan record not filed from Working:"; cat "$PKF"; exit 1; }
if "$SK/discovery/scripts/file-record.sh" "$PL" "$T3" --record ADR --title x --body "$T/adrp.md" --model smoke 2>"$T/err.txt"; then echo "default --from accepted a plan board"; exit 1; fi
grep -q 'no Asked lane' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if "$SK/discovery/scripts/file-record.sh" "$PL" "$T5" --record ADR --title x --body "$T/adrp.md" --from Working --model smoke 2>"$T/err.txt"; then echo "--from Working accepted a Blocked ticket"; exit 1; fi
grep -q 'is not a card in Working' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if "$SK/discovery/scripts/file-record.sh" "$D" "$C2" --record ADR --title x --body "$T/adrp.md" --model smoke 2>"$T/err.txt"; then echo "default --from accepted a non-Asked question"; exit 1; fi
grep -q 'is not a card in Asked' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
TF3="$(ls "$PL"/*/"$T3"/index.md)"; cp "$TF3" "$T/t3.md"; awk -v w="$WBLOCK" '{print} /^order:/ {print w}' "$T/t3.md" > "$TF3"
grep -q "^T3: .*(lanework://$PBID/$T3)  (waiting)\$" <<<"$("$PS/frontier.sh" "$PL" 2>/dev/null)" || { echo "frontier.sh lost the (waiting) mark on a block-form waiting"; "$PS/frontier.sh" "$PL"; exit 1; }
cp "$T/t3.md" "$TF3"
validate "$PL" >/dev/null; ok "file-record.sh --from Working files a plan record linking its ticket; the default still demands Asked, and --from refuses a card outside that lane; frontier.sh marks a block-form waiting"
# a model is required: every plan script that writes exits 2 and writes nothing
S4=$(sum "$PL")
refused file-ticket "$PS/file-ticket.sh" "$PL" "Nomodel" --type grilling --body "$T/t.md"
refused claim-ticket "$PS/claim-ticket.sh" "$PL" "$T5"
refused resolve-ticket "$PS/resolve-ticket.sh" "$PL" "$T3" --resolution "$T/res1.md"
refused found-plan-board "$PS/found-plan-board.sh" "$T/NoModel Plan.lanework"
[ "$S4" = "$(sum "$PL")" ] && [ ! -e "$T/NoModel Plan.lanework" ] || { echo "a refused plan call wrote something"; exit 1; }
ok "file-ticket, claim-ticket, resolve-ticket and found-plan-board exit 2 with usage and write nothing when no model is given"

# work: lint-ask
printf '@owner Should we ship it?\n\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/good.md"
printf '@owner maybe ship it; worth a try? and also this?\n' > "$T/bad.md"
"$SK/work/scripts/lint-ask.sh" "$T/good.md"; ok "lint-ask passes a clean ask"
if "$SK/work/scripts/lint-ask.sh" "$T/bad.md" >/dev/null; then exit 1; fi; ok "lint-ask fails a hedged, chained ask"
RECAP='- Recap: Explain this in plain terms first'
printf '@owner Which engine?\n\nOptions:\n- A: app\n- B: service\n\nIf no answer: blocked.\nContext: body.\n' > "$T/opt-bare.md"
printf '@owner Which engine?\n\nOptions:\n- A: app\n- B: service\n%s\n\nIf no answer: blocked.\nContext: body.\n' "$RECAP" > "$T/opt-recap.md"
W=$(grep -v -x -F -e "$RECAP" "$T/opt-recap.md" | wc -w | tr -d ' ')
pad=$(for _ in $(seq 1 $((79 - W))); do printf 'word '; done)
printf '@owner Which engine?\n\nOptions:\n- A: app\n- B: service\n%s\n\nIf no answer: blocked.\nContext: body. %s\n' "$RECAP" "$pad" > "$T/opt-79.md"
printf '@owner Which engine?\n\nOptions:\n- A: app\n%s\n- B: service\n\nIf no answer: blocked.\nContext: body.\n' "$RECAP" > "$T/opt-mid.md"
if "$SK/work/scripts/lint-ask.sh" "$T/opt-bare.md" >/dev/null; then echo "lint-ask passed options without the Recap line"; exit 1; fi
if "$SK/work/scripts/lint-ask.sh" "$T/opt-mid.md" >/dev/null; then echo "lint-ask passed a Recap line that is not last"; exit 1; fi
"$SK/work/scripts/lint-ask.sh" "$T/opt-recap.md"; ok "lint-ask fails an ask with options but no Recap line, passes one with it"
"$SK/work/scripts/lint-ask.sh" "$T/good.md"; ok "lint-ask passes an ask with no options and no Recap line"
[ "$(grep -v -x -F -e "$RECAP" "$T/opt-79.md" | wc -w | tr -d ' ')" -eq 79 ] && [ "$(wc -w < "$T/opt-79.md" | tr -d ' ')" -gt 80 ] || { echo "fixture is not 79 own words plus the line"; exit 1; }
"$SK/work/scripts/lint-ask.sh" "$T/opt-79.md"; ok "lint-ask leaves the Recap line out of the 80-word count"

# guide v117+: asks address @anyone; the board's own stamp gates it (ask_handle), older boards keep the handle
mkguide() { mkdir -p "$1"; printf '<!-- lanework-agent-guide v%s - app guide -->\n\n**This board'"'"'s human answers to `@kim` right now**\n' "$2" > "$1/CLAUDE.md"; }
G118="$T/G118.lanework"; G117="$T/G117.lanework"; G116="$T/G116.lanework"; G114="$T/G114.lanework"; GNONE="$T/GNone.lanework"
mkguide "$G118" 118; mkguide "$G117" 117; mkguide "$G116" 116; mkguide "$G114" 114; mkdir -p "$GNONE"
gv() { ( . "$SK/lanework/scripts/lib.sh"; guide_version "$1" ) || true; }
ah() { ( . "$SK/lanework/scripts/lib.sh"; ask_handle "$1" ) || true; }
{ [ "$(gv "$G118")" = 118 ] && [ "$(gv "$G114")" = 114 ] && [ -z "$(gv "$GNONE")" ] \
  && [ "$(ah "$G118")" = anyone ] && [ "$(ah "$G117")" = anyone ] && [ "$(ah "$G116")" = kim ] && [ "$(ah "$G114")" = kim ] && [ -z "$(ah "$GNONE")" ]; } \
  || { echo "guide_version/ask_handle: 118=$(gv "$G118") 114=$(gv "$G114") none=$(gv "$GNONE") ah118=$(ah "$G118") ah117=$(ah "$G117") ah116=$(ah "$G116") ah114=$(ah "$G114") ahnone=$(ah "$GNONE")"; exit 1; }
GAG="$T/GAgents.lanework"; mkguide "$GAG" 118; mv "$GAG/CLAUDE.md" "$GAG/AGENTS.md"
{ [ "$(gv "$GAG")" = 118 ] && [ "$(ah "$GAG")" = anyone ]; } || { echo "guide_version/ask_handle ignore AGENTS.md when CLAUDE.md is absent"; exit 1; }
rc=0; ( . "$SK/lanework/scripts/lib.sh"; ask_handle "$GNONE" ) >/dev/null || rc=$?; [ "$rc" -ne 0 ] || { echo "ask_handle on a board with no guide and no handle exited 0"; exit 1; }
ok "guide_version reads the stamp; ask_handle is anyone from v117 on, the guide's handle below it, and empty with exit 1 when neither exists"
printf '@anyone Should we ship it?\n\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/any-good.md"
printf 'Context first.\n\n@anyone Should we ship it?\n' > "$T/any-late.md"
{ printf '@anyone Should we ship it?'; for i in $(seq 1 90); do printf ' word'; done; printf '\n'; } > "$T/any-long.md"
printf '@anyone Which engine?\n\nOptions:\n- A: app\n- B: service\n\nIf no answer: blocked.\nContext: body.\n' > "$T/any-norecap.md"
printf '**We chose the app engine.**\n\nNothing is owed in reply.\n' > "$T/any-record.md"
"$SK/work/scripts/lint-ask.sh" "$T/any-good.md" "$G118"
"$SK/work/scripts/lint-ask.sh" "$T/any-record.md" "$G118"
for f in any-late any-long any-norecap; do
  if "$SK/work/scripts/lint-ask.sh" "$T/$f.md" "$G118" >/dev/null; then echo "lint-ask passed $f on a v118 board"; exit 1; fi
done
ok "lint-ask on a v118 board checks an @anyone ask: passes a clean one, fails a late handle, over 80 words and options without Recap, and passes a record that names nobody"
for f in any-late any-long any-norecap any-record; do "$SK/work/scripts/lint-ask.sh" "$T/$f.md" "$G114" || { echo "lint-ask checked @anyone on a v114 board ($f)"; exit 1; }; done
printf '@kim maybe ship it; worth a try?\n' > "$T/kim-bad.md"
if "$SK/work/scripts/lint-ask.sh" "$T/kim-bad.md" "$G114" >/dev/null; then echo "lint-ask passed a bad @kim ask on a v114 board"; exit 1; fi
ok "lint-ask on a v114 board ignores @anyone and still checks the board's own handle"
printf '**Asks changed.**\n\nThey now start `@anyone` on v118 boards. See [the guide](https://example.com/@anyone) for the reserved handle.\n' > "$T/any-quoted.md"
printf 'We said @anyone should answer, then went on to explain why in a long mid-sentence aside.\n\nSecond line.\n' > "$T/any-mid.md"
"$SK/work/scripts/lint-ask.sh" "$T/any-quoted.md" "$G118" || { echo "lint-ask treated a record quoting @anyone in backticks or a URL as an ask"; exit 1; }
printf 'Context first.\n\nWe said @anyone should answer.\n' > "$T/any-mid.md"
if "$SK/work/scripts/lint-ask.sh" "$T/any-mid.md" "$G118" >/dev/null; then echo "lint-ask passed a bare mid-thread @anyone"; exit 1; fi
ok "lint-ask on a v118 board passes a record quoting @anyone in a code span or a URL, and still fails a bare @anyone that is not on line 1"
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/fq-any.md"
for g in 118 114; do
  FQ="$T/FQ$g Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$FQ" --model smoke >/dev/null; mkguide "$FQ" "$g"
  O=$("$SK/discovery/scripts/file-question.sh" "$FQ" "Pricing" --round 1 --body "$T/fq-any.md" --model smoke 2>&1)
  ! grep -q 'lint-ask warning' <<<"$O" || { echo "$O"; exit 1; }
  FC="$(ls "$FQ"/*/"$(head -1 <<<"$O" | sed 's#.*/##')"/index.md)"; FA="$(dirname "$FC")/comments/$(sed -n 's/^ask comment //p' <<<"$O")/index.md"
  if [ "$g" = 118 ]; then want=anyone; else want=kim; fi
  grep -q "^waiting: {for: $want, " "$FC" && grep -q "^@$want Is sync free" "$FA" || { echo "file-question on v$g: want $want"; head -12 "$FC"; cat "$FA"; exit 1; }
done
ok "file-question.sh writes @anyone and waiting.for: anyone on a v118 board, the handle on a v114 board"
for s in "$SK/lanework/scripts/heal-board.py" "$SK/heal/scripts/heal-descriptors.py"; do
  AB="$T/AnyHeal.lanework"; rm -rf "$AB"; cp -R "$D" "$AB"
  S0=$(sum "$AB"); rc=0; "$s" "$AB" --apply --name anyone --model test >/dev/null 2>"$T/anyone.err" || rc=$?
  [ "$rc" -eq 64 ] && grep -q 'anyone is reserved for the app' "$T/anyone.err" && [ "$S0" = "$(sum "$AB")" ] || { echo "$s --name anyone: rc=$rc"; cat "$T/anyone.err"; exit 1; }
done
ok "heal-board and heal-descriptors refuse --name anyone, writing nothing"

# work: lint-stamps (a copy of the discovery board, so the board under test is never edited in place)
LS="$SK/work/scripts/lint-stamps.sh"; SB="$T/Stamps.lanework"; cp -R "$D" "$SB"
SC=$(ls "$SB"/*/*/index.md | head -1)
# setstamp <card file> modified|waiting <seconds-ahead>: set that stamp from the clock, ahead by N seconds
setstamp() { local ts; ts=$(date -u -v+${3}S +%FT%TZ)
  if [ "$2" = modified ]; then sed -i '' -E "s/^modified: \{at: [^,}]*/modified: {at: $ts/" "$1"
  else awk -v w="waiting: {for: rzen, since: $ts, comment: 11111111-1111-4111-8111-111111111111}" '/^waiting:/ {next} {print} /^modified:/ && !d {print w; d=1}' "$1" > "$1.new" && mv "$1.new" "$1"; fi; }
rc=0; out=$("$LS" "$SB" 2>&1) || rc=$?; [ "$rc" -eq 0 ] && [ -z "$out" ] || { echo "lint-stamps on a clean board: want silent exit 0, got $rc:"; echo "$out"; exit 1; }
ok "lint-stamps is silent and exits 0 on a clean board"
setstamp "$SC" modified 120
rc=0; out=$("$LS" "$SB") || rc=$?
[ "$rc" -eq 1 ] && grep -q "$(basename "$(dirname "$SC")").*modified" <<<"$out" && grep -q 'ahead' <<<"$out" || { echo "want exit 1 naming the card and modified, got $rc:"; echo "$out"; exit 1; }
ok "lint-stamps fails a modified.at 2 minutes ahead, naming the file and the field"
"$LS" "$SB" --slack 300 >/dev/null; ok "lint-stamps --slack 300 passes the 120 s case"
setstamp "$SC" modified 1; "$LS" "$SB"; ok "lint-stamps passes a stamp 1 s ahead (the ask offset stays legal)"
setstamp "$SC" waiting 120
rc=0; out=$("$LS" "$SB") || rc=$?
[ "$rc" -eq 1 ] && grep -q 'waiting' <<<"$out" || { echo "want exit 1 naming waiting, got $rc:"; echo "$out"; exit 1; }
rc=0; "$LS" "$SC" >/dev/null || rc=$?; [ "$rc" -eq 1 ] || { echo "single-file argument: want exit 1, got $rc"; exit 1; }
ok "lint-stamps fails a future waiting.since, and takes a single file"
rc=0; "$LS" "$T/no-such-board" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "missing path: want exit 2, got $rc"; exit 1; }
ok "lint-stamps exits 2 on a missing path"
# waiting in its other layouts: list-form for (flow) and the block form both read; neither crashes
ts=$(date -u -v+120S +%FT%TZ); setstamp "$SC" modified 0
awk -v t="$ts" '/^waiting:/ {next} /^  (for|since|comment):/ {next} {print} /^modified:/ && !d {printf "waiting:\n  for: [rzen, kim]\n  since: %s\n  comment: 11111111-1111-4111-8111-111111111111\n", t; d=1}' "$SC" > "$SC.new" && mv "$SC.new" "$SC"
rc=0; out=$("$LS" "$SB") || rc=$?; [ "$rc" -eq 1 ] && grep -q 'waiting.since' <<<"$out" || { echo "block-form waiting: want exit 1 naming waiting.since, got $rc:"; echo "$out"; exit 1; }
awk -v t="$(date -u +%FT%TZ)" '/^waiting:/ {next} /^  (for|since|comment):/ {next} {print} /^modified:/ && !d {print "waiting: {for: [rzen, kim], since: " t ", comment: 11111111-1111-4111-8111-111111111111}"; d=1}' "$SC" > "$SC.new" && mv "$SC.new" "$SC"
"$LS" "$SB"; ok "lint-stamps reads waiting.since in the block form, and passes a list-form for with a current since"

# lint-stamps: the forms a literal reader writes, and the argument edges
SB2="$T/Stamps2.lanework"; cp -R "$D" "$SB2"; SC2=$(ls "$SB2"/*/*/index.md | head -1); ahead=$(date -u -v+120S +%FT%TZ)
# putmod <file> <modified line>: replace the first modified line whole
putmod() { awk -v l="$2" '/^modified:/ && !d {print l; d=1; next} {print}' "$1" > "$1.new" && mv "$1.new" "$1"; }
BY='by: {name: x, kind: agent, model: m}'
rc=0; out=$(cd "$SB2" && sed -i '' -E "s/^modified: \{at: [^,}]*/modified: {at: $ahead/" "$SC2" && "$LS" . 2>&1) || rc=$?
[ "$rc" -eq 1 ] || { echo "lint-stamps . inside a board: want exit 1, got $rc:"; echo "$out"; exit 1; }
for form in "modified: {at: \"$ahead\", $BY}" "modified: {at: '$ahead', $BY}" "modified: {at:   $ahead, $BY}"; do
  putmod "$SC2" "$form"; rc=0; "$LS" "$SB2" >/dev/null || rc=$?; [ "$rc" -eq 1 ] || { echo "lint-stamps missed: $form (rc $rc)"; exit 1; }
done
putmod "$SC2" "modified: {at: $(date -u +%FT%TZ), by: {name: x, kind: agent, model: m, session: \"at: $ahead\"}}"
"$LS" "$SB2"; ok "lint-stamps: target '.', a quoted or double-spaced stamp are caught; an \"at: <future>\" inside by.session is not a stamp"
putmod "$SC2" "modified: {at: $ahead, $BY}"; sed -i '' $'s/$/\r/' "$SC2"
rc=0; "$LS" "$SB2" >/dev/null || rc=$?; [ "$rc" -eq 1 ] || { echo "lint-stamps skipped a CRLF file (rc $rc)"; exit 1; }
ok "lint-stamps reads a CRLF file"
sed -i '' $'s/\r$//' "$SC2"
putmod "$SC2" "modified: {by: {name: x, kind: agent, model: m, session: \"s\"}, at: $ahead}"
rc=0; "$LS" "$SB2" >/dev/null || rc=$?; [ "$rc" -eq 1 ] || { echo "lint-stamps missed a stamp with by before at (rc $rc)"; exit 1; }
putmod "$SC2" "$(printf 'modified:\t{at:\t%s, %s}' "$ahead" "$BY")"
rc=0; "$LS" "$SB2" >/dev/null || rc=$?; [ "$rc" -eq 1 ] || { echo "lint-stamps missed a stamp after tabs (rc $rc)"; exit 1; }
putmod "$SC2" "modified: {by: {name: x, kind: agent, model: m, session: \"at: $ahead\"}, at: $(date -u +%FT%TZ)}"
"$LS" "$SB2"; ok "lint-stamps finds at: anywhere at the top of the flow mapping (by first, tabs), and still ignores one inside a quoted string"
rc=0; perl -e 'alarm 5; exec @ARGV' "$LS" "$SB2" --slack >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "--slack with no value: want exit 2, got $rc"; exit 1; }
rc=0; "$LS" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "no arguments: want exit 2, got $rc"; exit 1; }
[ -z "$("$LS" "$T/no-such-board" 2>/dev/null)" ] || { echo "'no such path' went to stdout"; exit 1; }
ok "lint-stamps: --slack with no value and no arguments exit 2, and the error goes to stderr"

# work: lint-waiting-clears (the discovery board with its cards removed, so only the cards built here count; read-only, so the tree is byte-identical after)
WL="$SK/work/scripts/lint-waiting-clears.sh"; WB="$T/Clears.lanework"; cp -R "$D" "$WB"
WLANE=$(dirname "$(ls "$WB"/*/index.md | sed -n 2p)"); rm -rf "$WB"/*/*/
WC=c0000000-0000-4000-8000-00000000000; WA=a0000000-0000-4000-8000-00000000000; WH=b0000000-0000-4000-8000-00000000000   # card, agent comment, human comment ids, last digit appended
# wl_card <n> [<waiting lines, \n-separated>] [<folder>]: card n, in the lane or the given folder
wl_card() { local d="${3:-$WLANE}/$WC$1"; mkdir -p "$d/comments"
  { printf -- '---\nschema: 1\nkind: card\ntitle: "Card %s"\norder: 1024\ncreated: {at: 2026-11-01T00:00:00Z, by: {name: kim, kind: human}}\nmodified: {at: 2026-11-01T00:00:00Z, by: {name: kim, kind: human}}\n' "$1"
    [ -z "${2:-}" ] || printf "$2"; printf -- '---\nBody.\n'; } > "$d/index.md"; }
# wl_com <n> <id> <time hh:mm:ss> <agent|human> <in-reply-to or -> <body, printf format> [<folder>]: a comment on card n
wl_com() { local d="${7:-$WLANE}/$WC$1/comments/$2"; mkdir -p "$d"; local by='{name: kim, kind: human}' irt=''
  [ "$4" != agent ] || by='{name: claude, kind: agent, model: claude-sonnet-5-5}'; [ "$5" = - ] || irt="in-reply-to: $5"$'\n'
  { printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-17T%sZ, by: %s}\n%s---\n' "$3" "$by" "$irt"; printf "$6"; } > "$d/index.md"; }
WASK='@anyone Which route?\n\nOptions:\n- A: x\n- Recap: Explain this in plain terms first\n'
WREC='**Owner ruled off the board.**\n\n> Yes, A.\n\n**Given**: chat, 2026-11-17\n'
# wl_expect <rc> <output, printf format>: run the lint on the board; its exit code and stdout must match
wl_expect() { local rc=0 out; out=$("$WL" "$WB" 2>&1) || rc=$?; [ "$rc" -eq "$1" ] && [ "$out" = "$(printf "$2")" ] || { echo "lint-waiting-clears: want exit $1 and [$(printf "$2")], got $rc and [$out]"; exit 1; }; }
wl_reset() { rm -rf "$WLANE"/c0*; }
wl_expect 0 ''
ok "lint-waiting-clears is silent and exits 0 on a board with no cards"
wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WA}2 10:00:05 agent ${WA}1 "$WREC"
wl_expect 0 "QUOTED ${WC}1 ${WA}1\nQUOTED 1, NO-QUOTE 0"
ok "lint-waiting-clears: an agent ask, no waiting and a quoting record (in-reply-to, > line, Given line) is one QUOTED line, exit 0"
rm -rf "$WLANE/${WC}1/comments/${WA}2"; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
wl_com 1 ${WA}2 10:00:05 agent ${WA}1 '**Owner ruled off the board.**\n\nYes, A.\n\n**Given**: chat, 2026-11-17\n'; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
wl_com 1 ${WA}2 10:00:05 agent ${WA}1 '**Owner ruled off the board.**\n\n> Yes, A.\n'; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
wl_com 1 ${WA}2 10:00:05 agent - "$WREC"; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: no record, a record with no > line, one with no Given line, and a quoting record not in reply to the ask are each NO-QUOTE, exit 1"
wl_reset; wl_card 1 'waiting: {for: anyone, since: 2026-11-17T10:00:00Z, comment: '${WA}1'}\n'; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"
wl_card 2 'waiting:\n  for: [rzen, bobsmith, carol, dave]\n  since: 2026-11-17T10:00:00Z\n  comment: '${WA}1'\n'; wl_com 2 ${WA}1 10:00:00 agent - "$WASK"
wl_expect 0 ''
ok "lint-waiting-clears: an ask with waiting present is silent, in the flow and the block form"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WH}1 10:30:00 human - 'Looks fine.\n'
wl_card 2; wl_com 2 ${WA}1 10:00:00 agent - "$WASK"; wl_com 2 ${WH}1 09:00:00 human ${WA}1 'A: Yes.\n'
wl_expect 0 ''
ok "lint-waiting-clears: an ask followed by a human comment, or a human reply in-reply-to it, with waiting absent (the app's clear) is silent"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WA}2 11:00:00 agent - "$WASK"
wl_expect 1 "NO-QUOTE ${WC}1 ${WA}2\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: two asks, the newer unanswered and unmarked with no record, names the newer ask's uuid only"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - '**A record, no ask.**\n\nEvidence: none.\n'; wl_com 1 ${WH}1 10:01:00 human - '@anyone not an ask, a human wrote it\n'
wl_card 2 '' "$WB/.trash"; wl_com 2 ${WA}1 10:00:00 agent - "$WASK" "$WB/.trash"
wl_expect 0 ''
ok "lint-waiting-clears: a record with no handle, a human comment that starts with @, and a card in .trash are silent"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_card 2; wl_com 2 ${WA}1 10:00:00 agent - "$WASK"; wl_com 2 ${WA}2 10:00:05 agent ${WA}1 "$WREC"
SW=$(sum "$WB"); rc=0; out=$("$WL" "$WB") || rc=$?
[ "$rc" -eq 1 ] && [ "$(grep -c -E '^(QUOTED|NO-QUOTE) c0' <<<"$out")" -eq 2 ] && [ "$SW" = "$(sum "$WB")" ] || { echo "lint-waiting-clears: rc $rc, or it changed a file:"; echo "$out"; exit 1; }
ok "lint-waiting-clears leaves every file of the board byte-identical, with a QUOTED and a NO-QUOTE card listed"
rc=0; "$WL" "$T/no-such-board" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "missing path: want exit 2, got $rc"; exit 1; }
rc=0; "$WL" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "no arguments: want exit 2, got $rc"; exit 1; }
rc=0; "$WL" "$WB" --bogus >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "a bad flag: want exit 2, got $rc"; exit 1; }
[ -z "$("$WL" "$T/no-such-board" 2>/dev/null)" ] || { echo "'no such path' went to stdout"; exit 1; }
ok "lint-waiting-clears exits 2 on a missing path, no arguments or a bad flag, the message on stderr"

# work: post-comment (a second copy of the discovery board, whose founding comments sit 1-2 s ahead, so posts go --ahead 10 and up; stamps from the clock, never typed)
PC="$SK/work/scripts/post-comment.sh"; PB="$T/Posts.lanework"; cp -R "$D" "$PB"
PCARD=$(basename "$(dirname "$(ls "$PB"/*/*/index.md | head -1)")")
printf 'Checked the clock rule.\n\n**Evidence**: none yet.\n' > "$T/pc.md"
NC() { { ls "$PB"/*/"$PCARD"/comments 2>/dev/null || true; } | wc -l | tr -d ' '; }   # the first card may have no comments yet
n0=$(NC); LANE=$(dirname "$(dirname "$(ls "$PB"/*/"$PCARD"/index.md)")")
# refuse_same_second <real|flow|block> <ahead>: a comment already carries the second a post --ahead N will stamp (a real post, or a
# seeded flow-form line without by, or a block-form one); the next post must exit 1 naming --ahead. Aligned to the start of a second;
# if the clock still ticks between the two, both are undone and it retries, so the case does not depend on machine speed.
refuse_same_second() { local form=$1 a=$2 try rc seed id="" sid=00000000-1111-4111-8111-00000000000$2 d="$LANE/$PCARD/comments"
  for try in 1 2 3 4 5; do
    perl -MTime::HiRes=time,sleep -e '$t = time; sleep(1.02 - ($t - int $t))'
    seed=$(date -u -v+${a}S +%FT%TZ)
    case $form in
      real)  id=$("$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --ahead "$a") ;;
      flow)  mkdir -p "$d/$sid"; printf -- '---\nschema: 1\nkind: comment\ncreated: {at: %s}\nmodified: {at: %s}\n---\nseed\n' "$seed" "$seed" > "$d/$sid/index.md" ;;
      block) mkdir -p "$d/$sid"; printf -- '---\nschema: 1\nkind: comment\ncreated:\n  at: %s\n  by: {name: x, kind: agent, model: m}\nmodified: {at: %s}\n---\nseed\n' "$seed" "$seed" > "$d/$sid/index.md" ;;
    esac
    rc=0; "$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --ahead "$a" 2>"$T/err.txt" >"$T/out.txt" || rc=$?
    [ "$rc" -eq 0 ] && rm -rf "$d/$(cat "$T/out.txt")"
    rm -rf "$d/$sid" ${id:+"$d/$id"}; id=""
    [ "$rc" -eq 1 ] && grep -q -- '--ahead' "$T/err.txt" && return 0
  done; echo "same second ($form): want exit 1 naming --ahead, got $rc:"; cat "$T/err.txt"; exit 1; }
perl -MTime::HiRes=time,sleep -e '$t = time; sleep(1.02 - ($t - int $t))'   # start of a second, so the stamp check below holds
t0=$(date -u -v+10S +%FT%TZ)
U1=$("$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --session smoke --ahead 10) || { echo "post-comment failed"; exit 1; }
t1=$(date -u -v+10S +%FT%TZ)
CF=$(ls "$PB"/*/"$PCARD"/comments/"$U1"/index.md)
[ "$(NC)" -eq $((n0 + 1))  ] && [[ "$U1" =~ ^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$ ]] && grep -q 'kind: comment' "$CF" \
  && grep -q 'by: {name: claude, kind: agent, model: smoke, session: "smoke"}' "$CF" && grep -q 'Checked the clock rule' "$CF" || { echo "bad comment:"; cat "$CF"; exit 1; }
[ "$(grep -o "^created:  {at: [^,]*" "$CF" | sed "s/.*at: //")" = "$(grep -o "^modified: {at: [^,]*" "$CF" | sed "s/.*at: //")" ] || { echo "created and modified differ"; exit 1; }
CA=$(grep -o "^created:  {at: [^,]*" "$CF" | sed "s/.*at: //")
[[ ! "$CA" < "$t0" && ! "$CA" > "$t1" ]] || { echo "created.at $CA is not the clock + 10 s ($t0 .. $t1)"; exit 1; }
validate "$PB" >/dev/null; "$SK/work/scripts/lint-stamps.sh" "$PB"
ok "post-comment.sh lands one comment stamped by the clock, prints its uuid, and the board validates and lints clean"
refuse_same_second real 20; [ "$(NC)" -eq $((n0 + 1)) ] || { echo "a refused post wrote something"; exit 1; }
U2=$("$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --ahead 11 --in-reply-to "$U1")
grep -q "^in-reply-to: $U1\$" "$PB"/*/"$PCARD"/comments/"$U2"/index.md && [ "$(NC)" -eq $((n0 + 2)) ] || { echo "--ahead 1 / --in-reply-to not honoured"; exit 1; }
validate "$PB" >/dev/null; "$SK/work/scripts/lint-stamps.sh" "$PB"
ok "post-comment.sh refuses a second comment in the same second, and with --ahead and --in-reply-to lands it, still within the stamp slack"
PH=$(. "$SK/lanework/scripts/lib.sh"; owner_handle "$PB" || echo owner)
printf '@%s maybe ship it; worth a try? and also this?\n' "$PH" > "$T/badask.md"; printf -- '---\nkind: comment\n---\nx\n' > "$T/fm.md"
S5=$(sum "$PB")
rc=0; "$PC" "$PB" "$PCARD" --body "$T/badask.md" --model smoke --ahead 12 >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "a failing ask: want exit 1, got $rc"; exit 1; }
rc=0; "$PC" "$PB" "$PCARD" --body "$T/fm.md" --model smoke --ahead 12 >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "a body with frontmatter: want exit 1, got $rc"; exit 1; }
rc=0; "$PC" "$PB" 00000000-0000-4000-8000-000000000000 --body "$T/pc.md" --model smoke --ahead 12 >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "an unknown card: want exit 2, got $rc"; exit 1; }
refused post-comment "$PC" "$PB" "$PCARD" --body "$T/pc.md" --ahead 12
[ "$S5" = "$(sum "$PB")" ] || { echo "a refused post wrote something"; exit 1; }
ok "post-comment.sh refuses an ask that fails lint-ask, a body with frontmatter, an unknown card, and no model (exit 2), writing nothing"

# post-comment: the stamp stays near the clock, the card is found by its index.md, the same-second check is a check
S6=$(sum "$PB")
for a in 31 3600 -5 abc ""; do rc=0; "$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --ahead "$a" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "--ahead '$a': want exit 2, got $rc"; exit 1; }; done
[ "$S6" = "$(sum "$PB")" ] || { echo "a refused --ahead wrote something"; exit 1; }
GH="$PB/00000000-0000-4000-8000-000000000000"; mkdir -p "$GH/$PCARD"
U3=$("$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --ahead 13)
[ -f "$LANE/$PCARD/comments/$U3/index.md" ] && [ ! -e "$GH/$PCARD/comments" ] || { echo "the comment did not land in the real card, or went into the ghost folder"; exit 1; }
DUP="$PB/00000000-0000-4000-8000-000000000001"; mkdir -p "$DUP"; cp -R "$LANE/$PCARD" "$DUP/$PCARD"; S7=$(sum "$PB")
rc=0; "$PC" "$PB" "$PCARD" --body "$T/pc.md" --model smoke --ahead 14 >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] && [ "$S7" = "$(sum "$PB")" ] || { echo "two cards with one uuid: want exit 2 and nothing written, got $rc"; exit 1; }
rm -rf "$DUP" "$GH"
ok "post-comment.sh caps --ahead at 30 s (exit 2 above it, negative or not a number), finds the card by its index.md past an index-less folder, and refuses two cards with one uuid"
refuse_same_second flow 21; refuse_same_second block 22
ok "post-comment.sh's same-second check reads a created line with one space and no by, and in block form"

# watch: two boards, one watcher; a comment posted by renaming .draft/ is reported with its board
if command -v fswatch >/dev/null; then
  C=$(ls -d "$D"/*/"$C1"); W="$T/watch.log"
  "$SK/watch/scripts/watch-boards.sh" "$T/snap" "$P" "$D" > "$W" 2>&1 & WP=$!
  sleep 2; mkdir -p "$C/comments/.draft"; printf -- '---\nkind: comment\n---\nx\n' > "$C/comments/.draft/index.md"; sleep 1.5
  mv "$C/comments/.draft" "$C/comments/dddd0000-0000-4000-8000-000000000004"; sleep 1.5
  pkill -P "$WP" 2>/dev/null || true; kill "$WP" 2>/dev/null || true; wait "$WP" 2>/dev/null || true
  grep -q "^CHANGED Sync: v2 Discovery.lanework/.*/comments/dddd0000-0000-4000-8000-000000000004/index.md$" "$W" && ! grep -q "\.draft" "$W" || { cat "$W"; exit 1; }
  ok "watch-boards: comment post on the 2nd board reported with its board, draft not reported"
  if "$SK/watch/scripts/watch-boards.sh" "$T/snap2" "$P" "$P/" 2>/dev/null; then exit 1; fi; ok "watch-boards refuses two boards with one folder name"
  [ ! -e "$T/snap.skills" ] || { echo "no --skills, yet a .skills state file appeared"; exit 1; }; ok "watch-boards: without --skills no .skills state file is written"

  # watch --skills: a rule-file edit emits SKILLS CHANGED once, live and across a restart; a non-rule file emits nothing
  # scratch skills copy + scratch board, outside the repo; polling a bounded wait, never a fixed sleep
  S2="$T/skills-copy"; PB="$T/Probe.lanework"; W2="$T/watch-skills.log"; mkdir -p "$PB"; cp -R "$SK" "$S2"; printf -- '---\nkind: board\n---\n# Probe\n' > "$PB/index.md"
  wait_for() { local i; for i in $(seq 1 100); do grep -q -- "$2" "$1" 2>/dev/null && return 0; sleep 0.1; done; return 1; }
  # probe: a new board file the watcher must report; retried, because fswatch may still be starting
  pn=0; probe() { local t; for t in 1 2 3 4 5 6 7 8; do pn=$((pn+1)); printf 'x\n' > "$PB/probe-$pn.md"; wait_for "$W2" "^CHANGED Probe.lanework/probe-$pn.md$" && return 0; done; echo "watcher never reported a probe file:"; cat "$W2"; exit 1; }
  stop_watch() { pkill -P "$WP" 2>/dev/null || true; kill "$WP" 2>/dev/null || true; wait "$WP" 2>/dev/null || true; }
  nchanged() { grep -c '^SKILLS CHANGED$' "$W2" || true; }
  : > "$W2"; "$SK/watch/scripts/watch-boards.sh" --skills "$S2" "$T/snap3" "$PB" > "$W2" 2>&1 & WP=$!
  wait_for "$T/snap3.skills" '.' || { echo "no skills fingerprint stored:"; cat "$W2"; exit 1; }
  probe   # fswatch is live
  [ "$(nchanged)" = 0 ] || { echo "SKILLS CHANGED with no edit"; cat "$W2"; exit 1; }
  printf '\nan edit\n' >> "$S2/work/references/writing.md"
  wait_for "$W2" '^SKILLS CHANGED$' || { echo "live rule-file edit not reported:"; cat "$W2"; exit 1; }
  probe; probe; [ "$(nchanged)" = 1 ] || { echo "SKILLS CHANGED not exactly once after a live edit:"; cat "$W2"; exit 1; }
  ok "watch-boards --skills: a live rule-file edit emits SKILLS CHANGED once"
  printf '\nan edit\n' >> "$S2/work/templates/ask.md"; printf '\nan edit\n' >> "$S2/lanework/references/writes.md"; printf '\nan edit\n' >> "$S2/lanework/SKILL.md"
  probe; probe; [ "$(nchanged)" = 1 ] || { echo "a non-rule file edit emitted SKILLS CHANGED:"; cat "$W2"; exit 1; }
  ok "watch-boards --skills: an edit to a template or a non-rule reference emits nothing"
  stop_watch
  printf '\nan edit\n' >> "$S2/lanework/references/authority.md"
  : > "$W2"; "$SK/watch/scripts/watch-boards.sh" --skills "$S2" "$T/snap3" "$PB" > "$W2" 2>&1 & WP=$!
  wait_for "$W2" '^SKILLS CHANGED$' || { echo "restart after a rule-file edit did not report it:"; cat "$W2"; exit 1; }
  probe; [ "$(nchanged)" = 1 ] || { echo "SKILLS CHANGED not exactly once at start:"; cat "$W2"; exit 1; }
  stop_watch
  : > "$W2"; "$SK/watch/scripts/watch-boards.sh" --skills "$S2" "$T/snap3" "$PB" > "$W2" 2>&1 & WP=$!
  wait_for "$T/snap3.skills" '.'; probe; stop_watch
  [ "$(nchanged)" = 0 ] || { echo "a restart with no edit reported SKILLS CHANGED:"; cat "$W2"; exit 1; }
  ok "watch-boards --skills: a restart after a rule-file edit emits it at start, and a second restart emits nothing"

  # per-skill symlink install: a root of symlinks into a real copy; edits land through the real path
  S3="$T/skills-real"; SL="$T/skills-links"; cp -R "$SK" "$S3"; mkdir -p "$SL"; for n in watch work lanework; do ln -s "$S3/$n" "$SL/$n"; done
  : > "$W2"; "$SK/watch/scripts/watch-boards.sh" --skills "$SL" "$T/snap4" "$PB" > "$W2" 2>&1 & WP=$!
  wait_for "$T/snap4.skills" '.' || { echo "no skills fingerprint stored (symlinked root):"; cat "$W2"; exit 1; }
  probe; printf '\nan edit\n' >> "$S3/watch/references/events.md"
  wait_for "$W2" '^SKILLS CHANGED$' || { echo "edit through the real path of a symlinked skill not reported:"; cat "$W2"; exit 1; }
  probe; [ "$(nchanged)" = 1 ] || { echo "not exactly once (symlinked root):"; cat "$W2"; exit 1; }
  ok "watch-boards --skills: a root of per-skill symlinks reports an edit made through the real path, once"
  stop_watch
  printf '\nan edit\n' >> "$S3/work/SKILL.md"
  : > "$W2"; "$SK/watch/scripts/watch-boards.sh" --skills "$SL" "$T/snap4" "$PB" > "$W2" 2>&1 & WP=$!
  wait_for "$W2" '^SKILLS CHANGED$' || { echo "restart after an edit not reported (symlinked root):"; cat "$W2"; exit 1; }
  probe; stop_watch; [ "$(nchanged)" = 1 ] || { echo "not exactly once at start (symlinked root):"; cat "$W2"; exit 1; }
  ok "watch-boards --skills: a restart after an edit through a symlinked skill emits it at start"
  # bounded: a watcher that is not refused would run forever
  "$SK/watch/scripts/watch-boards.sh" --skills "$SK/watch" "$T/snap5" "$PB" >/dev/null 2>&1 & WP=$!
  for i in $(seq 1 50); do kill -0 "$WP" 2>/dev/null || break; sleep 0.1; done
  if kill -0 "$WP" 2>/dev/null; then stop_watch; echo "a root without watch/SKILL.md was not refused"; exit 1; fi
  rc=0; wait "$WP" || rc=$?
  [ "$rc" = 2 ] && [ ! -e "$T/snap5" ] || { echo "a root without watch/SKILL.md was not refused with exit 2 (rc=$rc)"; exit 1; }
  rc=0; out=$("$SK/watch/scripts/watch-boards.sh" --skills 2>&1) || rc=$?
  [ "$rc" = 2 ] && grep -q 'usage: watch-boards.sh \[--skills' <<<"$out" || { echo "bad usage text: $out"; exit 1; }
  ok "watch-boards --skills: a root with no watch/SKILL.md is refused with exit 2, and the usage text prints"
else
  echo "skip - fswatch not installed"
fi

# arm-pass.sh: the arming pass classes each card from its files; Done is never swept, a claim is flagged and never worked
AB="$T/Arm Pipeline.lanework"; AN="${AB##*/}"
"$SK/lanework/scripts/found-board.sh" "$AB" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Arm --var verified=make --model smoke >/dev/null
alane() { dirname "$(lane_of "$AB" "$1")"; }
AP="$SK/watch/scripts/arm-pass.sh"; NOWS=$(date -u +%FT%TZ); OLD='2026-10-01T00:00:00Z'; AGENT='{name: claude, kind: agent, model: x}'
OLD2H=$(date -u -v-2H +%FT%TZ); OLD3H=$(date -u -v-3H +%FT%TZ); HUMAN='{name: "Rouslan Z", kind: "human"}'
# acard <lane> <uuid> <title> <order>; acom <lane> <card> <uuid> <at> <by or ""> <in-reply-to or ""> <body>
acard() { mkdir -p "$(alane "$1")/$2"; printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\norder: %s\ncreated:  {at: %s}\nmodified: {at: %s}\n---\nBody.\n' "$3" "$4" "$OLD" "$OLD" > "$(alane "$1")/$2/index.md"; }
acom() { local d; d="$(alane "$1")/$2/comments/$3"; mkdir -p "$d"; printf -- '---\nschema: 1\nkind: comment\n%screated:  {at: %s%s}\nmodified: {at: %s%s}\n---\n%s\n' "${6:+in-reply-to: $6
}" "$4" "${5:+, by: $5}" "$4" "${5:+, by: $5}" "$7" > "$d/index.md"; }
A1=e1000000-0000-4000-8000-000000000001; acard Ideas $A1 "Ideas: owner question" 1024;   acom Ideas $A1 f1000000-0000-4000-8000-000000000001 "$OLD2H" "" "" "Why?"
A2=e1000000-0000-4000-8000-000000000002; acard Ideas $A2 "Ideas: answered" 2048;         acom Ideas $A2 f1000000-0000-4000-8000-000000000002 "$OLD3H" "$HUMAN" "" "Why?"; acom Ideas $A2 f1000000-0000-4000-8000-000000000003 "$OLD2H" "$AGENT" f1000000-0000-4000-8000-000000000002 "Because."
A3=e1000000-0000-4000-8000-000000000003; acard Proposed $A3 "Proposed: owner question" 1024; acom Proposed $A3 f1000000-0000-4000-8000-000000000004 "$OLD2H" "" "" "Why?"
A4=e1000000-0000-4000-8000-000000000004; acard Done $A4 "Done: old question" 1024;       acom Done $A4 f1000000-0000-4000-8000-000000000005 "$OLD2H" "" "" "Why?"; acom Done $A4 f1000000-0000-4000-8000-000000000006 "$OLD3H" "$AGENT" "" "**START: never closed.**"
A5=e1000000-0000-4000-8000-000000000005; acard Shaping $A5 "Shaping: dead claim" 1024;   acom Shaping $A5 f1000000-0000-4000-8000-000000000007 "$OLD2H" "$AGENT" "" "**START: shaping.**"
A6=e1000000-0000-4000-8000-000000000006; acard Shaping $A6 "Shaping: fresh claim" 2048;  acom Shaping $A6 f1000000-0000-4000-8000-000000000008 "$NOWS" "$AGENT" "" "**START: shaping.**"
A7=e1000000-0000-4000-8000-000000000007; acard Shaping $A7 "Shaping: unclaimed" 3072
A8=e1000000-0000-4000-8000-000000000008; acard Shaping $A8 "Shaping: claimed, owner waiting" 4096; acom Shaping $A8 f1000000-0000-4000-8000-000000000009 "$OLD3H" "$AGENT" "" "START: plain"; acom Shaping $A8 f1000000-0000-4000-8000-00000000000a "$OLD2H" "" "" "Status?"
A9=e1000000-0000-4000-8000-000000000009; acard Approved $A9 "Approved: top" 1024;        acard Approved e1000000-0000-4000-8000-00000000000a "Approved: second" 2048
AB1=e1000000-0000-4000-8000-00000000000b; acard Active $AB1 "Active: closed claim" 1024; acom Active $AB1 f1000000-0000-4000-8000-00000000000b "$OLD3H" "$AGENT" "" "**START: building.**"; acom Active $AB1 f1000000-0000-4000-8000-00000000000c "$OLD2H" "$AGENT" "" "**Merged: landed.**"
# a by-stamped owner comment is an owner's whatever the quote (the app writes kind: "human"; YAML allows 'human'); a CRLF file is read;
# a fractional-second stamp parses and a stamp that is not plain ...Z is never judged stale
A10=e1000000-0000-4000-8000-000000000010; acard Issues $A10 "Issues: app-stamped owner" 1024; acom Issues $A10 f1000000-0000-4000-8000-000000000010 "$OLD2H" '{name: Bob, kind: "human"}' "" "Why?"
A11=e1000000-0000-4000-8000-000000000011; acard Issues $A11 "Issues: single-quoted owner" 2048; acom Issues $A11 f1000000-0000-4000-8000-000000000011 "$OLD2H" "{name: Bob, kind: 'human'}" "" "Why?"
A12=e1000000-0000-4000-8000-000000000012; acard Issues $A12 "Issues: fractional fresh claim" 3072; acom Issues $A12 f1000000-0000-4000-8000-000000000012 "${NOWS%Z}.123Z" "$AGENT" "" "**START: x.**"
A13=e1000000-0000-4000-8000-000000000013; acard Issues $A13 "Issues: offset claim" 4096; acom Issues $A13 f1000000-0000-4000-8000-000000000013 "2026-10-01T00:00:00+00:00" "$AGENT" "" "**START: x.**"
A14=e1000000-0000-4000-8000-000000000014; acard Tasks $A14 "Tasks: CRLF owner" 1024; acom Tasks $A14 f1000000-0000-4000-8000-000000000014 "$OLD2H" "" "" "Why?"
sed -i '' 's/$/\r/' "$(alane Tasks)/$A14/comments/f1000000-0000-4000-8000-000000000014/index.md"
# an app move receipt (signed board, with a moved: key) is no reply, claim or activity: it neither clears an owner comment nor freshens a dead claim
AR='{name: board, kind: agent}'
acom Shaping $A5 f1000000-0000-4000-8000-00000000000d "$NOWS" "$AR" "" "moved"
acom Ideas $A1 f1000000-0000-4000-8000-00000000000e "$NOWS" "$AR" f1000000-0000-4000-8000-000000000001 "moved"
AO=$("$AP" "$AB")
exp=$(printf 'comment\t%s\t%s\tIdeas\tIdeas: owner question\towner\t%s/%s/comments/f1000000-0000-4000-8000-000000000001/index.md\n' "$AN" $A1 "$(basename "$(alane Ideas)")" $A1
  printf 'comment\t%s\t%s\tIssues\tIssues: app-stamped owner\towner\t%s/%s/comments/f1000000-0000-4000-8000-000000000010/index.md\n' "$AN" $A10 "$(basename "$(alane Issues)")" $A10
  printf 'comment\t%s\t%s\tIssues\tIssues: single-quoted owner\towner\t%s/%s/comments/f1000000-0000-4000-8000-000000000011/index.md\n' "$AN" $A11 "$(basename "$(alane Issues)")" $A11
  printf 'comment\t%s\t%s\tTasks\tTasks: CRLF owner\towner\t%s/%s/comments/f1000000-0000-4000-8000-000000000014/index.md\n' "$AN" $A14 "$(basename "$(alane Tasks)")" $A14
  printf 'stale\t%s\t%s\tShaping\tShaping: dead claim\t-\tXm\n' "$AN" $A5
  printf 'arm\t%s\t%s\tShaping\tShaping: unclaimed\t-\t-\n' "$AN" $A7
  printf 'comment\t%s\t%s\tShaping\tShaping: claimed, owner waiting\towner\t%s/%s/comments/f1000000-0000-4000-8000-00000000000a/index.md\n' "$AN" $A8 "$(basename "$(alane Shaping)")" $A8
  printf 'stale\t%s\t%s\tShaping\tShaping: claimed, owner waiting\t-\tXm\n' "$AN" $A8
  printf 'comment\t%s\t%s\tProposed\tProposed: owner question\towner\t%s/%s/comments/f1000000-0000-4000-8000-000000000004/index.md\n' "$AN" $A3 "$(basename "$(alane Proposed)")" $A3
  printf 'arm\t%s\t%s\tApproved\tApproved: top\t-\t-\n' "$AN" $A9
  printf 'arm\t%s\t%s\tActive\tActive: closed claim\t-\t-\n' "$AN" $AB1)
got=$(sed -E 's/\t(1[12][0-9])m$/\tXm/' <<<"$AO")
[ "$got" = "$exp" ] || { echo "arm-pass.sh lines:"; echo "want:"; echo "$exp"; echo "got:"; echo "$got"; exit 1; }
ok "arm-pass.sh: an unanswered owner comment is a comment line in any lane but Done (a reply in-reply-to clears it); an unclaimed agent-lane card is an arm line, Approved its top card only; a closed claim does not hold a card; a board move receipt is no reply and no activity; a by-stamped owner comment (either quote) and a CRLF one answer; a fractional or offset stamp is never stale; comment wins over arm; Done prints nothing"
[ "$(STALE_MINUTES=240 "$AP" "$AB" | grep -c '^stale')" = 0 ] && [ "$("$AP" "$AB" Ideas | grep '^arm' | cut -f3-4)" = "$(printf '%s\tIdeas' $A2)" ] || { echo "arm-pass.sh: STALE_MINUTES or the agent lane titles ignored"; exit 1; }
! "$AP" "$T" 2>/dev/null || { echo "arm-pass.sh accepted a non-board"; exit 1; }
ok "arm-pass.sh: STALE_MINUTES moves the stale line; lane titles on the command line replace the board-kinds.md agent rows; a non-board exits non-zero"
validate "$AB" >/dev/null; ok "the arm-pass fixture board validates"

# merge: one scratch repo, two clones, every rule row; driver + pass as a merge and as a rebase, and the pass alone
for m in merge rebase nodriver; do "$ROOT/tests/merge-case.sh" "$T" "$m" >/dev/null; ok "merge case: every row resolves with no prompt, as a $m"; done
"$ROOT/tests/merge-case.sh" "$T" clean >/dev/null; ok "merge case: git finishes a lossless merge alone, stops on a loss, and a comment left by a move is re-homed"
"$ROOT/tests/merge-case.sh" "$T" rebasemove >/dev/null; ok "merge case: a rebase with a later move leaves no orphaned folder"
"$ROOT/tests/merge-case.sh" "$T" dirty >/dev/null; ok "merge case: uncommitted edits in a conflicted card are carried as ours, never erased"
"$ROOT/tests/merge-case.sh" "$T" appside >/dev/null; ok "merge case: bytes the app wrote (tests/fixtures/app-writes) collide with scripted edits and resolve with no prompt"

# lane actors: every lane body names its actor and trigger; the lane -> actor table lives once; heal-descriptors brings old boards to currency
lane_file() { grep -l "^title: \"$2\"\$" "$1"/*/index.md | head -1; }
lane_body() { tail -1 "$(lane_file "$1" "$2")"; }
for b in "$P" "$T/design-loop.lanework" "$T/datapoint.lanework" "$D" "$PL"; do
  for f in "$b"/*/index.md; do
    lb=$(tail -1 "$f"); { [ -n "$lb" ] && [ "$lb" != --- ] && grep -qE '[.!?] [A-Z`]' <<<"$lb"; } || { echo "lane body missing or one sentence: $f"; exit 1; }
  done
done
ok "every lane of a founded pipeline, design-loop, datapoint, discovery and plan board has a body of two sentences or more"
grep -q 'unasked' <<<"$(lane_body "$P" Approved)" || { echo "the Approved body must say an agent takes the top card unasked"; exit 1; }
for l in Ideas Issues Tasks; do b=$(lane_body "$P" $l)
  ! grep -qiE 'unasked|without waiting|agents? (act|build|shape|fix)|builds? (it|them)|shapes? (it|them)' <<<"$b" || { echo "$l is a holding lane: its body must not have agents act unasked: $b"; exit 1; }
done
grep -q "^- \*\*Agent lanes\*\*: Shaping, Approved and Active: agents act on cards there unasked. Elsewhere they may read, link, research and answer, but move a card out or start its work only when asked" "$P/index.md" || { echo "pipeline board sheet has no Agent lanes line carrying the rule"; exit 1; }
! grep -q 'has passed both' "$P/index.md" || { echo "the sheet still says a Tasks chore has passed both gates"; exit 1; }
ok "Approved takes the top card unasked; Ideas, Issues and Tasks bodies have agents act on nothing; the sheet's Agent lanes line carries the rule"
[ "$(grep -rlE '^\| lane \| who acts \|' "$SK" | sed "s#^$SK/##")" = "lanework/references/board-kinds.md" ] || { echo "the lane -> actor table must live only in lanework/references/board-kinds.md"; exit 1; }
for l in Ideas Issues Tasks Shaping Proposed Approved Active Done; do grep -qE "^\| $l \|" "$SK/lanework/references/board-kinds.md" || { echo "board-kinds.md table has no $l row"; exit 1; }; done
! grep -qE '^\| (Done|Dead ends|Filed|Facts|Settled|Decisions|Parked|Resolved|Out of scope) \| agent ' "$SK/lanework/references/board-kinds.md" || { echo "a lane an agent only files into is marked agent (a work order for the arming pass): use none"; exit 1; }
ok "the lane -> actor table lives only in board-kinds.md, with a row per pipeline lane"

{ ! grep -q 'a move' <(grep -E '^6\. ' "$SK/watch/references/events.md") && ! grep -qiE 'requested' <(grep '^description:' "$SK/watch/SKILL.md") &&
  grep -q 'Arming pass' "$SK/watch/references/arming.md" && grep -q '^## A move' "$SK/watch/references/responding.md" &&
  grep -q 'unclaimed' "$SK/watch/references/arming.md" && grep -q 'companions.md' "$SK/watch/references/responding.md" && ! grep -q 'Ideas, Proposed' "$SK/watch/references/responding.md"; } || { echo "watch still calls a move context only, says requested, lacks the arming pass or the move case"; exit 1; }
ok "watch: no rule calls a move context only; arming acts on waiting cards; responding covers the move"

HD="$SK/heal/scripts/heal-descriptors.py"
X="$T/Heal Me.lanework"
"$SK/lanework/scripts/found-board.sh" "$X" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Heal --var verified='`make`' --model smoke >/dev/null
cp -R "$X" "$T/Heal Sheet.lanework"
setbody() { local f; f=$(lane_file "$X" "$1"); sed -i '' '$d' "$f"; [ -z "$2" ] || printf '%s\n' "$2" >> "$f"; }
setbody Approved 'The ready-to-build queue, ranked in build order, top is next. The spec is frozen, so a scope change bounces the card back to Shaping.'
setbody Tasks "Owner chores, built through Active. Nothing here needs shaping. Agents never file here."
setbody Shaping ''
validate "$X" >/dev/null
Z0=$(sum "$X"); O=$("$HD" "$X")
{ grep -q '^lane Approved: replace-body ' <<<"$O" && grep -q '^lane Tasks: insert-actor ' <<<"$O" && grep -q '^lane Shaping: fill-body ' <<<"$O" && grep -q '^3 changes in 3 files' <<<"$O"; } || { echo "$O"; exit 1; }
[ "$Z0" = "$(sum "$X")" ]; ok "heal-descriptors dry run lists the old-template, customised and empty lane bodies and writes nothing"
if "$HD" "$X" --apply >/dev/null 2>&1; then echo "--apply ran without --model"; exit 1; else [ $? -eq 2 ]; fi; [ "$Z0" = "$(sum "$X")" ]
ok "heal-descriptors --apply without --model exits 2 and writes nothing"
IDLE=$(lane_file "$X" Ideas); IDLE_SUM=$(shasum "$IDLE")
"$HD" "$X" --apply --name fixer --model test >/dev/null; validate "$X" >/dev/null
TPL() { awk -F'|' -v t="$1" '/^\| *[0-9]/ { gsub(/^ +| +$/, "", $3); gsub(/^ +| +$/, "", $6); if ($3 == t) print $6 }' "$SK/lanework/templates/pipeline-lanes.md"; }
[ "$(lane_body "$X" Approved)" = "$(TPL Approved)" ] && [ "$(lane_body "$X" Shaping)" = "$(TPL Shaping)" ] || { echo "replace or fill did not give the current template body"; exit 1; }
TB=$(lane_body "$X" Tasks); AS=$(TPL Tasks | sed -E 's/^[^.]*\. //; s/\. .*$/./')
[ "$TB" = "Owner chores, built through Active. $AS Nothing here needs shaping. Agents never file here." ] || { echo "customised body not extended in place: $TB"; exit 1; }
for l in Approved Tasks Shaping; do grep -qE '^modified: \{at: [0-9TZ:-]+, by: \{name: fixer, kind: agent, model: test\}\}$' "$(lane_file "$X" "$l")" || { echo "$l not restamped whole"; exit 1; }; done
[ "$IDLE_SUM" = "$(shasum "$IDLE")" ] || { echo "an untouched lane was rewritten"; exit 1; }
ok "heal-descriptors --apply replaces, extends in place and fills; touched lanes restamped with the agent, others untouched, board validates"
Z1=$(sum "$X"); O=$("$HD" "$X" --apply --name fixer --model test); [ "$Z1" = "$(sum "$X")" ] && grep -q '^0 changes' <<<"$O" || { echo "$O"; exit 1; }
ok "a second heal-descriptors --apply changes nothing"
Y="$T/Heal Sheet.lanework"; sed -i '' '/^- \*\*Agent lanes\*\*/d' "$Y/index.md"; validate "$Y" >/dev/null
O=$("$HD" "$Y"); grep -q '^board sheet: insert-permission ' <<<"$O" && grep -q '^1 changes in 1 files' <<<"$O" || { echo "$O"; exit 1; }
"$HD" "$Y" --apply --name fixer --model test >/dev/null; validate "$Y" >/dev/null
grep -q '^- \*\*Agent lanes\*\*' "$Y/index.md" && grep -qE '^modified: \{at: [0-9TZ:-]+, by: \{name: fixer, kind: agent, model: test\}\}$' "$Y/index.md" && grep -q '^0 changes' <<<"$("$HD" "$Y")" || { echo "board sheet not healed"; exit 1; }
ok "heal-descriptors inserts the permission line into a board sheet that lacks it, restamps the board, then finds nothing"
O=$("$HD" "$H3") && grep -q 'no known lane set' <<<"$O" || { echo "$O"; exit 1; }
ok "a board matching no lane set gets no descriptor changes"

# heal-descriptors, round 2: non-prose first paragraphs, wrapped anchor bullets, boards without Tasks, kind-less lanes, --skip, --expect, --name
lane_text() { awk 'n>=2{print} /^---$/{n++}' "$(lane_file "$1" "$2")"; }
AS2() { TPL "$1" | sed -E 's/^[^.]*\. //; s/\. .*$/./'; }
N="$T/Heal Markup.lanework"; "$SK/lanework/scripts/found-board.sh" "$N" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Heal --var verified=make --model smoke >/dev/null
for l in Ideas Issues Tasks; do f=$(lane_file "$N" $l); sed -i '' '$d' "$f"; done
printf '## Policy\n\nOnly the owner triages. Agents file here.\n' >> "$(lane_file "$N" Ideas)"
printf -- '- one rule\n- another rule\n' >> "$(lane_file "$N" Issues)"
printf '> quoted note\n' >> "$(lane_file "$N" Tasks)"
"$HD" "$N" --apply --name fixer --model test >/dev/null; validate "$N" >/dev/null
for l in Ideas Issues Tasks; do t=$(lane_text "$N" $l)
  [ "$(head -1 <<<"$t")" = "$(AS2 $l)" ] && [ -z "$(sed -n 2p <<<"$t")" ] || { echo "$l: the sentence is not its own first paragraph: $t"; exit 1; }; done
lane_text "$N" Ideas | grep -qxF '## Policy' && lane_text "$N" Ideas | grep -qxF 'Only the owner triages. Agents file here.' && lane_text "$N" Issues | grep -qxF -- '- another rule' && lane_text "$N" Tasks | grep -qxF '> quoted note' || { echo "markup was edited"; exit 1; }
[ "$(sum "$N")" = "$(sum "$N")" ] && grep -q '^0 changes' <<<"$("$HD" "$N")" || exit 1
ok "heal-descriptors puts the sentence above a heading, list or quote that opens a body, and leaves the markup as written"
W="$T/Heal Wrap.lanework"; cp -R "$T/Heal Sheet.lanework" "$W"; sed -i '' '/^- \*\*Agent lanes\*\*/d' "$W/index.md"
perl -0pi -e 's/(\*\*Two human gates\*\*: triage out of Ideas,) and/$1\n  and/' "$W/index.md"
"$HD" "$W" --apply --name fixer --model test >/dev/null; validate "$W" >/dev/null
[ "$(grep -A2 '^- \*\*Two human gates' "$W/index.md" | sed -n 2p | cut -c1-9)" = "  and rev" ] && grep -A2 '^- \*\*Two human gates' "$W/index.md" | sed -n 3p | grep -q '^- \*\*Agent lanes\*\*' || { echo "the Agent lanes bullet split a wrapped gates bullet"; exit 1; }
ok "heal-descriptors inserts the Agent lanes bullet after a wrapped Two human gates bullet's continuation lines"
grep -v '^| 1792 |' "$SK/lanework/templates/pipeline-lanes.md" > "$T/nt-lanes.md"
NT="$T/Heal NoTasks.lanework"; "$SK/lanework/scripts/found-board.sh" "$NT" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$T/nt-lanes.md" --var project=Heal --var verified=make --model smoke >/dev/null
sed -i '' '/^- \*\*Agent lanes\*\*/d' "$NT/index.md"; "$HD" "$NT" --apply --name fixer --model test >/dev/null; validate "$NT" >/dev/null
grep -q "^- \*\*Agent lanes\*\*: Shaping, Approved and Active: " "$NT/index.md" || { echo "no-Tasks sheet"; exit 1; }
sed -i '' '/^- \*\*Agent lanes\*\*/d' "$NT/index.md"; sed -i '' '/^| 2048 |/d' "$T/nt-lanes.md"
NT2="$T/Heal NoTasks2.lanework"; "$SK/lanework/scripts/found-board.sh" "$NT2" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$T/nt-lanes.md" --var project=Heal --var verified=make --model smoke >/dev/null
sed -i '' '/^- \*\*Agent lanes\*\*/d' "$NT2/index.md"; "$HD" "$NT2" --apply --name fixer --model test >/dev/null
grep -q "^- \*\*Agent lanes\*\*: Approved and Active: " "$NT2/index.md" || { grep Agent "$NT2/index.md"; exit 1; }
ok "the Agent lanes line names only the agent lanes the board has (no Tasks, or no Shaping either: the lane is left out)"
K="$T/Heal Kindless.lanework"; cp -R "$T/Heal Current.lanework" "$K" 2>/dev/null || { cp -R "$T/Heal Sheet.lanework" "$K"; }
f=$(lane_file "$K" Shaping); sed -i '' '$d' "$f"; sed -i '' '/^kind: lane$/d' "$f"
grep -q '^lane Shaping: fill-body ' <<<"$("$HD" "$K")" || { echo "a lane without kind: lane was ignored"; exit 1; }
ok "a depth-1 folder with no kind: lane is still a lane"
Q="$T/Heal Opts.lanework"; "$SK/lanework/scripts/found-board.sh" "$Q" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Heal --var verified=make --model smoke >/dev/null
for l in Approved Tasks; do f=$(lane_file "$Q" $l); sed -i '' '$d' "$f"; done
printf 'The ready-to-build queue, ranked in build order, top is next. The spec is frozen, so a scope change bounces the card back to Shaping.\n' >> "$(lane_file "$Q" Approved)"
printf 'Owner chores, built through Active. Agents never file here.\n' >> "$(lane_file "$Q" Tasks)"
TF=$(lane_file "$Q" Tasks); T0=$(shasum "$TF")
O=$("$HD" "$Q" --skip tasks); grep -q '^lane Approved: replace-body ' <<<"$O" && ! grep -q '^lane Tasks: ' <<<"$O" && grep -q '^skip lane Tasks: left alone by --skip' <<<"$O" || { echo "$O"; exit 1; }
DG=$("$HD" "$Q" | sed -n 's/^digest //p'); DS=$(sed -n 's/^digest //p' <<<"$O"); [ -n "$DG" ] && [ "$DG" != "$DS" ] || { echo "digest does not follow --skip"; exit 1; }
"$HD" "$Q" --skip Tasks --apply --model test --expect "$DS" >/dev/null; [ "$T0" = "$(shasum "$TF")" ] && [ "$(lane_body "$Q" Approved)" = "$(TPL Approved)" ] || { echo "--skip applied or missed a change"; exit 1; }
ok "--skip leaves a lane out of the list, the digest and the apply"
DG=$("$HD" "$Q" | sed -n 's/^digest //p'); f=$(lane_file "$Q" Ideas); sed -i '' '$d' "$f"; printf 'Notes only. Nothing else.\n' >> "$f"; S2=$(sum "$Q")
rc=0; "$HD" "$Q" --apply --model test --expect "$DG" >/dev/null 2>"$T/exp.err" || rc=$?; [ "$rc" -eq 3 ] && [ "$S2" = "$(sum "$Q")" ] && grep -q 'not the one shown' "$T/exp.err" || { echo "expect mismatch: rc=$rc"; exit 1; }
DG=$("$HD" "$Q" | sed -n 's/^digest //p'); "$HD" "$Q" --apply --model test --expect "$DG" >/dev/null; grep -q '^0 changes' <<<"$("$HD" "$Q")"
ok "--apply --expect refuses with exit 3 and writes nothing when the change list drifted; the fresh digest applies"
rc=0; "$HD" "$Q" --apply --model test --name "" >/dev/null 2>"$T/name.err" || rc=$?; [ "$rc" -ne 0 ] && grep -q -- '--name needs a non-empty name' "$T/name.err" || { echo "empty --name"; cat "$T/name.err"; exit 1; }
ok "an empty --name is refused with a plain message"

# a pre-ruling sheet: the released "passed both" sentence and Flow clause are template text; the heal removes them
OLDFLOW="- **Flow**: Ideas to Shaping to Proposed to Approved to Active to Done, with Issues as the side entrance for things broken in the running system, and Tasks as the owner's side entrance for chores that need no shaping."
R="$T/Heal Pre.lanework"; cp -R "$T/Heal Current.lanework" "$R" 2>/dev/null || cp -R "$T/Heal Sheet.lanework" "$R"
sed -i '' '/^- \*\*Agent lanes\*\*/d' "$R/index.md"
OLDFLOW="$OLDFLOW" perl -pi -e 'BEGIN{$o=$ENV{OLDFLOW}} $_="$o\n" if /^- \*\*Flow\*\*/; s/(is the agent.s job, not the owner.s\.)/$1 A chore the owner files in Tasks has passed both./' "$R/index.md"
grep -q 'passed both' "$R/index.md" || { echo "fixture lacks the released sentence"; exit 1; }
cp -R "$R" "$T/Heal Pre2.lanework"; perl -pi -e 's/^- \*\*Flow\*\*: .*$/- **Flow**: Ideas to Done, with Issues as the side entrance for something broken, and Tasks as the owner\x27s side entrance for chores that need no shaping./' "$T/Heal Pre2.lanework/index.md"
O=$("$HD" "$R"); { grep -q '^board sheet: drop-stale ' <<<"$O" && grep -q '^board sheet: replace-flow ' <<<"$O" && grep -q '^board sheet: insert-permission ' <<<"$O" && grep -q '^3 changes in 1 files' <<<"$O"; } || { echo "$O"; exit 1; }
"$HD" "$R" --apply --name fixer --model test >/dev/null; validate "$R" >/dev/null
! grep -q 'passed both' "$R/index.md" && [ "$(grep '^- \*\*Flow\*\*' "$R/index.md")" = "$(grep '^- \*\*Flow\*\*' "$SK/lanework/templates/pipeline-index.md")" ] && grep -q '^0 changes' <<<"$("$HD" "$R")" || { echo "pre-ruling sheet not healed"; exit 1; }
"$HD" "$T/Heal Pre2.lanework" --apply --name fixer --model test >/dev/null; grep -q '^- \*\*Flow\*\*: Ideas to Done, with Issues as the side entrance for something broken, and Tasks as a side entrance\.$' "$T/Heal Pre2.lanework/index.md" || { grep Flow "$T/Heal Pre2.lanework/index.md"; exit 1; }
ok "heal-descriptors removes the released Tasks-passed-both sentence, swaps the released Flow bullet (a customised Flow keeps its prose), validates, and finds nothing the second time"

# drop-stale goes line by line: an own bullet leaves no bare "-", an inline hit leaves its bullet whole, a fence or a quote is never edited
export STALE="A chore the owner files in Tasks has passed both."
sbody() { awk 'n>=2{print} /^---$/{n++}' "$1/index.md"; }
mkstale() { local d="$T/Heal Stale $1.lanework"; cp -R "$R" "$d"; echo "$d"; }       # $R is healed by now: the sheet is the only thing left to drop
D1=$(mkstale own);  printf -- '- %s\n' "$STALE" >> "$D1/index.md"
D2=$(mkstale inline); perl -pi -e 's/(not the owner.s\.)$/$1 $ENV{STALE}/ if /^- \*\*Two human gates\*\*/' "$D2/index.md"
D3=$(mkstale fence); printf '\n```\n- %s\n```\n' "$STALE" >> "$D3/index.md"
D4=$(mkstale quote); printf '\n> %s\n' "$STALE" >> "$D4/index.md"
D5=$(mkstale mixed); printf '\n~~~\n%s\n~~~\n\n> %s\n\n- Kept. %s\n' "$STALE" "$STALE" "$STALE" >> "$D5/index.md"
D6=$(mkstale nested); printf '\n````\n```\n%s\n```\n````\n' "$STALE" >> "$D6/index.md"
D7=$(mkstale tilde); printf '\n```\n~~~\n%s\n```\n' "$STALE" >> "$D7/index.md"
D8=$(mkstale listquote); printf '\n- > %s\n' "$STALE" >> "$D8/index.md"
D9=$(mkstale numbered); printf '1. %s\n' "$STALE" >> "$D9/index.md"
D10=$(mkstale task); printf -- '- [ ] %s\n' "$STALE" >> "$D10/index.md"
for d in "$D1" "$D2" "$D3" "$D4" "$D5" "$D6" "$D7" "$D8" "$D9" "$D10"; do grep -qF "$STALE" "$d/index.md" || { echo "fixture lacks the sentence: $d"; exit 1; }; done
grep -q 'not the owner.s\. A chore' "$D2/index.md" || { echo "inline fixture not inline"; exit 1; }
for d in "$D1" "$D2" "$D9" "$D10"; do
  O=$("$HD" "$d"); grep -q '^board sheet: drop-stale ' <<<"$O" || { echo "$d"; echo "$O"; exit 1; }
  "$HD" "$d" --apply --name fixer --model test >/dev/null; validate "$d" >/dev/null
  [ "$(sbody "$d")" = "$(sbody "$R")" ] && ! grep -qF "$STALE" "$d/index.md" && grep -q '^0 changes' <<<"$("$HD" "$d")" || { echo "drop-stale left a bare bullet or touched a neighbour: $d"; diff <(sbody "$d") <(sbody "$R"); exit 1; }
done
for d in "$D3" "$D4" "$D6" "$D7" "$D8"; do
  Z=$(sum "$d"); O=$("$HD" "$d")
  { ! grep -q 'drop-stale' <<<"$O" && grep -q '^0 changes' <<<"$O"; } || { echo "$d"; echo "$O"; exit 1; }
  "$HD" "$d" --apply --name fixer --model test >/dev/null; [ "$Z" = "$(sum "$d")" ] || { echo "a fenced or quoted sentence was edited: $d"; exit 1; }
done
"$HD" "$D5" --apply --name fixer --model test >/dev/null; validate "$D5" >/dev/null
{ [ "$(grep -cF "$STALE" "$D5/index.md")" = 2 ] && grep -q '^- Kept\.$' "$D5/index.md" && grep -q '^0 changes' <<<"$("$HD" "$D5")"; } || { echo "mixed fixture: the fence and quote hits must stay, the bullet hit must go"; tail -12 "$D5/index.md"; exit 1; }
ok "heal-descriptors drop-stale: removes an own bullet whole and an inline hit alone, never edits a fence or a quote, and a later real hit still goes"

# label kinds: found-board.sh --labels splices catalog rows into config.labels; heal-board.py reads its suggested kinds from the same file
LK="$SK/lanework/templates/label-kinds.md"; LD="$T/label-kinds"; mkdir -p "$LD"; FB="$SK/lanework/scripts/found-board.sh"
sed 's/<SF Symbol>/square.grid.2x2/; s/^<.*>$/Test board./; s/^- <.*>$/- Test rule./' "$SK/lanework/templates/index.md" > "$LD/idx.md"
norm_index() { sed -E 's/^id: .*/id: ID/; s/^(created|modified): .*/\1: STAMP/' "$1"; }
"$FB" "$LD/P.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Acme --var verified='`make check`' --model smoke >/dev/null
"$FB" "$LD/G.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --model smoke >/dev/null
[ "$(norm_index "$LD/P.lanework/index.md")" = "$(cat "$ROOT/tests/fixtures/founded-pipeline-index.md")" ] && [ "$(norm_index "$LD/G.lanework/index.md")" = "$(cat "$ROOT/tests/fixtures/founded-plain-index.md")" ] || { echo "founding without --labels drifted from the pre-catalog golden"; exit 1; }
ok "found-board.sh without --labels founds an index byte-identical to the pre-catalog founding (pipeline and plain templates)"
ALLK=priority,component,type,size,platform,round,release,epic
"$FB" "$LD/All.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Acme --var verified=x --labels "$ALLK" --model smoke >/dev/null
validate "$LD/All.lanework" >/dev/null
python3 - "$LD/All.lanework/index.md" "$ALLK" <<'PY' || { echo "config.labels is not exactly the seven kinds"; exit 1; }
import sys, yaml
fm = open(sys.argv[1]).read().split("---\n")[1]
cfg = yaml.safe_load(fm)["config"]
got = [e["type"] for e in cfg["labels"]]
assert got == sys.argv[2].split(","), got
assert cfg["show-card-body"] == 3
by = {e["type"]: e for e in cfg["labels"]}
assert by["priority"]["single"] is True and [v["rank"] for v in by["priority"]["values"]] == [0, 1, 2, 3]
assert "values" not in by["component"] and "values" not in by["platform"] and "icon" not in by["round"] and by["round"]["single"] is True
assert all("rank" in v for k in ("type", "size") for v in by[k]["values"])
PY
ok "found-board.sh --labels naming all eight kinds founds a board whose config.labels holds exactly those eight, in order, and it validates"
"$FB" "$LD/Two.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --labels size,priority --model smoke >/dev/null
validate "$LD/Two.lanework" >/dev/null
[ "$(python3 -c 'import sys,yaml; print(",".join(e["type"] for e in yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["config"]["labels"]))' "$LD/Two.lanework/index.md")" = size,priority ] || exit 1
ok "found-board.sh --labels takes any subset, in the order given, on the plain index template too"
"$FB" "$LD/Type.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --labels type --model smoke >/dev/null
validate "$LD/Type.lanework" >/dev/null
python3 - "$LD/Type.lanework/index.md" <<'PY' || { echo "the type kind does not carry icon: {glyph: cube}"; exit 1; }
import sys, yaml
by = {e["type"]: e for e in yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["config"]["labels"]}
t = by["type"]
assert t["icon"] == {"glyph": "cube"}, t.get("icon")
assert {v["text"]: v["icon"]["glyph"] for v in t["values"]} == {"Bug": "ladybug", "Feature": "sparkles", "Chore": "wrench", "Docs": "doc.text", "Spike": "magnifyingglass"}
PY
ok "found-board.sh --labels type stamps icon: {glyph: cube} on the type kind, leaves its five values' glyphs alone, and the board validates"
for bad in "type,nonsense" "nonsense" "type,,size" ""; do
  rm -rf "$LD/Bad.lanework"; rc=0
  "$FB" "$LD/Bad.lanework" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --var verified=x --labels "$bad" --model smoke >/dev/null 2>"$LD/err" || rc=$?
  [ "$rc" -eq 2 ] && [ ! -e "$LD/Bad.lanework" ] && [ -s "$LD/err" ] || { echo "--labels '$bad': exit $rc, board $( [ -e "$LD/Bad.lanework" ] && echo written || echo absent)"; exit 1; }
done
ok "found-board.sh --labels with an unknown, empty or blank kind exits 2 with a message and writes nothing"
# a card carrying one flattened entry of each kind validates with no DEPRECATED line
CD="$LD/All.lanework/$(ls "$LD/All.lanework" | grep -v -E '^(index.md|\.)' | head -1)"; CID=$(uuidgen | tr A-Z a-z); mkdir -p "$CD/$CID"
cat > "$CD/$CID/index.md" <<'CARD'
---
schema: 1
kind: card
title: "One of each kind"
order: 1024
labels:
  - {text: Urgent, rank: 0, color: "#C8283C", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}
  - {text: core, color: aluminum, kind: {type: component, text: Component, color: aluminum, icon: {glyph: puzzlepiece}}}
  - {text: Bug, rank: 1, icon: {glyph: ladybug}, kind: {type: type, text: Type, icon: {glyph: cube}}}
  - {text: M, rank: 2, kind: {type: size, text: Size, icon: {glyph: ruler}}}
  - {text: '1', kind: {type: round, text: Round}}
  - {text: macOS, kind: {type: platform, text: Platform, icon: {glyph: laptopcomputer.and.iphone}}}
  - {text: 0.3.0, kind: {type: release, text: Release, icon: {glyph: shippingbox}}}
  - {text: Search, kind: {type: epic, text: Epic, icon: {glyph: mountain.2}}}
created:  {at: 2026-10-10T00:00:00Z}
modified: {at: 2026-10-10T00:00:00Z}
---
Body.
CARD
validate "$LD/All.lanework" >/dev/null; ok "a card carrying one flattened entry of each of the eight kinds validates with no DEPRECATED line"
# discovery: the round kind comes from the catalog; the founded config is today's except round gains single: true
"$SK/discovery/scripts/found-discovery-board.sh" "$LD/D Discovery.lanework" --model smoke >/dev/null
sed 's/{type: round, text: Round}/{type: round, text: Round, single: true}/' "$ROOT/tests/fixtures/founded-discovery-index.md" > "$LD/want-discovery.md"
same_doc "$LD/D Discovery.lanework/index.md" "$LD/want-discovery.md" || { cat "$LD/D Discovery.lanework/index.md"; exit 1; }
validate "$LD/D Discovery.lanework" >/dev/null
ok "a founded discovery board takes round from the catalog: config the same as the pre-catalog founding except round gains single: true (compact layout aside), and it validates"
# discovery keeps round whatever the caller passes; slot and var guards in found-board.sh
for lb in priority priority,round,type round; do
  rm -rf "$LD/DL.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$LD/DL.lanework" --model smoke --labels "$lb" >/dev/null
  validate "$LD/DL.lanework" >/dev/null
  want=round,$(tr ',' '\n' <<<"$lb" | { grep -v '^round$' || true; } | paste -sd, - )
  got=$(python3 -c 'import sys,yaml; print(",".join(e["type"] for e in yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["config"]["labels"]))' "$LD/DL.lanework/index.md")
  [ "$got" = "${want%,},record,status" ] || { echo "--labels $lb: got $got"; exit 1; }
done
ok "found-discovery-board.sh --labels adds kinds to round (round first, deduped) and never loses it"
# --labels: repeats accumulate (a kind repeated across flags is written once), an empty list is an error, through both founding scripts
lbl_types() { python3 -c 'import sys,yaml; print(",".join(e["type"] for e in yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["config"]["labels"]))' "$1"; }
FD="$SK/discovery/scripts/found-discovery-board.sh"
for args in "--labels type --labels size:type,size" "--labels type,size --labels priority:type,size,priority" "--labels type --labels type:type" "--labels type --labels size --labels type:type,size"; do
  rm -rf "$LD/Rep.lanework" "$LD/RepD.lanework"
  # shellcheck disable=SC2086
  "$FB" "$LD/Rep.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" ${args%%:*} --model smoke >/dev/null
  [ "$(lbl_types "$LD/Rep.lanework/index.md")" = "${args#*:}" ] || { echo "found-board.sh ${args%%:*}: got $(lbl_types "$LD/Rep.lanework/index.md")"; exit 1; }
  "$FD" "$LD/RepD.lanework" --model smoke ${args%%:*} >/dev/null
  [ "$(lbl_types "$LD/RepD.lanework/index.md")" = "round,${args#*:},record,status" ] || { echo "found-discovery-board.sh ${args%%:*}: got $(lbl_types "$LD/RepD.lanework/index.md")"; exit 1; }
  validate "$LD/RepD.lanework" >/dev/null
done
ok "found-board.sh and found-discovery-board.sh: repeated --labels accumulate in order, and a kind repeated across flags is written once"
for bad in '--labels ""' '--labels type --labels ""' '--labels "" --labels type'; do
  rm -rf "$LD/Emp.lanework" "$LD/EmpD.lanework"; rc=0; rd=0
  eval "\"\$FB\" \"\$LD/Emp.lanework\" --index \"\$LD/idx.md\" --lanes \"\$SK/lanework/templates/datapoint-lanes.md\" $bad --model smoke" >/dev/null 2>&1 || rc=$?
  eval "\"\$FD\" \"\$LD/EmpD.lanework\" --model smoke $bad" >/dev/null 2>&1 || rd=$?
  [ "$rc" -eq 2 ] && [ "$rd" -eq 2 ] && [ ! -e "$LD/Emp.lanework" ] && [ ! -e "$LD/EmpD.lanework" ] || { echo "$bad: found-board.sh rc=$rc, found-discovery-board.sh rc=$rd, boards $(ls -d "$LD"/Emp*.lanework 2>/dev/null | wc -l | tr -d ' ') written"; exit 1; }
done
ok "found-board.sh and found-discovery-board.sh: an empty --labels list, alone or among others, exits 2 and writes nothing"
rm -rf "$LD/NoRound.lanework"; rc=0; "$FB" "$LD/NoRound.lanework" --index "$SK/discovery/templates/board.md" --lanes "$SK/discovery/templates/lanes.md" --var topic=x --model smoke >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 2 ] && [ ! -e "$LD/NoRound.lanework" ] || { echo "board.md without --labels: rc=$rc"; exit 1; }
ok "found-board.sh with the discovery template and no --labels exits 2 and writes nothing (round cannot be lost)"
printf '%s\n' '---' 'schema: 1' 'kind: board' 'title: {{title_yaml}}' 'id: {{id}}' 'icon: {glyph: square.grid.2x2}' 'config: {show-card-body: 3}' 'created:  {{stamp}}' 'modified: {{stamp}}' '---' '# {{title}}' > "$LD/slotless.md"
rm -rf "$LD/Slotless.lanework"; rc=0; "$FB" "$LD/Slotless.lanework" --index "$LD/slotless.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --labels priority --model smoke >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 2 ] && [ ! -e "$LD/Slotless.lanework" ] || { echo "slotless index with --labels: rc=$rc"; exit 1; }
"$FB" "$LD/Slotless.lanework" --index "$LD/slotless.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --model smoke >/dev/null
ok "found-board.sh --labels with an index that has neither {{labels}} nor {{label_entries}} exits 2 and writes nothing; without --labels such an index still founds"
for bad in "type,type" "priority,size,priority"; do
  rm -rf "$LD/Dup.lanework"; rc=0; "$FB" "$LD/Dup.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --labels "$bad" --model smoke >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ] && [ ! -e "$LD/Dup.lanework" ] || { echo "--labels $bad: rc=$rc"; exit 1; }
done
ok "found-board.sh --labels naming a kind twice exits 2 and writes nothing"
for rv in labels label_entries title title_yaml id stamp; do
  rm -rf "$LD/Rv.lanework"; rc=0; "$FB" "$LD/Rv.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --var "$rv=, foo: 1" --model smoke >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ] && [ ! -e "$LD/Rv.lanework" ] || { echo "--var $rv: rc=$rc"; exit 1; }
done
ok "found-board.sh --var naming a slot or built-in key (labels, label_entries, title, title_yaml, id, stamp) exits 2 and writes nothing"
# heal-board.py: embedded SUGGESTED priority equals the catalog row (component is a catalog kind only, guide v114); a copy with no catalog beside it still heals
python3 - "$SK/lanework/scripts/heal-board.py" "$LK" <<'PY' || { echo "heal's embedded SUGGESTED differs from the catalog rows"; exit 1; }
import importlib.util, sys; sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("hb", sys.argv[1]); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
rows = {}
for line in open(sys.argv[2]):
    if line.startswith("| ") and line.count("|") >= 3:
        cells = [c.strip() for c in line.strip().strip("|").split("|", 1)]
        if cells[0] in ("priority", "component"): rows[cells[0]] = hb.inline(cells[1])
assert sorted(rows) == ["component", "priority"], rows
assert [s["type"] for s in hb.EMBEDDED_SUGGESTED] == ["priority"]
assert all(s == rows[s["type"]] for s in hb.EMBEDDED_SUGGESTED), (hb.EMBEDDED_SUGGESTED, rows)
assert hb.SUGGESTED == hb.EMBEDDED_SUGGESTED
PY
ok "heal-board.py's embedded SUGGESTED priority equals the label-kinds.md row"
mkdir -p "$LD/solo"; cp "$SK/lanework/scripts/heal-board.py" "$LD/solo/lanework-heal.py"
"$FB" "$LD/Solo.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --model smoke >/dev/null
SC="$LD/Solo.lanework/$(ls "$LD/Solo.lanework" | grep -v -E '^(index.md|\.)' | head -1)"; SCD="$SC/$(uuidgen | tr A-Z a-z)"; mkdir -p "$SCD"
printf '%s\n' '---' 'schema: 1' 'kind: card' 'title: "Old"' 'order: 1024' 'priority: High' 'created:  {at: 2026-10-10T00:00:00Z}' 'modified: {at: 2026-10-10T00:00:00Z}' '---' 'Body.' > "$SCD/index.md"
grep -q " added-definition config.labels gains \`priority\`" <<<"$("$HEAL" "$LD/Solo.lanework")" || { echo "the skill heal did not list the missing priority definition"; exit 1; }
python3 "$LD/solo/lanework-heal.py" "$LD/Solo.lanework" --apply --name fixer --model smoke >/dev/null
grep -q 'type: "\?priority"\?' "$LD/Solo.lanework/index.md" && grep -q 'Urgent' "$LD/Solo.lanework/index.md" && ! grep -q '^priority:' "$SCD/index.md" || { cat "$LD/Solo.lanework/index.md"; exit 1; }
validate "$LD/Solo.lanework" >/dev/null
ok "heal-board.py run from a copy outside the skill tree (no catalog beside it) uses the embedded copy and heals a missing priority definition"

# guide v114: several people on one ask, a root component: left alone, relations walked, the board name reserved
printf '@owner @bob Should we ship it?\n\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/two-handles.md"
printf '@owner Should we ship it?\n\nIf no answer: blocked.\nContext: the comment above. Ask @bob too.\n' > "$T/late-handle.md"
"$SK/work/scripts/lint-ask.sh" "$T/two-handles.md"
O=$("$SK/work/scripts/lint-ask.sh" "$T/late-handle.md") && { echo "lint-ask passed an ask whose second handle is not on line 1"; exit 1; }
grep -qx 'handle @bob is not on the first line' <<<"$O" || { echo "$O"; exit 1; }
printf '@owner Which pin?\n\nOptions:\n- A: Pin `@types/node` to 20\n- B: Leave it\n%s\n\nIf no answer: B.\nContext: [the post](https://mastodon.social/@someone/123), https://mastodon.social/@other/9.\n' "$RECAP" > "$T/at-code.md"
"$SK/work/scripts/lint-ask.sh" "$T/at-code.md" || { echo "lint-ask failed an @ inside a code span or a link target"; exit 1; }
ok "lint-ask passes an ask naming two handles on line 1, fails one whose second handle is only on a later line, and ignores an @ in a code span or a URL"
HV="$T/V114.lanework"; HVL="$HV/aaaa0000-0000-4000-8000-0000000000b1"; HVC="$HVL/c0000000-0000-4000-8000-0000000000b1"
HVR="aaaa0000-0000-4000-8000-0000000000b2"; HVT="aaaa0000-0000-4000-8000-0000000000b3"; mkdir -p "$HVC/relations/$HVR" "$HVC/relations/.trash/$HVT"
printf -- '---\nschema: 1\nkind: board\ntitle: "V114"\nid: aaaa0000-0000-4000-8000-0000000000b0\ncreated:  %s\nmodified: %s\n---\nBody.\n' "$STAMP" "$STAMP" > "$HV/index.md"
printf -- '---\nschema: 1\nkind: lane\ntitle: "Lane"\norder: 1024\ncreated:  %s\nmodified: %s\n---\nLane.\n' "$STAMP" "$STAMP" > "$HVL/index.md"
printf -- '---\nschema: 1\nkind: card\ntitle: "Root component"\norder: 1024\ncomponent: {text: Sync}\nlabels: [{text: "core", kind: {type: "component", text: "Component"}}]\ncreated:  %s\nmodified: %s\n---\nBody.\n' "$STAMP" "$STAMP" > "$HVC/index.md"
for r in "$HVR" ".trash/$HVT"; do
  printf -- '---\nschema: 1\nkind: relation\nrel: "depends-on"\nto: "lanework://aaaa0000-0000-4000-8000-0000000000b0/aaaa0000-0000-4000-8000-0000000000b1"\ncreated:  %s\nmodified: 2026-10-01T00:00:00Z\n---\nWhy.\n' "$STAMP" > "$HVC/relations/$r/index.md"
done
cp "$HVC/index.md" "$T/v114-card.md"; cp "$HVC/relations/.trash/$HVT/index.md" "$T/v114-trashed.md"
O=$("$HEAL" "$HV")
{ grep -q "^aaaa0000-0000-4000-8000-0000000000b1/c0000000-0000-4000-8000-0000000000b1/relations/$HVR/index.md: bare-stamp modified" <<<"$O" \
  && ! grep -q '\.trash' <<<"$O" && ! grep -q 'c0000000-0000-4000-8000-0000000000b1/index.md' <<<"$O" && grep -q '^1 repairs in 1 files' <<<"$O"; } \
  || { echo "heal on the v114 board:"; echo "$O"; exit 1; }
"$HEAL" "$HV" --apply --name fixer --model test >/dev/null
cmp -s "$HVC/index.md" "$T/v114-card.md" && cmp -s "$HVC/relations/.trash/$HVT/index.md" "$T/v114-trashed.md" && ! grep -q component "$HV/index.md" \
  && grep -qx 'modified: {at: 2026-10-01T00:00:00Z}' "$HVC/relations/$HVR/index.md" || { echo "heal touched the root component:, the trashed relation or the config, or missed the live one"; exit 1; }
ok "heal-board leaves a root component: as written and adds no component definition, repairs a live relation, never walks relations/.trash"
for s in "$HEAL" "$HD"; do
  S0=$(sum "$HV"); rc=0; "$s" "$HV" --apply --name board --model test >/dev/null 2>"$T/board.err" || rc=$?
  [ "$rc" -eq 64 ] && grep -q 'board is reserved for the app' "$T/board.err" && [ "$S0" = "$(sum "$HV")" ] || { echo "$s --name board: rc=$rc"; cat "$T/board.err"; exit 1; }
done
ok "heal-board and heal-descriptors refuse --name board (app-reserved, move receipts), writing nothing"
mkdir -p "$T/singles/one.lanework" "$T/singles/two.lanework"
printf -- '---\nschema: 1\nkind: board\nconfig: {labels: [{type: "component", text: "Component"}]}\n---\n' > "$T/singles/one.lanework/index.md"
printf -- '---\nschema: 1\nkind: board\nconfig: {labels: [{type: "component", text: "Component", single: true}]}\n---\n' > "$T/singles/two.lanework/index.md"
python3 - "$SK/merge/scripts/lanework-merge.py" "$T/singles" <<'PY' || { echo "lanework-merge.py: component single where the board does not say so"; exit 1; }
import importlib.util, sys; sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("lm", sys.argv[1]); lm = importlib.util.module_from_spec(spec); spec.loader.exec_module(lm)
one, two = lm.board_singles(sys.argv[2], "one.lanework"), lm.board_singles(sys.argv[2], "two.lanework")
assert "priority" in one and "component" not in one, one
assert "component" in two, two
PY
ok "lanework-merge.py treats component as single only where the board marks it single; priority always"
"$ROOT/tests/check-refs.sh" >/dev/null; ok "every cited skill file exists"
"$ROOT/tests/check-sizes.sh" || { echo "README § Sizes is out of date: fix the rows named above"; exit 1; }; ok "README sizes match wc -w, rows, totals and summary"
# check-sizes walks the folders, so a § Sizes row or table left behind for a removed skill must be caught from the README side:
# a clean scratch copy passes (control), a leftover summary row and a leftover #### table each fail naming the skill
mkdir -p "$T/sizes-ok" "$T/sizes-row" "$T/sizes-tbl"
for d in sizes-ok sizes-row sizes-tbl; do ln -s "$SK" "$T/$d/skills"; cp "$ROOT/README.md" "$T/$d/README.md"; done
sed -i '' 's/^| `watch` | \([0-9]\)/| `ghost` | 1 | 1 | 1 |\
&/' "$T/sizes-row/README.md"
sed -i '' 's/^#### `watch`$/#### `ghost`\
\
| file | words |\
|---|---|\
| `SKILL.md` | 1 |\
| **total** | **1** |\
\
&/' "$T/sizes-tbl/README.md"
! cmp -s "$T/sizes-row/README.md" "$ROOT/README.md" && ! cmp -s "$T/sizes-tbl/README.md" "$ROOT/README.md" || { echo "the scratch READMEs were not edited"; exit 1; }
"$ROOT/tests/check-sizes.sh" "$T/sizes-ok" >/dev/null || { echo "check-sizes failed a clean copy"; exit 1; }
for d in sizes-row sizes-tbl; do
  rc=0; out=$("$ROOT/tests/check-sizes.sh" "$T/$d") || rc=$?
  { [ "$rc" -ne 0 ] && grep -q 'ghost' <<<"$out"; } || { echo "check-sizes passed a leftover § Sizes entry for a skill with no folder ($d, rc=$rc): $out"; exit 1; }
done
ok "check-sizes: a § Sizes row or table for a skill with no folder fails, naming it; a clean copy passes"
# watch carries the arming sweep and the compaction rule that dispatch's retirement moved into it
WA="$SK/watch/references/arming.md"
{ [ -x "$SK/watch/scripts/arm-pass.sh" ] && grep -q '^## Arming pass$' "$WA" && grep -q 'scripts/arm-pass.sh' "$WA" && grep -q 'scripts/arm-pass.sh' "$SK/watch/SKILL.md" \
  && grep -qi 'compact' "$WA" && grep -q 'from `ls`, never from memory' "$WA" \
  && grep -q 'Either way, then carry on as `arm`' "$WA" && grep -q 'every agent lane title' "$WA" && grep -q 'arming message' "$WA"; } || { echo "watch arming lacks the arm-pass section, its script, the compaction rule, the answer-then-arm clause, the full lane-title list or the stale report place"; exit 1; }
ok "watch arming runs scripts/arm-pass.sh (its own section, a row in SKILL.md) and carries the compaction rule, the answer-then-arm clause, the full lane-title list and where a stale report goes"

# format rules: skills point at the guide, never prescribe priority/component as card keys (retired, guide v82)
H=$({ grep -rn -i -E '\b(priority|component):|(priority|component)[^.]*(root|top-level)|(root|top-level)[^.]*(priority|component)' "$SK" || true; } | grep -v -i 'reserved' || true)
[ -z "$H" ] || { echo "a skill prescribes priority/component as a card key (they are labels entries, see the guide): $H"; exit 1; }
ok "no skill prescribes priority: or component: as a card key"

# versions: no skill names a guide version; the one stamp lives in the repo's CLAUDE.md
H=$({ grep -r -l -i -E 'lanework-(agent-guide|schema) +v[0-9]+' "$SK"; find "$SK" -name '*.md' -exec grep -l -i -E 'guide[^.]*[^[:alnum:]_-]v[0-9]+|(^|[^[:alnum:]_-])v[0-9]{2,}([^[:alnum:].]|$)' {} +; } 2>/dev/null || true)   # a stamp, or a guide version as a floor ("guide ... v105+")
[ -z "$H" ] || { echo "a skill names a guide version (the stamp lives only in CLAUDE.md): $H"; exit 1; }
S=$({ grep -o -E 'lanework-agent-guide v[0-9]+' "$ROOT/CLAUDE.md" || true; })
[ "$(printf '%s\n' "$S" | grep -c .)" -eq 1 ] || { echo "CLAUDE.md must carry exactly one guide stamp, found: ${S:-none}"; exit 1; }
SV=$({ grep -o -E 'lanework-schema v[0-9]+' "$ROOT/CLAUDE.md" || true; })
[ "$(printf '%s\n' "$SV" | grep -c .)" -eq 1 ] || { echo "CLAUDE.md must carry exactly one schema stamp, found: ${SV:-none}"; exit 1; }
ok "no skill names a guide version; one stamp ($S, $SV), in CLAUDE.md"

# compact form: what the skill scripts write is no repair for the board's own heal (H17), on boards founded
# with catalog kinds and filed by the plan and discovery scripts; the layout seed is the positive control
h17() { python3 "$VAL/bin/lanework-heal.py" "$1" | grep ' H17 ' || true; }
[ -n "$(h17 "$T/layout-seed")" ] || { echo "compact-form control: the board's heal found nothing on the layout seed"; exit 1; }
for b in "$T/Acme Pipeline.lanework" "$T/PL2.lanework" "$T/Sync: v2 Plan.lanework" "$T/Sync: v2 Discovery.lanework" "$T/label-kinds/D Discovery.lanework"; do
  hits=$(h17 "$b"); [ -z "$hits" ] || { echo "${b##*/}: not in the compact form:"; echo "$hits"; exit 1; }
done
hits=$(h17 "$T/label-kinds/All.lanework" | grep '^index.md:' || true); [ -z "$hits" ] || { echo "All.lanework: $hits"; exit 1; }
[ -z "$(find "$SK" -name __pycache__)" ] || { echo "a script left __pycache__ in the skill tree"; exit 1; }
ok "founded boards, tickets and records are written in the compact form: the board's heal finds no H17 (control: the layout seed), and no __pycache__ in skills/"

# filing scripts: the destination lane's card-defaults.labels are unioned into a card at birth (lib.sh union_lane_defaults)
# setdef <board> <lane title> <yaml value|->: set (or, with -, remove) the lane's card-defaults line
setdef() { SK="$SK" python3 -B - "$(lane_of "$1" "$2")" "$3" <<'PY'
import importlib.util, os, sys, yaml
spec = importlib.util.spec_from_file_location("hb", os.environ["SK"] + "/lanework/scripts/heal-board.py"); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
p, v = sys.argv[1:]; A = open(p).read().split("\n"); end = A.index("---", 1); L = []; skip = False
for l in A[1:end]:
    if l.startswith("card-defaults:"): skip = True; continue
    if skip and l[:1] == " ": continue
    skip = False; L.append(l)
if v[:1] == "=": L.append("card-defaults: " + v[1:])   # verbatim, as an owner types it
elif v != "-": L += hb.emit_key("card-defaults", yaml.safe_load(v))
open(p, "w").write("\n".join(["---"] + L + A[end:]))
PY
}
labels_of() { local f; f="$(ls "$1"/*/"$2"/index.md)"; fm_parses "$f" || { echo "$f does not parse"; return 1; }; flowed "$f" | grep '^labels:'; }
nothing_to_heal() { validate "$1" >/dev/null && [ "$(python3 "$SK/lanework/scripts/heal-board.py" "$1" | tail -1)" = "0 repairs in 0 files" ]; }
TXT='kind: {type: text, text: Text, icon: {glyph: tag}}'
printf 'Sync is free.\n' > "$T/dadr.md"; printf 'Is it free?\n\n## Options\n\n- A: yes\n- B: no\n\n## Recommended\n\nA. Simple.\n' > "$T/dq.md"
DD="$T/Defaults Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$DD" --model smoke >/dev/null

# 1. file-record: a free label and a kinded entry; the card's own single-kind value wins
setdef "$DD" Decisions '{labels: [needs-review, {text: Proposed, kind: {type: status, text: Status}}]}'
DQ=$("$SK/discovery/scripts/file-question.sh" "$DD" "Free" --round 1 --body "$T/dq.md" --model smoke | head -1 | sed 's#.*/##')
DR=$("$SK/discovery/scripts/file-record.sh" "$DD" "$DQ" --record ADR --title "Free sync" --body "$T/dadr.md" --model smoke | head -1 | sed 's#.*/##')
[ "$(labels_of "$DD" "$DR")" = "labels: [{text: ADR, rank: 1, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}, {text: needs-review, $TXT}]" ] \
  || { echo "file-record: lane defaults not unioned:"; labels_of "$DD" "$DR"; exit 1; }
nothing_to_heal "$DD" || { echo "file-record: board not clean"; exit 1; }
ok "file-record.sh: the Decisions lane's free label is added, its Proposed status is left out for the card's own accepted; validates, heal finds nothing"

# 2. file-question: a default matching the card's own label (case-insensitive, same kind) is not added twice
setdef "$DD" Asked '{labels: [urgent, {text: ROUND 1, kind: {type: round, text: Round}}]}'
DO=$("$SK/discovery/scripts/file-question.sh" "$DD" "Two" --round 1 --body "$T/dq.md" --model smoke 2>&1); DQ2=$(head -1 <<<"$DO" | sed 's#.*/##')
! grep -q 'lint-ask warning' <<<"$DO" || { echo "$DO"; exit 1; }
[ "$(labels_of "$DD" "$DQ2")" = "labels: [{text: Round 1, kind: {type: round, text: Round}}, {text: urgent, $TXT}]" ] || { echo "file-question: lane defaults not unioned:"; labels_of "$DD" "$DQ2"; exit 1; }
grep -q '^waiting: {for: ' "$(ls "$DD"/*/"$DQ2"/index.md)" || { echo "file-question: waiting lost"; exit 1; }
nothing_to_heal "$DD" || { echo "file-question: board not clean"; exit 1; }
ok "file-question.sh: 'urgent' is added, 'ROUND 1' of the same kind is not repeated; the ask lints clean and waiting stays; validates, heal finds nothing"

# 3. file-ticket: kinded entries stamped from config.labels; Blocked has no defaults
DP="$T/Defaults Plan.lanework"; "$SK/plan/scripts/found-plan-board.sh" "$DP" --labels priority --model smoke >/dev/null
setdef "$DP" Frontier '{labels: [{text: Grilling, kind: {type: ticket}}, {text: urgent, kind: {type: priority}}, extra]}'
DT1=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Rates" --type research --body "$T/t.md" --model smoke | head -1); DT1=${DT1##*/}
DT2=$("$SK/plan/scripts/file-ticket.sh" "$DP" "After rates" --type task --body "$T/t.md" --depends "lanework://$(sed -n 's/^id: //p' "$DP/index.md")/$DT1" --model smoke | head -1); DT2=${DT2##*/}
[ "$(labels_of "$DP" "$DT1")" = "labels: [{text: Research, rank: 2, icon: {glyph: magnifyingglass}, kind: {type: ticket, text: Ticket}}, {text: Urgent, rank: 0, color: \"#C8283C\", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}, {text: extra, $TXT}]" ] \
  || { echo "file-ticket: lane defaults not unioned:"; labels_of "$DP" "$DT1"; exit 1; }
[ "$(labels_of "$DP" "$DT2")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}]" ] || { echo "file-ticket: Blocked got defaults:"; labels_of "$DP" "$DT2"; exit 1; }
nothing_to_heal "$DP" || { echo "file-ticket: board not clean"; exit 1; }
ok "file-ticket.sh: Frontier's 'urgent' is stamped from the board's priority kind (rank, colour, glyph), 'extra' is a free label, the single-kind ticket default yields to the card's own; Blocked adds nothing"

# 4. a single kind with several lane values: the lowest rank is kept, and the card's own value beats them all
setdef "$DP" Frontier '{labels: [{text: High, kind: {type: priority}}, {text: Urgent, kind: {type: priority}}, {text: Task, kind: {type: ticket}}, {text: Grilling, kind: {type: ticket}}]}'
DT3=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Hammer" --type prototype --body "$T/t.md" --model smoke | head -1); DT3=${DT3##*/}
[ "$(labels_of "$DP" "$DT3")" = "labels: [{text: Prototype, rank: 3, icon: {glyph: hammer}, kind: {type: ticket, text: Ticket}}, {text: Urgent, rank: 0, color: \"#C8283C\", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]" ] \
  || { echo "single kind: wrong pick:"; labels_of "$DP" "$DT3"; exit 1; }
setdef "$DD" Decisions '{labels: [{text: superseded, kind: {type: status}}, {text: deprecated, kind: {type: status}}]}'
DR2=$("$SK/discovery/scripts/file-record.sh" "$DD" "$DQ2" --record PDR --title "Also free" --body "$T/dadr.md" --model smoke | head -1 | sed 's#.*/##')
[ "$(labels_of "$DD" "$DR2")" = "labels: [{text: PDR, rank: 2, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}]" ] || { echo "single kind: own value did not win:"; labels_of "$DD" "$DR2"; exit 1; }
nothing_to_heal "$DP" && nothing_to_heal "$DD" || { echo "single kind: board not clean"; exit 1; }
ok "single kind: of High and Urgent the lower rank (Urgent) is kept; the card's own accepted beats superseded and deprecated; heal finds nothing"

# 5. no defaults (or none with labels) change nothing; a malformed card-defaults refuses and writes nothing
for v in - '{note: 1}' '{labels: []}'; do
  setdef "$DP" Frontier "$v"; DT4=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Plain" --type grilling --body "$T/t.md" --model smoke | head -1); DT4=${DT4##*/}
  [ "$(labels_of "$DP" "$DT4")" = "labels: [{text: Grilling, rank: 1, icon: {glyph: bubble.left.and.bubble.right}, kind: {type: ticket, text: Ticket}}]" ] || { echo "no-op ($v) changed the labels:"; labels_of "$DP" "$DT4"; exit 1; }
done
for v in nope '[x]' '{labels: {a: 1}}'; do
  setdef "$DP" Frontier "$v"; setdef "$DD" Asked "$v"; setdef "$DD" Decisions "$v"; S5=$(sum "$DP")$(sum "$DD")
  ! "$SK/plan/scripts/file-ticket.sh" "$DP" "Bad" --type grilling --body "$T/t.md" --model smoke >/dev/null 2>"$T/err.txt" || { echo "file-ticket accepted card-defaults $v"; exit 1; }
  ! "$SK/discovery/scripts/file-question.sh" "$DD" "Bad" --round 1 --body "$T/dq.md" --model smoke >/dev/null 2>>"$T/err.txt" || { echo "file-question accepted card-defaults $v"; exit 1; }
  ! "$SK/discovery/scripts/file-record.sh" "$DD" "$DQ2" --record ADR --title Bad --body "$T/dadr.md" --model smoke >/dev/null 2>>"$T/err.txt" || { echo "file-record accepted card-defaults $v"; exit 1; }
  [ "$S5" = "$(sum "$DP")$(sum "$DD")" ] || { echo "a refused filing wrote something ($v)"; exit 1; }
done
grep -q 'card-defaults' "$T/err.txt" || { echo "the refusal does not name card-defaults:"; cat "$T/err.txt"; exit 1; }
setdef "$DP" Frontier '{labels: solo}'; DT5=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Solo" --type task --body "$T/t.md" --model smoke | head -1); DT5=${DT5##*/}
[ "$(labels_of "$DP" "$DT5")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: solo, $TXT}]" ] || { echo "a bare-name labels: is one free label:"; labels_of "$DP" "$DT5"; exit 1; }
ok "no card-defaults, none with labels, or an empty list; labels: <name> is one free label: the card is the template's own; a card-defaults that is a scalar or a list, or labels that is a mapping, exits non-zero naming card-defaults, in all three scripts, and writes nothing"

# 6. a bare number or boolean is the text as typed (1.10 stays 1.10), in the list and as the one-name scalar
setdef "$DP" Frontier '={labels: [v1, 2026, 1.10, true, "2027"]}'
DT6=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Typed" --type task --body "$T/t.md" --model smoke | head -1); DT6=${DT6##*/}
[ "$(labels_of "$DP" "$DT6")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: v1, $TXT}, {text: 2026, $TXT}, {text: 1.10, $TXT}, {text: true, $TXT}, {text: 2027, $TXT}]" ] \
  || { echo "typed scalars in card-defaults.labels not read as typed:"; labels_of "$DP" "$DT6"; exit 1; }
nothing_to_heal "$DP" || { echo "typed scalars: board not clean"; exit 1; }
for v in 2026 1.10 true; do
  setdef "$DP" Frontier "={labels: $v}"
  DT7=$("$SK/plan/scripts/file-ticket.sh" "$DP" "One $v" --type task --body "$T/t.md" --model smoke | head -1); DT7=${DT7##*/}
  [ "$(labels_of "$DP" "$DT7")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: $v, $TXT}]" ] || { echo "labels: $v is not one free label:"; labels_of "$DP" "$DT7"; exit 1; }
done
nothing_to_heal "$DP" || { echo "scalar labels: board not clean"; exit 1; }
ok "card-defaults.labels: a bare 2026, 1.10 or true is the label as typed, in a list and as the lone name; each validates and heal finds nothing"

# 7. the union is case-insensitive: a repeat within the lane's list, and a default equal to the card's own free label
setdef "$DP" Frontier '={labels: [extra, EXTRA, Extra]}'
DT8=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Cased" --type task --body "$T/t.md" --model smoke | head -1); DT8=${DT8##*/}
[ "$(labels_of "$DP" "$DT8")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: extra, $TXT}]" ] || { echo "case-variants not merged:"; labels_of "$DP" "$DT8"; exit 1; }
setdef "$DP" Frontier -; setdef "$DP" Blocked -
mkdir -p "$T/ulu"; printf -- '---\nschema: 1\nkind: card\ntitle: "x"\norder: 1024\nlabels: [{text: Mixed, %s}]\ncreated:  {at: 2026-10-01T00:00:00Z, by: {name: claude}}\n---\n' "$TXT" > "$T/ulu/fm.md"
setdef "$DP" Blocked '={labels: [mixed, MIXED, other]}'
( . "$SK/lanework/scripts/lib.sh"; union_lane_defaults "$(lane_of "$DP" Blocked | sed 's#/index.md$##')" "$DP" "$T/ulu/fm.md" )
[ "$(flowed "$T/ulu/fm.md" | grep '^labels:')" = "labels: [{text: Mixed, $TXT}, {text: other, $TXT}]" ] || { echo "a default equal to the card's own free label (case aside) was added:"; flowed "$T/ulu/fm.md"; exit 1; }
setdef "$DP" Blocked -
ok "union_lane_defaults: 'extra', 'EXTRA' and 'Extra' in the lane make one label; a default equal to the card's own free label, case aside, is not added"

# 8. typed text applies to names only: a kinded default's numeric rank stays a number on the card
setdef "$DP" Frontier '={labels: [{text: Critical, rank: 5, kind: {type: priority}}, {text: Odd, rank: 2, kind: {type: epic}}, 2026, {text: 1.10, kind: {type: text}}]}'
DT9=$("$SK/plan/scripts/file-ticket.sh" "$DP" "Ranked" --type task --body "$T/t.md" --model smoke | head -1); DT9=${DT9##*/}
python3 - "$(ls "$DP"/*/"$DT9"/index.md)" <<'PYEND' || { echo "a kinded default's rank or a typed name came out wrong:"; labels_of "$DP" "$DT9"; exit 1; }
import sys, yaml
L = yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1])["labels"]
by = {l["text"]: l for l in L}
assert [l["text"] for l in L] == ["Task", "Critical", "Odd", "2026", "1.10"], [l["text"] for l in L]
assert by["Critical"]["rank"] == 5 and type(by["Critical"]["rank"]) is int, by["Critical"]
assert by["Odd"]["rank"] == 2 and type(by["Odd"]["rank"]) is int, by["Odd"]
assert by["Critical"]["kind"]["type"] == "priority" and by["Odd"]["kind"]["type"] == "epic"
PYEND
setdef "$DP" Frontier -
ok "card-defaults: a kinded entry's rank stays an integer on the card (listed-kind and undefined-kind alike), while bare 2026 and {text: 1.10} still read as typed names"

# work: the board-write helpers. file-card, move-card and post-ask on a copy of the pipeline board with a v118 guide line and the
# borrowed .schema copied in (each script validates through the board's own validator); commit-board in a temp repo with a bare origin
FC="$SK/work/scripts/file-card.sh"; MC="$SK/work/scripts/move-card.sh"; PA="$SK/work/scripts/post-ask.sh"; LST="$SK/work/scripts/lint-stamps.sh"
WB="$T/Helpers.lanework"; cp -R "$P" "$WB"; cp -R "$VAL" "$WB/.schema"
printf '<!-- lanework-agent-guide v118 -->\n\nThis machine'"'"'s human answers to `@owner`.\n' > "$WB/CLAUDE.md"
lanedir() { dirname "$(lane_of "$1" "$2")"; }
cardf() { ls "$WB"/*/"$1"/index.md; }
# others <board> <rel path>...: one hash over every file of the board outside the named paths
others() { local b=$1 f x skip; shift; (cd "$b" && find . -type f | sed 's#^\./##' | LC_ALL=C sort | while IFS= read -r f; do
  skip=; for x in "$@"; do case "$f" in "$x"|"$x"/*) skip=1 ;; esac; done; [ -n "$skip" ] || shasum "$f"; done) | shasum; }
rel() { printf '%s' "${1#"$WB"/}"; }
fmline() { grep -m1 "^$2:" "$1"; }
atof() { sed -n "s/^$2: *{at: \([^,}]*\).*/\1/p" "$1" | head -1; }
BYF='{name: fixer, kind: agent, model: smoke, session: "smoke"}'

# file-card: an empty lane, a timed call (the hand-rolled glob read stdin and hung there); 1024, the caller's stamp, nothing else touched
printf 'Ship the thing.\n\n## Done when\n\n- it ships\n' > "$T/fc.md"; AP=$(lanedir "$WB" Approved)
[ "$(ls "$AP")" = index.md ] || { echo "Approved is not empty"; exit 1; }
S8=$(others "$WB"); t0=$(date -u +%FT%TZ)
# stdin is a pipe that stays open past the alarm: a stdin read hangs until the alarm kills it
F1=$(perl -e 'alarm 10; exec @ARGV' "$FC" "$WB" Approved "Fix: the thing" --body "$T/fc.md" --model smoke --name fixer --session smoke < <(sleep 12)) || { echo "file-card into an empty lane failed or hung"; exit 1; }
t1=$(date -u +%FT%TZ); C1F=$(basename "$F1"); CF="$AP/$C1F/index.md"
[ "$F1" = "$AP/$C1F" ] && [[ "$C1F" =~ ^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$ ]] || { echo "file-card printed $F1"; exit 1; }
[ "$(fmline "$CF" order)" = "order: 1024" ] && [ "$(fmline "$CF" kind)" = "kind: card" ] && [ "$(fmline "$CF" title)" = 'title: "Fix: the thing"' ] \
  && grep -qxF "created:  {at: $(atof "$CF" created), by: $BYF}" "$CF" && grep -qxF "modified: {at: $(atof "$CF" created), by: $BYF}" "$CF" \
  && [[ ! "$(atof "$CF" created)" < "$t0" && ! "$(atof "$CF" created)" > "$t1" ]] && ! grep -q '^labels:' "$CF" || { echo "file-card wrote:"; cat "$CF"; exit 1; }
[ "$(cd "$AP" && find . -type f | LC_ALL=C sort | tr '\n' ' ')" = "./$C1F/index.md ./index.md " ] && tail -n +2 "$CF" | sed '1,/^---$/d' | cmp -s - "$T/fc.md" || { echo "file-card left a stray file, or changed the body"; exit 1; }
[ "$S8" = "$(others "$WB" "$(rel "$AP/$C1F")")" ] && validate "$WB" >/dev/null && "$LST" "$WB" || { echo "file-card touched another file, or the board fails"; exit 1; }
F2=$("$FC" "$WB" Approved "Second" --body "$T/fc.md" --model smoke); C2F=$(basename "$F2")
[ "$(fmline "$F2/index.md" order)" = "order: 2048" ] && grep -q '^created:  {at: [^,]*, by: {name: claude, kind: agent, model: smoke}}$' "$F2/index.md" || { echo "file-card: second card:"; cat "$F2/index.md"; exit 1; }
ok "file-card.sh into an empty lane: order 1024 within 10 s with stdin held open, caller's by on created and modified from the clock, no temp file beside it, no other file changed; the next lands at max + 1024"
setdef "$DP" Frontier '{labels: [{text: High, kind: {type: priority}}, {text: Urgent, kind: {type: priority}}, extra]}'
F3=$("$FC" "$DP" Frontier "Defaulted" --body "$T/fc.md" --model smoke); C3F=$(basename "$F3")
[ "$(labels_of "$DP" "$C3F")" = "labels: [{text: Urgent, rank: 0, color: \"#C8283C\", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}, {text: extra, $TXT}]" ] \
  || { echo "file-card: lane defaults not unioned:"; labels_of "$DP" "$C3F"; exit 1; }
nothing_to_heal "$DP" || { echo "file-card: plan board not clean"; exit 1; }
setdef "$DP" Frontier -
ok "file-card.sh unions the lane's card-defaults (a single kind's lowest rank kept, a free label stamped as text), in the compact form; heal finds nothing"
S9=$(sum "$WB"); S9D=$(sum "$DP")
rc=0; "$FC" "$WB" "No such lane" "x" --body "$T/fc.md" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "file-card, missing lane: want exit 1, got $rc"; exit 1; }
rc=0; "$FC" "$WB" Approved "x" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "file-card, no --body: want exit 2, got $rc"; exit 1; }
printf -- '---\nkind: card\n---\nx\n' > "$T/fcfm.md"; rc=0; "$FC" "$WB" Approved "x" --body "$T/fcfm.md" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "file-card, body with frontmatter: want exit 1, got $rc"; exit 1; }
refused file-card "$FC" "$WB" Approved "x" --body "$T/fc.md"
setdef "$DP" Frontier nope; rc=0; "$FC" "$DP" Frontier "x" --body "$T/fc.md" --model smoke >/dev/null 2>&1 || rc=$?; setdef "$DP" Frontier -
[ "$rc" -eq 1 ] && [ "$S9" = "$(sum "$WB")" ] && [ "$S9D" = "$(sum "$DP")" ] || { echo "a refused file-card wrote something (rc $rc)"; exit 1; }
ok "file-card.sh: a missing lane and a malformed card-defaults exit 1, no --body and no --model exit 2, a body with frontmatter exits 1; nothing written"

# move-card: owner-filed cards (no by on any stamp) seeded by hand, two sharing a prefix, one waiting
IDEAS=$(lanedir "$WB" Ideas); OW1=abcd0000-0000-4000-8000-000000000001; OW2=abcd0000-0000-4000-8000-000000000002; AQ=abcd0000-0000-4000-8000-0000000000aa
for c in $OW1 $OW2; do mkdir -p "$IDEAS/$c"; printf -- '---\nschema: 1\nkind: card\ntitle: "Owner %s"\norder: %s\ncreated: {at: 2026-10-01T00:00:00Z}\nmodified: {at: 2026-10-01T00:00:00Z}\n---\nFiled in the app.\n' "${c: -1}" "${c: -1}024" > "$IDEAS/$c/index.md"; done
perl -pi -e "s/^modified:/waiting: {for: anyone, since: 2026-10-01T00:00:00Z, comment: $AQ}\nmodified:/" "$IDEAS/$OW2/index.md"
ISS=$(basename "$("$FC" "$WB" Issues "Broken" --body "$T/fc.md" --model smoke)")
ACT=$(lanedir "$WB" Active); validate "$WB" >/dev/null
# moved <card> <dest lane dir>: the card's body and every frontmatter line but order, modified and waiting are unchanged from <saved copy>
moved() { diff <(grep -v -E '^(order|modified|waiting):' "$3") <(grep -v -E '^(order|modified|waiting):' "$2/$1/index.md") >/dev/null; }
S10=$(others "$WB" "$(rel "$AP/$C1F")" "$(rel "$ACT/$C1F")"); cp "$AP/$C1F/index.md" "$T/mv1.md"; t0=$(date -u +%FT%TZ)
M1=$("$MC" "$WB" "${C1F:0:8}" Active --model smoke --name fixer --session smoke) || { echo "move-card from Approved failed"; exit 1; }
t1=$(date -u +%FT%TZ); MF="$ACT/$C1F/index.md"
[ "$M1" = "$ACT/$C1F" ] && [ ! -e "$AP/$C1F" ] && [ "$(fmline "$MF" order)" = "order: 1024" ] && grep -qxF "modified: {at: $(atof "$MF" modified), by: $BYF}" "$MF" \
  && [[ ! "$(atof "$MF" modified)" < "$t0" && ! "$(atof "$MF" modified)" > "$t1" ]] && moved "$C1F" "$ACT" "$T/mv1.md" || { echo "move-card from Approved wrote:"; cat "$MF"; exit 1; }
[ "$S10" = "$(others "$WB" "$(rel "$AP/$C1F")" "$(rel "$ACT/$C1F")")" ] && validate "$WB" >/dev/null && "$LST" "$WB" || { echo "move-card touched another file, or the board fails"; exit 1; }
"$MC" "$WB" "$ISS" Active --model smoke >/dev/null; [ "$(fmline "$ACT/$ISS/index.md" order)" = "order: 2048" ] && [ ! -e "$(lanedir "$WB" Issues)/$ISS" ] || { echo "move-card from Issues: not at max + 1024"; exit 1; }
"$MC" "$WB" "$C2F" Active --top --model smoke >/dev/null; [ "$(fmline "$ACT/$C2F/index.md" order)" = "order: 512" ] || { echo "move-card --top: want 512 (half of 1024)"; fmline "$ACT/$C2F/index.md" order; exit 1; }
ok "move-card.sh from Approved (by prefix) and from Issues: order max + 1024 (1024 into an empty lane), --top half the lowest, modified rewritten whole with the caller's by and the clock; nothing else changed; validates, lint-stamps clean"
S11=$(sum "$WB")
for p in ffffffff abcd0000 ABCD0000 '' 'abcd*'; do rc=0; "$MC" "$WB" "$p" Shaping --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "move-card '$p': want exit 2, got $rc"; exit 1; }; done
rc=0; "$MC" "$WB" "$OW1" "No such lane" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "move-card, missing lane: want exit 1, got $rc"; exit 1; }
rc=0; "$MC" "$WB" "$ISS" Active --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "move-card into its own lane: want exit 1, got $rc"; exit 1; }
rc=0; "$MC" "$WB" "$OW1" Shaping --top --bottom --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "move-card --top --bottom: want exit 2, got $rc"; exit 1; }
refused move-card "$MC" "$WB" "$OW1" Shaping
[ "$S11" = "$(sum "$WB")" ] || { echo "a refused move-card wrote something"; exit 1; }
ok "move-card.sh: no match, two prefix matches, an uppercase, empty or glob prefix exit 2; a missing lane or its own lane exit 1; --top with --bottom and no model exit 2; nothing written"
SH=$(lanedir "$WB" Shaping); PR=$(lanedir "$WB" Proposed); cp "$IDEAS/$OW2/index.md" "$T/mv2.md"
"$MC" "$WB" "$OW1" Shaping --model smoke --name fixer --session smoke >/dev/null
grep -qxF "modified: {at: $(atof "$SH/$OW1/index.md" modified), by: $BYF}" "$SH/$OW1/index.md" && grep -qxF 'created: {at: 2026-10-01T00:00:00Z}' "$SH/$OW1/index.md" || { echo "owner-filed card not stamped by the caller:"; cat "$SH/$OW1/index.md"; exit 1; }
"$MC" "$WB" "$OW2" Shaping --model smoke >/dev/null; grep -qxF "waiting: {for: anyone, since: 2026-10-01T00:00:00Z, comment: $AQ}" "$SH/$OW2/index.md" && moved "$OW2" "$SH" "$T/mv2.md" || { echo "move-card dropped waiting by default"; exit 1; }
printf 'Shaped: scope settled.\n\n**Evidence**: none needed.\n' > "$T/mvc.md"
"$MC" "$WB" "$OW2" Proposed --clear-waiting --comment "$T/mvc.md" --model smoke --name fixer --session smoke >/dev/null
! grep -q '^waiting:' "$PR/$OW2/index.md" && moved "$OW2" "$PR" "$T/mv2.md" || { echo "--clear-waiting left waiting, or changed another line"; cat "$PR/$OW2/index.md"; exit 1; }
MCF=$(ls "$PR/$OW2"/comments/*/index.md); [ "$(echo "$MCF" | wc -l | tr -d ' ')" -eq 1 ] && grep -q "^created:  {at: [^,]*, by: $BYF}\$" "$MCF" && grep -q 'Shaped: scope settled' "$MCF" || { echo "--comment did not carry the caller's by"; cat "$MCF"; exit 1; }
validate "$WB" >/dev/null && "$LST" "$WB" || exit 1
ok "move-card.sh: an owner-filed card (no by) comes out stamped by the caller, created untouched; waiting kept by default, dropped with --clear-waiting; --comment posts with the same by; validates, lint-stamps clean"
WG="$T/helpers-git"; mkdir -p "$WG"; cp -R "$WB" "$WG/Helpers.lanework"; gw() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 git -C "$WG" "$@"; }
gw init -q -b main && gw config user.name smoke && gw config user.email smoke@example.com && gw add -A && gw commit -q -m seed; h0=$(gw rev-parse HEAD)
"$MC" "$WG/Helpers.lanework" "$OW1" Proposed --model smoke >/dev/null
[ "$(gw rev-parse HEAD)" = "$h0" ] && gw diff --cached --quiet && [ -n "$(gw status --porcelain)" ] || { echo "move-card staged or committed in git"; gw status --short; exit 1; }
ok "move-card.sh in a git repo: the move is on disk only, nothing staged, nothing committed"

# post-ask: a record then the ask straight after; the ask waits for the next second, sets waiting to itself and restamps the card
printf '@anyone Ship the thing today?\n\nOptions:\n- A: Ship it.\n- B: Hold it.\n- Recap: Explain this in plain terms first\n\nWhy now: it is ready.\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/ask1.md"
sed 's/^@anyone /@kim /' "$T/ask1.md" > "$T/ask2.md"
# the record goes --ahead 1: an ask posted without the wait would land a second before it, every time
cp "$MF" "$T/pa1.md"; R1=$("$SK/work/scripts/post-comment.sh" "$WB" "$C1F" --body "$T/pc.md" --model smoke --ahead 1)
A1=$("$PA" "$WB" "$C1F" --body "$T/ask1.md" --for anyone --model smoke --name fixer --session smoke --in-reply-to "$R1") || { echo "post-ask failed"; exit 1; }
AF="$ACT/$C1F/comments/$A1/index.md"; RA=$(atof "$ACT/$C1F/comments/$R1/index.md" created); AA=$(atof "$AF" created)
[[ "$AA" > "$RA" ]] || { echo "the ask ($AA) is not after the record ($RA)"; exit 1; }
grep -qxF "waiting: {for: anyone, since: $AA, comment: $A1}" "$MF" && grep -qxF "modified: {at: $(atof "$MF" modified), by: $BYF}" "$MF" && [[ ! "$(atof "$MF" modified)" < "$AA" ]] \
  && grep -qxF "in-reply-to: $R1" "$AF" && moved "$C1F" "$ACT" "$T/pa1.md" || { echo "post-ask: waiting or modified wrong:"; cat "$MF"; exit 1; }
"$SK/work/scripts/lint-ask.sh" "$AF" "$WB" && validate "$WB" >/dev/null && "$LST" "$WB" || { echo "post-ask: the landed ask fails lint, or the board fails"; exit 1; }
A2=$("$PA" "$WB" "$ISS" --body "$T/ask2.md" --for kim --model smoke) && grep -qxF "waiting: {for: kim, since: $(atof "$ACT/$ISS/comments/$A2/index.md" created), comment: $A2}" "$ACT/$ISS/index.md" \
  && "$SK/work/scripts/lint-ask.sh" "$ACT/$ISS/comments/$A2/index.md" "$WB" || { echo "post-ask --for kim:"; cat "$ACT/$ISS/index.md"; exit 1; }
ok "post-ask.sh: the ask lands after a record stamped a second ahead, waiting.comment is its uuid and since its created.at, modified restamped by the caller; --for anyone and --for kim both lint clean"
S12=$(sum "$WB")
printf '@kim maybe ship it; worth a try? and also this?\n' > "$T/ask3.md"
rc=0; "$PA" "$WB" "$C2F" --body "$T/ask3.md" --for kim --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "post-ask, a failing ask for a person: want exit 1, got $rc"; exit 1; }
sed 's/^@kim /@anyone /' "$T/ask3.md" > "$T/ask4.md"; rc=0; "$PA" "$WB" "$C2F" --body "$T/ask4.md" --for anyone --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "post-ask, a failing ask: want exit 1, got $rc"; exit 1; }
rc=0; "$PA" "$WB" "$C2F" --body "$T/ask1.md" --for kim --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "post-ask, --for not on line 1: want exit 1, got $rc"; exit 1; }
rc=0; "$PA" "$WB" "$C2F" --body "$T/ask1.md" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "post-ask, no --for: want exit 2, got $rc"; exit 1; }
rc=0; "$PA" "$WB" "${C2F:0:8}" --body "$T/ask1.md" --for anyone --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "post-ask, a prefix: want exit 1, got $rc"; exit 1; }
refused post-ask "$PA" "$WB" "$C2F" --body "$T/ask1.md" --for anyone
[ "$S12" = "$(sum "$WB")" ] && ! grep -q '^waiting:' "$ACT/$C2F/index.md" || { echo "a refused post-ask wrote something"; exit 1; }
ok "post-ask.sh: a body failing lint-ask (for a person, and for anyone), --for not on line 1, a prefix uuid exit 1; no --for and no model exit 2; nothing written, waiting unset"

# commit-board: a temp repo with a bare origin and a second clone; global and system git config shut out, identity set in each repo
CB="$SK/work/scripts/commit-board.sh"; G="$T/cb"; mkdir -p "$G"
gx() { GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 git "$@"; }; g() { gx -C "$G/work" "$@"; }; go() { gx -C "$G/other" "$@"; }
cb() { (cd "$G/work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$CB" "$@"); }
gx init -q --bare -b main "$G/origin.git"; gx init -q -b main "$G/work"; g config user.name smoke; g config user.email smoke@example.com
CP="B.lanework/lane/card/index.md"; mkdir -p "$G/work/B.lanework/lane/card"; echo a > "$G/work/$CP"; echo x > "$G/work/notes.txt"
g add -A; g commit -q -m seed; g remote add origin "$G/origin.git"; g push -q -u origin main 2>/dev/null
gx clone -q "$G/origin.git" "$G/other"; go config user.name other; go config user.email other@example.com
echo y > "$G/work/notes.txt"; g stash -q; echo z > "$G/work/notes.txt"; g add notes.txt; echo junk > "$G/work/junk.txt"; echo b > "$G/work/$CP"
st0=$(g stash list | wc -l | tr -d ' '); o0=$(gx --git-dir="$G/origin.git" rev-parse main)
O=$(cb "B: card edited" "$CP") || { echo "commit-board failed: $O"; exit 1; }
[ "$(g show --name-only --format= HEAD)" = "$CP" ] && [ "$(g log -1 --format=%B | sed '/^$/d')" = "B: card edited" ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$o0" ] \
  && [ "$(g diff --cached --name-only)" = notes.txt ] && [ "$(g status --porcelain -- "$CP")" = "" ] && [ "$(g status --porcelain -- junk.txt)" = "?? junk.txt" ] \
  && [ "$(g stash list | wc -l | tr -d ' ')" = "$st0" ] || { echo "commit-board: wrong commit or touched the rest:"; g log -1 --stat; g status --short; exit 1; }
ok "commit-board.sh commits only the named path: the owner's staged and untracked files stay as they were, no trailer, no push without --push, stash count unchanged"
echo c > "$G/work/$CP"; cb --push --trailer "Claude-Session: smoke" --trailer "Reviewed-by: smoke" "B: pushed" "$CP" >/dev/null || { echo "commit-board --push failed"; exit 1; }
[ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] && [ "$(g log -1 --format=%B | sed '/^$/d' | tr '\n' '|')" = "B: pushed|Claude-Session: smoke|Reviewed-by: smoke|" ] || { echo "commit-board --push --trailer:"; g log -1; exit 1; }
# a rejected push: the pre-push hook lands another clone's commit first, once; the script un-commits, fast-forwards and retries
cat > "$G/work/.git/hooks/pre-push" <<HOOK
#!/bin/bash
[ -e "$G/hooked" ] && exit 0; touch "$G/hooked"; unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
cd "$G/other" && GIT_CONFIG_GLOBAL=/dev/null git pull -q && echo o > other.txt && GIT_CONFIG_GLOBAL=/dev/null git add other.txt && GIT_CONFIG_GLOBAL=/dev/null git commit -q -m other && GIT_CONFIG_GLOBAL=/dev/null git push -q 2>/dev/null
HOOK
chmod +x "$G/work/.git/hooks/pre-push"; echo d > "$G/work/$CP"
O=$(cb --push "B: retried" "$CP" 2>&1) || { echo "commit-board did not recover from a rejected push: $O"; exit 1; }
[ -e "$G/hooked" ] && grep -q 'rejected' <<<"$O" && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] && [ "$(g log -1 --format=%s HEAD^)" = other ] \
  && [ "$(g show --name-only --format= HEAD)" = "$CP" ] && [ -f "$G/work/other.txt" ] && [ "$(g log --format=%s | grep -c '^B: retried$')" -eq 1 ] || { echo "rejected push, retry: $O"; g log --oneline -4; exit 1; }
rm -f "$G/work/.git/hooks/pre-push"
ok "commit-board.sh --push lands on origin, trailers only from --trailer, each once, two kept in order; a rejected push un-commits, fast-forwards over the other commit and retries once"
# a kill while the push hangs (a pre-push hook that sleeps, then refuses): HEAD has the commit and the index already matches it,
# so the owner's next plain commit cannot revert the board write; SIGKILL, then SIGTERM
printf '#!/bin/bash\ntouch "%s/inpush"; sleep 3; touch "%s/pushdone"; exit 1\n' "$G" "$G" > "$G/work/.git/hooks/pre-push"; chmod +x "$G/work/.git/hooks/pre-push"
for sig in KILL TERM; do
  rm -f "$G/inpush" "$G/pushdone"; echo "k$sig" > "$G/work/$CP"
  (cd "$G/work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: killed $sig" "$CP") >/dev/null 2>&1 & KP=$!
  perl -e 'alarm 10; exec @ARGV' bash -c "until [ -e '$G/inpush' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the push never reached the hook"; exit 1; }
  kill -"$sig" "$KP"; wait "$KP" 2>/dev/null || true
  perl -e 'alarm 10; exec @ARGV' bash -c "until [ -e '$G/pushdone' ]; do sleep 0.1; done"; sleep 0.5
  [ "$(g log -1 --format=%s)" = "B: killed $sig" ] && g diff --cached --quiet -- "$CP" && g diff --quiet -- "$CP" || { echo "killed ($sig) mid-push: the index does not match HEAD on $CP"; g status --short; g diff --cached --stat; exit 1; }
done
rm -f "$G/work/.git/hooks/pre-push"
ok "commit-board.sh killed mid-push (SIGKILL, SIGTERM): HEAD holds the commit and the index already matches it on the named path"
# diverged: the other clone and a local commit both change the card file
go pull -q; echo e > "$G/other/$CP"; go commit -q -am theirs; go push -q 2>/dev/null; echo f > "$G/work/$CP"; g commit -q -am ours; h1=$(g rev-parse HEAD)
echo g > "$G/work/$CP"; rc=0; O=$(cb --push "B: diverged" "$CP" 2>&1) || rc=$?
[ "$rc" -eq 1 ] && grep -qxF "  $CP" <<<"$O" && [ "$(g rev-parse HEAD)" = "$h1" ] && [ "$(g stash list | wc -l | tr -d ' ')" = "$st0" ] || { echo "diverged: want exit 1 naming $CP, HEAD kept (rc $rc): $O"; exit 1; }
g reset -q --hard origin/main; g stash list >/dev/null
# dirty overlap: origin changed a file the owner has uncommitted edits to
go pull -q; echo h > "$G/other/notes.txt"; go commit -q -am notes; go push -q 2>/dev/null; echo mine > "$G/work/notes.txt"; echo i > "$G/work/$CP"; h2=$(g rev-parse HEAD)
rc=0; O=$(cb "B: overlap" "$CP" 2>&1) || rc=$?
[ "$rc" -eq 1 ] && grep -qx '  notes.txt' <<<"$O" && [ "$(g rev-parse HEAD)" = "$h2" ] && [ "$(cat "$G/work/notes.txt")" = mine ] || { echo "dirty overlap: want exit 1 naming notes.txt (rc $rc): $O"; exit 1; }
g checkout -q -- notes.txt; cb "B: caught up" "$CP" >/dev/null && [ "$(g log -1 --format=%s HEAD^)" = notes ] || { echo "commit-board did not fast-forward first"; exit 1; }
[ "$(g stash list | wc -l | tr -d ' ')" = "$st0" ] || { echo "stash count changed"; exit 1; }
ok "commit-board.sh stops (exit 1, HEAD kept) on a diverged branch and on a dirty overlap, naming the file each time; otherwise fast-forwards first; stash count unchanged throughout"
# refusals: outside the work tree, the root, .DS_Store named or inside a named folder, a glob pathspec, no paths
h3=$(g rev-parse HEAD); echo j > "$G/work/$CP"; echo k > "$T/outside.md"; touch "$G/work/B.lanework/lane/card/.DS_Store"
for a in "$T/outside.md" ../outside.md . "$G/work" B.lanework/lane/card/.DS_Store B.lanework/lane/card; do
  rc=0; cb "B: refused" "$a" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] && [ "$(g rev-parse HEAD)" = "$h3" ] || { echo "commit-board '$a': want exit 1 and no commit, got $rc"; exit 1; }
done
rc=0; cb "B: no paths" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "commit-board with no paths: want exit 2, got $rc"; exit 1; }
rc=0; cb --trailer >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "commit-board --trailer with no value: want exit 2, got $rc"; exit 1; }
rm -f "$G/work/B.lanework/lane/card/.DS_Store"; mkdir -p "$G/work/B.lanework/lane/card/comments/.draft"; echo draft > "$G/work/B.lanework/lane/card/comments/.draft/index.md"
rc=0; cb "B: draft" B.lanework/lane/card >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] && [ "$(g rev-parse HEAD)" = "$h3" ] || { echo "commit-board: a folder holding an owner's draft: want exit 1, got $rc"; exit 1; }
rm -rf "$G/work/B.lanework/lane/card/comments"
ok "commit-board.sh refuses a path outside the work tree, the root, .DS_Store named or inside a named folder, and an owner's comments/.draft (exit 1, no commit); no paths exits 2"
O=$(cb "B: one gone" B.lanework/old/card/index.md "$CP" 2>&1) && grep -q 'B.lanework/old/card/index.md is neither on disk nor in HEAD' <<<"$O" && [ "$(g show --name-only --format= HEAD)" = "$CP" ] \
  || { echo "commit-board: a never-committed old path beside a real one: $O"; exit 1; }
BR="B.lanework/lane [x]/i?.md"; mkdir -p "$G/work/B.lanework/lane [x]"; echo q > "$G/work/$BR"
cb "B: brackets" "$BR" >/dev/null && [ "$(g show --name-only --format= HEAD)" = "$BR" ] || { echo "commit-board: a real path with [ and ? was not committed"; exit 1; }
h4=$(g rev-parse HEAD); O=$(cb "B: glob" '*.md' 2>&1) && grep -q '^nothing to commit$' <<<"$O" && [ "$(g rev-parse HEAD)" = "$h4" ] || { echo "commit-board: a glob matching no path: $O"; exit 1; }
h3=$(g rev-parse HEAD); echo j2 > "$G/work/$CP"
ok "commit-board.sh skips a named path neither on disk nor in HEAD (a card's old lane path, filed since; a glob, read literally) and commits the rest; a real path with [ and ? commits"
# the lock: held by a live pid, the second invocation waits; held by a dead pid, it is reclaimed
LK="$(cd "$G/work" && cd "$(gx rev-parse --git-common-dir)" && pwd -P)/lanework-commit-board.lock"
sleep 30 & HP=$!; mkdir "$LK"; echo "$HP" > "$LK/pid"
( cb "B: after the lock" "$CP" > "$T/cb-wait.txt" 2>&1; echo "exit $?" >> "$T/cb-wait.txt" ) & WP=$!
sleep 2; [ "$(g rev-parse HEAD)" = "$h3" ] && grep -q "$HP" "$T/cb-wait.txt" || { kill "$HP" "$WP" 2>/dev/null; echo "commit-board did not wait on a live lock:"; cat "$T/cb-wait.txt"; exit 1; }
kill "$HP"; wait "$HP" 2>/dev/null || true; perl -e 'alarm 20; exec @ARGV' bash -c "while kill -0 $WP 2>/dev/null; do sleep 0.2; done" || { echo "commit-board hung after the holder died"; exit 1; }
grep -q '^exit 0$' "$T/cb-wait.txt" && [ "$(g log -1 --format=%s)" = "B: after the lock" ] && [ ! -e "$LK" ] || { echo "commit-board after a lock:"; cat "$T/cb-wait.txt"; exit 1; }
sh -c 'exit 0' & DPID=$!; wait "$DPID"; mkdir "$LK"; echo "$DPID" > "$LK/pid"; echo l > "$G/work/$CP"
perl -e 'alarm 20; exec @ARGV' bash -c "cd '$G/work' && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 '$CB' 'B: reclaimed' '$CP'" >/dev/null 2>&1 && [ "$(g log -1 --format=%s)" = "B: reclaimed" ] && [ ! -e "$LK" ] || { echo "commit-board did not reclaim a dead pid's lock"; exit 1; }
ok "commit-board.sh waits while the lock's pid is alive, then commits; a dead pid's lock is reclaimed; the lock is gone after"

# release gate (advisory): the Skills Pipeline board's guide and schema newer than the stamp is a note, never a failure
BG=$(head -1 "$VAL/../CLAUDE.md" | grep -o -E 'lanework-agent-guide v[0-9]+' | grep -o -E '[0-9]+$' || true)
BS=$(head -1 "$VAL/VERSION" | tr -d '\r' | grep -o -E 'lanework-schema v[0-9]+ *$' | grep -o -E '[0-9]+' || true)
if [ -z "$BG" ] || [ -z "$BS" ]; then
  echo "note: can't read the board's guide or schema version; check the stamp ($S, $SV) against the board by hand"
  ok "the board's guide and schema version are unreadable: advisory note, not a failure"
elif [ "$BG" -gt "${S##*v}" ] || [ "$BS" -gt "${SV##*v}" ]; then
  echo "note: the board is ahead of the stamp (guide v$BG, schema v$BS; stamp guide v${S##*v}, schema v${SV##*v}): read every skill against it, fix the drift, then bump the stamp in CLAUDE.md"
  ok "the board (guide v$BG, schema v$BS) is ahead of the stamp ($S, $SV): advisory note, not a failure"
else
  ok "the stamp ($S, $SV) is not behind the board's guide v$BG and schema v$BS"
fi

# release.sh warns, never stops, when the board's guide or schema is ahead of the stamp: a scratch repo on a branch
# other than main, so the run ends at its first hard check ("not on main") whether or not it warned
R="$T/release-warn"; mkdir -p "$R/scripts" "$R/Boards/Skills Pipeline.lanework/.schema"; cp "$ROOT/scripts/release.sh" "$R/scripts/"
printf 'stamp: lanework-agent-guide v10, lanework-schema v1\n' > "$R/CLAUDE.md"
printf '<!-- lanework-agent-guide v11 - app guide -->\n' > "$R/Boards/Skills Pipeline.lanework/CLAUDE.md"; printf 'lanework-schema v1\n' > "$R/Boards/Skills Pipeline.lanework/.schema/VERSION"
git -C "$R" init -q -b scratch && git -C "$R" add -A && git -C "$R" -c user.name=smoke -c user.email=smoke@example.com commit -q -m seed
rw() { (cd "$R" && scripts/release.sh 9.9.9 --dry-run 2>&1 >/dev/null; echo "exit $?"); }
W=$(rw); WC=$(grep -c 'warning: the board in' <<<"$W" || true)
[ "$WC" -eq 2 ] && grep -q 'guide v11, schema v1; stamp guide v10, schema v1' <<<"$W" && grep -q 'not on main' <<<"$W" && grep -q '^exit 1$' <<<"$W" || { echo "release.sh should warn for the working tree and HEAD, then stop at its own check: $W"; exit 1; }
printf 'stamp: lanework-agent-guide v11, lanework-schema v1\n' > "$R/CLAUDE.md"
W=$(rw); { ! grep -q warning <<<"$W" && grep -q 'not on main' <<<"$W" && grep -q '^exit 1$' <<<"$W"; } || { echo "release.sh should not warn when the stamp is current: $W"; exit 1; }
# a missing board folder, or a board CLAUDE.md missing from HEAD, is no reason for the advisory block to stop the script
git -C "$R" rm -q -r --cached "Boards" >/dev/null && git -C "$R" -c user.name=smoke -c user.email=smoke@example.com commit -q -m unboard && rm -rf "${R:?}/Boards"
W=$(rw); { ! grep -q -i 'warning\|line [0-9]' <<<"$W" && grep -q 'not on main' <<<"$W" && grep -q '^exit 1$' <<<"$W"; } || { echo "release.sh should reach its own check with no board folder: $W"; exit 1; }
rm -f "$R/CLAUDE.md"; W=$(rw); { ! grep -q -i 'warning\|line [0-9]\|No such' <<<"$W" && grep -q 'not on main' <<<"$W" && grep -q '^exit 1$' <<<"$W"; } || { echo "release.sh should reach its own check with no CLAUDE.md: $W"; exit 1; }
ok "release.sh warns (working tree and HEAD) when the board is ahead of the stamp, stays quiet when not, and exits the same either way"

# cite-as: scripts mint a citation and write a bare title only on a board whose guide line reads v117 or later (cite_enabled); the throwaway boards state their stamp
# cite-as: on a board whose guide line reads v117 or later the filing scripts mint a citation and write a bare title
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"; printf 'Sync is free.\n' > "$T/cr.md"; printf 'Where does the engine run?\n' > "$T/ct.md"
cq() { "$SK/discovery/scripts/file-question.sh" "$1" "$2" --round 1 --body "$T/cq.md" --model smoke 2>&1; }
cc() { head -1 <<<"$1" | sed 's#.*/##'; }
CA="$T/CiteA Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$CA" --model smoke >/dev/null; mkguide "$CA" 117
CO1=$(cq "$CA" "Pricing"); CO2=$(cq "$CA" "Engine: placement"); CQ1=$(cc "$CO1"); CQ2=$(cc "$CO2")
CF1=$(ls "$CA"/*/"$CQ1"/index.md); CF2=$(ls "$CA"/*/"$CQ2"/index.md)
{ grep -qx 'cite-as: Q1' "$CF1" && grep -qx 'title: "Pricing"' "$CF1" && grep -qx 'cite-as: Q2' "$CF2" && grep -qxF 'title: "Engine: placement"' "$CF2" \
  && grep -qx 'cite Q1' <<<"$CO1" && grep -qx 'cite Q2' <<<"$CO2" && ! grep -q 'lint-ask warning' <<<"$CO1$CO2"; } || { echo "questions not minted Q1, Q2 with bare titles:"; echo "$CO1"; head -8 "$CF1" "$CF2"; exit 1; }
CR1=$("$SK/discovery/scripts/file-record.sh" "$CA" "$CQ1" --record ADR --title "Sync engine" --body "$T/cr.md" --model smoke)
CR2=$("$SK/discovery/scripts/file-record.sh" "$CA" "$CQ1" --record ADR --title "Sync cache" --body "$T/cr.md" --supersedes "$(cc "$CR1")" --model smoke)
CR3=$("$SK/discovery/scripts/file-record.sh" "$CA" "$CQ1" --record PDR --title "Sync is free" --body "$T/cr.md" --model smoke)
RF1=$(ls "$CA"/*/"$(cc "$CR1")"/index.md); RF2=$(ls "$CA"/*/"$(cc "$CR2")"/index.md); RF3=$(ls "$CA"/*/"$(cc "$CR3")"/index.md)
{ grep -qx 'cite-as: ADR1' "$RF1" && grep -qx 'title: "Sync engine"' "$RF1" && grep -qx 'cite-as: ADR2' "$RF2" && grep -qx 'cite-as: PDR1' "$RF3" && grep -qx 'title: "Sync is free"' "$RF3" \
  && grep -qx 'cite ADR1' <<<"$CR1" && grep -qx 'cite PDR1' <<<"$CR3" && [ "$(ls "$(dirname "$RF2")"/relations/*/index.md | wc -l | tr -d ' ')" -eq 1 ]; } || { echo "records not minted ADR1, ADR2, PDR1:"; head -9 "$RF1" "$RF2" "$RF3"; exit 1; }
[ "$(grep -h '^cite-as:' "$CA"/*/*/index.md | wc -l | tr -d ' ')" -eq 5 ] && [ -z "$(grep -h '^cite-as:' "$CA"/*/*/index.md | sort | uniq -d)" ] || { echo "citations not five and distinct"; exit 1; }
CP="$T/CiteA Plan.lanework"; "$PS/found-plan-board.sh" "$CP" --model smoke >/dev/null; mkguide "$CP" 117
CT1=$("$PS/file-ticket.sh" "$CP" "Engine: placement" --type grilling --body "$T/ct.md" --model smoke); CT2=$("$PS/file-ticket.sh" "$CP" "Rate limits" --type research --body "$T/ct.md" --model smoke)
TF1=$(ls "$CP"/*/"$(cc "$CT1")"/index.md); TF2=$(ls "$CP"/*/"$(cc "$CT2")"/index.md)
{ grep -qx 'cite-as: T1' "$TF1" && grep -qxF 'title: "Engine: placement"' "$TF1" && grep -qx 'cite-as: T2' "$TF2" && grep -qx 'title: "Rate limits"' "$TF2" && grep -qx 'T1 -> Frontier' <<<"$CT1"; } || { echo "tickets not minted T1, T2 with bare titles:"; echo "$CT1"; head -8 "$TF1"; exit 1; }
validate "$CA" >/dev/null; validate "$CP" >/dev/null; ok "cite v117 mint: file-question, file-record and file-ticket write cite-as (Q1 Q2, ADR1 ADR2 PDR1, T1 T2) with a bare title and print it; --supersedes still works; both boards validate with five distinct citations"
# cite-as: a number is never reissued: a trashed card's, a trashed lane's, or a legacy title prefix's
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"
cq() { "$SK/discovery/scripts/file-question.sh" "$1" "$2" --round 1 --body "$T/cq.md" --model smoke 2>&1; }
cc() { head -1 <<<"$1" | sed 's#.*/##'; }
cite_of_card() { sed -n 's/^cite-as: //p' "$(ls "$1"/*/"$2"/index.md "$1"/.trash/"$2"/index.md "$1"/.trash/*/"$2"/index.md 2>/dev/null | head -1)"; }
CB="$T/CiteB Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$CB" --model smoke >/dev/null; mkguide "$CB" 117
BQ1=$(cc "$(cq "$CB" one)"); BQ2=$(cc "$(cq "$CB" two)")
mkdir -p "$CB/.trash"; mv "$(ls -d "$CB"/*/"$BQ2")" "$CB/.trash/"
BO3=$(cq "$CB" three); BQ3=$(cc "$BO3")
[ "$(cite_of_card "$CB" "$BQ3")" = Q3 ] && grep -qx 'cite Q3' <<<"$BO3" || { echo "a flat-trashed Q2 was reissued:"; echo "$BO3"; exit 1; }
BL=$(uuidgen | tr A-Z a-z); mkdir -p "$CB/.trash/$BL"
printf -- '---\nschema: 1\nkind: lane\ntitle: "Gone"\norder: 9000\ncreated: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\n' > "$CB/.trash/$BL/index.md"
mv "$(ls -d "$CB"/*/"$BQ3")" "$CB/.trash/$BL/"
BO4=$(cq "$CB" four); [ "$(cite_of_card "$CB" "$(cc "$BO4")")" = Q4 ] || { echo "a card in a trashed lane was reissued:"; echo "$BO4"; exit 1; }
BL2=$(uuidgen | tr A-Z a-z); ASKED=$(dirname "$(ls -d "$CB"/*/"$BQ1")"); mkdir -p "$ASKED/$BL2"
printf -- '---\nschema: 1\nkind: card\ntitle: "Q7: old"\norder: 9000\ncreated: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\nlegacy\n' > "$ASKED/$BL2/index.md"
BO8=$(cq "$CB" eight); [ "$(cite_of_card "$CB" "$(cc "$BO8")")" = Q8 ] || { echo "a legacy Q7: title did not count:"; echo "$BO8"; exit 1; }
( . "$SK/lanework/scripts/lib.sh"
  [ "$(next_cite "$CB" Q)" = Q9 ] && [ "$(next_cite "$CB" ADR)" = ADR1 ] && [ "$(next_cite "$CB" T)" = T1 ] || { echo "next_cite: Q=$(next_cite "$CB" Q) ADR=$(next_cite "$CB" ADR) T=$(next_cite "$CB" T)"; exit 1; }
  [ "$(cite_of "$ASKED/$BL2/index.md")" = "" ] && [ "$(card_ref "$ASKED/$BL2/index.md")" = "Q7: old" ] && [ "$(cite_of "$(ls "$CB"/*/"$BQ1"/index.md)")" = Q1 ] && [ "$(card_ref "$(ls "$CB"/*/"$BQ1"/index.md)")" = Q1 ] \
    || { echo "cite_of/card_ref wrong"; exit 1; }
  printf -- '---\nschema: 1\nkind: card\ntitle: "A [x] \\\\ b"\n---\n' > "$T/ref.md"; [ "$(card_ref "$T/ref.md")" = 'A \[x\] \\ b' ] || { echo "card_ref did not escape: $(card_ref "$T/ref.md")"; exit 1; } )
validate "$CB" >/dev/null; ok "cite trash and legacy scan: a flat-trashed Q2 and a Q3 in a trashed lane are not reissued, a legacy Q7: title makes the next Q8; next_cite counts per prefix, cite_of and card_ref read the key, else the escaped title"
# cite-as: a board on an older guide, or with no readable stamp, is filed as before
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"; printf 'Sync is free.\n' > "$T/cr.md"; printf 'Where does the engine run?\n' > "$T/ct.md"
cc() { head -1 <<<"$1" | sed 's#.*/##'; }
for g in 114 116 none; do
  CD="$T/CiteC$g Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$CD" --model smoke >/dev/null; [ "$g" = none ] || mkguide "$CD" "$g"
  O=$("$SK/discovery/scripts/file-question.sh" "$CD" "Pricing" --round 1 --body "$T/cq.md" --model smoke 2>&1); Q=$(cc "$O")
  R=$("$SK/discovery/scripts/file-record.sh" "$CD" "$Q" --record ADR --title "Sync engine" --body "$T/cr.md" --model smoke)
  CPL="$T/CiteC$g Plan.lanework"; "$PS/found-plan-board.sh" "$CPL" --model smoke >/dev/null; [ "$g" = none ] || mkguide "$CPL" "$g"
  TO=$("$PS/file-ticket.sh" "$CPL" "Engine" --type grilling --body "$T/ct.md" --model smoke)
  { grep -qx 'title: "Q1: Pricing"' "$CD"/*/"$Q"/index.md && grep -qx 'title: "ADR: Sync engine"' "$CD"/*/"$(cc "$R")"/index.md && grep -qx 'title: "T1: Engine"' "$CPL"/*/"$(cc "$TO")"/index.md \
    && ! grep -q '^cite' <<<"$O$R" && [ -z "$(grep -l '^cite-as:' "$CD"/*/*/index.md "$CPL"/*/*/index.md || true)" ] \
    && grep -qxF "Question: [Q1: Pricing](lanework://$(sed -n 's/^id: //p' "$CD/index.md")/$Q)" "$CD"/*/"$(cc "$R")"/index.md; } \
    || { echo "board with guide $g was not filed as before:"; echo "$O$R$TO"; exit 1; }
  validate "$CD" >/dev/null; validate "$CPL" >/dev/null
done
ok "cite v114 and unreadable stamp: on a v114 board, a v116 board and one with no stamp, the same filings keep Q1:, ADR: and T1: titles, write no cite-as and print no citation"
# cite-as: links and listings use the citation
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"; printf 'Sync is free.\n' > "$T/cr.md"; printf 'Where does the engine run?\n' > "$T/ct.md"
cc() { head -1 <<<"$1" | sed 's#.*/##'; }
CL="$T/CiteD Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$CL" --model smoke >/dev/null; mkguide "$CL" 117; LBID=$(sed -n 's/^id: //p' "$CL/index.md")
LQ=$(cc "$("$SK/discovery/scripts/file-question.sh" "$CL" "Pricing" --round 1 --body "$T/cq.md" --model smoke 2>&1)")
LR=$(cc "$("$SK/discovery/scripts/file-record.sh" "$CL" "$LQ" --record ADR --title "Sync engine" --body "$T/cr.md" --model smoke)")
[ "$(awk '/^---$/ { n++; next } n == 2 && NF { print; exit }' "$CL"/*/"$LR"/index.md)" = "Question: [Q1](lanework://$LBID/$LQ)" ] || { echo "record line 1 does not link [Q1]"; exit 1; }
RB=$("$SK/lanework/scripts/read-board.sh" "$CL"); grep -qE "^   [0-9.]+ +Q1: Pricing  \[${LQ:0:8}\]$" <<<"$RB" || { echo "read-board.sh does not print Q1 before the title:"; echo "$RB"; exit 1; }
CP="$T/CiteD Plan.lanework"; "$PS/found-plan-board.sh" "$CP" --model smoke >/dev/null; mkguide "$CP" 117; PBID=$(sed -n 's/^id: //p' "$CP/index.md")
LT1=$(cc "$("$PS/file-ticket.sh" "$CP" "Engine: placement" --type grilling --body "$T/ct.md" --model smoke)"); LT2=$(cc "$("$PS/file-ticket.sh" "$CP" "Rate limits" --type research --body "$T/ct.md" --model smoke)")
LT3=$(cc "$("$PS/file-ticket.sh" "$CP" "Both" --type task --body "$T/ct.md" --depends "lanework://$PBID/$LT1" --depends "lanework://$PBID/$LT2" --model smoke)")
{ grep -qxF -- "- [T1](lanework://$PBID/$LT1)" "$CP"/*/"$LT3"/index.md && grep -qxF -- "- [T2](lanework://$PBID/$LT2)" "$CP"/*/"$LT3"/index.md; } || { echo "Depends on lines are not citation links:"; cat "$CP"/*/"$LT3"/index.md; exit 1; }
FO=$("$PS/frontier.sh" "$CP" 2>"$T/cdrift.txt")
{ grep -qxF "T1: Engine: placement  [${LT1:0:8}](lanework://$PBID/$LT1)" <<<"$FO" && grep -qxF "T3: Both  [${LT3:0:8}](lanework://$PBID/$LT3)" <<<"$FO" && grep -qxF '    waits on T1 (Frontier)' <<<"$FO" && [ ! -s "$T/cdrift.txt" ]; } || { echo "frontier.sh does not show the citation:"; echo "$FO"; cat "$T/cdrift.txt"; exit 1; }
# a Blocked ticket moved to Frontier by hand while its dependencies are open: the drift warning names the citation
mv "$(ls -d "$CP"/*/"$LT3")" "$(dirname "$(ls -d "$CP"/*/"$LT1")")/"; "$PS/frontier.sh" "$CP" >/dev/null 2>"$T/cdrift.txt"
grep -qxF 'frontier.sh: drift: T3 is on the Frontier with a dependency open: T1 (Frontier) T2 (Frontier)' "$T/cdrift.txt" || { echo "frontier.sh warning does not name the citations:"; cat "$T/cdrift.txt"; exit 1; }
ok "cite links: Depends on lines and a record's first line are [T1](…) and [Q1](…); frontier.sh and read-board.sh print the citation before the title, and its listing and drift warning name the citation"
# cite-as: resolving a ticket with a bare title names the citation, not the title
printf 'Where does the engine run?\n' > "$T/ct.md"; printf '**2026-11-17**: Done.\n' > "$T/cres.md"
cc() { head -1 <<<"$1" | sed 's#.*/##'; }
CP="$T/CiteE Plan.lanework"; "$PS/found-plan-board.sh" "$CP" --model smoke >/dev/null; mkguide "$CP" 117; PBID=$(sed -n 's/^id: //p' "$CP/index.md")
ET1=$(cc "$("$PS/file-ticket.sh" "$CP" "Engine: placement" --type grilling --body "$T/ct.md" --model smoke)")
ET2=$(cc "$("$PS/file-ticket.sh" "$CP" "Wire: both" --type task --body "$T/ct.md" --depends "lanework://$PBID/$ET1" --model smoke)")
ET3=$(cc "$("$PS/file-ticket.sh" "$CP" "Third, no colon" --type task --body "$T/ct.md" --depends "lanework://$PBID/$ET1" --model smoke)")
# T2 and T3 are written as a v117 board holds them: a bare title and the key (this case is resolve-ticket.sh's, not file-ticket.sh's)
for e in "$ET2|T2|Wire: both" "$ET3|T3|Third, no colon"; do
  IFS='|' read -r id ci ti <<<"$e"; perl -pi -e 's/^title: ".*"$/title: "'"$ti"'"\ncite-as: '"$ci"'/' "$(ls "$CP"/*/"$id"/index.md)"
done
grep -qx 'cite-as: T2' "$(ls "$CP"/*/"$ET2"/index.md)" && grep -qx 'title: "Wire: both"' "$(ls "$CP"/*/"$ET2"/index.md)" || { echo "fixture not written"; exit 1; }
"$PS/claim-ticket.sh" "$CP" "$ET1" --model smoke >/dev/null
RO=$("$PS/resolve-ticket.sh" "$CP" "$ET1" --resolution "$T/cres.md" --model smoke)
{ grep -qx 'unblocked T2' <<<"$RO" && grep -qx 'unblocked T3' <<<"$RO" && ! grep -q -e 'Wire' -e 'Third' <<<"$RO"; } || { echo "resolve-ticket.sh did not name the citations:"; echo "$RO"; exit 1; }
validate "$CP" >/dev/null; ok "cite resolve unblocked: resolving T1 prints unblocked T2 and unblocked T3 for bare titles (one with a colon), never the title"
# cite-as: a zero-padded number is decimal, and a prefix counts only its own cards
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"
cc() { head -1 <<<"$1" | sed 's#.*/##'; }
cardwith() {  # cardwith <board> <lane card path> <title> [cite-as]: a hand-written card
  mkdir -p "$2"; { printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\n' "$3"; [ -z "${4:-}" ] || printf 'cite-as: %s\n' "$4"
    printf 'order: 9000\ncreated: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\nx\n'; } > "$2/index.md"; }
CZ="$T/CiteZ Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$CZ" --model smoke >/dev/null; mkguide "$CZ" 117
ZL=$(dirname "$(ls -d "$CZ"/*/ | sed -n 3p | sed 's#/$##')")/$(basename "$(ls -d "$CZ"/*/ | sed -n 3p | sed 's#/$##')")
cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "nine" ADR9; cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "padded" ADR010
cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "Topic tail" Topic; cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "frodo" FR12; cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "pdr" PDR4
cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "tail of Q" DQ50; cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "tail of ADR" XADR40
cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "Q08" Q08; cardwith "$CZ" "$ZL/$(uuidgen | tr A-Z a-z)" "Q09: legacy"
( . "$SK/lanework/scripts/lib.sh"
  got="ADR=$(next_cite "$CZ" ADR) Q=$(next_cite "$CZ" Q) T=$(next_cite "$CZ" T) F=$(next_cite "$CZ" F) PDR=$(next_cite "$CZ" PDR)"
  [ "$got" = "ADR=ADR11 Q=Q10 T=T1 F=F1 PDR=PDR5" ] || { echo "next_cite miscounted: $got"; exit 1; } )
ZO=$("$SK/discovery/scripts/file-question.sh" "$CZ" "after padding" --round 1 --body "$T/cq.md" --model smoke 2>&1); grep -qx 'cite Q10' <<<"$ZO" || { echo "file-question.sh on a padded board:"; echo "$ZO"; exit 1; }
validate "$CZ" >/dev/null; ok "cite padded and prefix: ADR9 beside ADR010 mints ADR11, Q08 and a Q09: title mint Q10, and a prefix ignores the numbers of Topic, FR12, DQ50, XADR40 and the other prefixes; file-question.sh files Q10 on that board"

# plugin: the manifest agrees with the skills folders; one version, in plugin.json
python3 - "$ROOT/.claude-plugin" "$SK" <<'EOF'
import json, os, sys
d, sk = sys.argv[1:]; p = json.load(open(f"{d}/plugin.json"))
want = sorted(f"./skills/{n}" for n in os.listdir(sk) if os.path.isfile(f"{sk}/{n}/SKILL.md"))
assert sorted(p["skills"]) == want, f"plugin.json skills {p['skills']} != folders {want}"
EOF
# claude plugin validate: errors fail (exit status). Warnings fail too, except the one known
# warning: this repo's CLAUDE.md is its dev guide, which sits at the plugin root by design.
# (--strict would turn that warning into an error, and can't be told to skip just it.)
if command -v claude >/dev/null; then
  V=$(claude plugin validate "$ROOT" 2>&1) || { echo "$V"; echo "plugin validate failed"; exit 1; }
  # newer CLIs append a "Plugin directory checks" section (catalog advice such as ICON_MISSING)
  # that, in its own words, does not change the result, and a "Provides:" list of the skills; only warnings above either count
  W=$(printf '%s\n' "$V" | sed -e '/^Provides:/,$d' -e '/^Plugin directory checks/,$d' | grep -E '^ +❯ ' | grep -v -F 'root: CLAUDE.md at the plugin root is not loaded as project context' || true)
  [ -z "$W" ] || { echo "$V"; echo "plugin validate: unexpected warning"; exit 1; }
fi
ok "plugin manifests match the skills folders and validate"

echo "smoke: $pass passed"
[ -n "${1:-}" ] || rm -rf "$T"
