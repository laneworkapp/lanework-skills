#!/bin/bash
# smoke.sh: run every skill script against throwaway boards; validate with a board's schema.
# usage: tests/smoke.sh [<scratch dir>]   (default: a fresh mktemp dir, removed on success)
# The validator is borrowed from the Skills Pipeline board's app-installed .schema/.
set -euo pipefail
# the session running smoke is no session of the cases: the card-writing scripts check a lease only under a session id, set per case
unset CLAUDE_CODE_SESSION_ID CLAUDE_PID
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

# early-closing readers: no script under test pipes into head or grep -q/-m here. The reader closes after its first match and a
# later write of the script dies of a broken pipe, rc 141 under pipefail. Capture the output whole (bfirst). The pattern matches a sample
EC='(scripts/[a-z-]+|\$PS/[a-z-]+)\.sh"[^|]*\| *(head|grep -[a-zA-Z]*[qm])'
ec1='X=$("$PS/file-ticket'; ec1+='.sh" "$B" t | head -1)'; ec2='"$SK/x/scripts/a-b'; ec2+='.sh" 2>&1 | grep -qF y'   # split: no self-match
[ "$(printf '%s\n' "$ec1" "$ec2" | grep -cE "$EC")" = 2 ] || { echo "the early-reader pattern misses its samples"; exit 1; }
hits=$(grep -nE "$EC" "$ROOT/tests/smoke.sh" || true); [ -z "$hits" ] || { echo "a script's output piped into an early-closing reader:"; echo "$hits"; exit 1; }
ok "no script under test pipes its output into head or grep -q/-m in smoke"

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
# owner_comment <card dir> <text>: an owner (kind human) comment five seconds ahead, so it is newer than the card's ask
owner_comment() { local d="$1/comments/$(uuidgen | tr A-Z a-z)" at; at=$(date -u -v+5S +%FT%TZ); mkdir -p "$d"
  printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: %s, by: {name: owner, kind: human}}\nmodified: {at: %s, by: {name: owner, kind: human}}\n---\n%s\n' "$at" "$at" "$2" > "$d/index.md"; }
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
C1=$(head -1 <<<"$O1" | sed 's#.*/##'); A1=$(sed -n 's/^ask comment //p' <<<"$O1"); C2=$(head -1 <<<"$O2" | sed 's#.*/##'); A2=$(sed -n 's/^ask comment //p' <<<"$O2")
grep -q '^title: "Q2: Engine: placement"$' "$D"/*/"$C2"/index.md; ok "Q1, Q2 filed, numbered, asks lint clean"
printf '**2026-09-27**: A, as recommended.\n' > "$T/r1.md"; printf '**Owner ruled off the board.**\n\n> A.\n\n**Given**: chat, 2026-09-27\n' > "$T/rec.md"
# refusal: a record with no quote or no Given line writes nothing, exit 2
printf '**Owner answered in chat.** "A."\n' > "$T/rec-old.md"; CF1b="$(ls "$D"/*/"$C1"/index.md)"; SUMB=$(cksum < "$CF1b"); NCB=$(ls "$(dirname "$CF1b")/comments" | wc -l)
set +e; "$SK/discovery/scripts/settle-question.sh" "$D" "$C1" --ruling "$T/r1.md" --record "$T/rec-old.md" --model smoke >/dev/null 2>&1; RC=$?; set -e
CF1b="$(ls "$D"/*/"$C1"/index.md)"; [ "$RC" = 2 ] && [ "$(cksum < "$CF1b")" = "$SUMB" ] && [ "$(ls "$(dirname "$CF1b")/comments" | wc -l)" = "$NCB" ] || { echo "settle-question accepted an unquoted record (rc $RC) or wrote something"; exit 1; }
ok "settle-question refuses a record with no quote or Given line, writes nothing"
# several people, past 120 characters: the compact form writes waiting as a block (lanework/scripts/lib.sh compact_fm, the heal's H17)
CF1="$(ls "$D"/*/"$C1"/index.md)"; perl -0pi -e 's/^waiting: \{for: [^,]*, since: ([^,]*), comment: ([^}]*)\}\n/waiting:\n  for: [owner, bobsmith, carol, dave]\n  since: $1\n  comment: $2\n/m' "$CF1"; grep -q '^  for: \[owner, bobsmith, carol, dave\]$' "$CF1"
"$SK/discovery/scripts/settle-question.sh" "$D" "$C1" --ruling "$T/r1.md" --record "$T/rec.md" --reply "$A1" --model smoke >/dev/null
CF1="$(ls "$D"/*/"$C1"/index.md)"; { ! grep -q -E '^(waiting:|  (for|since|comment):)' "$CF1" && fm_parses "$CF1" && grep -q "in-reply-to: $A1" "$D"/*/"$C1"/comments/*/index.md; } \
  || { echo "settle-question left waiting, or its block lines, or a frontmatter that does not parse:"; head -12 "$CF1"; exit 1; }
LW=$("$SK/work/scripts/lint-waiting-clears.sh" "$D" 2>&1 || true); grep -q "^QUOTED $C1 $A1\$" <<<"$LW" || { echo "chat record not QUOTED: $LW"; exit 1; }
ok "settled with chat record in reply to the ask, read QUOTED by the waiting-clear lint, a block-form list waiting dropped whole"
# waiting set, no --record, no owner comment after the ask: settle and park both refused, exit 1, nothing written, the message names --record
CF2="$(ls "$D"/*/"$C2"/index.md)"; S2B=$(sum "$D")
for to in settled parked; do
  RC=0; "$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to "$to" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
  [ "$RC" = 1 ] && grep -q -- '--record' "$T/err.txt" && [ "$(sum "$D")" = "$S2B" ] || { echo "settle --to $to with waiting and no record: rc $RC, or no --record in the message, or the board changed"; cat "$T/err.txt"; exit 1; }
done
ok "settle-question refuses to clear waiting with no record and no owner answer (settled and parked): exit 1, message names --record, nothing written"
# the NO-QUOTE line the lint prints is read by settle-question.sh at field 3: a record that answers another ask is refused naming this card's ask
S2B=$(sum "$D"); RC=0; "$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --record "$T/rec.md" --reply "$A1" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q "newest ask is $A2" "$T/err.txt" && [ "$(sum "$D")" = "$S2B" ] || { echo "settle-question on a record for another ask: want rc 1 naming ask $A2, nothing written (rc $RC)"; cat "$T/err.txt"; exit 1; }
ok "settle-question.sh reads the ask id as field 3 of the lint's NO-QUOTE line (a record answering another ask is refused naming the right ask)"
# --record with a --reply that is not the newest ask: the lint would read NO-QUOTE, so refused, nothing written
RC=0; "$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec.md" --reply "$A1" --model smoke >/dev/null 2>&1 || RC=$?
[ "$RC" = 1 ] && [ "$(sum "$D")" = "$S2B" ] || { echo "settle with a record in reply to another ask: rc $RC, or the board changed"; exit 1; }
ok "settle-question refuses a record in reply to an ask other than the card's newest: exit 1, nothing written"
# a waiting-clear lint that exits 2 (it could not read the board) is a failure whatever its text says: refused, nothing written
SKSTUB="$T/skstub"; cp -R "$SK" "$SKSTUB"; printf '#!/bin/bash\necho "QUOTED x y"; echo "QUOTED 1, NO-QUOTE 0"; exit 2\n' > "$SKSTUB/work/scripts/lint-waiting-clears.sh"
RC=0; "$SKSTUB/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec.md" --reply "$A2" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q 'lint-waiting-clears.sh failed' "$T/err.txt" && [ "$(sum "$D")" = "$S2B" ] || { echo "settle with a lint exiting 2: want exit 1 and nothing written, got rc $RC"; cat "$T/err.txt"; exit 1; }
ok "settle-question treats a waiting-clear lint exit of 2 as failed even when its output reads QUOTED: exit 1, nothing written"
# refusal text names the newest ask and the real causes: a bare > quote and the right --reply
printf '**Owner ruled off the board.**\n\n>\n\n**Given**: chat, 2026-09-27\n' > "$T/rec-bare.md"
RC=0; "$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec-bare.md" --reply "$A2" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q "$A2" "$T/err.txt" && grep -q 'fence' "$T/err.txt" && [ "$(sum "$D")" = "$S2B" ] || { echo "bare > record: want exit 1, the newest ask id and 'fence', nothing written; got rc $RC"; cat "$T/err.txt"; exit 1; }
RC=0; "$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec.md" --reply "$A1" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q "$A2" "$T/err.txt" && ! grep -q "$A1" "$T/err.txt" || { echo "stale --reply: the message must name the newest ask $A2, not $A1"; cat "$T/err.txt"; exit 1; }
ok "settle-question refusal names the newest ask's id and the fence cause, not the passed --reply"
# only each comment's index.md is staged for the lint (the stub refuses with NO-QUOTE, so nothing is written)
SKL="$T/sklist"; rm -rf "$SKL"; cp -R "$SK" "$SKL"; LS="$SKL/work/scripts/lint-waiting-clears.sh"
printf '#!/bin/bash\nfind "$1" > "%s/listing.txt"\necho "NO-QUOTE x y"; exit 1\n' "$T" > "$LS"; chmod +x "$LS"
ATT="$(dirname "$CF2")/comments/$A2/attachments/aaaaaaaa-0000-4000-8000-000000000000"; mkdir -p "$ATT"; echo blob > "$ATT/blob.txt"
S2B=$(sum "$D")
RC=0; "$SKL/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec.md" --reply "$A2" --model smoke >/dev/null 2>&1 || RC=$?
[ "$RC" = 1 ] && grep -q "comments/$A2/index.md" "$T/listing.txt" && ! grep -q attachments "$T/listing.txt" || { echo "staged lint input: want each comment's index.md and no attachments (rc $RC)"; cat "$T/listing.txt"; exit 1; }
rm -rf "$(dirname "$ATT")"; S2B=$(sum "$D")
ok "settle-question stages only each comment's index.md for the waiting-clear lint, no attachments"
# a present lint that is not executable is not called missing, and an absent one is
chmod -x "$LS"
RC=0; "$SKL/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec.md" --reply "$A2" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q 'not executable' "$T/err.txt" && ! grep -q 'missing' "$T/err.txt" && [ "$(sum "$D")" = "$S2B" ] || { echo "non-executable lint: want exit 1, 'not executable', not 'missing'; got rc $RC"; cat "$T/err.txt"; exit 1; }
rm -f "$LS"
RC=0; "$SKL/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --record "$T/rec.md" --reply "$A2" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q 'missing' "$T/err.txt" && [ "$(sum "$D")" = "$S2B" ] || { echo "absent lint: want exit 1 and 'missing'; got rc $RC"; cat "$T/err.txt"; exit 1; }
ok "settle-question says 'not executable' for a present lint without the x bit and 'missing' for an absent one, nothing written"
grep 'owner answer' "$SK/discovery/references/rounds.md" | grep -q 'Recap' || { echo "rounds.md lost the Recap rule beside 'owner answer'"; exit 1; }
ok "rounds.md says a Recap: click is not an owner answer"
# a Recap: click is not an owner answer: refused with no --record, an answer before or after it still counts (own board, own questions)
R="$T/Recap Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$R" --model smoke >/dev/null
rq() { local o; o=$("$SK/discovery/scripts/file-question.sh" "$R" "$1" --round 1 --body "$T/q1.md" --model smoke 2>&1) || return; o=${o%%$'\n'*}; printf '%s\n' "${o##*/}"; }
rcard() { ls -d "$R"/*/"$1"; }
RA=$(rq "Click only"); RB=$(rq "Click then answer"); RC_=$(rq "Click then record"); RD=$(rq "Recapitulate")
owner_comment "$(rcard "$RA")" "Recap: Explain this in plain terms first"
owner_comment "$(rcard "$RB")" "Recap: Explain this in plain terms first"; owner_comment "$(rcard "$RB")" "A."
owner_comment "$(rcard "$RC_")" "Recap: Explain this in plain terms first"
owner_comment "$(rcard "$RD")" "Recapitulate: A."
SR=$(sum "$R")
RC=0; "$SK/discovery/scripts/settle-question.sh" "$R" "$RA" --ruling "$T/r1.md" --model smoke >/dev/null 2>"$T/err.txt" || RC=$?
[ "$RC" = 1 ] && grep -q -- '--record' "$T/err.txt" && [ "$(sum "$R")" = "$SR" ] || { echo "settle on a Recap: click alone: want exit 1, --record in the message, nothing written; got rc $RC"; cat "$T/err.txt"; exit 1; }
ok "settle-question refuses a waiting card whose only owner comment is a Recap: click: exit 1, message names --record, nothing written"
"$SK/discovery/scripts/settle-question.sh" "$R" "$RB" --ruling "$T/r1.md" --model smoke >/dev/null
ok "settle-question settles when a real owner answer follows the Recap: click"
"$SK/discovery/scripts/settle-question.sh" "$R" "$RC_" --ruling "$T/r1.md" --record "$T/rec.md" --model smoke >/dev/null
ok "settle-question settles a card with only a Recap: click when --record quotes the owner"
"$SK/discovery/scripts/settle-question.sh" "$R" "$RD" --ruling "$T/r1.md" --model smoke >/dev/null
ok "settle-question counts Recapitulate: A. (not the Recap: prefix) as an answer"
# --record with no --reply, CRLF line ends: in reply to waiting.comment, written LF, read QUOTED
printf '**Owner ruled off the board.**\r\n\r\n> Later.\r\n\r\n**Given**: chat, 2026-09-27\r\n' > "$T/rec-crlf.md"; printf '**2026-09-27**: Parked. "Later."\r\n' > "$T/r-crlf.md"
"$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r-crlf.md" --to parked --record "$T/rec-crlf.md" --model smoke >/dev/null
CF2="$(ls "$D"/*/"$C2"/index.md)"; RF2=$(grep -l '^> Later.' "$D"/*/"$C2"/comments/*/index.md)
{ [ "$(grep -l '^title: "Parked"$' "$(dirname "$(dirname "$CF2")")/index.md")" ] && grep -qx "in-reply-to: $A2" "$RF2" && ! grep -q $'\r' "$RF2" && ! grep -q $'\r' "$CF2"; } \
  || { echo "record with no --reply not in reply to waiting.comment, or CRLF left in the record or ruling:"; cat -v "$RF2"; exit 1; }
LW=$("$SK/work/scripts/lint-waiting-clears.sh" "$D" 2>&1 || true); grep -q "^QUOTED $C2 $A2\$" <<<"$LW" || { echo "record with no --reply not QUOTED: $LW"; exit 1; }
ok "parked with a CRLF record and no --reply: in reply to waiting.comment, record and ruling written LF, read QUOTED by the waiting-clear lint"
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
owner_comment "$(dirname "$(ls "$D"/*/"$C3"/index.md)")" 'A.'
"$SK/discovery/scripts/settle-question.sh" "$D" "$C3" --ruling "$T/r3.md" --model smoke >/dev/null || { echo "settle-question refused a clear the owner answered on the board"; exit 1; }
SETTLED=$(grep -l '^title: "Settled"$' "$D"/*/index.md | sed 's#/index.md$##')
[ -f "$SETTLED/$C3/index.md" ] && ! grep -q '^waiting:' "$SETTLED/$C3/index.md" &&
  grep -q "^ADR: \[ADR: Sync engine\]($(head -1 <<<"$R1"))\$" "$D"/*/"$C3"/index.md || { echo "settled ruling does not carry the record link"; exit 1; }
ok "record filed before settling; settled with no --record after an owner comment on the board, waiting dropped; the ruling links both cards"
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
# a question with no waiting settles with no record, as before
O6=$("$SK/discovery/scripts/file-question.sh" "$D" "No waiting" --round 1 --body "$T/q1.md" --model smoke 2>&1); C6=$(head -1 <<<"$O6" | sed 's#.*/##')
CF6="$(ls "$D"/*/"$C6"/index.md)"; perl -ni -e 'print unless /^waiting:/' "$CF6"; ! grep -q '^waiting:' "$CF6" || { echo "the no-waiting card still has a waiting line"; exit 1; }
"$SK/discovery/scripts/settle-question.sh" "$D" "$C6" --ruling "$T/r1.md" --model smoke >/dev/null || { echo "settle-question refused a question with no waiting"; exit 1; }
[ "$(grep -m1 '^title:' "$(dirname "$(dirname "$(ls "$D"/*/"$C6"/index.md)")")/index.md")" = 'title: "Settled"' ] || { echo "question with no waiting not in Settled"; exit 1; }
ok "a question with no waiting settles with no record"

# discovery: file-record.sh --supersedes states a supersedes relation on the new card, never touches the old one
FR="$SK/discovery/scripts/file-record.sh"
SQ() { local o; o=$("$SK/discovery/scripts/file-question.sh" "$D" "$1" --round 2 --body "$T/q3.md" --model smoke 2>&1) || return; o=${o%%$'\n'*}; printf '%s\n' "${o##*/}"; }
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
# claim-ticket.sh stakes through lanework/scripts/lease.sh, so the plan scripts run as a session: PE, as session S-plan under a
# stand-in CLAUDE_PID (a sleep ended by its pid on exit and before the lease cases' last check), a TMPDIR of their own, the test knobs
PT=$(mktemp -d "$T/plan-tmp.XXXXXX"); sleep 600 </dev/null >/dev/null 2>&1 & PSP=$!; disown "$PSP"; trap 'kill "$PSP" 2>/dev/null || true' EXIT
PE() { CLAUDE_CODE_SESSION_ID=S-plan CLAUDE_PID="$PSP" TMPDIR="$PT" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_NOTICE_WAIT=1.5 LEASE_TEST_POLL=0.2 \
  LEASE_TEST_RENEW_EVERY=1000 "$@"; }
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
if PE "$PS/claim-ticket.sh" "$PL" "$T3" --model smoke 2>"$T/err.txt"; then echo "claimed a Blocked ticket"; exit 1; fi
grep -q 'is in Blocked, not Frontier' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
PE "$PS/claim-ticket.sh" "$PL" "$T1" --model smoke --session s1 >/dev/null
[ "$(plane "$T1")" = Working ] && grep -qx '\*\*Claimed\*\* by claude, session s1.' "$PL"/*/"$T1"/comments/*/index.md || { echo "claim did not move to Working with a Claimed comment"; exit 1; }
grep -q 'modified: {at: .*, by: {name: claude, kind: agent, model: smoke, session: "s1"}}' "$(ls "$PL"/*/"$T1"/index.md)" || { echo "claim did not restamp modified"; exit 1; }
if PE "$PS/claim-ticket.sh" "$PL" "$T1" --model smoke 2>"$T/err.txt"; then echo "claimed a Working ticket twice"; exit 1; fi
grep -q 'is in Working, not Frontier' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if PE "$PS/resolve-ticket.sh" "$PL" "$T2" --resolution "$T/t.md" --model smoke 2>/dev/null; then echo "resolved an unclaimed ticket"; exit 1; fi
ok "claim-ticket.sh moves Frontier to Working with a Claimed comment and a restamp; refuses a Blocked or already-claimed ticket; resolve refuses an unclaimed one"
# a Working ticket wearing waiting loses it on resolve; one of two deps resolved keeps T3 Blocked, unblocks T4
WBLOCK='waiting:\n  for: [rzen, bobsmith, carol, dave]\n  since: 2026-10-10T00:00:00Z\n  comment: 11111111-1111-4111-8111-111111111111'   # past 120 characters: a block (awk -v reads the \n)
TF1="$(ls "$PL"/*/"$T1"/index.md)"; awk -v w="$WBLOCK" '{print} /^order:/ {print w}' "$TF1" > "$T/w.md"; mv "$T/w.md" "$TF1"; grep -q '^  for: \[rzen, bobsmith' "$TF1"
printf '**2026-10-10**: In the app, as recommended. "Yes."\n' > "$T/res1.md"
RO1=$(PE "$PS/resolve-ticket.sh" "$PL" "$T1" --resolution "$T/res1.md" --model smoke)
TF1="$(ls "$PL"/*/"$T1"/index.md)"
{ [ "$(plane "$T1")" = Resolved ] && ! grep -q -E '^(waiting:|  (for|since|comment):)' "$TF1" && fm_parses "$TF1" && grep -qx '## Resolution' "$TF1" && grep -qF '"Yes."' "$TF1" &&
  [ "$(plane "$T4")" = Frontier ] && [ "$(plane "$T3")" = Blocked ] && grep -qx 'unblocked T4' <<<"$RO1" && ! grep -q 'unblocked T3' <<<"$RO1" && [ "$(tail -1 <<<"$RO1")" = "$TL1" ]; } || { echo "resolve/unblock wrong: $RO1"; exit 1; }
PE "$PS/claim-ticket.sh" "$PL" "$T2" --model smoke >/dev/null
RO2=$(PE "$PS/resolve-ticket.sh" "$PL" "$T2" --resolution "$T/res1.md" --model smoke)
[ "$(plane "$T3")" = Frontier ] && grep -qx 'unblocked T3' <<<"$RO2" || { echo "T3 not unblocked once both deps resolved: $RO2"; exit 1; }
[ "$(sed -n 's/^order: //p' "$(ls "$PL"/*/"$T3"/index.md)")" -gt "$(sed -n 's/^order: //p' "$(ls "$PL"/*/"$T4"/index.md)")" ] || { echo "unblocked ticket not at the bottom of Frontier"; exit 1; }
validate "$PL" >/dev/null; ok "resolve-ticket.sh appends the resolution, drops a block-form list waiting whole, moves to Resolved; unblocks exactly the tickets whose deps are all Resolved (two deps: only after both), to the bottom of Frontier"
# out of scope: from Frontier; a new ticket depending on it is refused; Resolved can't go out of scope
printf '**2026-10-10**: Out of scope: past the destination.\n' > "$T/oos.md"
PE "$PS/resolve-ticket.sh" "$PL" "$T4" --resolution "$T/oos.md" --to out-of-scope --model smoke >/dev/null
[ "$(plane "$T4")" = "Out of scope" ] || { echo "out-of-scope did not move the ticket"; exit 1; }
if "$PS/file-ticket.sh" "$PL" "Needs four" --type grilling --body "$T/t.md" --depends "lanework://$PBID/$T4" --model smoke 2>"$T/err.txt"; then echo "accepted an out-of-scope dependency"; exit 1; fi
grep -q 'is Out of scope: rule this ticket out too, or drop the dependency' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if PE "$PS/resolve-ticket.sh" "$PL" "$T1" --resolution "$T/oos.md" --to out-of-scope --model smoke 2>/dev/null; then echo "moved a Resolved ticket out of scope"; exit 1; fi
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
PE "$PS/claim-ticket.sh" "$PL" "$T3" --model smoke >/dev/null
printf 'Engine in the app.\n' > "$T/adrp.md"
PR=$(PE "$SK/discovery/scripts/file-record.sh" "$PL" "$T3" --record ADR --title "Engine in the app" --body "$T/adrp.md" --from Working --model smoke)
PK=${PR##*/}; PKF="$(ls "$PL"/*/"$PK"/index.md)"
[ "$(plane "$PK")" = Decisions ] && [ "$(awk '/^---$/ { n++; next } n == 2 && NF { print; exit }' "$PKF")" = "Question: [T3: Both \[x\] \"q\"](lanework://$PBID/$T3)" ] || { echo "plan record not filed from Working:"; cat "$PKF"; exit 1; }
if PE "$SK/discovery/scripts/file-record.sh" "$PL" "$T3" --record ADR --title x --body "$T/adrp.md" --model smoke 2>"$T/err.txt"; then echo "default --from accepted a plan board"; exit 1; fi
grep -q 'no Asked lane' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if PE "$SK/discovery/scripts/file-record.sh" "$PL" "$T5" --record ADR --title x --body "$T/adrp.md" --from Working --model smoke 2>"$T/err.txt"; then echo "--from Working accepted a Blocked ticket"; exit 1; fi
grep -q 'is not a card in Working' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
if "$SK/discovery/scripts/file-record.sh" "$D" "$C2" --record ADR --title x --body "$T/adrp.md" --model smoke 2>"$T/err.txt"; then echo "default --from accepted a non-Asked question"; exit 1; fi
grep -q 'is not a card in Asked' "$T/err.txt" || { cat "$T/err.txt"; exit 1; }
TF3="$(ls "$PL"/*/"$T3"/index.md)"; cp "$TF3" "$T/t3.md"; awk -v w="$WBLOCK" '{print} /^order:/ {print w}' "$T/t3.md" > "$TF3"
grep -q "^T3: .*(lanework://$PBID/$T3)  (waiting)\$" <<<"$("$PS/frontier.sh" "$PL" 2>/dev/null)" || { echo "frontier.sh lost the (waiting) mark on a block-form waiting"; "$PS/frontier.sh" "$PL"; exit 1; }
cp "$T/t3.md" "$TF3"
PE "$SK/lanework/scripts/lease.sh" release "$PL" "$T3" --model smoke   # T3 stays in Working: release what its claim staked
[ -z "$("$SK/lanework/scripts/lease.sh" list "$PL")" ] || { echo "a plan case left a lease on its board"; "$SK/lanework/scripts/lease.sh" list "$PL"; exit 1; }
validate "$PL" >/dev/null; ok "file-record.sh --from Working files a plan record linking its ticket; the default still demands Asked, and --from refuses a card outside that lane; frontier.sh marks a block-form waiting"
# a model is required: every plan script that writes exits 2 and writes nothing
S4=$(sum "$PL")
refused file-ticket "$PS/file-ticket.sh" "$PL" "Nomodel" --type grilling --body "$T/t.md"
refused claim-ticket "$PS/claim-ticket.sh" "$PL" "$T5"
refused resolve-ticket "$PS/resolve-ticket.sh" "$PL" "$T3" --resolution "$T/res1.md"
refused found-plan-board "$PS/found-plan-board.sh" "$T/NoModel Plan.lanework"
[ "$S4" = "$(sum "$PL")" ] && [ ! -e "$T/NoModel Plan.lanework" ] || { echo "a refused plan call wrote something"; exit 1; }
ok "file-ticket, claim-ticket, resolve-ticket and found-plan-board exit 2 with usage and write nothing when no model is given"

# usage errors exit 2 (option C): a bad flag, a flag with no value, or a missing positional exits 2 and writes nothing. Before, each of
# these exited 1 (file-question, file-record, file-ticket: every bad-argument path; the other six: a ${N:?} path)
usage2() { local n="$1"; shift; local rc=0; "$@" >/dev/null 2>"$T/err.txt" || rc=$?
  [ "$rc" -eq 2 ] || { echo "$n: exit $rc, want 2: $*"; cat "$T/err.txt"; exit 1; }
  [ -s "$T/err.txt" ] || { echo "$n: exit 2 with no message on stderr"; exit 1; }; }
S5=$(sum "$D"); S6=$(sum "$PL")
usage2 file-question-flag "$SK/discovery/scripts/file-question.sh" "$D" "Bad flag" --round 2 --body "$T/q5.md" --model smoke --bogus
usage2 file-question-value "$SK/discovery/scripts/file-question.sh" "$D" "No value" --body "$T/q5.md" --model smoke --round
usage2 file-question-round "$SK/discovery/scripts/file-question.sh" "$D" "No round" --body "$T/q5.md" --model smoke
usage2 file-question-bare "$SK/discovery/scripts/file-question.sh" "$D"
usage2 file-record-flag "$SK/discovery/scripts/file-record.sh" "$D" "$C4" --record ADR --title x --body "$T/adr.md" --model smoke --bogus
usage2 file-record-kind "$SK/discovery/scripts/file-record.sh" "$D" "$C4" --record XDR --title x --body "$T/adr.md" --model smoke
usage2 file-record-bare "$SK/discovery/scripts/file-record.sh" "$D"
usage2 settle-question-flag "$SK/discovery/scripts/settle-question.sh" "$D" "$C4" --ruling "$T/r1.md" --model smoke --bogus
usage2 settle-question-value "$SK/discovery/scripts/settle-question.sh" "$D" "$C4" --model smoke --ruling
usage2 settle-question-bare "$SK/discovery/scripts/settle-question.sh" "$D"
usage2 file-ticket-flag "$PS/file-ticket.sh" "$PL" "Bad flag" --type grilling --body "$T/t.md" --model smoke --bogus
usage2 file-ticket-type "$PS/file-ticket.sh" "$PL" "Bad type" --type nonsense --body "$T/t.md" --model smoke
usage2 file-ticket-value "$PS/file-ticket.sh" "$PL" "No value" --type grilling --body "$T/t.md" --model smoke --why
usage2 file-ticket-bare "$PS/file-ticket.sh" "$PL"
usage2 claim-ticket-flag "$PS/claim-ticket.sh" "$PL" "$T5" --model smoke --bogus
usage2 claim-ticket-value "$PS/claim-ticket.sh" "$PL" "$T5" --model smoke --session
usage2 claim-ticket-bare "$PS/claim-ticket.sh" "$PL"
usage2 resolve-ticket-flag "$PS/resolve-ticket.sh" "$PL" "$T3" --resolution "$T/res1.md" --model smoke --bogus
usage2 resolve-ticket-value "$PS/resolve-ticket.sh" "$PL" "$T3" --model smoke --resolution
usage2 resolve-ticket-bare "$PS/resolve-ticket.sh" "$PL"
usage2 found-discovery-board-bare "$SK/discovery/scripts/found-discovery-board.sh"
usage2 found-discovery-board-labels "$SK/discovery/scripts/found-discovery-board.sh" "$T/XU Discovery.lanework" --model smoke --labels
usage2 found-plan-board-bare "$PS/found-plan-board.sh"
usage2 found-plan-board-labels "$PS/found-plan-board.sh" "$T/XU Plan.lanework" --model smoke --labels
usage2 frontier-bare "$PS/frontier.sh"
usage2 frontier-extra "$PS/frontier.sh" "$PL" --bogus
usage2 frontier-leading-flag "$PS/frontier.sh" --bogus
FRC=0; "$PS/frontier.sh" "$T/not-a-board" >/dev/null 2>&1 || FRC=$?
[ "$FRC" -eq 1 ] || { echo "frontier.sh: not a board exits $FRC, want 1"; exit 1; }
[ "$S5" = "$(sum "$D")" ] && [ "$S6" = "$(sum "$PL")" ] && [ ! -e "$T/XU Discovery.lanework" ] && [ ! -e "$T/XU Plan.lanework" ] || { echo "a usage-error call wrote something"; exit 1; }
ok "file-question, file-record, settle-question, file-ticket, claim-ticket, resolve-ticket, found-discovery-board, found-plan-board and frontier exit 2 on a bad flag, a flag with no value or a missing positional, and write nothing; frontier's not-a-board stays 1"

# triple closing brace: the guard reads only the stamp lines a script wrote (lanework/scripts/lib.sh stamp_lines_ok), so a card whose
# labels line (an iconed kind) or body (a JSON example) holds `}}}` is still written, and a `}}}` in a stamp the script writes is still refused
BQ="$T/Brace Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$BQ" --model smoke >/dev/null
cp -R "$VAL" "$BQ/.schema"; printf '<!-- lanework-agent-guide v118 -->\n\nThis machine'"'"'s human answers to `@owner`.\n' > "$BQ/CLAUDE.md"
BLAB='{text: Low, rank: 3, icon: {glyph: arrow.down}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}'
# bracecard <card index.md>: the iconed label kind in the labels (added to the list, or a new line), a JSON block at the end of the body
bracecard() { python3 - "$1" "$BLAB" <<'PY'
import sys, re
p, lab = sys.argv[1:]; t = open(p).read(); head, fm, body = t.split("---\n", 2)
lines = fm.split("\n")
for i, l in enumerate(lines):
    if l.startswith("labels: ["): lines[i] = l[:-1] + ", " + lab + "]"; break
else: lines.insert(len(lines) - 1, "labels: [" + lab + "]")
open(p, "w").write(head + "---\n" + "\n".join(lines) + "---\n" + body.rstrip("\n") + '\n\n```json\n{"a": {"b": {"c": 1}}}\n```\n')
PY
}
# bfirst <script...>: the last path segment of the script's first output line. The output is read whole first: a reader that
# closes after one line (head -1) can break the script's later writes, rc 141 under pipefail
bfirst() { local o; o=$("$@") || return; o=${o%%$'\n'*}; printf '%s\n' "${o##*/}"; }
! bfirst false >/dev/null || { echo "bfirst hides a failing script"; exit 1; }
bodyof() { awk 'n >= 2 { print } /^---$/ { n++ }' "$1"; }
bsnap() { (cd "$1" && find . -type f | LC_ALL=C sort | while IFS= read -r f; do shasum "$f"; done) | shasum; }
# bholds <before copy> <after file>: the labels line and the whole old body are as they were (a body only grew by an appended ruling)
bholds() { [ "$(grep -m1 '^labels:' "$1")" = "$(grep -m1 '^labels:' "$2")" ] && [[ "$(bodyof "$2")" == "$(bodyof "$1")"* ]]; }
printf 'Is brace safe?\n\n## Options\n\n- A: yes\n- B: no\n\n## Recommended\n\nA. Simple.\n' > "$T/bq.md"
bq() { local o; o=$("$SK/discovery/scripts/file-question.sh" "$BQ" "$1" --round 1 --body "$T/bq.md" --model smoke 2>&1); head -1 <<<"$o" | sed 's#.*/##'; }
BQM=$(bq "Brace move"); BQA=$(bq "Brace ask"); BQS=$(bq "Brace settle"); BQR=$(bq "Brace record")
bcard() { ls "$BQ"/*/"$1"/index.md; }
for c in "$BQM" "$BQA" "$BQS" "$BQR"; do bracecard "$(bcard "$c")"; done
validate "$BQ" >/dev/null
bsave() { cp "$(bcard "$1")" "$T/brace.before"; }
bsave "$BQM"; "$SK/work/scripts/move-card.sh" "$BQ" "$BQM" Parked --model smoke >/dev/null; bholds "$T/brace.before" "$(bcard "$BQM")" && validate "$BQ" >/dev/null || { echo "move-card.sh refused or changed a card with }}} outside its stamps"; exit 1; }
ok "move-card.sh moves a card whose labels line and body hold a triple brace: labels and body byte for byte, board validates"
printf '@anyone Ship the brace today?\n\nOptions:\n- A: Ship it.\n- B: Hold it.\n- Recap: Explain this in plain terms first\n\nWhy now: it is ready.\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/bask.md"
bsave "$BQA"; "$SK/work/scripts/post-ask.sh" "$BQ" "$BQA" --body "$T/bask.md" --for anyone --model smoke >/dev/null; bholds "$T/brace.before" "$(bcard "$BQA")" && grep -q '^waiting:' "$(bcard "$BQA")" && validate "$BQ" >/dev/null || { echo "post-ask.sh refused or changed a card with }}} outside its stamps"; exit 1; }
ok "post-ask.sh sets waiting on a card whose labels line and body hold a triple brace: labels and body byte for byte, board validates"
printf '**2026-11-20**: A. `{"a": {"b": {"c": 1}}}`\n' > "$T/bruling.md"
owner_comment "$(dirname "$(bcard "$BQS")")" 'A.'; bsave "$BQS"; "$SK/discovery/scripts/settle-question.sh" "$BQ" "$BQS" --ruling "$T/bruling.md" --model smoke >/dev/null; bholds "$T/brace.before" "$(bcard "$BQS")" && validate "$BQ" >/dev/null || { echo "settle-question.sh refused or changed a card with }}} outside its stamps"; exit 1; }
ok "settle-question.sh settles a card whose labels line and body hold a triple brace, with a triple brace in the ruling: labels and old body byte for byte, board validates"
printf 'The brace is fine.\n' > "$T/badr.md"
BR=$(bfirst "$SK/discovery/scripts/file-record.sh" "$BQ" "$BQR" --record ADR --title 'Braces }}} are fine' --body "$T/badr.md" --model smoke)
grep -q '^title: "Braces }}} are fine"$' "$(bcard "$BR")" && validate "$BQ" >/dev/null || { echo "file-record.sh refused a title with }}}"; exit 1; }
ok "file-record.sh files a record whose title holds a triple brace; the board validates"
BPL="$T/Brace Plan.lanework"; "$PS/found-plan-board.sh" "$BPL" --model smoke >/dev/null; cp -R "$VAL" "$BPL/.schema"
printf 'A brace ticket.\n' > "$T/bt.md"
BTK=$(bfirst "$PS/file-ticket.sh" "$BPL" "Brace }}} ticket" --type grilling --body "$T/bt.md" --model smoke)
grep -q '^title: ".*Brace }}} ticket"$' "$BPL"/*/"$BTK"/index.md && validate "$BPL" >/dev/null || { echo "file-ticket.sh refused a title with }}}"; exit 1; }
BT2=$(bfirst "$PS/file-ticket.sh" "$BPL" "Second" --type grilling --body "$T/bt.md" --model smoke)
ok "file-ticket.sh files a ticket whose title holds a triple brace; the board validates"
bpcard() { ls "$BPL"/*/"$1"/index.md; }
bracecard "$(bpcard "$BTK")"; cp "$(bpcard "$BTK")" "$T/brace.before"
PE "$PS/claim-ticket.sh" "$BPL" "$BTK" --model smoke >/dev/null; bholds "$T/brace.before" "$(bpcard "$BTK")" && validate "$BPL" >/dev/null || { echo "claim-ticket.sh refused or changed a card with }}} outside its stamps"; exit 1; }
ok "claim-ticket.sh claims a ticket whose labels line and body hold a triple brace: labels and body byte for byte, board validates"
cp "$(bpcard "$BTK")" "$T/brace.before"; printf 'Done, `{"a": {"b": {"c": 1}}}`.\n' > "$T/bres.md"
PE "$PS/resolve-ticket.sh" "$BPL" "$BTK" --resolution "$T/bres.md" --model smoke >/dev/null; bholds "$T/brace.before" "$(bpcard "$BTK")" && validate "$BPL" >/dev/null || { echo "resolve-ticket.sh refused or changed a card with }}} outside its stamps"; exit 1; }
ok "resolve-ticket.sh resolves a ticket whose labels line and body hold a triple brace: labels and old body byte for byte, board validates"
# stamp values: one quoting rule (lanework/scripts/lib.sh by_of). Every script that stamps a name, model or session either exits 0 and the
# board validates, or exits non-zero and the board is unchanged. brace, quote, backslash, colon-space and hash values all come through quoted
SV=('{n}' 'a"b' 'a\' 'a\"}}}' 'x: y' '#x')
svcheck() { local n=$1 b=$2; shift 2; local s rc=0; s=$(bsnap "$b"); "$@" >/dev/null 2>&1 || rc=$?
  if [ "$rc" -eq 0 ]; then validate "$b" >/dev/null || { echo "$n: exit 0 but the board is invalid"; exit 1; }
  else [ "$s" = "$(bsnap "$b")" ] || { echo "$n: exit $rc and the board changed"; exit 1; }; fi; }
svrefused() { local n=$1 want=$2 b=$3; shift 3; local s rc=0; s=$(bsnap "$b"); "$@" >/dev/null 2>&1 || rc=$?
  { [ "$rc" = "$want" ] || { [ "$want" = any ] && [ "$rc" -ne 0 ]; }; } && [ "$s" = "$(bsnap "$b")" ] || { echo "$n: exit $rc (want $want) or the board changed"; exit 1; }; }
byof() { grep -m1 '^modified:' "$1" | sed 's/.*by: //'; }
SBQ="$BQ"; BQ="$T/sv-bq.lanework"; cp -R "$SBQ" "$BQ"   # the boards under test are copies; BQ and BPL point at them until the block ends
SBPL="$BPL"; BPL="$T/sv-bpl.lanework"; cp -R "$SBPL" "$BPL"
SVBODY="$T/bask.md"
for sv in "${SV[@]}"; do for k in name model session; do
  F=(--model smoke); case $k in model) F=(--model "$sv") ;; name) F+=(--name "$sv") ;; session) F+=(--session "$sv") ;; esac
  svcheck "file-card $k=$sv" "$BQ" "$SK/work/scripts/file-card.sh" "$BQ" Parked "SV card" --body "$SVBODY" "${F[@]}"
  svcheck "file-question $k=$sv" "$BQ" "$SK/discovery/scripts/file-question.sh" "$BQ" "SV q" --round 1 --body "$T/bq.md" "${F[@]}"
  SQ=$(bq "SV id $k $sv"); SQF=$(bcard "$SQ")
  svcheck "label-card $k=$sv" "$BQ" "$SK/work/scripts/label-card.sh" "$BQ" "$SQF" "Needs review" "${F[@]}"
  svcheck "post-ask $k=$sv" "$BQ" "$SK/work/scripts/post-ask.sh" "$BQ" "$SQ" --body "$SVBODY" --for anyone "${F[@]}"
  SQ2=$(bq "SV id2 $k $sv"); owner_comment "$(dirname "$(bcard "$SQ2")")" 'A.'
  svcheck "settle-question $k=$sv" "$BQ" "$SK/discovery/scripts/settle-question.sh" "$BQ" "$SQ2" --ruling "$T/bruling.md" "${F[@]}"
  SQ3=$(bq "SV id3 $k $sv"); owner_comment "$(dirname "$(bcard "$SQ3")")" 'A.'; "$SK/discovery/scripts/settle-question.sh" "$BQ" "$SQ3" --ruling "$T/bruling.md" --model smoke >/dev/null
  svcheck "file-record $k=$sv" "$BQ" "$SK/discovery/scripts/file-record.sh" "$BQ" "$SQ3" --record ADR --title "SV rec" --body "$T/badr.md" "${F[@]}"
  svcheck "file-ticket $k=$sv" "$BPL" "$PS/file-ticket.sh" "$BPL" "SV t" --type grilling --body "$T/bt.md" "${F[@]}"
  ST1=$(bfirst "$PS/file-ticket.sh" "$BPL" "SV claim" --type grilling --body "$T/bt.md" --model smoke)
  svcheck "claim-ticket $k=$sv" "$BPL" PE "$PS/claim-ticket.sh" "$BPL" "$ST1" "${F[@]}"
  ST2=$(bfirst "$PS/file-ticket.sh" "$BPL" "SV resolve" --type grilling --body "$T/bt.md" --model smoke); PE "$PS/claim-ticket.sh" "$BPL" "$ST2" --model smoke >/dev/null
  svcheck "resolve-ticket $k=$sv" "$BPL" PE "$PS/resolve-ticket.sh" "$BPL" "$ST2" --resolution "$T/bres.md" "${F[@]}"
  # byte identity: the stamp's by is the same from a comment and from a card restamp
  SQ4=$(bq "SV same $k $sv"); SQD=$(dirname "$(bcard "$SQ4")"); ls "$SQD"/comments/*/index.md >/dev/null 2>&1 && C0=$(ls "$SQD"/comments/*/index.md) || C0=""
  # --ahead 3: file-question stamps its comments one and two seconds ahead, so a bare post-comment right after it is refused (one distinct second per comment)
  rc1=0; "$SK/work/scripts/post-comment.sh" "$BQ" "$SQ4" --body "$SVBODY" --ahead 3 "${F[@]}" >/dev/null 2>&1 || rc1=$?
  CN=$(comm -13 <(printf '%s\n' "$C0" | sort) <({ ls "$SQD"/comments/*/index.md 2>/dev/null || true; } | sort) | head -1); CB=$([ -n "$CN" ] && byof "$CN" || true)   # read before the move: it takes the card folder to another lane
  rc2=0; "$SK/work/scripts/move-card.sh" "$BQ" "$SQ4" Parked "${F[@]}" >/dev/null 2>&1 || rc2=$?
  rc3=0; "$SK/work/scripts/label-card.sh" "$BQ" "$(bcard "$SQ4")" "Needs review" "${F[@]}" >/dev/null 2>&1 || rc3=$?
  # every value here is writable: a refusal would skip the comparison, so it fails the case
  [ $rc1 -eq 0 ] && [ $rc2 -eq 0 ] && [ $rc3 -eq 0 ] || { echo "post-comment rc $rc1, move-card rc $rc2, label-card rc $rc3 for $k=$sv: each must write"; exit 1; }
  [ -n "$CB" ] && [ "$CB" = "$(byof "$(bcard "$SQ4")")" ] || { echo "by differs between post-comment and the card after move-card and label-card for $k=$sv: '$CB' vs '$(byof "$(bcard "$SQ4")")'"; exit 1; }
  validate "$BQ" >/dev/null || { echo "post-comment/move-card/label-card $k=$sv: board invalid"; exit 1; }
done; done
ok "file-card, file-question, post-ask, settle-question, file-record, file-ticket, claim-ticket, resolve-ticket, post-comment and move-card, given {n}, a\"b, a\\, a\\\"}}}, 'x: y' and #x as --name, --model and --session: exit 0 and the board validates, or nothing written; the stamp's by is the same from a comment and a card"
for sv in "${SV[@]}"; do for k in name model; do
  FBN="$T/sv-found.lanework"; rm -rf "$FBN"; F=(--model smoke); case $k in model) F=(--model "$sv") ;; name) F+=(--name "$sv") ;; esac
  rc=0; "$FB" "$FBN" "${FA[@]}" "${F[@]}" >/dev/null 2>&1 || rc=$?
  if [ $rc -eq 0 ]; then cp -R "$VAL" "$FBN/.schema"; validate "$FBN" >/dev/null || { echo "found-board $k=$sv: founded an invalid board"; exit 1; }
  else [ ! -e "$FBN" ] || { echo "found-board $k=$sv: exit $rc but a folder exists"; exit 1; }; fi
done; done
ok "found-board.sh given {n}, a\"b, a\\, a\\\"}}}, 'x: y' and #x as --name or --model: the board validates, or no folder is created"
# a control character in a stamp value is refused by every script with exit 2 and nothing written (stamp_args_ok); an empty --name too
NLV=$'a\nb'; TBV=$'a\tb'
SVQ=$(bq "SV refuse"); owner_comment "$(dirname "$(bcard "$SVQ")")" 'A.'
# the plan scripts run on a board of their own with no claim and no lease timer: nothing writes to it while the snapshots compare
# (stamp_args_ok runs before any state check, so an unclaimed ticket is refused with exit 2 by resolve-ticket.sh too)
SBPL2="$BPL"; BPL="$T/sv-bpl2.lanework"; "$PS/found-plan-board.sh" "$BPL" --model smoke >/dev/null; cp -R "$VAL" "$BPL/.schema"
SVT=$(bfirst "$PS/file-ticket.sh" "$BPL" "SV refuse t" --type grilling --body "$T/bt.md" --model smoke); SVT2=$(bfirst "$PS/file-ticket.sh" "$BPL" "SV refuse t2" --type grilling --body "$T/bt.md" --model smoke)
C1V=$'a\xc2\x85b'   # a C1 control (U+0085), UTF-8 C2 85
FLS=(--name "$NLV" --model "$NLV" --session "$TBV" --name "" --name "$C1V" --model "$C1V" --session "$C1V")
for ((i = 0; i < ${#FLS[@]}; i += 2)); do
  FF=(--model smoke "${FLS[i]}" "${FLS[i+1]}"); [ "${FLS[i]}" = --model ] && FF=(--model "${FLS[i+1]}"); w=2; [ -z "${FLS[i+1]}" ] && w=any; fl="${FLS[i]}#$i"
  svrefused "file-card $fl" $w "$BQ" "$SK/work/scripts/file-card.sh" "$BQ" Parked "R" --body "$SVBODY" "${FF[@]}"
  svrefused "post-comment $fl" $w "$BQ" "$SK/work/scripts/post-comment.sh" "$BQ" "$SVQ" --body "$SVBODY" "${FF[@]}"
  svrefused "post-ask $fl" $w "$BQ" "$SK/work/scripts/post-ask.sh" "$BQ" "$SVQ" --body "$SVBODY" --for anyone "${FF[@]}"
  svrefused "label-card $fl" $w "$BQ" "$SK/work/scripts/label-card.sh" "$BQ" "$(bcard "$SVQ")" "Needs review" "${FF[@]}"
  svrefused "move-card $fl" $w "$BQ" "$SK/work/scripts/move-card.sh" "$BQ" "$SVQ" Parked "${FF[@]}"
  svrefused "file-question $fl" $w "$BQ" "$SK/discovery/scripts/file-question.sh" "$BQ" "R" --round 1 --body "$T/bq.md" "${FF[@]}"
  svrefused "settle-question $fl" $w "$BQ" "$SK/discovery/scripts/settle-question.sh" "$BQ" "$SVQ" --ruling "$T/bruling.md" "${FF[@]}"
  svrefused "file-record $fl" $w "$BQ" "$SK/discovery/scripts/file-record.sh" "$BQ" "$SQ3" --record ADR --title x --body "$T/badr.md" "${FF[@]}"
  svrefused "file-ticket $fl" $w "$BPL" "$PS/file-ticket.sh" "$BPL" "R" --type grilling --body "$T/bt.md" "${FF[@]}"
  svrefused "claim-ticket $fl" $w "$BPL" PE "$PS/claim-ticket.sh" "$BPL" "$SVT2" "${FF[@]}"
  svrefused "resolve-ticket $fl" $w "$BPL" PE "$PS/resolve-ticket.sh" "$BPL" "$SVT" --resolution "$T/bres.md" "${FF[@]}"
done
for fl in --name --model; do
  rm -rf "$T/sv-found.lanework"; rc=0; "$FB" "$T/sv-found.lanework" "${FA[@]}" --model smoke "$fl" "$NLV" >/dev/null 2>&1 || rc=$?
  [ $rc -eq 2 ] && [ ! -e "$T/sv-found.lanework" ] || { echo "found-board $fl newline: exit $rc or a folder exists"; exit 1; }; done
ok "a newline or a C1 control in --name or --model, a tab or a C1 control in --session: exit 2 and nothing written from every stamping script; an empty --name is refused too"
# values YAML would not read back as the same string (null, ~, a bool word, a number) are quoted: valid, and the same bytes from every script
for nv in null '~' true 123 1e3; do for k in name model; do
  F=(--model smoke); case $k in model) F=(--model "$nv") ;; name) F+=(--name "$nv") ;; esac
  NQ=$(bq "NV same $k $nv"); NQD=$(dirname "$(bcard "$NQ")"); NC0=$({ ls "$NQD"/comments/*/index.md 2>/dev/null || true; } | sort)
  "$SK/work/scripts/post-comment.sh" "$BQ" "$NQ" --body "$SVBODY" --ahead 5 "${F[@]}" >/dev/null || { echo "post-comment.sh refused $k=$nv"; exit 1; }
  NCN=$(comm -13 <(printf '%s\n' "$NC0") <({ ls "$NQD"/comments/*/index.md 2>/dev/null || true; } | sort) | head -1); NCB=$(byof "$NCN")
  "$SK/work/scripts/move-card.sh" "$BQ" "$NQ" Parked "${F[@]}" >/dev/null || { echo "move-card.sh refused $k=$nv"; exit 1; }
  NMB=$(byof "$(bcard "$NQ")")
  svcheck "label-card $k=$nv" "$BQ" "$SK/work/scripts/label-card.sh" "$BQ" "$(bcard "$NQ")" "Needs review" "${F[@]}"
  svcheck "file-card $k=$nv" "$BQ" "$SK/work/scripts/file-card.sh" "$BQ" Parked "NV card" --body "$SVBODY" "${F[@]}"
  [ -n "$NCB" ] && [ "$NCB" = "$NMB" ] && grep -qF "$k: \"$nv\"" <<<"$NMB" && validate "$BQ" >/dev/null || { echo "$k=$nv: not quoted, invalid, or by differs: '$NCB' vs '$NMB'"; exit 1; }
done; done
ok "null, ~, true, 123 and 1e3 as --name or --model are written quoted by file-card, post-comment, move-card and label-card: the board validates and the by is the same from a comment and a card"
# stamp_lines_ok, the last guard, refuses a broken stamp line and passes a quoted brace (nothing now feeds it a bare brace, so it is tested directly)
( . "$SK/lanework/scripts/lib.sh"
  printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: n}}}\n---\nbody }}}\n' > "$T/sl-bad.md"
  printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: "n}}}", kind: agent}}\nlabels: [{text: a, kind: {type: b, icon: {glyph: c}}}]\n---\nbody }}}\n' > "$T/sl-ok.md"
  printf -- '---\nkind: comment\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: n}, kind: agent}}\n---\n' > "$T/sl-open.md"
  ! stamp_lines_ok "$T/sl-bad.md" created && ! stamp_lines_ok "$T/sl-open.md" created && stamp_lines_ok "$T/sl-ok.md" created ) || { echo "stamp_lines_ok: a broken stamp passed or a quoted brace was refused"; exit 1; }
ok "stamp_lines_ok refuses a triple brace and an unbalanced brace on the stamp lines, and passes a quoted brace and a copied iconed label"
# existing bare stamps are unchanged: no quotes, no churn
SVQ2=$(bq "SV bare"); "$SK/work/scripts/post-comment.sh" "$BQ" "$SVQ2" --body "$SVBODY" --model claude-fable-5-2 --name claude --session s-1_2 --ahead 5 >/dev/null
grep -q '^modified: {at: [^,]*, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "s-1_2"}}$' "$(dirname "$(bcard "$SVQ2")")"/comments/*/index.md || { echo "a bare stamp changed"; exit 1; }
ok "a plain --name and --model stay bare in the stamp, byte for byte as before"
# the merge driver's signer quotes model by the same rule, and drops a control character with a note
python3 - "$SK/merge/scripts/lanework-merge.py" <<'PY' || { echo "lanework-merge.py signer: model not quoted"; exit 1; }
import importlib.util, sys, yaml; sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("lm", sys.argv[1]); lm = importlib.util.module_from_spec(spec); spec.loader.exec_module(lm)
for m in ['a: b', '{n}', 'a"b', 'a\\', 'a\\"}}}', '#x', 'plain-1.2', 'null', 'Null', '~', 'true', 'Yes', '123', '1e3', '0x1F', '0o17', '.inf', '-.NaN', '1.5']:
    by = yaml.safe_load("by: " + lm.signer(m))["by"]
    assert by["model"] == m and by["session"] == "merge" and by["name"] == "claude", (m, by)
assert lm.signer("plain-1.2") == '{name: claude, kind: agent, model: plain-1.2, session: "merge"}'
for bad in ("a\nb", "a\x85b", "a\x9fb", "a\x7fb"):
    by = yaml.safe_load("by: " + lm.signer(bad))["by"]; assert "model" not in by, (bad, by)
assert lm.signer("claude-fable-5-2") == '{name: claude, kind: agent, model: claude-fable-5-2, session: "merge"}'
hs = importlib.util.spec_from_file_location("hd", sys.argv[1].replace("merge/scripts/lanework-merge.py", "heal/scripts/heal-descriptors.py")); hd = importlib.util.module_from_spec(hs); hs.loader.exec_module(hd)
for m in ["null", "~", "true", "123", "1e3", "0x1F", ".inf", "a: b"]:
    assert yaml.safe_load("v: " + hd.scalar(m))["v"] == m, m
for m in ["claude", "claude-fable-5-2", "smoke", "m"]:
    assert hd.scalar(m) == m, m
PY
ok "lanework-merge.py signer: model 'a: b', '{n}', a quote, a backslash and '#x' parse back unchanged, a plain model stays bare, a control character is dropped"
BQ="$SBQ"; BPL="$SBPL"
# by_of quotes `session` always: a brace, even a triple one, inside the quoted session is a valid stamp
for sv in 'a{b' 'x}' 'x}}}'; do
  BQS2=$(bq "Brace session $sv"); "$SK/work/scripts/move-card.sh" "$BQ" "$BQS2" Parked --model smoke --session "$sv" >/dev/null || { echo "move-card.sh refused --session $sv"; exit 1; }
  grep -qF "session: \"$sv\"" "$(bcard "$BQS2")" && validate "$BQ" >/dev/null || { echo "move-card.sh --session $sv: stamp or board wrong"; exit 1; }
done
BQS3=$(bq "Brace session comment"); "$SK/work/scripts/post-comment.sh" "$BQ" "$BQS3" --body "$T/bruling.md" --model smoke --session 'a{b}}}' --ahead 5 >/dev/null && validate "$BQ" >/dev/null || { echo "post-comment.sh refused a braced --session"; exit 1; }
ok "a --session holding a brace, or a triple brace, is a valid quoted stamp: move-card.sh and post-comment.sh write it and the board validates"
# a card whose front matter closes with trailing spaces after the --- : the guard stops there, so a body line that starts like a stamp key is not read
BQT=$(bq "Brace trailing fence"); BQTF=$(bcard "$BQT"); owner_comment "$(dirname "$BQTF")" 'A.'; python3 - "$BQTF" <<'PY'
import sys
p = sys.argv[1]; h, fm, b = open(p).read().split("---\n", 2)
open(p, "w").write(h + "---\n" + fm + "---  \n" + b.rstrip("\n") + '\n\nmodified: {"a": {"b": {"c": 1}}}\n')
PY
"$SK/discovery/scripts/settle-question.sh" "$BQ" "$BQT" --ruling "$T/bruling.md" --model smoke >/dev/null || { echo "settle-question.sh refused a card whose front matter closes with trailing spaces"; exit 1; }
grep -qxF 'modified: {"a": {"b": {"c": 1}}}' "$(bcard "$BQT")" || { echo "settle-question.sh changed the body line that looks like a stamp"; exit 1; }
ok "a card whose closing --- has trailing spaces: the guard stops at it, so a body line starting like a stamp key is not read (settle-question.sh exits 0, line unchanged)"
if grep -rn "grep -q '}}}'" "$SK" | grep -v '/lib.sh:' | grep -q .; then echo "a script still greps a whole file for a triple brace:"; grep -rn "grep -q '}}}'" "$SK" | grep -v '/lib.sh:'; exit 1; fi
ok "no script outside lib.sh greps a whole file for a triple brace"

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
rc=0; "$SK/work/scripts/lint-ask.sh" >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "lint-ask with no arguments: want exit 2, got $rc"; exit 1; }; ok "lint-ask with no arguments exits 2 (usage), not 1 (violations)"
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
"$SK/work/scripts/lint-ask.sh" "$T/any-quoted.md" "$G118" || { echo "lint-ask treated a record quoting @anyone in backticks or a URL as an ask"; exit 1; }
printf 'Context first.\n\nWe said @anyone should answer.\n' > "$T/any-mid.md"
if "$SK/work/scripts/lint-ask.sh" "$T/any-mid.md" "$G118" >/dev/null; then echo "lint-ask passed a bare mid-thread @anyone"; exit 1; fi
ok "lint-ask on a v118 board passes a record quoting @anyone in a code span or a URL, and still fails a bare @anyone that is not on line 1"
printf '@bob Should we ship it?\n\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/bob-good.md"
printf '@bob maybe ship it; worth a try? or not?\n' > "$T/bob-bad.md"
printf 'Per @bob we shipped it.\n\nNothing is owed in reply.\n' > "$T/bob-mid.md"
for B in "$G118" "$G114"; do
  "$SK/work/scripts/lint-ask.sh" "$T/bob-good.md" "$B" || { echo "lint-ask failed a clean @bob ask on $B"; exit 1; }
  "$SK/work/scripts/lint-ask.sh" "$T/bob-mid.md" "$B" || { echo "lint-ask treated a mid-sentence @bob as an ask on $B"; exit 1; }
  OB=$("$SK/work/scripts/lint-ask.sh" "$T/bob-bad.md" "$B") && { echo "lint-ask passed a bad @bob ask on $B"; exit 1; }
  [ -n "$OB" ] || { echo "lint-ask failed a bad @bob ask silently on $B"; exit 1; }
done
ok "lint-ask treats a handle starting line 1 as an ask for that person (clean passes, bad fails) on v118 and v114 boards, and passes a mid-sentence @bob record"
GAQ="$T/GAgentsOnly.lanework"; mkdir -p "$GAQ"; printf '<!-- lanework-agent-guide v118 - app guide -->\n' > "$GAQ/AGENTS.md"
"$SK/work/scripts/lint-ask.sh" "$T/any-quoted.md" "$GAQ" || { echo "lint-ask treated a quoted @anyone as an ask on a board with no handle line"; exit 1; }
"$SK/work/scripts/lint-ask.sh" "$T/any-quoted.md" || { echo "lint-ask treated a quoted @anyone as an ask with no board"; exit 1; }
GAH="$T/GAgentsHandle.lanework"; mkguide "$GAH" 118; mv "$GAH/CLAUDE.md" "$GAH/AGENTS.md"
[ "$( . "$SK/lanework/scripts/lib.sh"; owner_handle "$GAH" )" = kim ] || { echo "owner_handle ignores AGENTS.md when CLAUDE.md is absent"; exit 1; }
ok "lint-ask passes a record quoting @anyone in backticks on an AGENTS.md-only board and with no board; owner_handle reads AGENTS.md"
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

# sentinel card for the lints: sent_card <lane dir> <card folder> [comment folder suffix] writes a card every lint finds something in, so a silent run
# on a board that holds it proves the lint read the cards: a modified.at 10 minutes ahead (lint-stamps), an agent ask with no waiting (lint-waiting-clears
# NO-QUOTE), a START with a session (lint-leases: one leased card). sent_check <script> <board as given> <lane dir as given> <card folder> [suffix]: the
# lint's run on <board> (rc UR, stdout UO, stderr UE, from unr_run) must be exactly that card's findings, nothing else.
SENT_TS=$(date -u -v+600S +%FT%TZ); SENT_ASK=f0000000-0000-4000-8000-00000000000a; SENT_START=f0000000-0000-4000-8000-00000000000b
sent_card() { local d="$1/$2" x="${3:-}"; mkdir -p "$d/comments/$SENT_ASK$x" "$d/comments/$SENT_START$x"
  printf -- '---\nschema: 1\nkind: card\ntitle: "Sentinel"\norder: 1024\ncreated: {at: 2026-11-01T00:00:00Z, by: {name: kim, kind: human}}\nmodified: {at: %s, by: {name: kim, kind: human}}\n---\nBody.\n' "$SENT_TS" > "$d/index.md"
  printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-17T10:00:00Z, by: {name: claude, kind: agent, model: smoke}}\n---\n@anyone Which route?\n' > "$d/comments/$SENT_ASK$x/index.md"
  printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-17T10:00:05Z, by: {name: claude, kind: agent, model: smoke, session: "S-sent"}}\n---\nSTART: sentinel\n' > "$d/comments/$SENT_START$x/index.md"; }
esc() ( . "$SK/lanework/scripts/lib.sh"; show_name "$1" )   # the escaped form a lint prints for a name (lanework/scripts/lib.sh show_name)
sent_check() { local want x="${5:-}"
  case "$(basename "$1")" in
    lint-stamps.sh) want="$(esc "$3/$4/index.md"): modified.at $SENT_TS is Ns ahead"; [ "$UR" = 1 ] && [ "$(sed -E 's/is [0-9]+s ahead/is Ns ahead/' <<<"$UO")" = "$want" ] ;;
    lint-waiting-clears.sh) want="NO-QUOTE $(esc "$4") $(esc "${SENT_ASK}${x}")"$'\n'"QUOTED 0, NO-QUOTE 1"; [ "$UR" = 1 ] && [ "$UO" = "$want" ] ;;
    lint-leases.sh) want="leased cards: 1, lease lost: 0, two STARTs: 0, lapsed: 0"; [ "$UR" = 0 ] && [ -z "$UO" ] && [ "$UE" = "$want" ] ;;
  esac || unr_fail "$(basename "$1") on $2: want exactly the sentinel card's finding (${want:-})"; }
# work: lint-stamps (a copy of the discovery board, so the board under test is never edited in place)
LS="$SK/work/scripts/lint-stamps.sh"; SB="$T/Stamps.lanework"; cp -R "$D" "$SB"
SC=$(ls "$SB"/*/*/index.md | head -1)
# setstamp <card file> modified|waiting <seconds-ahead>: set that stamp from the clock, ahead by N seconds
setstamp() { local ts; ts=$(date -u -v+${3}S +%FT%TZ)
  if [ "$2" = modified ]; then sed -i '' -E "s/^modified: \{at: [^,}]*/modified: {at: $ts/" "$1"
  else awk -v w="waiting: {for: rzen, since: $ts, comment: 11111111-1111-4111-8111-111111111111}" '/^waiting:/ {next} {print} /^modified:/ && !d {print w; d=1}' "$1" > "$1.new" && mv "$1.new" "$1"; fi; }
SBL=$(dirname "$(dirname "$SC")"); SBS="$SBL/f1000000-0000-4000-8000-000000000001"; sent_card "$SBL" "$(basename "$SBS")"
rc=0; out=$("$LS" "$SB" 2>&1) || rc=$?; [ "$rc" -eq 1 ] && [ "$(sed -E 's/is [0-9]+s ahead/is Ns ahead/' <<<"$out")" = "$SBS/index.md: modified.at $SENT_TS is Ns ahead" ] || { echo "lint-stamps on a board with only a sentinel finding: want exactly that line, exit 1, got $rc:"; echo "$out"; exit 1; }
rm -rf "$SBS"
rc=0; out=$("$LS" "$SB" 2>&1) || rc=$?; [ "$rc" -eq 0 ] && [ -z "$out" ] || { echo "lint-stamps on a clean board: want silent exit 0, got $rc:"; echo "$out"; exit 1; }
ok "lint-stamps finds exactly the sentinel card's stamp on a board of clean cards, and is silent and exits 0 once it is removed"
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

# work: lint-leases (a copy of the discovery board with its cards removed and the comments, claimed keys and START records seeded here; read-only, so the tree is byte-identical after)
LL="$SK/work/scripts/lint-leases.sh"; LLB="$T/LeaseLint.lanework"; LLBASE="$T/LeaseLintBase.lanework"; cp -R "$D" "$LLBASE"
LLN=$(basename "$(dirname "$(ls "$LLBASE"/*/index.md | sed -n 2p)")"); rm -rf "${LLBASE:?}"/*/*/
LLPRE=$(. "$SK/lanework/scripts/lib.sh"; printf '%s' "$LEASE_LOST_PREFIX")
# every fixture time of a case is an offset from ONE epoch (LLNOW, taken by llfresh), so no two stamps straddle a second boundary
llago() { date -u -r $((LLNOW - $1)) +%Y-%m-%dT%H:%M:%SZ; }; llahead() { date -u -r $((LLNOW + $1)) +%Y-%m-%dT%H:%M:%SZ; }
# llfresh: a new board from the base; llcard <card> [claimed text]; llcom <card> <comment id> <at> <session> <first line> [crlf|block]
llfresh() { LLNOW=$(date -u +%s); rm -rf "${LLB:?}"; cp -R "$LLBASE" "$LLB"; }
llcard() { mkdir -p "$LLB/$LLN/$1"
  { printf -- '---\nschema: 1\nkind: card\ntitle: "Lint %s"\norder: 1024\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n' "$1"
    [ -z "${2:-}" ] || printf '%s\n' "$2"; printf -- '---\nBody.\n'; } > "$LLB/$LLN/$1/index.md"; }
llcom() { local d="$LLB/$LLN/$1/comments/$2" f; mkdir -p "$d"; f="$d/index.md"
  if [ "${6:-}" = block ]; then
    printf -- '---\nschema: 1\nkind: comment\ncreated:\n  at: %s\n  by: {name: x, kind: agent, model: smoke, session: "%s"}\n---\n%s\n' "$3" "$4" "$5" > "$f"
  else
    printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: %s, by: {name: x, kind: agent, model: smoke, session: "%s"}}\nmodified: {at: %s, by: {name: x, kind: agent, model: smoke, session: "%s"}}\n---\n%s\n' "$3" "$4" "$3" "$4" "$5" > "$f"
  fi
  if [ "${6:-}" = crlf ]; then perl -pi -e 's/\n/\r\n/' "$f"; fi; }
# lint <args>: LO stdout, LE stderr, LR exit
lint() { LR=0; LO=$("$LL" "$@" 2>"$T/ll.err") || LR=$?; LE=$(cat "$T/ll.err"); }
llfail() { echo "$1"; echo "stdout: $LO"; echo "stderr: $LE"; echo "exit: $LR"; exit 1; }
LA=d1000000-0000-4000-8000-000000000001; LB2=d1000000-0000-4000-8000-000000000002; LC=d1000000-0000-4000-8000-000000000003
LD=d1000000-0000-4000-8000-000000000004; LH=d1000000-0000-4000-8000-000000000005; LF=d1000000-0000-4000-8000-000000000006; LG=d1000000-0000-4000-8000-000000000007

# 1. one-session STARTs only (flow, block and CRLF comments, a non-START comment, a card with no comment): silent, exit 0, tally on stderr
llfresh; llcard $LA; llcard $LB2; llcard $LC
llcom $LA c1000000-0000-4000-8000-000000000001 "$(llago 7200)" S-one '**START: first**'
llcom $LA c1000000-0000-4000-8000-000000000002 "$(llago 7100)" S-one 'START: again after a compaction' block
llcom $LA c1000000-0000-4000-8000-000000000003 "$(llago 7000)" S-one 'Just a note.'
llcom $LB2 c1000000-0000-4000-8000-000000000004 "$(llago 7200)" S-two '**START: b**' crlf
lint "$LLB"; [ "$LR" = 0 ] && [ -z "$LO" ] && [ "$LE" = "leased cards: 2, lease lost: 0, two STARTs: 0, lapsed: 0" ] || llfail "lint-leases on one-session STARTs: want silent exit 0 and the tally on stderr"
ok "lint-leases is silent, exits 0 and tallies the leased cards on a board with only one-session STARTs (flow, block and CRLF comments read)"

# 2. a lease-lost record
llfresh; LT2=$(llago 600); llcard $LA; llcom $LA c2000000-0000-4000-8000-000000000001 "$LT2" S-gone "$LLPRE session S-gone no longer holds this card; session S-other does."
# not hits: the prefix quoted mid-line, and on the second line
llcom $LA c2000000-0000-4000-8000-000000000002 "$(llago 500)" S-gone "A note quoting $LLPRE mid-line, and nothing else."
llcom $LA c2000000-0000-4000-8000-000000000003 "$(llago 400)" S-gone $'A note whose second line starts it.\n'"$LLPRE not the opening."
lint "$LLB"
[ "$LR" = 1 ] && [ "$LO" = "$LLB/$LLN/$LA: lease lost c2000000-0000-4000-8000-000000000001 $LT2" ] && [ "$LE" = "leased cards: 1, lease lost: 1, two STARTs: 0, lapsed: 0" ] || llfail "lint-leases on a lease-lost record"
ok "lint-leases finds a lease-lost record, naming the card and the comment id and its time"

# 3. two STARTs
llfresh; for c in $LD $LH $LF $LG; do llcard $c; done
llcom $LD c3000000-0000-4000-8000-000000000001 "$(llago 5000)" S-a '**START: d1**'; llcom $LD c3000000-0000-4000-8000-000000000002 "$(llago 4900)" S-b 'START: d2' block
llcom $LD c3000000-0000-4000-8000-000000000003 "$(llago 4000)" S-a 'The first session writes again.'
llcom $LH c3000000-0000-4000-8000-000000000004 "$(llago 5000)" S-a '**START: e1**'; llcom $LH c3000000-0000-4000-8000-000000000005 "$(llago 4900)" S-b '**START: e2**'
llcom $LF c3000000-0000-4000-8000-000000000006 "$(llago 5000)" S-a '**START: f1**'; llcom $LF c3000000-0000-4000-8000-000000000007 "$(llago 4900)" S-a '**START: f2**'
llcom $LG c3000000-0000-4000-8000-000000000008 "$(llago 5000)" S-a '**START: g1**'; llcom $LG c3000000-0000-4000-8000-000000000009 "$(llago 2000)" S-b '**START: g2**'
lint "$LLB"
[ "$LR" = 1 ] && [ "$(grep -c . <<<"$LO")" = 2 ] \
  && grep -qE ": two STARTs c3000000-0000-4000-8000-000000000001 c3000000-0000-4000-8000-000000000002 100s apart first session wrote again\$" <<<"$(grep "/$LD:" <<<"$LO")" \
  && grep -qE ": two STARTs c3000000-0000-4000-8000-000000000004 c3000000-0000-4000-8000-000000000005 100s apart\$" <<<"$(grep "/$LH:" <<<"$LO")" \
  && [ "$LE" = "leased cards: 4, lease lost: 0, two STARTs: 2, lapsed: 0" ] || llfail "lint-leases two STARTs: want D tagged, E plain, F (one session) and G (3000 s apart) passed"
lint "$LLB" --window 4000; [ "$(grep -c . <<<"$LO")" = 3 ] && grep -q "/$LG: two STARTs .* 3000s apart\$" <<<"$LO" || llfail "--window 4000 should add G"
ok "lint-leases finds two STARTs from two sessions inside the window, tags first session wrote again, and passes two from one session and two from sessions farther apart than the window (--window widens it)"

# 4. a lapsed claimed
llfresh
llcard $LD "claimed: {by: {name: c, kind: agent, model: smoke, session: \"S-x\"}, until: $(llago 2000)}"
llcard $LH "claimed:
  by: {name: c, kind: agent, model: smoke, session: \"S-x\"}
  until: $(llago 2000)"
llcard $LF "claimed:
  by: {name: c, kind: agent, model: smoke, session: \"S-x\"}
  until: $(llahead 1500)"
llcard $LG "claimed: {by: {name: c, kind: agent, model: smoke, session: \"S-x\"}, until: $(llago 100)}"
lint "$LLB"
[ "$LR" = 1 ] && [ "$(grep -c . <<<"$LO")" = 2 ] && grep -qE "/$LD: claimed until 20[0-9-]+T[0-9:]+Z is 20[0-9][0-9]s lapsed\$" <<<"$LO" \
  && grep -qE "/$LH: claimed until 20[0-9-]+T[0-9:]+Z is 20[0-9][0-9]s lapsed\$" <<<"$LO" && [ "$LE" = "leased cards: 0, lease lost: 0, two STARTs: 0, lapsed: 2" ] || llfail "lint-leases lapsed: want the flow and block claims 2000 s lapsed, the live one and the one inside the grace passed"
lint "$LLB" --grace 50; [ "$(grep -c . <<<"$LO")" = 3 ] && grep -q "/$LG: claimed until" <<<"$LO" || llfail "--grace 50 should add the 100 s lapse"
# a voided claim (until over 35 minutes ahead, or unreadable) is no lapse
llcard $LD "claimed: {by: {name: c, kind: agent, model: smoke, session: \"S-x\"}, until: $(llahead 9000)}"; llcard $LH "claimed: {by: {name: c, kind: agent, model: smoke, session: \"S-x\"}, until: tomorrow}"
rm -rf "${LLB:?}/$LLN/$LF" "${LLB:?}/$LLN/$LG"; lint "$LLB"; [ "$LR" = 0 ] && [ -z "$LO" ] || llfail "a voided claim (until far ahead or unreadable) must not be reported lapsed"
ok "lint-leases finds a claimed lapsed past the grace in flow and block form, passes a live lease and one lapsed inside the grace (--grace narrows it), and skips a voided claim"

# 5. --since and --first
llfresh; for c in $LA $LB2 $LC $LD; do llcard $c; done
llcom $LA c5000000-0000-4000-8000-000000000001 "$(llago 4000)" S-a '**START: a**'; llcom $LA c5000000-0000-4000-8000-000000000002 "$(llago 3900)" S-a "$LLPRE one"
llcom $LB2 c5000000-0000-4000-8000-000000000003 "$(llago 3000)" S-a '**START: b**'; llcom $LB2 c5000000-0000-4000-8000-000000000004 "$(llago 2950)" S-b '**START: b2**'
llcom $LC c5000000-0000-4000-8000-000000000005 "$(llago 2000)" S-a '**START: c**'
llcom $LD c5000000-0000-4000-8000-000000000006 "$(llago 1000)" S-a '**START: d**'; llcom $LD c5000000-0000-4000-8000-000000000007 "$(llago 900)" S-a "$LLPRE two"
lint "$LLB"; [ "$LE" = "leased cards: 4, lease lost: 2, two STARTs: 1, lapsed: 0" ] || llfail "lint-leases with no --since: want all four cards"
lint "$LLB" --since "$(llago 3500)"; [ "$LE" = "leased cards: 3, lease lost: 1, two STARTs: 1, lapsed: 0" ] && ! grep -q "/$LA:" <<<"$LO" && grep -q "/$LD: lease lost" <<<"$LO" || llfail "--since left card A's earlier START and lost record in"
lint "$LLB" --since "$(llago 2500)"; [ "$LE" = "leased cards: 2, lease lost: 1, two STARTs: 0, lapsed: 0" ] || llfail "--since 2500 s ago: want C and D, the two-START card B out"
lint "$LLB" --first 2; [ "$LE" = "leased cards: 2, lease lost: 1, two STARTs: 1, lapsed: 0" ] && grep -q "/$LA: lease lost" <<<"$LO" && grep -q "/$LB2: two STARTs" <<<"$LO" && ! grep -q "/$LD:" <<<"$LO" || llfail "--first 2 should keep A and B only"
lint "$LLB" --first 3 --since "$(llago 3500)"; [ "$LE" = "leased cards: 3, lease lost: 1, two STARTs: 1, lapsed: 0" ] || llfail "--first 3 with --since: B, C, D"
lint "$LLB" --first 1 --since "$(llago 3500)"; [ "$LE" = "leased cards: 1, lease lost: 0, two STARTs: 1, lapsed: 0" ] || llfail "--first 1 with --since: B only"
ok "lint-leases --since leaves out earlier STARTs and lost records and --first keeps the earliest n cards, for the tally and the findings"

# 6. read-only, and the exit-2 edges
llfresh; llcard $LA "claimed: {by: {name: c, kind: agent, model: smoke, session: \"S-x\"}, until: $(llago 2000)}"; llcom $LA c6000000-0000-4000-8000-000000000001 "$(llago 600)" S-gone "$LLPRE x"
llcom $LA c6000000-0000-4000-8000-000000000002 "$(llago 5000)" S-a '**START: a**'; llcom $LA c6000000-0000-4000-8000-000000000003 "$(llago 4900)" S-b '**START: b**'
S0=$(sum "$LLB"); lint "$LLB" --since "$(llago 9000)" --first 5; [ "$LR" = 1 ] && [ "$(grep -c . <<<"$LO")" = 3 ] || llfail "lint-leases did not find the three seeded findings"
lint "$LLB" "$LLB/"; [ "$LR" = 1 ] && [ "$S0" = "$(sum "$LLB")" ] || llfail "lint-leases changed the board"
mkdir -p "$T/not-a-board"; for a in "$T/no-such-board" "$T/not-a-board"; do lint "$a"; [ "$LR" = 2 ] && [ -z "$LO" ] && [ -n "$LE" ] || llfail "lint-leases $a: want exit 2, nothing on stdout, a message on stderr"; done
lint; [ "$LR" = 2 ] && [ -z "$LO" ] && grep -q '^usage: lint-leases.sh' <<<"$LE" || llfail "no board: want exit 2 and the usage on stderr"
for a in "--bogus" "--since" "--since yesterday" "--since 2026-13-01T00:00:00Z" "--since 2026-02-30T00:00:00Z" "--since 2026-01-01T24:00:00Z" "--first 0" "--first x" "--window -1" "--grace"; do lint "$LLB" $a; [ "$LR" = 2 ] && [ -z "$LO" ] && [ -n "$LE" ] || llfail "lint-leases $a: want exit 2"; done
ok "lint-leases leaves every file of the board unchanged (checksum before and after) and exits 2 on a missing path, a folder that is no board, no board, an unknown flag and a bad flag value"

# 8. a symlinked board reads like its target; 9. a board passed twice (any spelling) counts once, and the lines print the first spelling given
llfresh; llcard $LA "claimed: {by: {name: c, kind: agent, model: smoke, session: \"S-x\"}, until: $(llago 2000)}"; llcom $LA c8000000-0000-4000-8000-000000000001 "$(llago 600)" S-gone "$LLPRE x"
llcom $LA c8000000-0000-4000-8000-000000000002 "$(llago 5000)" S-a '**START: a**'
llnorm() { sed -E "s/is [0-9]+s lapsed/is Ns lapsed/"; }   # the lapsed seconds move with the lint's own clock; compare the rest
lint "$LLB"; LO1=$(llnorm <<<"$LO"); LE1=$LE; [ "$LR" = 1 ] && [ "$LE1" = "leased cards: 1, lease lost: 1, two STARTs: 0, lapsed: 1" ] || llfail "case 8: the real folder"
ln -s "$LLB" "$T/LeaseLintLink.lanework"
lint "$T/LeaseLintLink.lanework"; [ "$LR" = 1 ] && [ "$LE" = "$LE1" ] && [ "$(llnorm <<<"$LO")" = "$(sed "s#^$LLB/#$T/LeaseLintLink.lanework/#" <<<"$LO1")" ] || llfail "case 8: a symlinked board must read like its target and print the spelling given"
lint "$T/LeaseLintLink.lanework/"; [ "$LR" = 1 ] && [ "$LE" = "$LE1" ] || llfail "case 8: a symlink with a trailing slash"
ok "lint-leases reads a symlinked board like the folder it points at, and prints the spelling it was given"
lint "$LLB" "$LLB"; [ "$LR" = 1 ] && [ "$(llnorm <<<"$LO")" = "$LO1" ] && [ "$LE" = "$LE1" ] || llfail "case 9: a board passed twice"
lint "$LLB" "$T/LeaseLintLink.lanework" "$LLB/"; [ "$LR" = 1 ] && [ "$(llnorm <<<"$LO")" = "$LO1" ] && [ "$LE" = "$LE1" ] || llfail "case 9: a board passed as itself, a symlink and with a slash"
(cd "$T" && LR=0 && LO=$("$LL" "./LeaseLint.lanework" "LeaseLint.lanework" "$LLB" 2>"$T/ll.err") || LR=$?; [ "$(llnorm <<<"$LO")" = "$(sed "s#^$LLB/#./LeaseLint.lanework/#" <<<"$LO1")" ] && [ "$(cat "$T/ll.err")" = "$LE1" ]) || llfail "case 9: X, ./X and the absolute path"
ok "lint-leases counts a board passed twice once, in the same spelling, as X and ./X, and through a symlink"

# 7. the real record: lease.sh loses a card (staked, its timer ended, claimed taken by another session, then checked); the lint finds it
LLT=$(mktemp -d "$T/lease-lint-tmp.XXXXXX"); sleep 600 </dev/null >/dev/null 2>&1 & LLP=$!; disown "$LLP"
llfresh; llcard $LA; LLK=$(printf '%s' "$(cd "$LLB" && pwd -P)" | shasum | cut -c1-16)
LLL() { CLAUDE_CODE_SESSION_ID=S-lintlease CLAUDE_PID="$LLP" TMPDIR="$LLT" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_NOTICE_WAIT=1.5 LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 "$SK/lanework/scripts/lease.sh" "$@"; }
LLL stake "$LLB" $LA --model smoke >/dev/null || { kill "$LLP"; echo "case 7: stake failed"; exit 1; }
LLTP=$(sed -n 's/^pid=//p' "$LLT/lanework-lease/S-lintlease/$LLK/$LA"); kill "$LLTP" 2>/dev/null || true
perl -0pi -e 's/^claimed:.*\n(?:[ \t].*\n)*//m; s/\A(---\n.*?\n)(---\n)/$1claimed:\n  by: {name: claude, kind: agent, model: smoke, session: "S-other"}\n  until: '"$(llahead 1500)"'\n$2/s' "$LLB/$LLN/$LA/index.md"
LLR=0; LLL check "$LLB" $LA --model smoke >/dev/null 2>&1 || LLR=$?; kill "$LLP" 2>/dev/null || true
LLREC=$(grep -l -F 'Lease lost' "$LLB/$LLN/$LA"/comments/*/index.md); LLID=$(basename "$(dirname "$LLREC")")
[ "$LLR" = 3 ] && [ "$(awk 'f && NF {print; exit} /^---$/ {n++; if (n == 2) f = 1}' "$LLREC" | cut -c1-${#LLPRE})" = "$LLPRE" ] || llfail "case 7: lease.sh check rc $LLR; the record does not open with LEASE_LOST_PREFIX: $(cat "$LLREC")"
lint "$LLB"; [ "$LR" = 1 ] && [ "$(grep -c . <<<"$LO")" = 1 ] && grep -qE "/$LA: lease lost $LLID 20[0-9-]+T[0-9:]+Z\$" <<<"$LO" && [ "$LE" = "leased cards: 1, lease lost: 1, two STARTs: 0, lapsed: 0" ] || llfail "case 7: the lint did not find the real loss record"
ok "lint-leases finds the real lease-lost record lease.sh posts on a throwaway board, which opens with LEASE_LOST_PREFIX"

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
  case "$4" in agent) by='{name: claude, kind: agent, model: claude-sonnet-5-5}' ;; human) ;; *) by="{name: shortcuts, kind: $4}" ;; esac; [ "$5" = - ] || irt="in-reply-to: $5"$'\n'
  { printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-17T%sZ, by: %s}\n%s---\n' "$3" "$by" "$irt"; printf "$6"; } > "$d/index.md"; }
WASK='@anyone Which route?\n\nOptions:\n- A: x\n- Recap: Explain this in plain terms first\n'
WREC='**Owner ruled off the board.**\n\n> Yes, A.\n\n**Given**: chat, 2026-11-17\n'
# wl_expect <rc> <output, printf format>: run the lint on the board; its exit code and stdout must match
WLX=""   # extra arguments for the next wl_expect, word-split
wl_expect() { local rc=0 out; out=$("$WL" "$WB" $WLX 2>&1) || rc=$?; [ "$rc" -eq "$1" ] && [ "$out" = "$(printf "$2")" ] || { echo "lint-waiting-clears: want exit $1 and [$(printf "$2")], got $rc and [$out]"; exit 1; }; }
wl_reset() { rm -rf "$WLANE"/c0*; }
# wl_silent: the board must list nothing but a sentinel NO-QUOTE card built here, so silence proves the lint read the cards (a lint that skipped every card would pass a bare silent case)
wl_silent() { wl_card 9; wl_com 9 ${WA}9 12:00:00 agent - "$WASK"; wl_expect 1 "NO-QUOTE ${WC}9 ${WA}9\nQUOTED 0, NO-QUOTE 1"; rm -rf "$WLANE/${WC}9"; }
wl_silent
ok "lint-waiting-clears lists only the sentinel card on a board with no other cards"
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
wl_silent
ok "lint-waiting-clears: an ask with waiting present is silent, in the flow and the block form"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WH}1 10:30:00 human - 'Looks fine.\n'
wl_card 2; wl_com 2 ${WA}1 10:00:00 agent - "$WASK"; wl_com 2 ${WH}1 09:00:00 human ${WA}1 'A: Yes.\n'
wl_silent
ok "lint-waiting-clears: an ask followed by a human comment, or a human reply in-reply-to it, with waiting absent (the app's clear) is silent"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WA}2 11:00:00 agent - "$WASK"
wl_expect 1 "NO-QUOTE ${WC}1 ${WA}2\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: two asks, the newer unanswered and unmarked with no record, names the newer ask's uuid only"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - '**A record, no ask.**\n\nEvidence: none.\n'; wl_com 1 ${WH}1 10:01:00 human - '@anyone not an ask, a human wrote it\n'
wl_card 2 '' "$WB/.trash"; wl_com 2 ${WA}1 10:00:00 agent - "$WASK" "$WB/.trash"
wl_silent
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
# --since: a card is listed when its clear time (the newest of the ask and the agent records in-reply-to it) is at or after the value
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WA}2 10:00:05 agent ${WA}1 "$WREC"
WLX="--since 2026-11-17T10:01:00Z"; wl_silent
WLX="--since 2026-11-17T10:00:05Z"; wl_expect 0 "QUOTED ${WC}1 ${WA}1\nQUOTED 1, NO-QUOTE 0"
ok "lint-waiting-clears --since: an ask and record both before it are silent, exit 0; at it, one QUOTED line"
WLX="--since 2026-11-17T10:00:03Z"; wl_expect 0 "QUOTED ${WC}1 ${WA}1\nQUOTED 1, NO-QUOTE 0"
ok "lint-waiting-clears --since: an old ask whose record comes after it is listed"
wl_reset; wl_card 1; wl_com 1 ${WA}1 09:00:00 agent - "$WASK"; wl_card 2; wl_com 2 ${WA}1 10:00:00 agent - "$WASK"; wl_com 2 ${WA}2 10:00:05 agent ${WA}1 "$WREC"
WLX="--since 2026-11-17T10:00:00Z"; wl_expect 0 "QUOTED ${WC}2 ${WA}1\nQUOTED 1, NO-QUOTE 0"
WLX=""; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED ${WC}2 ${WA}1\nQUOTED 1, NO-QUOTE 1"
ok "lint-waiting-clears --since: the tally counts the listed cards only; without it every card counts"
for bad in "--since nonsense" "--since" "--since 2026-11-17T10:00:00Z --since 2026-11-17T11:00:00Z" "--since 2026-11-17T10:00:00"; do
  rc=0; err=$("$WL" "$WB" $bad 2>&1 >/dev/null) || rc=$?; [ "$rc" -eq 2 ] && [ -n "$err" ] || { echo "lint-waiting-clears $bad: want exit 2 and a message on stderr, got $rc [$err]"; exit 1; }
done
ok "lint-waiting-clears --since: a bad value, a missing value and a repeated flag exit 2 with a message on stderr"
# the five edges
wl_reset; WLX=""; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WA}2 10:00:05 agent ${WA}1 '**Owner ruled off the board.**\n\nYes, A.\n'; wl_com 1 ${WH}1 10:10:00 shortcut - 'Build finished.\n'
wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: a shortcut comment after an agent clear is not a human answer, the clear is still listed"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WH}1 10:02:00.123 human - 'Done.\n'
wl_silent
ok "lint-waiting-clears: a human comment stamped with fractional seconds is read, so the card is not a clear"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; wl_com 1 ${WA}2 10:00:05 agent ${WA}1 '**Owner ruled off the board.**\n\n```\n> fake\n```\n\n**Given**: chat, 2026-11-17\n'
wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: a > line inside a code fence is not a quote"
wl_com 1 ${WA}2 10:00:05 agent ${WA}1 '**Owner ruled off the board.**\n\n> Yes, A.\n\n**Given** chat, 2026-11-17\n'; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: a Given line with no colon does not count"
wl_com 1 ${WA}2 10:00:05 agent ${WA}1 '**Owner ruled off the board.**\n\n> **Given**: chat, 2026-11-17\n'; wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: one quoted line carrying **Given**: is not both a quote and a Given line"
wl_reset; wl_card 1; wl_com 1 ${WA}1 10:00:00 agent - "$WASK"; printf 'waiting: {for: anyone, since: 2026-11-17T10:00:00Z, comment: x}\n' >> "$WLANE/${WC}1/index.md"
wl_expect 1 "NO-QUOTE ${WC}1 ${WA}1\nQUOTED 0, NO-QUOTE 1"
ok "lint-waiting-clears: a waiting: line in the card body is not the frontmatter key, the card is still listed"
wl_reset

# work: the lints follow a symlinked board and exit 2 with `could not read <path>` when part of it is unreadable (lanework/scripts/lib.sh board_index_files)
UB="$T/Unread.lanework"; cp -R "$D" "$UB"; UL=$(dirname "$(ls "$UB"/*/index.md | sed -n 2p)"); rm -rf "$UB"/*/*/   # no cards but the one built here
UC="$UL/e0000000-0000-4000-8000-000000000001"; UI="$UC/index.md"; mkdir -p "$UC/comments/e1000000-0000-4000-8000-000000000001"
printf -- '---\nschema: 1\nkind: card\ntitle: "Unread"\norder: 1024\ncreated: {at: 2026-11-01T00:00:00Z, by: {name: kim, kind: human}}\nmodified: {at: 2026-11-01T00:00:00Z, by: {name: kim, kind: human}}\n---\nBody.\n' > "$UI"
printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-01T00:00:00Z, by: {name: kim, kind: human}}\n---\nA note.\n' > "$UC/comments/e1000000-0000-4000-8000-000000000001/index.md"
USEN=f9000000-0000-4000-8000-000000000009; sent_card "$UL" "$USEN"   # the card a readable run must find
unr_restore() { chmod 755 "$UL" "$UC" 2>/dev/null || true; chmod 644 "$UI" 2>/dev/null || true; }
trap 'unr_restore; kill "$PSP" 2>/dev/null || true' EXIT
# unr_run <script> <board>: UO stdout, UE stderr, UR exit
unr_run() { UR=0; UO=$("$1" "$2" 2>"$T/unr.err") || UR=$?; UE=$(cat "$T/unr.err"); }
unr_fail() { echo "$1"; echo "stdout: $UO"; echo "stderr: $UE"; echo "exit: $UR"; exit 1; }
# a symlinked board with a future stamp reads like the folder
USB="$T/UnrStamps.lanework"; cp -R "$D" "$USB"; USC=$(ls "$USB"/*/*/index.md | sed -n 1p)
sed -i '' -E "s/^modified: \{at: [^,}]*/modified: {at: $(date -u -v+600S +%FT%TZ)/" "$USC"
unr_run "$LS" "$USB"; [ "$UR" = 1 ] && [ -n "$UO" ] || unr_fail "lint-stamps on the real path: want exit 1 and findings"
UREAL=$(sed -E "s/is [0-9]+s ahead/is Ns ahead/" <<<"$UO"); ln -s "$USB" "$T/UnrStampsLink.lanework"
unr_run "$LS" "$T/UnrStampsLink.lanework"; [ "$UR" = 1 ] && [ "$(sed -E "s#^$T/UnrStampsLink.lanework/#$USB/#; s/is [0-9]+s ahead/is Ns ahead/" <<<"$UO")" = "$UREAL" ] || unr_fail "lint-stamps on a symlink: want exit 1 and the same findings as the real path"
ok "lint-stamps follows a symlinked board: exit 1 with the same findings as the real path"
# a mode-000 lane, card folder and card index.md each give exit 2 and a could-not-read line on stderr, for the three lints
if [ "$(id -u)" = 0 ]; then echo "skip: running as root, mode 000 stays readable"; else
  for U in "$LS" "$LL" "$WL"; do
    unr_run "$U" "$UB"; sent_check "$U" "$UB" "$UL" "$USEN"
    for what in lane card index; do
      case $what in lane) X=$UL ;; card) X=$UC ;; index) X=$UI ;; esac
      chmod 000 "$X"; if [ -r "$X" ]; then unr_restore; unr_fail "$what is still readable after chmod 000"; fi
      unr_run "$U" "$UB"; unr_restore
      [ "$UR" = 2 ] && grep -q "^$(basename "$U"): could not read " <<<"$UE" || unr_fail "$(basename "$U") with the $what at mode 000: want exit 2 and a could not read line on stderr"
    done
    unr_run "$U" "$UB"; sent_check "$U" "$UB" "$UL" "$USEN"
  done
  ok "lint-stamps, lint-leases and lint-waiting-clears: a lane, a card folder and a card index.md at mode 000 each exit 2 with a could not read line; a readable board finds exactly its sentinel card"
fi
# a board path starting with - is a path, not a find option; a path that vanished between find and the read check is a moved card, not an error
UW="$T/UnrAsk.lanework"; cp -R "$UB" "$UW"; mkdir -p "$UW/$(basename "$UL")/$(basename "$UC")/comments/e2000000-0000-4000-8000-000000000001"
printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-02T00:00:00Z, by: {name: claude, kind: agent, model: smoke}}\n---\n@anyone Which route?\n' > "$UW/$(basename "$UL")/$(basename "$UC")/comments/e2000000-0000-4000-8000-000000000001/index.md"
# a board with findings, under a plain name and under one starting with -: same exit code, same number of lines
cp -R "$UW" "$T/-dashask.lanework"; cp -R "$USB" "$T/-dashstamps.lanework"
for pair in "$WL:UnrAsk.lanework:-dashask.lanework" "$LS:UnrStamps.lanework:-dashstamps.lanework"; do
  U=${pair%%:*}; r=${pair#*:}; plain=${r%%:*}; dash=${r#*:}
  unr_run "$U" "$T/$plain"; PR=$UR; PN=$(grep -c . <<<"$UO" || true)
  UR=0; UO=$(cd "$T" && "$U" "$dash" 2>"$T/unr.err") || UR=$?; UE=$(cat "$T/unr.err")
  [ "$PR" = 1 ] && [ "$PN" -ge 1 ] && [ "$UR" = "$PR" ] && [ "$(grep -c . <<<"$UO")" = "$PN" ] && [ -z "$UE" ] || unr_fail "$(basename "$U") on $dash: want exit $PR and $PN lines like the plain name (plain rc $PR, $PN lines)"
done
UO=$(. "$SK/lanework/scripts/lib.sh"; printf '%s\n' "$UB/moved-away/index.md" | unreadable_files 2>"$T/unr.err") && UR=0 || UR=$?; UE=$(cat "$T/unr.err")
[ "$UR" = 0 ] && [ -z "$UO" ] && [ -z "$UE" ] || unr_fail "a listed path that no longer exists: want it skipped silently, exit 0"
ok "the lints read a board whose name starts with -, and a path that vanished after find listed it is skipped, not reported"
unr_restore

# work: the lints read symlinked lanes and names with a newline, print the path as the caller spelled it, and a smoke line that greps nothing still reaches its message
NB="$T/NewCases.lanework"; cp -R "$D" "$NB"; NL=$(dirname "$(ls "$NB"/*/index.md | sed -n 2p)"); rm -rf "$NB"/*/*/
SLX="$T/ExtLane"; mkdir -p "$SLX"; cp "$NL/index.md" "$SLX/index.md"; SLC=f2000000-0000-4000-8000-000000000002; sent_card "$SLX" "$SLC"
ln -s "$SLX" "$NB/f2000000-0000-4000-8000-0000000000ff"   # a lane that is a symlink to a folder elsewhere
for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$NB"; sent_check "$U" "$NB" "$NB/f2000000-0000-4000-8000-0000000000ff" "$SLC"; done
rm "$NB/f2000000-0000-4000-8000-0000000000ff"
ok "lint-stamps, lint-leases and lint-waiting-clears read a lane that is a symlink: each reports that lane's card"
NLN=f3000000-0000-4000-8000-000000000003$'\n'x; NLC=$'\n'y; sent_card "$NL" "$NLN" "$NLC"   # a card folder and its comment folders with a newline in the name
for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$NB"; sent_check "$U" "$NB" "$NL" "$NLN" "$NLC"; done
rm -rf "$NL/$NLN"
NLT=f5000000-0000-4000-8000-000000000005$'\n'; sent_card "$NL" "$NLT"   # a card folder whose name ends in a newline
for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$NB"; sent_check "$U" "$NB" "$NL" "$NLT"; done
rm -rf "$NL/$NLT"
ok "lint-stamps, lint-leases and lint-waiting-clears read a card and a comment folder with a newline in the name, and print them escaped"
# one finding is one line: a tab, newline, carriage return or backslash in a name prints as \t, \n, \r or \\ (lanework/scripts/lib.sh show_name)
SHN=$'a\tb\\t\n\rz'; [ "$(. "$SK/lanework/scripts/lib.sh"; show_name "$SHN")" = 'a\tb\\t\n\rz' ] && [ "$(. "$SK/lanework/scripts/lib.sh"; show_name "plain name-1")" = "plain name-1" ] \
  && [ "$(. "$SK/lanework/scripts/lib.sh"; T="$SHN" awk "$SHOW_NAME_AWK"'BEGIN { print show_name(ENVIRON["T"]) }')" = 'a\tb\\t\n\rz' ] || { echo "show_name: want a<TAB>b\\t<NL><CR>z -> a\\tb\\\\t\\n\\rz, plain names unchanged, shell and awk alike"; exit 1; }
TN=f6000000-0000-4000-8000-000000000006$'\t'x; TC=$'\t'z; sent_card "$NL" "$TN" "$TC"; TO=f0000000-0000-4000-8000-00000000000c
mkdir -p "$NL/$TN/comments/$TO$TC"; printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-17T10:00:10Z, by: {name: claude, kind: agent, model: smoke, session: "S-other"}}\n---\nSTART: other\n' > "$NL/$TN/comments/$TO$TC/index.md"
tab_check() { local n="$1" w
  unr_run "$LS" "$NB"; [ "$UR" = 1 ] && [ "$(grep -c '' <<<"$UO")" = 1 ] && [ "$(sed -E 's/is [0-9]+s ahead/is Ns ahead/' <<<"$UO")" = "$(esc "$NL/$TN/index.md"): modified.at $SENT_TS is Ns ahead" ] \
    && w=$(sed -E 's/.* is ([0-9]+)s ahead/\1/' <<<"$UO") && w=$((w - ($(date -j -u -f %Y-%m-%dT%H:%M:%SZ "$SENT_TS" +%s) - $(date -u +%s)))) && [ "$w" -ge -3 ] && [ "$w" -le 3 ] || unr_fail "lint-stamps $n: want one line with the escaped path and the true seconds ahead (the stamp minus now, within 3 s)"
  unr_run "$WL" "$NB"; [ "$UR" = 1 ] && [ "$UO" = "NO-QUOTE $(esc "$TN") $(esc "$SENT_ASK$TC")"$'\n'"QUOTED 0, NO-QUOTE 1" ] || unr_fail "lint-waiting-clears $n: want the escaped card name and ask id, tally 1"
  unr_run "$LL" "$NB"; [ "$UR" = 1 ] && [ "$UO" = "$(esc "$NL/$TN"): two STARTs $(esc "$SENT_START$TC") $(esc "$TO$TC") 5s apart" ] && [ "$UE" = "leased cards: 1, lease lost: 0, two STARTs: 1, lapsed: 0" ] || unr_fail "lint-leases $n: want one escaped two-STARTs line, leased cards 1"; }
tab_check "on a card and comment folder with a tab in the name"
ok "lint-stamps, lint-leases and lint-waiting-clears print a tab in a card or comment name as \\t, one line per finding, with the true seconds"
ln -s "$(basename "$NL")" "$NB/zz-sibling"   # a lane that is a symlink to a sibling lane: each card is read once
tab_check "with a lane symlinked to a sibling lane"
rm -rf "$NL/$TN"; sent_card "$NL" f7000000-0000-4000-8000-000000000007
for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$NB"; sent_check "$U" "$NB" "$NL" f7000000-0000-4000-8000-000000000007; done
rm -rf "$NL/f7000000-0000-4000-8000-000000000007"
rm "$NB/zz-sibling"
ok "a lane that is a symlink to a sibling lane lists each card once in all three lints (leased cards: 1)"
# CDPATH set and a relative board path: no cd in the dedupe prints a folder or breaks it; each card is still listed once
ln -s "$(basename "$NL")" "$NB/zz-sibling"; sent_card "$NL" f7000000-0000-4000-8000-000000000007
for U in "$LS" "$LL" "$WL"; do UR=0; UO=$(cd "$T" && CDPATH=.: "$U" NewCases.lanework 2>"$T/unr.err") || UR=$?; UE=$(cat "$T/unr.err")
  case "$(basename "$U")" in lint-leases.sh) [ "$UE" = "leased cards: 1, lease lost: 0, two STARTs: 0, lapsed: 0" ] && [ -z "$UO" ] ;; *) [ "$(grep -c '' <<<"$UO")" -le 2 ] && [ "$(grep -c 'f7000000' <<<"$UO")" = 1 ] ;; esac || unr_fail "$(basename "$U") with CDPATH set and a relative board path: want the card once"; done
rm -rf "$NL/f7000000-0000-4000-8000-000000000007" "$NB/zz-sibling"
# a newline in a name shifts realpath's lines: the dedupe falls back to one folder at a time and still lists the card once
ln -s "$(basename "$NL")" "$NB/zz-sibling"; sent_card "$NL" "$NLN" "$NLC"
for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$NB"; sent_check "$U" "$NB" "$NL" "$NLN" "$NLC"; done
rm -rf "$NL/$NLN" "$NB/zz-sibling"
# a real \001 byte in a name prints as \001 in all three lints, one finding per line
SOH=f8000000-0000-4000-8000-000000000008$'\001'y; sent_card "$NL" "$SOH" $'\001'z
for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$NB"; sent_check "$U" "$NB" "$NL" "$SOH" $'\001'z; done
rm -rf "$NL/$SOH"
# an ask id holding a backslash, answered by an agent record in-reply-to it: still QUOTED (ids match as written, only the print is escaped)
BA='f9100000-0000-4000-8000-000000000009\x'; sent_card "$NL" f9100000-0000-4000-8000-0000000000aa; rm -rf "$NL"/f9100000-0000-4000-8000-0000000000aa/comments/*
mkdir -p "$NL/f9100000-0000-4000-8000-0000000000aa/comments/$BA" "$NL/f9100000-0000-4000-8000-0000000000aa/comments/rep1"
printf -- '---\nschema: 1\nkind: comment\ncreated: {at: 2026-11-17T10:00:00Z, by: {name: claude, kind: agent, model: smoke}}\n---\n@anyone Which route?\n' > "$NL/f9100000-0000-4000-8000-0000000000aa/comments/$BA/index.md"
printf -- '---\nschema: 1\nkind: comment\nin-reply-to: %s\ncreated: {at: 2026-11-17T10:00:05Z, by: {name: claude, kind: agent, model: smoke}}\n---\n**Owner ruled.**\n\n> A.\n\n**Given**: chat, 2026-11-17\n' "$BA" > "$NL/f9100000-0000-4000-8000-0000000000aa/comments/rep1/index.md"
unr_run "$WL" "$NB"; [ "$UO" = "QUOTED f9100000-0000-4000-8000-0000000000aa f9100000-0000-4000-8000-000000000009\\\\x"$'\n'"QUOTED 1, NO-QUOTE 0" ] && [ "$UR" = 0 ] || unr_fail "lint-waiting-clears: an ask id with a backslash, quoted in reply, want QUOTED with the id printed escaped"
rm -rf "$NL/f9100000-0000-4000-8000-0000000000aa"
ok "a CDPATH and a relative board path list each card once; a newline-named card in a sibling-symlinked lane is listed once; a \\001 byte in a name prints escaped in all three lints; an ask id with a backslash still reads QUOTED"
if [ "$(id -u)" != 0 ]; then
  N4=f4000000-0000-4000-8000-000000000004; sent_card "$NL" "$N4"; N4I="$NL/$N4/comments/$SENT_START/index.md"
  chmod 000 "$N4I"; unr_run "$WL" "$NB"; chmod 644 "$N4I"
  [ "$UR" = 2 ] && [ "$UE" = "lint-waiting-clears.sh: could not read $N4I" ] || unr_fail "lint-waiting-clears with an unreadable comment: want exit 2 and only its own could-not-read line on stderr"
  ok "lint-waiting-clears with a comment index.md at mode 000 prints its could-not-read line and no awk error, exit 2"
  ln -s "$NB" "$T/BL.lanework"; chmod 000 "$N4I"
  for U in "$LS" "$LL" "$WL"; do unr_run "$U" "$T/BL.lanework"
    [ "$UR" = 2 ] && grep -q "^$(basename "$U"): could not read $T/BL.lanework/" <<<"$UE" || { chmod 644 "$N4I"; unr_fail "$(basename "$U") on a symlinked board with an unreadable card: want the path as given ($T/BL.lanework/...)"; }
  done
  chmod 644 "$N4I"; rm -rf "$NL/$N4"
  ok "all three lints name an unreadable path in the spelling given for a symlinked board, not the resolved folder"
fi
mkdir -p "$T/-dashnew.lanework"; cp -R "$USB"/. "$T/-dashnew.lanework"/
UO=$(cd "$T" && "$LS" -dashnew.lanework 2>&1) || true
[ -n "$UO" ] && ! grep -v '^-dashnew.lanework/' <<<"$UO" >/dev/null && UR=0 || unr_fail "lint-stamps on a - board: every finding must begin -dashnew.lanework/, not ./"
: > "$T/-f"; UO=$(cd "$T" && "$WL" -f 2>&1) && UR=0 || UR=$?
[ "$UR" = 2 ] && [ "$UO" = "lint-waiting-clears.sh: not a board folder: -f" ] || unr_fail "lint-waiting-clears -f (a file): want not a board folder: -f"
ok "lint-stamps prints a - board's paths as given, and lint-waiting-clears names a - file as given"
P1='PR=$UR; PN=$(grep -c . <<<"$UO" '; P2='|| true)'   # split, so this line does not match itself
grep -qF "$P1$P2" "$0" || unr_fail "the dash case's PN line must keep || true: a silent plain run must reach its message"
ok "a grep -c that counts nothing does not stop smoke before its message"

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

# arm-pass.sh: the arming pass classes each card from its files and the card leases (read through lease.sh list); Done is never swept,
# a held or lapsed lease is reported and never worked, a START comment is no claim
AB="$T/Arm Pipeline.lanework"; AN="${AB##*/}"
"$SK/lanework/scripts/found-board.sh" "$AB" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Arm --var verified=make --model smoke >/dev/null
alane() { dirname "$(lane_of "$AB" "$1")"; }
AP="$SK/watch/scripts/arm-pass.sh"; NOWS=$(date -u +%FT%TZ); OLD='2026-10-01T00:00:00Z'; AGENT='{name: claude, kind: agent, model: x}'
OLD2H=$(date -u -v-2H +%FT%TZ); OLD3H=$(date -u -v-3H +%FT%TZ); HUMAN='{name: "Rouslan Z", kind: "human"}'
# acard <lane> <uuid> <title> <order> [<until>]: a lease is hand-written into the front matter (no lease.sh stake: no timer)
acard() { local cl=""; [ -z "${5:-}" ] || cl=$(printf 'claimed:\n  by: {name: claude, kind: agent, model: x, session: "s-%s"}\n  until: %s\n' "$2" "$5")
  mkdir -p "$(alane "$1")/$2"; printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\norder: %s\ncreated:  {at: %s}\nmodified: {at: %s}\n%s---\nBody.\n' "$3" "$4" "$OLD" "$OLD" "${cl:+$cl
}" > "$(alane "$1")/$2/index.md"; }
# acom <lane> <card> <uuid> <at> <by or ""> <in-reply-to or ""> <body>
acom() { local d; d="$(alane "$1")/$2/comments/$3"; mkdir -p "$d"; printf -- '---\nschema: 1\nkind: comment\n%screated:  {at: %s%s}\nmodified: {at: %s%s}\n---\n%s\n' "${6:+in-reply-to: $6
}" "$4" "${5:+, by: $5}" "$4" "${5:+, by: $5}" "$7" > "$d/index.md"; }
UP20=$(date -u -v+20M +%FT%TZ); DN10=$(date -u -v-10M +%FT%TZ); UP50=$(date -u -v+50M +%FT%TZ)
A1=e1000000-0000-4000-8000-000000000001; acard Ideas $A1 "Ideas: owner question" 1024;   acom Ideas $A1 f1000000-0000-4000-8000-000000000001 "$OLD2H" "" "" "Why?"
A2=e1000000-0000-4000-8000-000000000002; acard Ideas $A2 "Ideas: answered" 2048;         acom Ideas $A2 f1000000-0000-4000-8000-000000000002 "$OLD3H" "$HUMAN" "" "Why?"; acom Ideas $A2 f1000000-0000-4000-8000-000000000003 "$OLD2H" "$AGENT" f1000000-0000-4000-8000-000000000002 "Because."
A3=e1000000-0000-4000-8000-000000000003; acard Proposed $A3 "Proposed: owner question" 1024; acom Proposed $A3 f1000000-0000-4000-8000-000000000004 "$OLD2H" "" "" "Why?"
# Done: an old question, a START never closed, and a live lease: none of it is swept
A4=e1000000-0000-4000-8000-000000000004; acard Done $A4 "Done: old question" 1024 "$UP20"; acom Done $A4 f1000000-0000-4000-8000-000000000005 "$OLD2H" "" "" "Why?"; acom Done $A4 f1000000-0000-4000-8000-000000000006 "$OLD3H" "$AGENT" "" "**START: never closed.**"
# a START with no lease is no claim: an old one and a fresh one are both arms
A5=e1000000-0000-4000-8000-000000000005; acard Shaping $A5 "Shaping: START only, old" 1024;   acom Shaping $A5 f1000000-0000-4000-8000-000000000007 "$OLD2H" "$AGENT" "" "**START: shaping.**"
A6=e1000000-0000-4000-8000-000000000006; acard Shaping $A6 "Shaping: START only, fresh" 2048; acom Shaping $A6 f1000000-0000-4000-8000-000000000008 "$NOWS" "$AGENT" "" "**START: shaping.**"
A7=e1000000-0000-4000-8000-000000000007; acard Shaping $A7 "Shaping: unclaimed" 3072
A8=e1000000-0000-4000-8000-000000000008; acard Shaping $A8 "Shaping: START only, owner waiting" 4096; acom Shaping $A8 f1000000-0000-4000-8000-000000000009 "$OLD3H" "$AGENT" "" "START: plain"; acom Shaping $A8 f1000000-0000-4000-8000-00000000000a "$OLD2H" "" "" "Status?"
# a lapsed lease (until 10 minutes ago), and an until 50 minutes ahead (over the 35-minute clock guard: no lease)
AL2=e1000000-0000-4000-8000-000000000021; acard Shaping $AL2 "Shaping: lapsed lease" 5120 "$DN10"
AL3=e1000000-0000-4000-8000-000000000022; acard Shaping $AL3 "Shaping: until too far ahead" 6144 "$UP50"; acom Shaping $AL3 f1000000-0000-4000-8000-000000000010 "$NOWS" "$AGENT" "" "**START: x.**"
# two cards with one title, one leased: the lease joins by uuid, never by title
AT1=e1000000-0000-4000-8000-000000000024; acard Shaping $AT1 "Shaping: twin title" 7168 "$UP20"
AT2=e1000000-0000-4000-8000-000000000025; acard Shaping $AT2 "Shaping: twin title" 8192
A9=e1000000-0000-4000-8000-000000000009; acard Approved $A9 "Approved: top" 1024;        acard Approved e1000000-0000-4000-8000-00000000000a "Approved: second" 2048
AB1=e1000000-0000-4000-8000-00000000000b; acard Active $AB1 "Active: closed START" 1024; acom Active $AB1 f1000000-0000-4000-8000-00000000000b "$OLD3H" "$AGENT" "" "**START: building.**"; acom Active $AB1 f1000000-0000-4000-8000-00000000000c "$OLD2H" "$AGENT" "" "**Merged: landed.**"
# a live lease (until 20 minutes ahead), alone and with an unanswered owner comment
AL1=e1000000-0000-4000-8000-000000000020; acard Active $AL1 "Active: held lease" 2048 "$UP20"
AL4=e1000000-0000-4000-8000-000000000023; acard Active $AL4 "Active: held lease, owner waiting" 3072 "$UP20"; acom Active $AL4 f1000000-0000-4000-8000-00000000000f "$OLD2H" "" "" "Status?"
# a by-stamped owner comment is an owner's whatever the quote (the app writes kind: "human"; YAML allows 'human'); a CRLF file is read
A10=e1000000-0000-4000-8000-000000000010; acard Issues $A10 "Issues: app-stamped owner" 1024; acom Issues $A10 f1000000-0000-4000-8000-000000000010 "$OLD2H" '{name: Bob, kind: "human"}' "" "Why?"
A11=e1000000-0000-4000-8000-000000000011; acard Issues $A11 "Issues: single-quoted owner" 2048; acom Issues $A11 f1000000-0000-4000-8000-000000000011 "$OLD2H" "{name: Bob, kind: 'human'}" "" "Why?"
A14=e1000000-0000-4000-8000-000000000014; acard Tasks $A14 "Tasks: CRLF owner" 1024; acom Tasks $A14 f1000000-0000-4000-8000-000000000014 "$OLD2H" "" "" "Why?"
sed -i '' 's/$/\r/' "$(alane Tasks)/$A14/comments/f1000000-0000-4000-8000-000000000014/index.md"
# an app move receipt (signed board, with a moved: key) is no reply: it does not clear an owner comment
AR='{name: board, kind: agent}'
acom Shaping $A5 f1000000-0000-4000-8000-00000000000d "$NOWS" "$AR" "" "moved"
acom Ideas $A1 f1000000-0000-4000-8000-00000000000e "$NOWS" "$AR" f1000000-0000-4000-8000-000000000001 "moved"
find "$AB" -type f -exec shasum {} + | sort -k2 | shasum > "$T/arm.before"
AO=$("$AP" "$AB"); AOX=$(sed -E 's/\t(1[0-9]|20|9)m$/\tXm/' <<<"$AO")
find "$AB" -type f -exec shasum {} + | sort -k2 | shasum > "$T/arm.after"
al() { printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$AN" "$2" "$3" "$4" "$5" "$6"; }   # kind uuid lane title author paths
cm() { printf 'comment\t%s\t%s\t%s\t%s\towner\t%s/%s/comments/%s/index.md\n' "$AN" "$2" "$1" "$3" "$(basename "$(alane "$1")")" "$2" "$4"; }
exp=$(cm Ideas $A1 "Ideas: owner question" f1000000-0000-4000-8000-000000000001
  cm Issues $A10 "Issues: app-stamped owner" f1000000-0000-4000-8000-000000000010
  cm Issues $A11 "Issues: single-quoted owner" f1000000-0000-4000-8000-000000000011
  cm Tasks $A14 "Tasks: CRLF owner" f1000000-0000-4000-8000-000000000014
  al arm $A5 Shaping "Shaping: START only, old" - -
  al arm $A6 Shaping "Shaping: START only, fresh" - -
  al arm $A7 Shaping "Shaping: unclaimed" - -
  cm Shaping $A8 "Shaping: START only, owner waiting" f1000000-0000-4000-8000-00000000000a
  al stale $AL2 Shaping "Shaping: lapsed lease" - Xm
  al arm $AL3 Shaping "Shaping: until too far ahead" - -
  al held $AT1 Shaping "Shaping: twin title" - Xm
  al arm $AT2 Shaping "Shaping: twin title" - -
  cm Proposed $A3 "Proposed: owner question" f1000000-0000-4000-8000-000000000004
  al arm $A9 Approved "Approved: top" - -
  al arm $AB1 Active "Active: closed START" - -
  al held $AL1 Active "Active: held lease" - Xm
  cm Active $AL4 "Active: held lease, owner waiting" f1000000-0000-4000-8000-00000000000f
  al held $AL4 Active "Active: held lease, owner waiting" - Xm)
[ "$AOX" = "$exp" ] || { echo "arm-pass.sh lines:"; echo "want:"; echo "$exp"; echo "got:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: every line of the arming pass on the fixture board, in reading order (comment lines, arm lines for agent-lane cards without a lease, Approved its top card only, held and stale lines for leases, Done nothing)"
# 1: a valid lease in an agent lane: one held line with the minutes left, no arm
[ "$(grep -c "	$AL1	" <<<"$AO")" = 1 ] && grep -qE "^held	$AN	$AL1	Active	Active: held lease	-	(19|20)m$" <<<"$AO" || { echo "no single held line with 19m or 20m for the leased Active card:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: a card with a valid lease in an agent lane is no arm and prints one held line with the minutes left"
# 2: a lapsed lease: a stale line with the minutes since until, no arm
[ "$(grep -c "	$AL2	" <<<"$AO")" = 1 ] && grep -qE "^stale	$AN	$AL2	Shaping	Shaping: lapsed lease	-	(10|11)m$" <<<"$AO" || { echo "no single stale line with 10m or 11m for the lapsed card:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: a lapsed lease prints a stale line with the minutes since until, and no arm"
# 3: a START comment is not a claim (old or fresh), and a START in a closed shape neither
for u in $A5 $A6 $AB1; do grep -qE "^arm	$AN	$u	" <<<"$AO" && ! grep -qE "^(held|stale)	$AN	$u	" <<<"$AO" || { echo "a card with only a START comment is not an arm: $u"; echo "$AO"; exit 1; }; done
ok "arm-pass.sh: a START comment with no lease is an arm"
# 4: the clock guard (until over 35 minutes ahead) is no lease, so an arm
grep -qE "^arm	$AN	$AL3	" <<<"$AO" && ! grep -qE "^(held|stale)	$AN	$AL3	" <<<"$AO" || { echo "an until 50 minutes ahead was read as a lease:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: an until more than 35 minutes ahead is no lease, so the card is an arm"
# 5: Done is never swept, a lease or not
[ "$(grep -c "$A4" <<<"$AO")" = 0 ] || { echo "a Done card was swept:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: a leased card in Done prints nothing"
# 6: an unanswered owner comment on a held card: comment, then held, no arm
[ "$(grep -n "	$AL4	" <<<"$AO" | cut -d: -f2 | cut -f1 | paste -sd, -)" = "comment,held" ] || { echo "the held card with an owner comment must print comment then held:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: an unanswered owner comment on a held card prints comment, then held"
# 7: the pass writes nothing
cmp -s "$T/arm.before" "$T/arm.after" || { echo "arm-pass.sh changed a file on the board"; exit 1; }
ok "arm-pass.sh: leaves every card file byte-identical"
[ "$("$AP" "$AB" Ideas | grep '^arm' | cut -f3-4)" = "$(printf '%s\tIdeas' $A2)" ] || { echo "arm-pass.sh: the agent lane titles on the command line are ignored"; exit 1; }
! "$AP" "$T" 2>/dev/null || { echo "arm-pass.sh accepted a non-board"; exit 1; }
ok "arm-pass.sh: lane titles on the command line replace the board-kinds.md agent rows; a non-board exits non-zero"
# two cards sharing a title, one leased: the leased one is held, the other an arm
{ grep -qE "^held	$AN	$AT1	" <<<"$AO" && grep -qE "^arm	$AN	$AT2	" <<<"$AO" && ! grep -qE "^(held|stale)	$AN	$AT2	" <<<"$AO" && ! grep -qE "^arm	$AN	$AT1	" <<<"$AO"; } || { echo "two cards with one title, one leased: the lease must join by uuid:"; echo "$AO"; exit 1; }
ok "arm-pass.sh: of two cards sharing a title, the leased one prints held and the other arm (the lease joins by uuid)"
# lease.sh missing: no lease is known, so no arm, held or stale line; the comment lines still print, exit 1, a note on stderr
SNL="$T/skills-nolease"; cp -R "$SK" "$SNL"; rm "$SNL/lanework/scripts/lease.sh"; rc=0; out=$("$SNL/watch/scripts/arm-pass.sh" "$AB" 2>"$T/arm.err") || rc=$?
{ [ "$rc" = 1 ] && grep -q '^comment	' <<<"$out" && ! grep -qE '^(arm|held|stale)	' <<<"$out" && grep -q 'lease.sh list failed or is missing' "$T/arm.err"; } || { echo "arm-pass.sh without lease.sh (rc=$rc):"; echo "$out"; cat "$T/arm.err"; exit 1; }
ok "arm-pass.sh: with lease.sh missing it prints comment lines only, says so on stderr and exits 1"
# lease.sh list failing: its own stderr reaches ours, beside the arm-pass note
printf '#!/bin/bash\necho "boom: no lease today" >&2\nexit 1\n' > "$SNL/lanework/scripts/lease.sh"; rc=0; out=$("$SNL/watch/scripts/arm-pass.sh" "$AB" 2>"$T/arm.err") || rc=$?
{ [ "$rc" = 1 ] && ! grep -qE '^(arm|held|stale)	' <<<"$out" && grep -q 'boom: no lease today' "$T/arm.err" && grep -q 'lease.sh list failed or is missing' "$T/arm.err"; } || { echo "arm-pass.sh with a failing lease.sh list (rc=$rc):"; cat "$T/arm.err"; exit 1; }
ok "arm-pass.sh: a failing lease.sh list has its own stderr passed through, beside the arm-pass note, and exit 1"
validate "$AB" >/dev/null; ok "the arm-pass fixture board validates"

# merge: one scratch repo, two clones, every rule row; driver + pass as a merge and as a rebase, and the pass alone
for m in merge rebase nodriver; do "$ROOT/tests/merge-case.sh" "$T" "$m" >/dev/null; ok "merge case: every row resolves with no prompt, as a $m"; done
"$ROOT/tests/merge-case.sh" "$T" clean >/dev/null; ok "merge case: git finishes a lossless merge alone, stops on a loss, and a comment left by a move is re-homed"
"$ROOT/tests/merge-case.sh" "$T" rebasemove >/dev/null; ok "merge case: a rebase with a later move leaves no orphaned folder"
"$ROOT/tests/merge-case.sh" "$T" dirty >/dev/null; ok "merge case: uncommitted edits in a conflicted card are carried as ours, never erased"
"$ROOT/tests/merge-case.sh" "$T" appside >/dev/null; ok "merge case: bytes the app wrote (tests/fixtures/app-writes) collide with scripted edits and resolve with no prompt"

# merge, heal and watch headers card: usage errors exit 2 (64 for the heal scripts), no traceback, no silent exit 0
MP="$SK/merge/scripts/lanework-merge.py"; MBS="$SK/merge/scripts/merge-board.sh"; mkdir -p "$T/mhw"; git init -q "$T/mhw/repo"
for a in "resolve $T/mhw/repo --model" "driver a b" "driver --quiet a b c" "resolve $T/mhw/nope" "install $T/mhw/nope"; do
  rc=0; python3 "$MP" $a >"$T/mhw/out" 2>"$T/mhw/err" </dev/null || rc=$?
  { [ "$rc" = 2 ] && ! grep -q Traceback "$T/mhw/err"; } || { echo "lanework-merge.py $a: rc=$rc"; cat "$T/mhw/err"; exit 1; }
done
uo=$(python3 "$MP" driver a b 2>&1 || true)
{ grep -q 'not a git repo: ' "$T/mhw/err" && grep -q '^usage:' <<<"$uo"; } || { echo "lanework-merge.py usage or not-a-repo message missing"; exit 1; }
ok "lanework-merge.py: driver with fewer than 4 paths, resolve with --model last, and resolve or install on a non-repo exit 2 with no traceback"
rc=0; "$MBS" >/dev/null 2>"$T/mhw/err" || rc=$?; [ "$rc" = 2 ] || { echo "merge-board.sh with no argument: rc=$rc"; exit 1; }
rc=0; "$MBS" --bogus >/dev/null 2>"$T/mhw/err" || rc=$?; [ "$rc" = 2 ] || { echo "merge-board.sh leading unknown argument: rc=$rc"; exit 1; }
rc=0; "$MBS" "$T/mhw/repo" --bogus >/dev/null 2>"$T/mhw/err" || rc=$?; [ "$rc" = 2 ] || { echo "merge-board.sh unknown argument: rc=$rc"; exit 1; }
rc=0; "$MBS" "$T/mhw/repo" --model >/dev/null 2>"$T/mhw/err" || rc=$?; [ "$rc" = 2 ] || { echo "merge-board.sh --model with no value: rc=$rc"; exit 1; }
rc=0; "$MBS" "$T/mhw/nope" >/dev/null 2>"$T/mhw/err" || rc=$?; { [ "$rc" = 1 ] && grep -q 'not a git repo' "$T/mhw/err"; } || { echo "merge-board.sh not a repo: rc=$rc"; exit 1; }
ok "merge-board.sh: no argument, an unknown argument and --model with no value exit 2; a path that is not a repo stays exit 1"
mkdir -p "$T/mhw/wb"; : > "$T/mhw/wb/index.md"; rc=0
env PATH=/usr/bin:/bin perl -e 'alarm 10; exec @ARGV' /bin/zsh "$SK/watch/scripts/watch-boards.sh" "$T/mhw/snap" "$T/mhw/wb" >"$T/mhw/out" 2>"$T/mhw/err" </dev/null || rc=$?
{ [ "$rc" = 2 ] && grep -q 'needs fswatch' "$T/mhw/err"; } || { echo "watch-boards.sh without fswatch on PATH: rc=$rc"; cat "$T/mhw/err"; exit 1; }
[ ! -e "$T/mhw/snap" ] || { echo "watch-boards.sh took a snapshot before checking for fswatch"; exit 1; }
ok "watch-boards.sh: with no fswatch on PATH it prints 'needs fswatch' and exits 2 before the first snapshot"

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
[ "$(grep -rl --exclude-dir=__pycache__ 'claiming it with a comment' "$SK" | sed "s#^$SK/##")" = "heal/scripts/heal-descriptors.py" ] || { echo "'claiming it with a comment' must appear under skills/ only in heal/scripts/heal-descriptors.py:"; grep -rl --exclude-dir=__pycache__ 'claiming it with a comment' "$SK"; exit 1; }
AB=$(lane_body "$P" Active); { ! grep -q 'claiming it with a comment' <<<"$AB" && grep -qF 'holds it with a lease while it works' <<<"$AB"; } || { echo "a founded pipeline board's Active body: $AB"; exit 1; }
ok "'claiming it with a comment' lives under skills/ only in the heal's old-body table, and a board founded from the template has an Active body that holds the card with a lease"

{ ! grep -q 'a move' <(grep -E '^6\. ' "$SK/watch/references/events.md") && ! grep -qiE 'requested' <(grep '^description:' "$SK/watch/SKILL.md") &&
  grep -q 'Arming pass' "$SK/watch/references/arming.md" && grep -q '^## A move' "$SK/watch/references/responding.md" &&
  grep -q 'no lease (none' "$SK/watch/references/arming.md" && grep -q 'companions.md' "$SK/watch/references/responding.md" && ! grep -q 'Ideas, Proposed' "$SK/watch/references/responding.md"; } || { echo "watch still calls a move context only, says requested, lacks the arming pass or the move case"; exit 1; }
ok "watch: no rule calls a move context only; arming acts on waiting cards; responding covers the move"

EV="$SK/watch/references/events.md"
{ grep -q 'moved:' <(sed -n '/^4\. /,/^5\. /p' "$EV") && grep -q 'moved\.by' <(sed -n '/^5\. /,/^6\. /p' "$EV") && grep -q 'to\.lane' <(sed -n '/^5\. /,/^6\. /p' "$EV") && ! grep -q 'bare move with no comment' "$EV"; } || { echo "events.md item 4 lacks moved: as a receipt, item 5 lacks moved.by or to.lane (which receipt counts), or it still says bare move with no comment"; exit 1; }
ok "watch events: a move receipt is a record and moved.by names the mover"
# 8: watch prose: the lease is the claim; its rules are linked, never restated; a subagent never stakes
WR="$SK/watch/references/responding.md"; WS="$SK/watch/SKILL.md"
{ grep -q '`held`' "$SK/watch/references/arming.md" && grep -q 'no lease (none' "$SK/watch/references/arming.md" \
  && ! { grep -rhw 'START' "$SK/watch" | grep -qv 'no claim\|not a claim'; } && ! grep -rq 'STALE_MINUTES' "$SK/watch" \
  && grep -q 'writes.md` § Lease' "$SK/watch/references/arming.md" && grep -q 'writes.md` § Lease' "$WR" \
  && grep -q 'lease.sh stake' "$WR" && grep -q 'held by another session' "$WR" && grep -q 'lease.sh release' "$WR" && grep -q 'never to stake' "$WR" && grep -q 'farmed-prompt.md' "$WR" \
  && grep -q 'stake, then act' "$EV" && grep -q 'lease write' <(sed -n '/^6\. /,/^7\. /p' "$EV") \
  && grep -q 'held cards, lapsed leases' "$WS" && ! grep -rqE '35 min|30 min' "$SK/watch/references"; } || { echo "watch prose: a START still reads as a claim, the lease rules are restated or not linked, the work order does not stake first, release at a gate or say a subagent never stakes, or events item 6 / SKILL.md lack the lease"; exit 1; }
ok "watch prose: arming defines no claim by a START and names held; responding stakes before a work order, releases at a gate or when done, and never lets a subagent stake; events item 6 names a lease write as context"

HD="$SK/heal/scripts/heal-descriptors.py"
X="$T/Heal Me.lanework"
"$SK/lanework/scripts/found-board.sh" "$X" --index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Heal --var verified='`make`' --model smoke >/dev/null
cp -R "$X" "$T/Heal Sheet.lanework"
setbody() { local f; f=$(lane_file "$X" "$1"); sed -i '' '$d' "$f"; [ -z "$2" ] || printf '%s\n' "$2" >> "$f"; }
setbody Approved 'The ready-to-build queue, ranked in build order, top is next. The spec is frozen, so a scope change bounces the card back to Shaping.'
setbody Tasks "Owner chores, built through Active. Nothing here needs shaping. Agents never file here."
setbody Shaping ''
setbody Active 'Work in progress. An agent moves a card in as it starts, claiming it with a comment naming the session and branch, and moves it to Done when its done-when is met.'
validate "$X" >/dev/null
Z0=$(sum "$X"); O=$("$HD" "$X")
{ grep -q '^lane Approved: replace-body ' <<<"$O" && grep -q '^lane Tasks: insert-actor ' <<<"$O" && grep -q '^lane Shaping: fill-body ' <<<"$O" && grep -q '^lane Active: replace-body ' <<<"$O" && grep -q '^4 changes in 4 files' <<<"$O"; } || { echo "$O"; exit 1; }
[ "$Z0" = "$(sum "$X")" ]; ok "heal-descriptors dry run lists the old-template, customised and empty lane bodies and writes nothing"
if "$HD" "$X" --apply >/dev/null 2>&1; then echo "--apply ran without --model"; exit 1; else [ $? -eq 2 ]; fi; [ "$Z0" = "$(sum "$X")" ]
ok "heal-descriptors --apply without --model exits 2 and writes nothing"
IDLE=$(lane_file "$X" Ideas); IDLE_SUM=$(shasum "$IDLE")
"$HD" "$X" --apply --name fixer --model test >/dev/null; validate "$X" >/dev/null
TPL() { awk -F'|' -v t="$1" '/^\| *[0-9]/ { gsub(/^ +| +$/, "", $3); gsub(/^ +| +$/, "", $6); if ($3 == t) print $6 }' "$SK/lanework/templates/pipeline-lanes.md"; }
[ "$(lane_body "$X" Approved)" = "$(TPL Approved)" ] && [ "$(lane_body "$X" Shaping)" = "$(TPL Shaping)" ] && [ "$(lane_body "$X" Active)" = "$(TPL Active)" ] || { echo "replace or fill did not give the current template body"; exit 1; }
TB=$(lane_body "$X" Tasks); AS=$(TPL Tasks | sed -E 's/^[^.]*\. //; s/\. .*$/./')
[ "$TB" = "Owner chores, built through Active. $AS Nothing here needs shaping. Agents never file here." ] || { echo "customised body not extended in place: $TB"; exit 1; }
for l in Approved Tasks Shaping Active; do grep -qE '^modified: \{at: [0-9TZ:-]+, by: \{name: fixer, kind: agent, model: test\}\}$' "$(lane_file "$X" "$l")" || { echo "$l not restamped whole"; exit 1; }; done
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
# names_guide_version <dir>: every file under <dir>, of any type, that names a guide version: the stamp, or a floor ("guide ... v105+", a bare v plus 2+ digits; $v10 is a shell variable)
names_guide_version() { grep -r -l -i -E 'lanework-(agent-guide|schema) +v[0-9]+|guide[^.]*[^[:alnum:]_$-]v[0-9]+|(^|[^[:alnum:]_$-])v[0-9]{2,}([^[:alnum:].]|$)' "$1" 2>/dev/null | sort -u || true; }
H=$(names_guide_version "$SK")
[ -z "$H" ] || { echo "a skill names a guide version (the stamp lives only in CLAUDE.md): $H"; exit 1; }
S=$({ grep -o -E 'lanework-agent-guide v[0-9]+' "$ROOT/CLAUDE.md" || true; })
[ "$(printf '%s\n' "$S" | grep -c .)" -eq 1 ] || { echo "CLAUDE.md must carry exactly one guide stamp, found: ${S:-none}"; exit 1; }
SV=$({ grep -o -E 'lanework-schema v[0-9]+' "$ROOT/CLAUDE.md" || true; })
[ "$(printf '%s\n' "$SV" | grep -c .)" -eq 1 ] || { echo "CLAUDE.md must carry exactly one schema stamp, found: ${SV:-none}"; exit 1; }
ok "no skill names a guide version; one stamp ($S, $SV), in CLAUDE.md"
# controls: the check flags what it names, in every file type, and only that
mkdir -p "$T/gv-pos" "$T/gv-neg" "$T/gv-lib"
printf 'Needs guide v105+ on the board.\n' > "$T/gv-pos/a.md"
printf '# on a guide v117+ board, ask anyone\n' > "$T/gv-pos/b.sh"
printf '# needs guide v105 or later\n' > "$T/gv-pos/c.py"
printf '{"note": "lanework-agent-guide v114"}\n' > "$T/gv-pos/d.json"
printf '# floor: v117 or later\n' > "$T/gv-pos/e.sh"
got=$(names_guide_version "$T/gv-pos" | sed "s#^$T/gv-pos/##" | tr '\n' ' ')
[ "$got" = "a.md b.sh c.py d.json e.sh " ] || { echo "guide-version positive control: flagged '$got', want 'a.md b.sh c.py d.json e.sh '"; exit 1; }
ok "the guide-version check flags a stamp or a version floor in .md, .sh, .py and .json files"
printf 'schema v1, v0.8.0, v10.2.1, v2→v5\n' > "$T/gv-neg/a.md"
printf 'echo $v10 and x=$v12\n' > "$T/gv-neg/b.sh"
printf '  if [ -n "$v" ] && [ "$v" -ge 117 ]; then printf anyone; else owner_handle "$1"; fi\n' > "$T/gv-neg/c.sh"
printf "grep -o -E 'lanework-agent-guide v[0-9]+'\n" > "$T/gv-neg/d.sh"
got=$(names_guide_version "$T/gv-neg")
[ -z "$got" ] || { echo "guide-version negative control: flagged: $got"; exit 1; }
ok "the guide-version check does not flag schema v1, semvers, a one-digit range, a shell variable, or a numeric comparison such as -ge 117"
sed -E 's/^[[:space:]]*#.*$//' "$SK/lanework/scripts/lib.sh" > "$T/gv-lib/lib.sh"
[ -s "$T/gv-lib/lib.sh" ] || { echo "guide-version lib.sh control: empty copy"; exit 1; }
got=$(names_guide_version "$T/gv-lib")
[ -z "$got" ] || { echo "guide-version lib.sh control: flagged: $got"; exit 1; }
ok "the guide-version check does not flag the code of lib.sh, comments aside"

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
DQ=$(bfirst "$SK/discovery/scripts/file-question.sh" "$DD" "Free" --round 1 --body "$T/dq.md" --model smoke)
DR=$(bfirst "$SK/discovery/scripts/file-record.sh" "$DD" "$DQ" --record ADR --title "Free sync" --body "$T/dadr.md" --model smoke)
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
DT1=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Rates" --type research --body "$T/t.md" --model smoke)
DT2=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "After rates" --type task --body "$T/t.md" --depends "lanework://$(sed -n 's/^id: //p' "$DP/index.md")/$DT1" --model smoke)
[ "$(labels_of "$DP" "$DT1")" = "labels: [{text: Research, rank: 2, icon: {glyph: magnifyingglass}, kind: {type: ticket, text: Ticket}}, {text: Urgent, rank: 0, color: \"#C8283C\", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}, {text: extra, $TXT}]" ] \
  || { echo "file-ticket: lane defaults not unioned:"; labels_of "$DP" "$DT1"; exit 1; }
[ "$(labels_of "$DP" "$DT2")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}]" ] || { echo "file-ticket: Blocked got defaults:"; labels_of "$DP" "$DT2"; exit 1; }
nothing_to_heal "$DP" || { echo "file-ticket: board not clean"; exit 1; }
ok "file-ticket.sh: Frontier's 'urgent' is stamped from the board's priority kind (rank, colour, glyph), 'extra' is a free label, the single-kind ticket default yields to the card's own; Blocked adds nothing"

# 4. a single kind with several lane values: the lowest rank is kept, and the card's own value beats them all
setdef "$DP" Frontier '{labels: [{text: High, kind: {type: priority}}, {text: Urgent, kind: {type: priority}}, {text: Task, kind: {type: ticket}}, {text: Grilling, kind: {type: ticket}}]}'
DT3=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Hammer" --type prototype --body "$T/t.md" --model smoke)
[ "$(labels_of "$DP" "$DT3")" = "labels: [{text: Prototype, rank: 3, icon: {glyph: hammer}, kind: {type: ticket, text: Ticket}}, {text: Urgent, rank: 0, color: \"#C8283C\", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]" ] \
  || { echo "single kind: wrong pick:"; labels_of "$DP" "$DT3"; exit 1; }
setdef "$DD" Decisions '{labels: [{text: superseded, kind: {type: status}}, {text: deprecated, kind: {type: status}}]}'
DR2=$(bfirst "$SK/discovery/scripts/file-record.sh" "$DD" "$DQ2" --record PDR --title "Also free" --body "$T/dadr.md" --model smoke)
[ "$(labels_of "$DD" "$DR2")" = "labels: [{text: PDR, rank: 2, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}]" ] || { echo "single kind: own value did not win:"; labels_of "$DD" "$DR2"; exit 1; }
nothing_to_heal "$DP" && nothing_to_heal "$DD" || { echo "single kind: board not clean"; exit 1; }
ok "single kind: of High and Urgent the lower rank (Urgent) is kept; the card's own accepted beats superseded and deprecated; heal finds nothing"

# 5. no defaults (or none with labels) change nothing; a malformed card-defaults refuses and writes nothing
for v in - '{note: 1}' '{labels: []}'; do
  setdef "$DP" Frontier "$v"; DT4=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Plain" --type grilling --body "$T/t.md" --model smoke)
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
setdef "$DP" Frontier '{labels: solo}'; DT5=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Solo" --type task --body "$T/t.md" --model smoke)
[ "$(labels_of "$DP" "$DT5")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: solo, $TXT}]" ] || { echo "a bare-name labels: is one free label:"; labels_of "$DP" "$DT5"; exit 1; }
ok "no card-defaults, none with labels, or an empty list; labels: <name> is one free label: the card is the template's own; a card-defaults that is a scalar or a list, or labels that is a mapping, exits non-zero naming card-defaults, in all three scripts, and writes nothing"

# 6. a bare number or boolean is the text as typed (1.10 stays 1.10), in the list and as the one-name scalar
setdef "$DP" Frontier '={labels: [v1, 2026, 1.10, true, "2027"]}'
DT6=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Typed" --type task --body "$T/t.md" --model smoke)
[ "$(labels_of "$DP" "$DT6")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: v1, $TXT}, {text: 2026, $TXT}, {text: 1.10, $TXT}, {text: true, $TXT}, {text: 2027, $TXT}]" ] \
  || { echo "typed scalars in card-defaults.labels not read as typed:"; labels_of "$DP" "$DT6"; exit 1; }
nothing_to_heal "$DP" || { echo "typed scalars: board not clean"; exit 1; }
for v in 2026 1.10 true; do
  setdef "$DP" Frontier "={labels: $v}"
  DT7=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "One $v" --type task --body "$T/t.md" --model smoke)
  [ "$(labels_of "$DP" "$DT7")" = "labels: [{text: Task, rank: 4, icon: {glyph: checklist}, kind: {type: ticket, text: Ticket}}, {text: $v, $TXT}]" ] || { echo "labels: $v is not one free label:"; labels_of "$DP" "$DT7"; exit 1; }
done
nothing_to_heal "$DP" || { echo "scalar labels: board not clean"; exit 1; }
ok "card-defaults.labels: a bare 2026, 1.10 or true is the label as typed, in a list and as the lone name; each validates and heal finds nothing"

# 7. the union is case-insensitive: a repeat within the lane's list, and a default equal to the card's own free label
setdef "$DP" Frontier '={labels: [extra, EXTRA, Extra]}'
DT8=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Cased" --type task --body "$T/t.md" --model smoke)
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
DT9=$(bfirst "$SK/plan/scripts/file-ticket.sh" "$DP" "Ranked" --type task --body "$T/t.md" --model smoke)
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

# label-card: a hand-written label would land as a block list the heal flags (H17); the script writes the compact form
LC="$SK/work/scripts/label-card.sh"
# fmlines <file> <key>: how many physical frontmatter lines the key takes (1 = compact one-liner)
fmlines() { awk -v k="$2" 'NR > 1 && /^---$/ {exit} $0 ~ ("^" k ":") {f=1; n=1; next} f && /^[^ \t]/ {f=0} f {n++} END {print n+0}' "$1"; }
L1=$("$FC" "$DP" Frontier "Unlabelled" --body "$T/fc.md" --model smoke); L1ID=$(basename "$L1")
S10=$(others "$DP" "$(basename "$(dirname "$L1")")/$L1ID"); t0=$(date -u +%FT%TZ)
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1" "Needs review" --model smoke --name fixer --session smoke >/dev/null || rc=$?
t1=$(date -u +%FT%TZ)
[ "$rc" -eq 0 ] && [ "$(labels_of "$DP" "$L1ID")" = "labels: [{text: Needs review, $TXT}]" ] && [ "$(fmlines "$L1/index.md" labels)" = 1 ] \
  && grep -qxF "modified: {at: $(atof "$L1/index.md" modified), by: $BYF}" "$L1/index.md" && [[ ! "$(atof "$L1/index.md" modified)" < "$t0" && ! "$(atof "$L1/index.md" modified)" > "$t1" ]] \
  && [ "$S10" = "$(others "$DP" "$(basename "$(dirname "$L1")")/$L1ID")" ] && nothing_to_heal "$DP" || { echo "label-card: rc $rc:"; cat "$L1/index.md"; exit 1; }
ok "label-card.sh: a card with no labels gets one stamped label on one compact line, modified from the clock with the caller's by, no other file changed, validates, heal finds nothing"
RAW1=$(sed -n 's/^labels: \[\(.*\)\]$/\1/p' "$L1/index.md"); [ -n "$RAW1" ] || { echo "fixture: the first label is not one compact line"; exit 1; }
env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1/index.md" "second" --model smoke >/dev/null
# two entries pass 120 characters: the block form, key line then one line per entry, the first entry byte for byte
[ "$(fmlines "$L1/index.md" labels)" = 3 ] && [ "$(grep -A1 '^labels:$' "$L1/index.md" | tail -1)" = "  - $RAW1" ] && nothing_to_heal "$DP" \
  || { echo "label-card, existing label: $(fmlines "$L1/index.md" labels) lines:"; sed -n 1,12p "$L1/index.md"; exit 1; }
env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1/index.md" "Urgent:priority" --model smoke >/dev/null
[ "$(labels_of "$DP" "$L1ID")" = "labels: [{text: Needs review, $TXT}, {text: second, $TXT}, {text: Urgent, rank: 0, color: \"#C8283C\", icon: {glyph: exclamationmark.2}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]" ] \
  && nothing_to_heal "$DP" || { echo "label-card, kinded label:"; sed -n 1,16p "$L1/index.md"; exit 1; }
ok "label-card.sh: a second label makes the block form (past 120 characters, measured: key line and one line per entry) with the first entry byte for byte; a kinded label is stamped from the board; heal finds nothing"
S11=$(sum "$DP")
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1" "High:priority" --model smoke >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 1 ] && [ "$S11" = "$(sum "$DP")" ] || { echo "label-card, a different value of a single kind: want exit 1, nothing written, got $rc"; exit 1; }
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1" "urgent:Priority" "NEEDS REVIEW" --model smoke >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 0 ] && [ "$S11" = "$(sum "$DP")" ] || { echo "label-card, labels the card has: want exit 0, nothing written, got $rc"; exit 1; }
ok "label-card.sh: a different value of a single kind the card holds exits 1; the same labels, case aside, are a no-op (exit 0); nothing written either way"
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1" "x:nokind" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "label-card, undefined kind: want exit 1, got $rc"; exit 1; }
L2=$("$FC" "$DP" Frontier "No priority yet" --body "$T/fc.md" --model smoke); S12=$(sum "$DP"); S11=$S12   # no priority on it: only the closed-kind rule can refuse
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L2" "Nope:priority" --model smoke >/dev/null 2>"$T/err.txt" || rc=$?
[ "$rc" -eq 1 ] && grep -q "not a value of the closed kind priority" "$T/err.txt" && [ "$S12" = "$(sum "$DP")" ] || { echo "label-card, unlisted priority value on a card with none: want exit 1, got $rc:"; cat "$T/err.txt"; exit 1; }
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$(dirname "$L1")" "x" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 1 ] || { echo "label-card, a lane: want exit 1, got $rc"; exit 1; }
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L1" --model smoke >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "label-card, no label: want exit 2, got $rc"; exit 1; }
refused label-card "$LC" "$DP" "$L1" x
[ "$S11" = "$(sum "$DP")" ] || { echo "a refused label-card wrote something"; exit 1; }
cp "$L2/index.md" "$T/lf.md"; sed 's/$/\r/' "$T/lf.md" > "$L2/index.md"; S12=$(sum "$DP")
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L2" "x" --model smoke >/dev/null 2>"$T/err.txt" || rc=$?
[ "$rc" -eq 1 ] && grep -q "CRLF line endings" "$T/err.txt" && [ "$S12" = "$(sum "$DP")" ] || { echo "label-card, a CRLF card: want exit 1 naming CRLF, got $rc:"; cat "$T/err.txt"; exit 1; }
cp "$T/lf.md" "$L2/index.md"
ok "label-card.sh: an undefined kind, a value a closed kind does not list and a path that is not a card exit 1, no label and no model exit 2; nothing written"
# an index.md at card depth under attachments/ or a dot folder is no card (board_index_files prunes the same): refused, while a real card on the same board is labelled
GB="$T/Guard.lanework"; rm -rf "$GB"; cp -R "$DP" "$GB"; GL=$(dirname "$(dirname "$GB/${L2#"$DP"/}")"); GREAL="$GB/${L2#"$DP"/}"
mkdir -p "$GB/attachments/x" "$GL/attachments" "$GB/.hidden/x"; for g in "$GB/attachments/x" "$GL/attachments" "$GB/.hidden/x"; do printf -- '---\ntitle: "x"\n---\nb\n' > "$g/index.md"; done
S15=$(sum "$GB")
for g in "$GB/attachments/x/index.md" "$GL/attachments/index.md" "$GB/.hidden/x/index.md"; do
  rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$GB" "$g" "x" --model smoke >/dev/null 2>"$T/err.txt" || rc=$?
  [ "$rc" -eq 1 ] && [ "$S15" = "$(sum "$GB")" ] || { echo "label-card on $g: want exit 1, nothing written, got $rc:"; cat "$T/err.txt"; exit 1; }
done
rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$GB" "$GREAL" "real" --model smoke >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 0 ] && grep -q '^labels: \[{text: "real"' "$GREAL/index.md" && [ "$S15" != "$(sum "$GB")" ] || { echo "label-card on a real card of the same board: rc $rc"; exit 1; }
ok "label-card.sh refuses an index.md under attachments/ at the board or lane level and under a dot folder (exit 1, nothing written), while a real card on the same board is labelled"
setdef "$DP" Frontier '{labels: [extra]}'
F4=$("$FC" "$DP" Frontier "Both" --body "$T/fc.md" --model smoke --label "High:priority" --label "hand: written:text"); F4ID=$(basename "$F4")
[ "$(labels_of "$DP" "$F4ID")" = "labels: [{text: High, rank: 1, color: \"#E07A1F\", icon: {glyph: exclamationmark}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}, {text: hand: written, $TXT}, {text: extra, $TXT}]" ] \
  && nothing_to_heal "$DP" || { echo "file-card --label:"; labels_of "$DP" "$F4ID"; exit 1; }
rc=0; "$FC" "$DP" Frontier "Clash" --body "$T/fc.md" --model smoke --label "High:priority" --label "Low:priority" >/dev/null 2>&1 || rc=$?
[ "$rc" -eq 1 ] || { echo "file-card, two values of a single kind: want exit 1, got $rc"; exit 1; }
setdef "$DP" Frontier -
ok "file-card.sh --label: the labels, then the lane's default, on one compact line; heal finds nothing; two values of one single kind exit 1"

# compact_fm earns its place: a block `icon:` that fits one line is rewritten by the same write, so the card leaves no H17 behind
L3=$("$FC" "$DP" Frontier "Block icon" --body "$T/fc.md" --model smoke); perl -pi -e 's/^(order: .*)$/$1\nicon:\n  glyph: hammer.fill\n  color: fern/' "$L3/index.md"
[ "$(fmlines "$L3/index.md" icon)" = 3 ] || { echo "fixture: block icon"; exit 1; }
env -u CLAUDE_CODE_SESSION_ID "$LC" "$DP" "$L3" "tidy" --model smoke >/dev/null
[ "$(fmlines "$L3/index.md" icon)" = 1 ] && [ "$(fmlines "$L3/index.md" labels)" = 1 ] && nothing_to_heal "$DP" || { echo "label-card, compact_fm:"; sed -n 1,12p "$L3/index.md"; exit 1; }
ok "label-card.sh runs compact_fm over the card: a block icon that fits one line comes out on one, and heal finds nothing"

# the validator step, on a board that ships one (VB: a copy of WB with the borrowed .schema re-copied in place; the label-card cases above ran on DP, the plan board, which has no .schema, so they skipped validation)
VB="$T/Validated.lanework"; cp -R "$WB" "$VB"; rm -rf "$VB/.schema"; cp -R "$VAL" "$VB/.schema"; [ -f "$VB/.schema/bin/lanework-validate.py" ] || { echo "fixture: VB has no validator"; exit 1; }
V1=$("$FC" "$VB" Approved "Valid" --body "$T/fc.md" --model smoke 2>/dev/null)
env -u CLAUDE_CODE_SESSION_ID "$LC" "$VB" "$V1" "checked" --model smoke >/dev/null 2>"$T/err.txt" && grep -q '^labels: \[{text: "checked"' "$V1/index.md" && ! grep -q 'not validated' "$T/err.txt" && validate "$VB" >/dev/null \
  || { echo "label-card on a board with a validator:"; cat "$T/err.txt" "$V1/index.md"; exit 1; }
V2=$("$FC" "$VB" Approved "Invalid" --body "$T/fc.md" --model smoke 2>/dev/null); perl -pi -e 's/^title: .*$/title: [a, b]/' "$V2/index.md"
if python3 "$VAL/bin/lanework-validate.py" --schema "$VAL" "$V2/index.md" >/dev/null 2>&1; then echo "fixture: the validator accepts a list for title"; exit 1; fi
S13=$(sum "$VB"); rc=0; env -u CLAUDE_CODE_SESSION_ID "$LC" "$VB" "$V2" "x" --model smoke >/dev/null 2>"$T/err.txt" || rc=$?
[ "$rc" -eq 1 ] && grep -q "fails the board's validator" "$T/err.txt" && [ "$S13" = "$(sum "$VB")" ] || { echo "label-card, validator: want exit 1, nothing written, got $rc:"; cat "$T/err.txt"; exit 1; }
perl -pi -e 's/^title: .*$/title: "Invalid"/' "$V2/index.md"
ok "label-card.sh validates the staged card with the board's validator: a valid result lands (no 'not validated' note), an invalid one exits 1 and writes nothing"

# a card changed between the read and the rename is not overwritten (LABEL_CARD_TEST_HOLD holds the script just before the compare)
V3=$("$FC" "$VB" Approved "Raced" --body "$T/fc.md" --model smoke 2>/dev/null); HD="$T/hold"; rm -rf "$HD"; mkdir "$HD"
env -u CLAUDE_CODE_SESSION_ID LABEL_CARD_TEST_HOLD="$HD" "$LC" "$VB" "$V3" "late" --model smoke >/dev/null 2>"$T/err.txt" & LCPID=$!
n=0; while [ ! -e "$HD/held" ] && [ $n -lt 400 ]; do sleep 0.05; n=$((n+1)); done; [ -e "$HD/held" ] || { kill "$LCPID"; echo "label-card never reached the hold"; exit 1; }
printf 'A late edit by someone else.\n' >> "$V3/index.md"; S14=$(sum "$VB"); : > "$HD/release"
rc=0; wait "$LCPID" || rc=$?
[ "$rc" -eq 1 ] && grep -q "changed while it was staged" "$T/err.txt" && [ "$S14" = "$(sum "$VB")" ] && grep -q "A late edit" "$V3/index.md" && ! grep -q '^labels:' "$V3/index.md" \
  || { echo "label-card, a card changed meanwhile: rc $rc:"; cat "$T/err.txt"; exit 1; }
ok "label-card.sh: a card changed between the read and the rename is not overwritten: exit 1, the other writer's edit kept, no label added"

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
mkdir -p "$G/tmp"   # the SIGKILL leg skips the trap: its stage folder stays here, inside the folder smoke removes
for sig in KILL TERM; do
  rm -f "$G/inpush" "$G/pushdone"; echo "k$sig" > "$G/work/$CP"
  (cd "$G/work" && TMPDIR="$G/tmp" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: killed $sig" "$CP") >/dev/null 2>&1 & KP=$!
  perl -e 'alarm 10; exec @ARGV' bash -c "until [ -e '$G/inpush' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the push never reached the hook"; exit 1; }
  kill -"$sig" "$KP"; wait "$KP" 2>/dev/null || true
  perl -e 'alarm 10; exec @ARGV' bash -c "until [ -e '$G/pushdone' ]; do sleep 0.1; done"; sleep 0.5
  [ "$(g log -1 --format=%s)" = "B: killed $sig" ] && g diff --cached --quiet -- "$CP" && g diff --quiet -- "$CP" || { echo "killed ($sig) mid-push: the index does not match HEAD on $CP"; g status --short; g diff --cached --stat; exit 1; }
done
rm -f "$G/work/.git/hooks/pre-push"
ok "commit-board.sh killed mid-push (SIGKILL, SIGTERM): HEAD holds the commit and the index already matches it on the named path"
ls "$G/tmp" | grep -q '^work-commit\.' || { echo "the kill loop left no stage folder in \$G/tmp: TMPDIR is not reaching commit-board.sh"; exit 1; }
ok "commit-board.sh smoke: the killed run's stage folder lands in the throwaway folder, not the real TMPDIR"
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
h4=$(g rev-parse HEAD); rc=0; O=$(cb "B: glob" '*.md' 2>&1) || rc=$?; [ "$rc" -eq 1 ] && grep -q 'none of the named paths is on disk or in HEAD' <<<"$O" && [ "$(g rev-parse HEAD)" = "$h4" ] || { echo "commit-board: a glob matching no path: $O"; exit 1; }
ok "commit-board.sh skips a named path neither on disk nor in HEAD (a card's old lane path, filed since; a glob, read literally) and commits the rest; a real path with [ and ? commits"
# a failing pre-commit hook: nothing committed, the owner's staged version of the named path stays staged
h5=$(g rev-parse HEAD); printf '#!/bin/bash\nexit 1\n' > "$G/work/.git/hooks/pre-commit"; chmod +x "$G/work/.git/hooks/pre-commit"
echo v2 > "$G/work/$CP"; g add -- "$CP"; echo v3 > "$G/work/$CP"
rc=0; O=$(cb "B: hooked" "$CP" 2>&1) || rc=$?
[ "$rc" -eq 1 ] && [ "$(g rev-parse HEAD)" = "$h5" ] && [ "$(g show ":$CP")" = v2 ] && [ "$(g status --porcelain -- "$CP")" = "MM $CP" ] && grep -q 'git commit failed' <<<"$O" \
  || { echo "commit-board: a failing pre-commit hook (rc $rc): $O"; g status --short; exit 1; }
grep -q 'nothing committed, the index untouched' <<<"$O" || { echo "commit-board: a first-try hook failure should say the index is untouched: $O"; exit 1; }
rm -f "$G/work/.git/hooks/pre-commit"
cb "B: unhooked" "$CP" >/dev/null && [ "$(g show "HEAD:$CP")" = v3 ] && g diff --cached --quiet -- "$CP" && g diff --quiet -- "$CP" || { echo "commit-board: after the hook was removed it did not commit and sync"; g status --short; exit 1; }
ok "commit-board.sh: a failed pre-commit hook commits nothing and leaves the owner's staged version in the index"
# a rejected push, then nothing of the run left on HEAD: the index for the named folder is what the owner staged before
# the run (CP staged v2 with v3 on disk, a staged new file); then a rejected push followed by a good one syncs it to HEAD
CD="B.lanework/lane/card"; PP="$G/work/.git/hooks/pre-push"
owner_state() { echo r2 > "$G/work/$CP"; g add -- "$CP"; echo r3 > "$G/work/$CP"; echo n > "$G/work/$CD/n.md"; g add -- "$CD/n.md"; echo i > "$G/work/$CD/i.md"; g add -N -- "$CD/i.md"; }
snap() { g rev-parse HEAD; g ls-files -s; g status --porcelain; }
owner_state; s7=$(snap)
printf '#!/bin/bash\nprintf "#!/bin/bash\\nexit 1\\n" > "%s/work/.git/hooks/pre-commit"; chmod +x "%s/work/.git/hooks/pre-commit"; rm -f "$0"; exit 1\n' "$G" "$G" > "$PP"; chmod +x "$PP"
rc=0; O=$(cb --push "B: rejected, hooked" "$CD" 2>&1) || rc=$?
[ "$rc" -eq 1 ] && [ "$(snap)" = "$s7" ] && grep -q 'push rejected (try 1 of 5)' <<<"$O" && grep -q 'nothing committed, the index restored to what was staged before the run' <<<"$O" && ! grep -q 'index untouched' <<<"$O" \
  || { echo "commit-board: a rejected push then a failed hook (rc $rc): $O"; g status --short; exit 1; }
rm -f "$G/work/.git/hooks/pre-commit" "$PP"
ok "commit-board.sh: a rejected push, then a failed hook on the retry: HEAD, index and status as before the run, and it says restored, not untouched"
printf '#!/bin/bash\nexit 1\n' > "$PP"; chmod +x "$PP"
rc=0; O=$(cb --push "B: never pushed" "$CD" 2>&1) || rc=$?
[ "$rc" -eq 1 ] && [ "$(snap)" = "$s7" ] && [ "$(grep -c 'push rejected' <<<"$O")" -eq 5 ] && grep -q 'push failed 5 times; nothing committed, files on disk, the index restored' <<<"$O" \
  || { echo "commit-board: five failed pushes (rc $rc): $O"; g status --short; exit 1; }
ok "commit-board.sh: five failed pushes: HEAD, index and status as before the run (the staged version, the staged new file and the intent-to-add one kept)"
printf '#!/bin/bash\nrm -f "$0"; exit 1\n' > "$PP"; chmod +x "$PP"
O=$(cb --push "B: second push" "$CD" 2>&1) || { echo "commit-board: a rejected push then a good one: $O"; exit 1; }
[ "$(g show "HEAD:$CP")" = r3 ] && [ "$(g show "HEAD:$CD/n.md")" = n ] && g diff --cached --quiet -- "$CD" && g diff --quiet -- "$CD" && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] \
  || { echo "commit-board: a rejected push then a good one, the index does not match HEAD: $O"; g status --short; exit 1; }
ok "commit-board.sh: a rejected push, then a good one: the disk versions committed and pushed, the index matches HEAD on the named folder"
# owner_at <tag>: under the card folder, the card staged at <tag>2 with <tag>3 on disk, a staged new file and an intent-to-add one
owner_at() { echo "${1}2" > "$G/work/$CP"; g add -- "$CP"; echo "${1}3" > "$G/work/$CP"; echo "$1" > "$G/work/$CD/$1.md"; g add -- "$CD/$1.md"; echo i > "$G/work/$CD/$1-i.md"; g add -N -- "$CD/$1-i.md"; }
saved() { ls "$G/work/.git" | grep '^lanework-commit-board\.saved\.' || true; }
rm -f "$G/work/.git"/lanework-commit-board.saved.*   # the SIGKILL leg above leaves its saved file, as the header says
# a good push while HEAD moves past our commit (a pre-push hook commits): the index on the named folder stays HEAD's
owner_at s; printf '#!/bin/bash\nunset GIT_DIR GIT_INDEX_FILE; git -C "%s/work" commit -q --allow-empty -m "owner: past it"; rm -f "$0"; exit 0\n' "$G" > "$PP"; chmod +x "$PP"
O=$(cb --push "B: moved past" "$CD" 2>&1) || { echo "commit-board: a good push while HEAD moved past it: $O"; exit 1; }
[ "$(g log -1 --format=%s)" = "owner: past it" ] && [ "$(g log -1 --format=%s HEAD^)" = "B: moved past" ] && [ "$(g show "HEAD:$CP")" = s3 ] && g diff --cached --quiet HEAD -- "$CD" && [ -z "$(saved)" ] \
  || { echo "commit-board: HEAD moved past the pushed commit, and the owner's pre-run entries came back: $O"; g status --short; exit 1; }
ok "commit-board.sh: a good push while HEAD moves past its commit (a hook commits): exit 0, the index on the named folder matches HEAD"
# a good push while the owner amends our commit (pre-push): HEAD is neither ours nor where we started, the index is left as it is, and it says so
owner_at a; printf '#!/bin/bash\nunset GIT_DIR GIT_INDEX_FILE; git -C "%s/work" commit -q --amend -m "owner: amended"; rm -f "$0"; exit 0\n' "$G" > "$PP"; chmod +x "$PP"
O=$(cb --push "B: amended" "$CD" 2>&1) || { echo "commit-board: a good push while the owner amended: $O"; exit 1; }
[ "$(g log -1 --format=%s)" = "owner: amended" ] && [ "$(g show "HEAD:$CP")" = a3 ] && [ "$(g show ":$CP")" = a3 ] && g diff --cached --quiet HEAD -- "$CD" && grep -q 'HEAD moved to .* the index left as it is' <<<"$O" && ! grep -q 'interrupted' <<<"$O" \
  || { echo "commit-board: the owner amended the pushed commit, and the index changed: $O"; g status --short; exit 1; }
g push -q -f origin main 2>/dev/null
ok "commit-board.sh: a good push while the owner amends its commit: exit 0, the index left matching the amended HEAD, and it says HEAD moved"
# SIGTERM while a git child runs: held until it returns, then the cleanup. (1) during the un-commit's reset (a git
# wrapper pauses it until go exists), and a second one during the cleanup's update-index (paused until go2):
# HEAD, index and status as before the run, exit 143
WB="$G/wbin"; mkdir -p "$WB"; RG=$(command -v git)
cat > "$WB/git" <<WRAP
#!/bin/bash
if [ "\$1" = reset ] && [ -e "$G/p1" ] && [ ! -e "$G/inreset" ]; then touch "$G/inreset"; n=0; until [ -e "$G/go" ] || [ \$n -ge 100 ]; do sleep 0.1; n=\$((n+1)); done; fi
if [ "\$1" = update-index ] && [ -e "$G/p1" ] && [ ! -e "$G/inupd" ]; then touch "$G/inupd"; n=0; until [ -e "$G/go2" ] || [ \$n -ge 100 ]; do sleep 0.1; n=\$((n+1)); done; fi
"$RG" "\$@"; rc=\$?; [ "\$1" != reset ] || [ ! -e "$G/go" ] || touch "$G/resetdone"; exit \$rc
WRAP
chmod +x "$WB/git"; rm -f "$G/p1" "$G/inreset" "$G/go" "$G/resetdone" "$G/inupd" "$G/go2"
owner_at t; s8=$(snap); printf '#!/bin/bash\ntouch "%s/p1"; exit 1\n' "$G" > "$PP"; chmod +x "$PP"
(cd "$G/work" && PATH="$WB:$PATH" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: termed in reset" "$CD") > "$G/term.out" 2>&1 & KP=$!
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/inreset' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the un-commit never reached its reset"; cat "$G/term.out"; exit 1; }
kill -TERM "$KP"; sleep 0.3; touch "$G/go"
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/inupd' ]; do sleep 0.1; done" || { echo "the cleanup never reached its update-index"; exit 1; }
kill -TERM "$KP" 2>/dev/null || true; sleep 0.3; touch "$G/go2"; rc=0; wait "$KP" || rc=$?
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/resetdone' ]; do sleep 0.1; done" || { echo "the paused reset never finished"; exit 1; }
[ "$rc" -eq 143 ] && [ "$(snap)" = "$s8" ] && [ ! -e "$G/work/.git/lanework-commit-board.lock" ] && [ -z "$(saved)" ] || { echo "commit-board: SIGTERM during the un-commit's reset (rc $rc):"; cat "$G/term.out"; g status --short; exit 1; }
ok "commit-board.sh: SIGTERM during the un-commit's git reset waits for it, then restores, and a second SIGTERM does not cut the restore short: exit 143, HEAD, index and status as before the run, the lock gone"
# (2) during a commit-msg hook: the commit lands, then the cleanup syncs the index to it; nothing pushed
rm -f "$PP" "$G/inmsg" "$G/go" "$G/landed"; owner_at u; o9=$(gx --git-dir="$G/origin.git" rev-parse main)
printf '#!/bin/bash\ntouch "%s/inmsg"; n=0; until [ -e "%s/go" ] || [ $n -ge 100 ]; do sleep 0.1; n=$((n+1)); done\n' "$G" "$G" > "$G/work/.git/hooks/commit-msg"
printf '#!/bin/bash\ntouch "%s/landed"\n' "$G" > "$G/work/.git/hooks/post-commit"; chmod +x "$G/work/.git/hooks/commit-msg" "$G/work/.git/hooks/post-commit"
(cd "$G/work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: termed in hook" "$CD") > "$G/term.out" 2>&1 & KP=$!
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/inmsg' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the commit never reached its commit-msg hook"; cat "$G/term.out"; exit 1; }
kill -TERM "$KP"; sleep 0.3; touch "$G/go"; rc=0; wait "$KP" || rc=$?
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/landed' ]; do sleep 0.1; done" || { echo "the commit never landed"; exit 1; }
rm -f "$G/work/.git/hooks/commit-msg" "$G/work/.git/hooks/post-commit"
[ "$rc" -eq 143 ] && [ "$(g log -1 --format=%s)" = "B: termed in hook" ] && [ "$(g show "HEAD:$CP")" = u3 ] && g diff --cached --quiet HEAD -- "$CD" \
  && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$o9" ] && [ ! -e "$G/work/.git/lanework-commit-board.lock" ] && grep -q "interrupted: $(g rev-parse --short=8 HEAD) committed, not confirmed pushed (origin/main does not hold it)" "$G/term.out" || { echo "commit-board: SIGTERM during a commit-msg hook (rc $rc):"; cat "$G/term.out"; g status --short; exit 1; }
g push -q origin main 2>/dev/null
ok "commit-board.sh: SIGTERM during a commit-msg hook waits for the commit, then syncs the index to it and says it is not pushed: exit 143, the lock gone"
# (3) during a push that succeeds (pre-push paused until go3): the commit is on origin, and the line says pushed, not "not pushed"
rm -f "$G/inpush3" "$G/go3"; owner_at x
printf '#!/bin/bash\ntouch "%s/inpush3"; n=0; until [ -e "%s/go3" ] || [ $n -ge 100 ]; do sleep 0.1; n=$((n+1)); done; rm -f "$0"; exit 0\n' "$G" "$G" > "$PP"; chmod +x "$PP"
(cd "$G/work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: termed in a good push" "$CD") > "$G/term.out" 2>&1 & KP=$!
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/inpush3' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the push never reached its hook"; cat "$G/term.out"; exit 1; }
kill -TERM "$KP"; sleep 0.3; touch "$G/go3"; rc=0; wait "$KP" || rc=$?
[ "$rc" -eq 143 ] && [ "$(g log -1 --format=%s)" = "B: termed in a good push" ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] && g diff --cached --quiet HEAD -- "$CD" \
  && grep -q "interrupted: $(g rev-parse --short=8 HEAD) committed and pushed" "$G/term.out" && ! grep -q 'not pushed' "$G/term.out" || { echo "commit-board: SIGTERM during a good push (rc $rc):"; cat "$G/term.out"; exit 1; }
ok "commit-board.sh: SIGTERM during a push that succeeds: exit 143, the commit on origin, the index synced, and it says committed and pushed"
# a failed restore: the saved file gone says NOT restored; an index.lock keeps the saved file and prints how to put it back
owner_at v; s10=$(snap)
printf '#!/bin/bash\nrm -f "%s/work/.git"/lanework-commit-board.saved.*; printf "#!/bin/bash\\nexit 1\\n" > "%s/work/.git/hooks/pre-commit"; chmod +x "%s/work/.git/hooks/pre-commit"; rm -f "$0"; exit 1\n' "$G" "$G" "$G" > "$PP"; chmod +x "$PP"
rc=0; O=$(cb --push "B: save gone" "$CD" 2>&1) || rc=$?; rm -f "$G/work/.git/hooks/pre-commit"
[ "$rc" -eq 1 ] && grep -q 'the saved entries (.*) are gone' <<<"$O" && grep -q 'nothing committed, the index for the named paths NOT restored to what was staged before the run' <<<"$O" && ! grep -q 'index restored' <<<"$O" \
  || { echo "commit-board: the saved file removed mid-run (rc $rc): $O"; exit 1; }
g reset -q -- "$CD"; owner_at v; s10=$(snap)
printf '#!/bin/bash\ntouch "%s/work/.git/index.lock"; printf "#!/bin/bash\\nexit 1\\n" > "%s/work/.git/hooks/pre-commit"; chmod +x "%s/work/.git/hooks/pre-commit"; rm -f "$0"; exit 1\n' "$G" "$G" "$G" > "$PP"; chmod +x "$PP"
rc=0; O=$(cb --push "B: index locked" "$CD" 2>&1) || rc=$?; rm -f "$G/work/.git/index.lock" "$G/work/.git/hooks/pre-commit"
KS=$(saved); [ "$rc" -eq 1 ] && [ -n "$KS" ] && grep -q "saved entries are kept in .*$KS" <<<"$O" && grep -q 'NOT restored' <<<"$O" || { echo "commit-board: a restore failing on index.lock (rc $rc): $O"; exit 1; }
grep -E '^  git (reset|update-index|add) ' <<<"$O" | (cd "$G/work" && bash -e) && [ "$(snap)" = "$s10" ] || { echo "commit-board: the printed recovery did not put the owner's entries back: $O"; g status --short; exit 1; }
rm -f "$G/work/.git/$KS"; g reset -q -- "$CD"; g checkout -q -- "$CD"; rm -f "$G/work/$CD/v.md" "$G/work/$CD/v-i.md"   # the card folder as HEAD has it, for the cases below
ok "commit-board.sh: a failed restore says NOT restored (saved file gone, index.lock); with index.lock the saved file is kept and the printed commands put the owner's entries back"
# a failed restore on try 1 (a git wrapper fails the first update-index), then a good push: exit 0, the saved file removed (its entries obsolete)
WB2="$G/wbin2"; mkdir -p "$WB2"; rm -f "$G/p1" "$G/updfail"
printf '#!/bin/bash\nif [ "$1" = update-index ] && [ -e "%s/p1" ] && [ ! -e "%s/updfail" ]; then touch "%s/updfail"; exit 1; fi\nexec "%s" "$@"\n' "$G" "$G" "$G" "$RG" > "$WB2/git"; chmod +x "$WB2/git"
printf '#!/bin/bash\n[ -e "%s/p1" ] && { rm -f "$0"; exit 0; }; touch "%s/p1"; exit 1\n' "$G" "$G" > "$PP"; chmod +x "$PP"; owner_at w
rc=0; O=$(cd "$G/work" && PATH="$WB2:$PATH" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$CB" --push "B: restore failed, then pushed" "$CD" 2>&1) || rc=$?
[ "$rc" -eq 0 ] && [ -e "$G/updfail" ] && grep -q 'could not restore' <<<"$O" && [ -z "$(saved)" ] && [ "$(g show "HEAD:$CP")" = w3 ] && g diff --cached --quiet HEAD -- "$CD" \
  && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] || { echo "commit-board: a failed restore, then a good push (rc $rc): $O"; saved; exit 1; }
ok "commit-board.sh: a restore that failed on try 1, then a good push: exit 0, pushed, the saved file removed"
# every named path skipped: exit 1; a real path with no changes: nothing to commit, exit 0
h6=$(g rev-parse HEAD); rc=0; O=$(cb "B: none" B.lanework/typo/index.md 2>&1) || rc=$?
[ "$rc" -eq 1 ] && grep -q 'none of the named paths is on disk or in HEAD; nothing committed' <<<"$O" && [ "$(g rev-parse HEAD)" = "$h6" ] || { echo "commit-board: every path skipped: want exit 1, got $rc: $O"; exit 1; }
rc=0; O=$(cb "B: same" "$CP" 2>&1) || rc=$?; [ "$rc" -eq 0 ] && [ "$O" = "nothing to commit" ] || { echo "commit-board: an unchanged real path: want exit 0, got $rc: $O"; exit 1; }
ok "commit-board.sh: every named path skipped exits 1 naming it; an existing unchanged path still prints nothing to commit, exit 0"
# a value-taking flag with no value, and post-comment.sh with no arguments: exit 2
PCM="$SK/work/scripts/post-comment.sh"
for c in "$FC b L t --body" "$MC b c L --model" "$PA b c --for" "$PCM b c --body" "$PCM"; do
  rc=0; O=$($c 2>&1) || rc=$?; [ "$rc" -eq 2 ] || { echo "'$c' with no value: want exit 2, got $rc: $O"; exit 1; }
done
ok "file-card.sh, move-card.sh, post-ask.sh and post-comment.sh exit 2 on a flag with no value; post-comment.sh with no arguments exits 2"
# a symlink in the tree is committed as the link, not its target
echo t1 > "$G/work/target.md"; g add target.md; g commit -q -m target; ln -s target.md "$G/work/link.md"
cb "B: link" link.md >/dev/null && [ "$(g ls-files -s link.md | cut -c1-6)" = 120000 ] && [ "$(g show --name-only --format= HEAD)" = link.md ] || { echo "commit-board: a symlink was not committed as a link"; g show --stat HEAD; exit 1; }
ok "commit-board.sh commits a symlink as the link (mode 120000), not its target"
h3=$(g rev-parse HEAD); echo j2 > "$G/work/$CP"
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
# --push with nothing to commit but HEAD ahead of origin (a run SIGKILLed while its pre-push hook slept): pushes it
g reset -q --hard HEAD; g push -q origin main 2>/dev/null; rm -f "$PP" "$G/inpush4" "$G/hookpid"; echo r4 > "$G/work/$CP"
printf '#!/bin/bash\necho $$ > "%s/hookpid"; touch "%s/inpush4"; exec sleep 30\n' "$G" "$G" > "$PP"; chmod +x "$PP"
(cd "$G/work" && TMPDIR="$G/tmp" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: killed, then retried" "$CP") >/dev/null 2>&1 & KP=$!
perl -e 'alarm 60; exec @ARGV' bash -c "until [ -e '$G/inpush4' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the push never reached the hook"; exit 1; }
kill -KILL "$KP"; wait "$KP" 2>/dev/null || true; HK=$(cat "$G/hookpid"); kill -KILL "$HK" 2>/dev/null || true; rm -f "$PP"
perl -e 'alarm 60; exec @ARGV' bash -c "while kill -0 $HK 2>/dev/null; do sleep 0.1; done"; sleep 0.5
hk=$(g rev-parse HEAD); [ "$(g log -1 --format=%s)" = "B: killed, then retried" ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" != "$hk" ] || { echo "the killed run did not leave its commit unpushed"; exit 1; }
rc=0; O=$(cb --push "B: retry" "$CP" 2>&1) || rc=$?
[ "$rc" -eq 0 ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$hk" ] && [ "$(g rev-parse HEAD)" = "$hk" ] && ! grep -q 'nothing to commit' <<<"$O" \
  || { echo "commit-board --push after a killed push left its commit unpushed (rc $rc): $O"; exit 1; }
ok "commit-board.sh --push with nothing to commit but HEAD ahead of origin (an earlier run SIGKILLed mid-push): pushes it, exit 0"
# the same with origin refusing every push: exit 1 after 5 tries, naming the unpushed commit
echo r5 > "$G/work/$CP"; cb "B: unpushed" "$CP" >/dev/null; hu=$(g rev-parse HEAD)
printf '#!/bin/bash\nexit 1\n' > "$G/origin.git/hooks/pre-receive"; chmod +x "$G/origin.git/hooks/pre-receive"
rc=0; O=$(cb --push "B: refused retry" "$CP" 2>&1) || rc=$?; rm -f "$G/origin.git/hooks/pre-receive"
[ "$rc" -eq 1 ] && grep -q "push failed 5 times; ${hu:0:8}" <<<"$O" && [ "$(g rev-parse HEAD)" = "$hu" ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" != "$hu" ] \
  || { echo "commit-board --push of an earlier commit to an origin that refuses (rc $rc): $O"; exit 1; }
g push -q origin main 2>/dev/null
ok "commit-board.sh --push of an earlier unpushed commit that origin refuses: exit 1 after 5 tries, naming it, HEAD kept"
# the push bound: LANEWORK_PUSH_TIMEOUT=2, a pre-push hook that sleeps 30 in a child; the run ends at the bound, the hook's
# child gone, the commit kept and the cleanup run; a later --push lands it
mkdir -p "$G/tmp3"; rm -f "$G/sleeppid"; echo r6 > "$G/work/$CP"
printf '#!/bin/bash\nsleep 30 & echo $! > "%s/sleeppid"; wait\n' "$G" > "$PP"; chmod +x "$PP"
t0=$(date +%s); rc=0; O=$(cd "$G/work" && TMPDIR="$G/tmp3" LANEWORK_PUSH_TIMEOUT=2 GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 perl -e 'alarm 45; exec @ARGV' "$CB" --push "B: bounded" "$CP" 2>&1) || rc=$?; t1=$(date +%s)
SP=$(cat "$G/sleeppid" 2>/dev/null || true); rm -f "$PP"; sleep 0.3
if [ -n "$SP" ] && kill -0 "$SP" 2>/dev/null; then kill "$SP"; echo "commit-board: the pre-push hook's child outlived the bound"; exit 1; fi
[ "$rc" -eq 1 ] && [ $((t1 - t0)) -lt 15 ] && [ -n "$SP" ] && grep -q "push timed out after 2 s; $(g rev-parse --short=8 HEAD) committed, not confirmed pushed" <<<"$O" && ! grep -q interrupted <<<"$O" \
  && [ "$(g log -1 --format=%s)" = "B: bounded" ] && [ -z "$(g status --porcelain -- "$CP")" ] && [ ! -e "$LK" ] && [ -z "$(ls "$G/tmp3")" ] \
  || { echo "commit-board: a push past LANEWORK_PUSH_TIMEOUT (rc $rc, $((t1 - t0)) s): $O"; g status --short; ls "$G/tmp3"; exit 1; }
hb=$(g rev-parse HEAD); cb --push "B: after the bound" "$CP" >/dev/null && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$hb" ] || { echo "commit-board: --push after a timed-out push did not land it"; exit 1; }
rc=0; (cd "$G/work" && LANEWORK_PUSH_TIMEOUT=x GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$CB" --push "B: bad bound" "$CP") >/dev/null 2>&1 || rc=$?; [ "$rc" -eq 2 ] || { echo "commit-board: a bad LANEWORK_PUSH_TIMEOUT: want exit 2, got $rc"; exit 1; }
ok "commit-board.sh: a push past LANEWORK_PUSH_TIMEOUT ends at the bound (exit 1, timed out, not confirmed pushed), the hook's child killed, the commit on HEAD, the index synced, lock and stage folder gone; the next --push lands it; a bad value exits 2"
# push.err unwritable (a pre-commit hook makes the stage folder read-only): a failed push, the commit taken back, no "interrupted"
mkdir -p "$G/tmp4"; echo r7 > "$G/work/$CP"; h7=$(g rev-parse HEAD)
printf '#!/bin/bash\nchmod a-w "%s/tmp4"/work-commit.*\n' "$G" > "$G/work/.git/hooks/pre-commit"; chmod +x "$G/work/.git/hooks/pre-commit"
rc=0; O=$(cd "$G/work" && TMPDIR="$G/tmp4" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$CB" --push "B: unwritable" "$CP" 2>&1) || rc=$?
rm -f "$G/work/.git/hooks/pre-commit"; chmod -R u+w "$G/tmp4"
[ "$rc" -eq 1 ] && [ "$(g rev-parse HEAD)" = "$h7" ] && ! grep -q interrupted <<<"$O" && grep -q 'git push output unavailable' <<<"$O" && [ ! -e "$LK" ] \
  || { echo "commit-board: an unwritable push.err (rc $rc): $O"; g log --oneline -2; exit 1; }
ok "commit-board.sh: push.err unwritable: a failed push (git push output unavailable), the commit taken back, HEAD as before, no interrupted line, the lock gone"
# the saved-file sweep: a dead pid's saved file from 2020 goes; one an hour old, and a live pid's from 2020, stay
sh -c 'exit 0' & DPID=$!; wait "$DPID"; SO="$G/work/.git/lanework-commit-board.saved.$DPID.oldold"; SN="$G/work/.git/lanework-commit-board.saved.$DPID.newnew"
sleep 60 & LPID=$!; SL="$G/work/.git/lanework-commit-board.saved.$LPID.livold"
: > "$SO"; : > "$SN"; : > "$SL"; touch -t 202001010000 "$SO" "$SL"; touch -t "$(date -v-1H +%Y%m%d%H%M.%S)" "$SN"
echo r8 > "$G/work/$CP"; rc=0; cb "B: swept" "$CP" >/dev/null || rc=$?; kill "$LPID"; wait "$LPID" 2>/dev/null || true
[ "$rc" -eq 0 ] && [ ! -e "$SO" ] && [ -e "$SN" ] && [ -e "$SL" ] || { echo "commit-board: the saved-file sweep (rc $rc): want only the dead pid's old one gone"; ls "$G/work/.git"; exit 1; }
rm -f "$SN" "$SL"
ok "commit-board.sh sweeps a dead pid's saved file over a day old and keeps one an hour old and a live pid's old one"
# the closing line after an owner's reset during a good push names the run's commit, not the owner's
echo r9 > "$G/work/$CP"; g push -q origin main 2>/dev/null
printf '#!/bin/bash\nunset GIT_DIR GIT_INDEX_FILE; git -C "%s/work" update-ref refs/heads/main HEAD^; rm -f "$0"; exit 0\n' "$G" > "$PP"; chmod +x "$PP"
O=$(cb --push "B: owner reset" "$CP" 2>/dev/null) || { echo "commit-board: a good push with an owner reset failed"; exit 1; }
hn=$(gx --git-dir="$G/origin.git" rev-parse main)
[ "$(tail -1 <<<"$O")" = "$(g log --oneline -1 "$hn")" ] && [ "$(gx --git-dir="$G/origin.git" log -1 --format=%s main)" = "B: owner reset" ] || { echo "commit-board: the closing line after an owner reset: $O"; exit 1; }
g reset -q --hard origin/main
ok "commit-board.sh: an owner's reset during a good push: the closing line names the run's commit, not the owner's"
# a push mapped to another branch (remote.origin.push), SIGTERM during it: "not confirmed pushed", never "not pushed"
g config remote.origin.push refs/heads/main:refs/heads/other; rm -f "$G/inpush7" "$G/go7"; echo r10 > "$G/work/$CP"
printf '#!/bin/bash\ntouch "%s/inpush7"; n=0; until [ -e "%s/go7" ] || [ $n -ge 100 ]; do sleep 0.1; n=$((n+1)); done; rm -f "$0"; exit 0\n' "$G" "$G" > "$PP"; chmod +x "$PP"
(cd "$G/work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec "$CB" --push "B: mapped" "$CP") > "$G/term.out" 2>&1 & KP=$!
perl -e 'alarm 20; exec @ARGV' bash -c "until [ -e '$G/inpush7' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the mapped push never reached its hook"; cat "$G/term.out"; exit 1; }
kill -TERM "$KP"; sleep 0.3; touch "$G/go7"; rc=0; wait "$KP" || rc=$?; g config --unset remote.origin.push
[ "$rc" -eq 143 ] && [ "$(gx --git-dir="$G/origin.git" rev-parse other)" = "$(g rev-parse HEAD)" ] && grep -q "interrupted: $(g rev-parse --short=8 HEAD) committed, not confirmed pushed (origin/main does not hold it)" "$G/term.out" \
  && ! grep -q 'not pushed' "$G/term.out" || { echo "commit-board: SIGTERM during a push mapped to another branch (rc $rc):"; cat "$G/term.out"; exit 1; }
ok "commit-board.sh: SIGTERM during a push mapped to another branch: exit 143, it says not confirmed pushed, never not pushed"
# the owner's staged entries across a push-only first try: HEAD ahead of origin, the card staged at pown with HEAD's p1 on
# disk; the pre-push hook rejects every push and writes p2 to disk on its first call, so try 2 commits; after 5 the index is pown
g push -q origin main 2>/dev/null; rm -f "$PP" "$G/rw1"; echo p1 > "$G/work/$CP"; g commit -q -am "B: ahead"; hp=$(g rev-parse HEAD)
echo pown > "$G/work/$CP"; g add -- "$CP"; echo p1 > "$G/work/$CP"; sv0=$(saved)   # an earlier SIGKILL leg's saved file stays
printf '#!/bin/bash\n[ -e "%s/rw1" ] || { touch "%s/rw1"; echo p2 > "%s/work/%s"; }; exit 1\n' "$G" "$G" "$G" "$CP" > "$PP"; chmod +x "$PP"
rc=0; O=$(cb --push "B: push-only first" "$CP" 2>&1) || rc=$?; rm -f "$PP"
[ "$rc" -eq 1 ] && grep -q "push of ${hp:0:8} rejected (try 1 of 5)" <<<"$O" && grep -q 'push rejected (try 2 of 5)' <<<"$O" && grep -q 'the index restored to what was staged before the run' <<<"$O" \
  && [ "$(g show ":$CP")" = pown ] && ! g diff --quiet -- "$CP" && [ "$(cat "$G/work/$CP")" = p2 ] && [ "$(g rev-parse HEAD)" = "$hp" ] && [ "$(saved)" = "$sv0" ] \
  || { echo "commit-board: staged entries across a push-only first try (rc $rc, index $(g show ":$CP")): $O"; g status --short; exit 1; }
g reset -q -- "$CP"; g checkout -q -- "$CP"; g push -q origin main 2>/dev/null
ok "commit-board.sh: a push-only first try, then commits on the retries: the owner's staged entry is saved and put back, the message true"
# the bound's ceiling: above 86400 (alarm sets nothing from 1000000000 up) exits 2, no commit, no lock, the hook never run; 86400 pushes
printf '#!/bin/bash\ntouch "%s/ranhook"; exit 0\n' "$G" > "$PP"; chmod +x "$PP"; rm -f "$G/ranhook"; echo c1 > "$G/work/$CP"; hc=$(g rev-parse HEAD)
for v in 86401 100000000 99999999999; do
  rc=0; O=$(cd "$G/work" && LANEWORK_PUSH_TIMEOUT=$v GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 perl -e 'alarm 30; exec @ARGV' "$CB" --push "B: ceiling $v" "$CP" 2>&1) || rc=$?
  [ "$rc" -eq 2 ] && grep -q 'a whole number of seconds from 1 to 86400' <<<"$O" && [ "$(g rev-parse HEAD)" = "$hc" ] && [ ! -e "$G/ranhook" ] && [ ! -e "$LK" ] \
    || { echo "commit-board: LANEWORK_PUSH_TIMEOUT=$v: want exit 2, nothing run (rc $rc): $O"; exit 1; }
done
rc=0; O=$(cd "$G/work" && LANEWORK_PUSH_TIMEOUT=86400 GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 perl -e 'alarm 30; exec @ARGV' "$CB" --push "B: ceiling 86400" "$CP" 2>&1) || rc=$?; rm -f "$PP"
[ "$rc" -eq 0 ] && [ -e "$G/ranhook" ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] || { echo "commit-board: LANEWORK_PUSH_TIMEOUT=86400 (rc $rc): $O"; exit 1; }
ok "commit-board.sh: LANEWORK_PUSH_TIMEOUT above 86400 (86401, 100000000, 99999999999) exits 2, nothing committed or run, no lock; 86400 pushes"
# signals to the push wrapper (the hook's grandparent, found by pid; never a group): TERM, HUP, INT each end the push and the
# hook's foreground sleep at once, and the retry pushes. Launched with INT at its default (a background job ignores it)
for sig in TERM HUP INT; do
  rm -f "$G/fw1" "$G/hookppid" "$G/sleeppid"; echo "f$sig" > "$G/work/$CP"
  printf '#!/bin/bash\n[ -e "%s/fw1" ] && exit 0; touch "%s/fw1"; echo $PPID > "%s/hookppid"; bash -c '\''echo $$ > "$1"; exec sleep 30'\'' _ "%s/sleeppid"\n' "$G" "$G" "$G" "$G" > "$PP"; chmod +x "$PP"
  (cd "$G/work" && LANEWORK_PUSH_TIMEOUT=60 GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 exec perl -e '$SIG{INT} = "DEFAULT"; exec @ARGV' "$CB" --push "B: forwarded $sig" "$CP") > "$G/fw.out" 2>&1 & KP=$!
  perl -e 'alarm 20; exec @ARGV' bash -c "until [ -s '$G/sleeppid' ]; do sleep 0.1; done" || { kill -KILL "$KP"; echo "the forwarded push never reached its sleep"; cat "$G/fw.out"; exit 1; }
  SP=$(cat "$G/sleeppid"); WP=$(ps -o ppid= -p "$(cat "$G/hookppid")" | tr -d ' ')
  case "$(ps -o comm= -p "$WP")" in *perl*) ;; *) kill -KILL "$KP" "$SP"; echo "the hook's grandparent $WP is not the perl wrapper"; exit 1 ;; esac
  t0=$(date +%s); kill -"$sig" "$WP"
  perl -e 'alarm 30; exec @ARGV' bash -c "while kill -0 $KP 2>/dev/null; do sleep 0.1; done" || true; t1=$(date +%s)
  if kill -0 "$KP" 2>/dev/null; then kill -KILL "$KP" "$SP" 2>/dev/null; echo "commit-board: $sig to the push wrapper did not end the run"; cat "$G/fw.out"; exit 1; fi
  rc=0; wait "$KP" || rc=$?
  if kill -0 "$SP" 2>/dev/null; then kill -KILL "$SP"; echo "commit-board: $sig to the push wrapper left the hook's sleep running"; exit 1; fi
  [ "$rc" -eq 0 ] && [ $((t1 - t0)) -lt 15 ] && ! grep -q 'timed out' "$G/fw.out" && grep -q 'push rejected (try 1 of 5)' "$G/fw.out" && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] \
    || { echo "commit-board: $sig to the push wrapper (rc $rc, $((t1 - t0)) s):"; cat "$G/fw.out"; exit 1; }
done
rm -f "$PP"
ok "commit-board.sh: TERM, HUP and INT to the push wrapper end the push and the hook's sleep at once (no timeout), and the retry pushes"
# a git that itself exits 124 on its first push reads as a rejected push, never a timeout
WB3="$G/wbin3"; mkdir -p "$WB3"; rm -f "$G/g124"; echo g124 > "$G/work/$CP"
printf '#!/bin/bash\nif [ "$1" = push ] && [ ! -e "%s/g124" ]; then touch "%s/g124"; exit 124; fi\nexec "%s" "$@"\n' "$G" "$G" "$RG" > "$WB3/git"; chmod +x "$WB3/git"
rc=0; O=$(cd "$G/work" && PATH="$WB3:$PATH" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 "$CB" --push "B: git 124" "$CP" 2>&1) || rc=$?
[ "$rc" -eq 0 ] && [ -e "$G/g124" ] && grep -q 'push rejected (try 1 of 5)' <<<"$O" && ! grep -q 'timed out' <<<"$O" && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] \
  || { echo "commit-board: a git push exiting 124 (rc $rc): $O"; exit 1; }
ok "commit-board.sh: a git push that itself exits 124 is a rejected push (retried, pushed), not a timeout"
# the cleanup's rm is not fatal: a pre-push hook makes the git dir read-only, so the lock and saved file cannot go; exit 0, pushed
echo ro > "$G/work/$CP"; printf '#!/bin/bash\nchmod a-w "%s/work/.git"\n' "$G" > "$PP"; chmod +x "$PP"
rc=0; O=$(cb --push "B: read-only git dir" "$CP" 2>&1) || rc=$?
chmod u+w "$G/work/.git"; rm -f "$PP"; ro=$([ -e "$LK" ] && echo lock; saved); rm -rf "$LK"; rm -f "$G/work/.git"/lanework-commit-board.saved.*
[ "$rc" -eq 0 ] && [ -n "$ro" ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] && [ "$(g log -1 --format=%s)" = "B: read-only git dir" ] \
  || { echo "commit-board: a cleanup rm that fails (rc $rc, left: $ro): $O"; exit 1; }
ok "commit-board.sh: a cleanup whose rm fails (the git dir read-only) still exits 0 with the commit on origin"
# no terminal for the push: under a pty (script), a pre-push hook cannot open /dev/tty, and the push lands
rm -f "$G/ttyres" "$G/ttyrc"; echo tty > "$G/work/$CP"
printf '#!/bin/bash\nif ( exec 3<>/dev/tty ) 2>/dev/null; then echo tty-open; else echo tty-closed; fi > "%s/ttyres"\n' "$G" > "$PP"; chmod +x "$PP"
(cd "$G/work" && GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 perl -e 'alarm 60; exec @ARGV' script -q /dev/null bash -c '"$1" --push "B: no tty" "$2"; echo $? > "$3"' _ "$CB" "$CP" "$G/ttyrc") < /dev/null > "$G/tty.out" 2>&1 || true
rm -f "$PP"
[ "$(cat "$G/ttyres" 2>/dev/null)" = tty-closed ] && [ "$(cat "$G/ttyrc" 2>/dev/null)" = 0 ] && [ "$(gx --git-dir="$G/origin.git" rev-parse main)" = "$(g rev-parse HEAD)" ] && [ "$(g log -1 --format=%s)" = "B: no tty" ] \
  || { echo "commit-board: the push under a pty (hook: $(cat "$G/ttyres" 2>/dev/null), rc $(cat "$G/ttyrc" 2>/dev/null)):"; cat "$G/tty.out"; exit 1; }
ok "commit-board.sh: under a pty the push has no terminal (a pre-push hook cannot open /dev/tty), and it lands"
# work: headers card. move-card.sh posts --comment only after every refusal, and passes a lost lease from post-comment.sh through as exit 3;
# lint-ask.sh sends its unreadable-file message to stderr and fails an ask of exactly 80 words
HM="$T/HdrWork.lanework"; cp -R "$P" "$HM"; cp -R "$VAL" "$HM/.schema"
HMI=$(dirname "$(lane_of "$HM" Ideas)"); HMA=$(dirname "$(lane_of "$HM" Active)")
HC1=feed0000-0000-4000-8000-000000000001; mkdir -p "$HMI/$HC1"
printf 'no frontmatter here\n' > "$HMI/$HC1/index.md"; printf 'A note.\n' > "$T/hm-c.md"
rc=0; O=$(env -u CLAUDE_CODE_SESSION_ID "$MC" "$HM" "${HC1:0:8}" Active --model smoke --comment "$T/hm-c.md" 2>&1) || rc=$?
[ "$rc" -eq 1 ] && grep -q 'no frontmatter; nothing written' <<<"$O" && [ ! -e "$HMI/$HC1/comments" ] && [ -f "$HMI/$HC1/index.md" ] && [ ! -e "$HMA/$HC1" ] \
  || { echo "move-card --comment on a card with no frontmatter (rc $rc): want exit 1 and no comment left: $O"; ls -R "$HMI/$HC1"; exit 1; }
ok "move-card.sh --comment: a card with no frontmatter is refused with the comment not posted (before the fix, one comment was left)"
HMS="$T/hm-skills"; cp -R "$SK" "$HMS"; HC2=beef0000-0000-4000-8000-000000000002; mkdir -p "$HMI/$HC2"
printf -- '---\nschema: 1\nkind: card\ntitle: "Lease race"\norder: 2048\ncreated: {at: 2026-10-01T00:00:00Z}\nmodified: {at: 2026-10-01T00:00:00Z}\n---\nBody.\n' > "$HMI/$HC2/index.md"
printf '#!/bin/bash\nn="$0.calls"; c=$(cat "$n" 2>/dev/null || echo 0); echo $((c+1)) > "$n"; [ "$c" -eq 0 ] && exit 4; exit 3\n' > "$HMS/lanework/scripts/lease.sh"; chmod +x "$HMS/lanework/scripts/lease.sh"
rc=0; O=$(CLAUDE_CODE_SESSION_ID=s-hm-test "$HMS/work/scripts/move-card.sh" "$HM" "${HC2:0:8}" Active --model smoke --comment "$T/hm-c.md" 2>&1) || rc=$?
[ "$rc" -eq 3 ] && grep -q 'move-card.sh: this session.s lease on beef0000 is lost' <<<"$O" && [ -d "$HMI/$HC2" ] && [ ! -e "$HMI/$HC2/comments" ] \
  || { echo "move-card --comment, lease lost at the comment (rc $rc): want exit 3 and the card not moved: $O"; exit 1; }
ok "move-card.sh --comment: a lease lost between the move's check and the comment's exits 3 with its own line, the card unmoved (before the fix, exit 1 'the comment was refused')"
rc=0; O=$("$SK/work/scripts/lint-ask.sh" "$T/no-such-ask.md" 2>/dev/null) || rc=$?
[ "$rc" -eq 2 ] && [ -z "$O" ] || { echo "lint-ask, an unreadable file: want exit 2 and nothing on stdout (rc $rc): $O"; exit 1; }
rc=0; O=$("$SK/work/scripts/lint-ask.sh" "$T/no-such-ask.md" 2>&1 >/dev/null) || rc=$?
[ "$rc" -eq 2 ] && [ "$O" = "lint-ask.sh: no such file: $T/no-such-ask.md" ] || { echo "lint-ask, an unreadable file: want the message on stderr (rc $rc): $O"; exit 1; }
{ printf '@owner Which engine?'; for _ in $(seq 1 77); do printf ' word'; done; printf '\n'; } > "$T/ask-80.md"
{ printf '@owner Which engine?'; for _ in $(seq 1 76); do printf ' word'; done; printf '\n'; } > "$T/ask-79.md"
[ "$(wc -w < "$T/ask-80.md" | tr -d ' ')" -eq 80 ] || { echo "ask-80 fixture is not 80 words"; exit 1; }
rc=0; O=$("$SK/work/scripts/lint-ask.sh" "$T/ask-80.md") || rc=$?
[ "$rc" -eq 1 ] && grep -q '^80 words; an ask stays under 80' <<<"$O" || { echo "lint-ask, an 80-word ask: want exit 1 (rc $rc): $O"; exit 1; }
"$SK/work/scripts/lint-ask.sh" "$T/ask-79.md" || { echo "lint-ask, a 79-word ask failed"; exit 1; }
ok "lint-ask.sh: an unreadable file prints 'lint-ask.sh: no such file: <f>' on stderr only, exit 2; an ask of exactly 80 words fails, 79 passes (before the fix: stdout message, 80 passed)"

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
BL3=$(uuidgen | tr A-Z a-z); mkdir -p "$ASKED/$BL3"   # a title with no cite-as whose Q40: does not open it: must not count
printf -- '---\nschema: 1\nkind: card\ntitle: "See Q40: not a prefix"\norder: 9100\ncreated: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\nnot a legacy prefix\n' > "$ASKED/$BL3/index.md"
BO8=$(cq "$CB" eight); [ "$(cite_of_card "$CB" "$(cc "$BO8")")" = Q8 ] || { echo "a legacy Q7: title did not count:"; echo "$BO8"; exit 1; }
( . "$SK/lanework/scripts/lib.sh"
  [ "$(next_cite "$CB" Q)" = Q9 ] && [ "$(next_cite "$CB" ADR)" = ADR1 ] && [ "$(next_cite "$CB" T)" = T1 ] || { echo "next_cite: Q=$(next_cite "$CB" Q) ADR=$(next_cite "$CB" ADR) T=$(next_cite "$CB" T)"; exit 1; }
  [ "$(cite_of "$ASKED/$BL2/index.md")" = "" ] && [ "$(card_ref "$ASKED/$BL2/index.md")" = "Q7: old" ] && [ "$(cite_of "$(ls "$CB"/*/"$BQ1"/index.md)")" = Q1 ] && [ "$(card_ref "$(ls "$CB"/*/"$BQ1"/index.md)")" = Q1 ] \
    || { echo "cite_of/card_ref wrong"; exit 1; }
  printf -- '---\nschema: 1\nkind: card\ntitle: "A [x] \\\\ b"\n---\n' > "$T/ref.md"; [ "$(card_ref "$T/ref.md")" = 'A \[x\] \\ b' ] || { echo "card_ref did not escape: $(card_ref "$T/ref.md")"; exit 1; } )
validate "$CB" >/dev/null; ok "cite trash and legacy scan: a flat-trashed Q2 and a Q3 in a trashed lane are not reissued, a legacy Q7: title makes the next Q8 while a See Q40: title is not counted; next_cite counts per prefix, cite_of and card_ref read the key, else the escaped title"
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
PE "$PS/claim-ticket.sh" "$CP" "$ET1" --model smoke >/dev/null
RO=$(PE "$PS/resolve-ticket.sh" "$CP" "$ET1" --resolution "$T/cres.md" --model smoke)
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

# cite-as leftovers: stamp_cite checks it stamped; the older-board path reads a padded number as decimal; next_cite ignores case and a trailing comment
( . "$SK/lanework/scripts/lib.sh"
  printf -- 'cite-as: CITEPENDING\ntitle: "x"\n' > "$T/sc-ok.md"; printf -- 'title: "x"\n' > "$T/sc-none.md"
  rc=0; out=$(stamp_cite "$T/sc-ok.md" "$CZ" Q 2>/dev/null) || rc=$?
  [ "$rc" -eq 0 ] && [ "$out" = Q11 ] && grep -qx "cite-as: Q11" "$T/sc-ok.md" || { echo "stamp_cite on a staged file: rc=$rc out=$out"; exit 1; }
  rc=0; out=$(stamp_cite "$T/sc-none.md" "$CZ" Q 2>/dev/null) || rc=$?
  [ "$rc" -ne 0 ] && [ -z "$out" ] || { echo "stamp_cite on a file without the placeholder: rc=$rc out=$out"; exit 1; }
  printf -- 'cite-as: CITEPENDING\ntitle: "x"\n' > "$T/sc-ok2.md"
  rc=0; out=$(stamp_cite "$T/sc-ok2.md" "$CZ" "" 2>/dev/null) || rc=$?
  [ "$rc" -ne 0 ] && [ -z "$out" ] || { echo "stamp_cite with an empty prefix: rc=$rc out=$out"; exit 1; } )
ok "stamp_cite fails with no output on a file without the placeholder and on an empty prefix, and stamps a file that has it"
cardw() {  # cardw <lane card path> <title> [cite-as]: a hand-written card
  mkdir -p "$1"; { printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\n' "$2"; [ -z "${3:-}" ] || printf 'cite-as: %s\n' "$3"
    printf 'order: 9000\ncreated: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\nx\n'; } > "$1/index.md"; }
firstlane() { ls -d "$1"/*/ | sed -n 1p | sed 's#/$##'; }
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"; printf 'Where does the engine run?\n' > "$T/ct.md"
for pair in "9|Q9: nine|Q010: padded|Q11" "8|Q08: padded||Q9"; do
  IFS='|' read -r tag t1 t2 want <<<"$pair"
  PQ="$T/Pad$tag Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$PQ" --model smoke >/dev/null; mkguide "$PQ" 114
  PT="$T/Pad$tag Plan.lanework"; "$PS/found-plan-board.sh" "$PT" --model smoke >/dev/null; mkguide "$PT" 114
  for b in "$PQ" "$PT"; do cardw "$(firstlane "$b")/$(uuidgen | tr A-Z a-z)" "$t1"; [ -z "$t2" ] || cardw "$(firstlane "$b")/$(uuidgen | tr A-Z a-z)" "$t2"; done
  # tickets are T-numbered
  for f in "$PT"/*/*/index.md; do sed -i '' 's/^title: "Q/title: "T/' "$f"; done
  QO=$("$SK/discovery/scripts/file-question.sh" "$PQ" "next" --round 1 --body "$T/cq.md" --model smoke 2>&1) || { echo "file-question.sh failed on an older board holding $t1 $t2: $QO"; exit 1; }
  TO=$("$PS/file-ticket.sh" "$PT" "next" --type grilling --body "$T/ct.md" --model smoke 2>&1) || { echo "file-ticket.sh failed on an older board holding $t1 $t2: $TO"; exit 1; }
  grep -qx "title: \"Q${want#Q}: next\"" "$PQ"/*/"$(cc "$QO")"/index.md && grep -qx "title: \"T${want#Q}: next\"" "$PT"/*/"$(cc "$TO")"/index.md \
    || { echo "older board holding $t1 $t2 did not file number ${want#Q}:"; echo "$QO"; echo "$TO"; exit 1; }
done
ok "cite older-board padding: Q9 and Q010 on a v114 board file Q11 (not a second Q9), a Q08 files Q9, and tickets the same with T"
NQ="$T/Case Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$NQ" --model smoke >/dev/null; mkguide "$NQ" 117
NC="$T/Comment Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$NC" --model smoke >/dev/null; mkguide "$NC" 117
cardw "$(firstlane "$NQ")/$(uuidgen | tr A-Z a-z)" "lower" q7; cardw "$(firstlane "$NC")/$(uuidgen | tr A-Z a-z)" "commented" "Q15 # x"
NK="$T/Quoted Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$NK" --model smoke >/dev/null; mkguide "$NK" 117
cardw "$(firstlane "$NK")/$(uuidgen | tr A-Z a-z)" "quoted" '"q9" # c'
( . "$SK/lanework/scripts/lib.sh"
  [ "$(next_cite "$NQ" Q)" = Q8 ] && [ "$(next_cite "$NC" Q)" = Q16 ] && [ "$(next_cite "$NK" Q)" = Q10 ] || { echo "next_cite: lower-case q7 gives $(next_cite "$NQ" Q), 'Q15 # x' gives $(next_cite "$NC" Q), quoted "q9" # c gives $(next_cite "$NK" Q)"; exit 1; } )
ok "next_cite counts a hand-typed cite-as: q7, a cite-as: Q15 # x and a quoted \"q9\" # c with the trailing comment"
# a title holding the word CITEPENDING files fine on a gated board
printf 'Is sync free?\n\n## Options\n\n- A: free\n- B: paid\n\n## Recommended\n\nA. Simple.\n' > "$T/cq.md"; printf 'Where does the engine run?\n' > "$T/ct.md"
NP="$T/Pending Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$NP" --model smoke >/dev/null; mkguide "$NP" 117
NPP="$T/Pending Plan.lanework"; "$PS/found-plan-board.sh" "$NPP" --model smoke >/dev/null; mkguide "$NPP" 117
PQO=$("$SK/discovery/scripts/file-question.sh" "$NP" "Why is CITEPENDING left in a title" --round 1 --body "$T/cq.md" --model smoke 2>&1) || { echo "file-question.sh refused a CITEPENDING title: $PQO"; exit 1; }
PTO=$("$PS/file-ticket.sh" "$NPP" "CITEPENDING in a title" --type grilling --body "$T/ct.md" --model smoke 2>&1) || { echo "file-ticket.sh refused a CITEPENDING title: $PTO"; exit 1; }
grep -qx 'cite-as: Q1' "$NP"/*/"$(cc "$PQO")"/index.md && grep -qx 'cite-as: T1' "$NPP"/*/"$(cc "$PTO")"/index.md || { echo "CITEPENDING-titled cards not stamped Q1 and T1"; exit 1; }
ok "a question and a ticket whose title holds CITEPENDING are filed and stamped Q1 and T1 on a gated board"
# heal-descriptors: the v0.8.0 discovery Brief and Decisions bodies are replaced; an edited body is not
HB='The two standing references: the Topic card (scope) and the Discovery map card (every decision, by corner of the space). The agent rewrites the map at the close of each round, and a resuming session reads it first.'
HDN="One card per ADR or PDR, titled \`ADR:\` or \`PDR:\`, with \`Record\` and \`Status\` labels and line 1 linking its question. The agent files it from a question's ruling, before the question settles. Cards never leave; an overturned decision gets the \`superseded\` status and a dated comment linking its replacement."
setb() { local f; f=$(lane_file "$1" "$2"); sed -i '' '$d' "$f"; printf '%s\n' "$3" >> "$f"; }
HO="$T/HealOld Discovery.lanework"; "$SK/discovery/scripts/found-discovery-board.sh" "$HO" --model smoke >/dev/null; HE="$T/HealEdited Discovery.lanework"; cp -R "$HO" "$HE"
CURB=$(lane_body "$HO" Brief); CURD=$(lane_body "$HO" Decisions)
setb "$HO" Brief "$HB"; setb "$HO" Decisions "$HDN"; setb "$HE" Brief "${HB/rewrites/rewrites quietly}"; setb "$HE" Decisions "${HDN/Cards never leave/Cards stay}"
O=$("$SK/heal/scripts/heal-descriptors.py" "$HO"); { grep -q '^lane Brief: replace-body ' <<<"$O" && grep -q '^lane Decisions: replace-body ' <<<"$O"; } || { echo "old Brief and Decisions not replace-body:"; echo "$O"; exit 1; }
"$SK/heal/scripts/heal-descriptors.py" "$HO" --apply --model smoke >/dev/null
{ [ "$(lane_body "$HO" Brief)" = "$CURB" ] && [ "$(lane_body "$HO" Decisions)" = "$CURD" ]; } || { echo "old bodies not replaced by the current template"; exit 1; }
O=$("$SK/heal/scripts/heal-descriptors.py" "$HE"); if grep -q 'replace-body' <<<"$O"; then echo "an edited body was replaced:"; echo "$O"; exit 1; fi
"$SK/heal/scripts/heal-descriptors.py" "$HE" --apply --model smoke >/dev/null
{ grep -q 'rewrites quietly' "$(lane_file "$HE" Brief)" && grep -q 'Cards stay' "$(lane_file "$HE" Decisions)"; } || { echo "an edited body lost its own text"; exit 1; }
ok "heal-descriptors replaces the v0.8.0 discovery Brief and Decisions bodies word for word and keeps an edited body's own text"

# lanework: lease.sh. A copy of the pipeline board with the borrowed .schema; fake session ids; stand-in CLAUDE_PIDs (sleeps this
# smoke starts and kills); per-session memory under a TMPDIR of its own, never the real one; the test knobs keep it to seconds.
# Every timer started here is killed on exit, and case 13 checks none outlives the cases.
LS="$SK/lanework/scripts/lease.sh"; LT=$(mktemp -d "$T/lease-tmp.XXXXXX"); LSP=()
lease_cleanup() {
  local p; for p in ${LSP[@]+"${LSP[@]}"} "$PSP"; do kill "$p" 2>/dev/null || true; done
  pkill -f "$LS _timer" 2>/dev/null || true
  [ -z "${LB:-}" ] || chmod -R u+w "$LB" 2>/dev/null || true   # a case makes a comments folder read-only
}
trap lease_cleanup EXIT
standin() { sleep 600 </dev/null >/dev/null 2>&1 & SP=$!; disown "$SP"; LSP+=("$SP"); }
standin; LPID=$SP
# L <session> <args...>: lease.sh as that session, under the stand-in CLAUDE_PID (LPID) and the test knobs
L() { local s="$1"; shift; CLAUDE_CODE_SESSION_ID="$s" CLAUDE_PID="$LPID" TMPDIR="$LT" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_NOTICE_WAIT="${NW:-1.5}" \
  LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY="${RE:-1000}" "$LS" "$@"; }
LB="$T/Lease.lanework"; cp -R "$P" "$LB"; rm -rf "$LB/.schema"; cp -R "$VAL" "$LB/.schema"
printf '<!-- lanework-agent-guide v118 -->\n\nThis machine'"'"'s human answers to `@owner`.\n' > "$LB/CLAUDE.md"
LL=$(dirname "$(lane_of "$LB" Active)")
lcard() { local id; id=$(uuidgen | tr A-Z a-z); mkdir -p "$LL/$id"
  printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\norder: 1024\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\nBody line one.\n\nBody: two, with "quotes" and a trailing space. \n' "$1" > "$LL/$id/index.md"; echo "$id"; }
lcf() { ls "$LB"/*/"$1"/index.md; }
# cget <file> s|n|u: claimed's by.session, by.name or until, in whichever layout the compact form gave it (flow when it fits 120)
cget() { python3 - "$1" "$2" <<'PY'
import sys, yaml, datetime
d = yaml.safe_load(open(sys.argv[1]).read().split("---\n")[1]); c = d.get("claimed") or {}; b = c.get("by") or {}
v = {"s": b.get("session"), "n": b.get("name"), "u": c.get("until")}[sys.argv[2]]
if isinstance(v, datetime.datetime): v = v.strftime("%Y-%m-%dT%H:%M:%SZ")
print("" if v is None else v)
PY
}
csess() { cget "$1" s; }; cname() { cget "$1" n; }; cuntil() { cget "$1" u; }
epoch() { date -j -u -f %Y-%m-%dT%H:%M:%SZ "$1" +%s; }
iso() { date -u -r "$1" +%FT%TZ; }
setclaim() {  # setclaim <file> <session> <until> [name]: a claimed block as another session (or this one) left it
  local f="$1" s="$2" u="$3" n="${4:-claude}"
  perl -0pi -e 's/^claimed:.*\n(?:[ \t].*\n)*//m; s/\A(---\n.*?\n)(---\n)/$1claimed:\n  by: {name: '"$n"', kind: agent, model: smoke, session: "'"$s"'"}\n  until: '"$u"'\n$2/s' "$f"; }
bodyof() { awk 'f{print} /^---$/{n++; if(n==2) f=1}' "$1"; }
mem() { printf '%s' "$LT/lanework-lease/$1/$(printf '%s' "$(cd "$LB" && pwd -P)" | shasum | cut -c1-16)/$2"; }   # <session>/<board key>/<card>
mpid() { sed -n 's/^pid=//p' "$(mem "$1" "$2")"; }
alive() { kill -0 "$1" 2>/dev/null; }
records() { { grep -l -F -- "$2" "$(dirname "$(lcf "$1")")"/comments/*/index.md 2>/dev/null || true; } | grep -c . || true; }
# waitfor <condition> [seconds, default 20]: poll every 0.1 s until it holds, bounded by wall time (a count of polls stretches under load)
waitfor() { local wf_end=$((SECONDS + ${2:-20})); while :; do if eval "$1"; then return 0; fi; [ $SECONDS -lt $wf_end ] || return 1; sleep 0.1; done; }
# SID1: a session id of real length (a uuid): its by passes 120 characters, so claimed keeps the 3-line block form
SID1=$(uuidgen | tr A-Z a-z)
# a git repo to stake from: the loss record names its branch, directory and touched files
GR="$T/lease-repo"; mkdir -p "$GR"; git -C "$GR" init -q -b lease-br; printf 'wip\n' > "$GR/wip.txt"; GR=$(cd "$GR" && pwd -P)

# 1. stake
C1=$(lcard "One"); F1=$(lcf "$C1")
O=$(cd "$GR" && L "$SID1" stake "$LB" "$C1" --model smoke) || { echo "stake failed: $O"; exit 1; }
U=$(cuntil "$F1"); D=$(( $(epoch "$U") - $(date -u +%s) ))
[ "$(csess "$F1")" = $SID1 ] && [ "$D" -ge 1790 ] && [ "$D" -le 1801 ] || { echo "stake: session $(csess "$F1"), until $U ($D s ahead)"; cat "$F1"; exit 1; }
[ "$(grep -A2 '^claimed:$' "$F1" | sed -n '2p;3p' | grep -c -E '^  (by: \{name: claude, kind: agent, model: smoke, session: "'"$SID1"'"\}|until: [0-9TZ:-]+)$')" = 2 ] || { echo "claimed is not the 3-line block form:"; cat "$F1"; exit 1; }
grep -q '^modified: {at: [0-9TZ:-]*, by: {name: claude, kind: agent, model: smoke, session: "'"$SID1"'"}}$' "$F1" || { echo "stake did not restamp modified"; cat "$F1"; exit 1; }
validate "$LB" >/dev/null; HO=$(python3 "$LB/.schema/bin/lanework-heal.py" "$LB"); grep -q '^0 repairs' <<<"$HO" || { echo "heal dry run after stake: $HO"; exit 1; }
[ -f "$(mem $SID1 "$C1")" ] && alive "$(mpid $SID1 "$C1")" || { echo "stake: no memory file or no live timer"; exit 1; }
ok "lease: stake writes claimed with by.session and until 30 minutes ahead; the board validates and the heal dry run lists nothing"

# 2. no session id, no CLAUDE_PID, no model: exit 2, nothing written
C2=$(lcard "Two"); F2=$(lcf "$C2"); S2=$(shasum < "$F2")
RC=0; env -u CLAUDE_CODE_SESSION_ID CLAUDE_PID="$LPID" TMPDIR="$LT" "$LS" stake "$LB" "$C2" --model smoke 2>/dev/null || RC=$?; [ $RC = 2 ] || { echo "no session id: rc $RC"; exit 1; }
RC=0; env -u CLAUDE_PID CLAUDE_CODE_SESSION_ID=S-two TMPDIR="$LT" "$LS" stake "$LB" "$C2" --model smoke 2>/dev/null || RC=$?; [ $RC = 2 ] || { echo "no CLAUDE_PID: rc $RC"; exit 1; }
RC=0; env -u CLAUDE_MODEL CLAUDE_CODE_SESSION_ID=S-two CLAUDE_PID="$LPID" TMPDIR="$LT" "$LS" stake "$LB" "$C2" 2>/dev/null || RC=$?; [ $RC = 2 ] || { echo "no model: rc $RC"; exit 1; }
RC=0; L S-two stake "$LB" 00000000-0000-4000-8000-000000000000 --model smoke 2>/dev/null || RC=$?; [ $RC = 2 ] || { echo "no such card: rc $RC"; exit 1; }
[ "$S2" = "$(shasum < "$F2")" ] && [ ! -e "$LT/lanework-lease/S-two" ] || { echo "a refused stake wrote something"; exit 1; }
ok "lease: no session id or no CLAUDE_PID is exit 2 and writes nothing"

# 3. two racing stakes
C3=$(lcard "Three"); F3=$(lcf "$C3")
( RC=0; L S-race-a stake "$LB" "$C3" --model smoke >/dev/null 2>&1 || RC=$?; echo "$RC" > "$T/race-a" ) & RPA=$!
( RC=0; L S-race-b stake "$LB" "$C3" --model smoke >/dev/null 2>&1 || RC=$?; echo "$RC" > "$T/race-b" ) & RPB=$!
wait "$RPA" "$RPB"
RA=$(cat "$T/race-a"); RB=$(cat "$T/race-b"); WIN=$(csess "$F3")
{ [ "$RA$RB" = 01 ] && [ "$WIN" = S-race-a ]; } || { [ "$RA$RB" = 10 ] && [ "$WIN" = S-race-b ]; } || { echo "race: a=$RA b=$RB holder=$WIN"; exit 1; }
LOSER=S-race-a; [ "$WIN" = S-race-a ] && LOSER=S-race-b; [ ! -e "$(mem "$LOSER" "$C3")" ] || { echo "race: the loser kept a memory file"; exit 1; }
ok "lease: two racing stakes leave one holder"

# 3b. a stake held between its read and its write (LEASE_TEST_WRITE_PAUSE, a TMPDIR of its own) while another session's stake lands:
# the held stake writes only over the claimed it read, so it backs off: exit 1, nothing written, no memory, no timer
C3b=$(lcard "Three b"); F3b=$(lcf "$C3b"); LSA=$(mktemp -d "$T/lease-stake-a.XXXXXX")
( RC=0; CLAUDE_CODE_SESSION_ID=S-held CLAUDE_PID="$LPID" TMPDIR="$LSA" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 \
  LEASE_TEST_WRITE_PAUSE=1.5 "$LS" stake "$LB" "$C3b" --model smoke >/dev/null 2>"$T/s3b.err" || RC=$?; echo "$RC" > "$T/s3b.rc" ) & S3P=$!
waitfor '[ -n "$(ls "$LSA"/lease-write.*/read 2>/dev/null)" ]' || { echo "3b: the held stake never read the card"; exit 1; }
L S-first stake "$LB" "$C3b" --model smoke >/dev/null || { echo "3b: the stake landing during the pause failed"; exit 1; }
H3b=$(shasum < "$F3b"); wait "$S3P"
[ "$(cat "$T/s3b.rc")" = 1 ] && [ "$(csess "$F3b")" = S-first ] && [ "$H3b" = "$(shasum < "$F3b")" ] && grep -q 'staked by S-first meanwhile; backing off' "$T/s3b.err" \
  && [ ! -e "$LSA/lanework-lease/S-held" ] && [ -z "$(pgrep -f "$LS _timer $(cd "$LB" && pwd -P) $C3b S-held " || true)" ] \
  || { echo "3b: held stake rc $(cat "$T/s3b.rc"), holder $(csess "$F3b"), err: $(cat "$T/s3b.err")"; cat "$F3b"; exit 1; }
L S-first release "$LB" "$C3b" --model smoke >/dev/null
ok "lease: a stake held through another session's stake backs off (exit 1), writes nothing over it, and keeps no memory or timer"

# 3c. a release held between its read and its write while claimed changes: it clears only its holder's claim.
# LRP <tmpdir> <session> <args...>: lease.sh in the background under the pause, rc to $T/lrp.rc, stdout and stderr to lrp.out/lrp.err
LRP() { local d="$1" s="$2"; shift 2; ( RC=0; CLAUDE_CODE_SESSION_ID="$s" CLAUDE_PID="$LPID" TMPDIR="$d" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_POLL=0.2 \
  LEASE_TEST_RENEW_EVERY=1000 LEASE_TEST_WRITE_PAUSE=1.5 "$LS" "$@" --model smoke >"$T/lrp.out" 2>"$T/lrp.err" || RC=$?; echo "$RC" > "$T/lrp.rc" ) & LRPP=$!
  PD="$d"; waitfor '[ -n "$(ls "$PD"/lease-write.*/read 2>/dev/null)" ]'; }
# own release, another session's claim set during the pause: exit 1, nothing released, the memory kept; check then finds the loss once
LRA=$(mktemp -d "$T/lease-rel-a.XXXXXX"); C3c=$(lcard "Three c"); F3c=$(lcf "$C3c")
CLAUDE_CODE_SESSION_ID=S-rel CLAUDE_PID="$LPID" TMPDIR="$LRA" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 "$LS" stake "$LB" "$C3c" --model smoke >/dev/null
LRP "$LRA" S-rel release "$LB" "$C3c" || { echo "3c: the release never read the card"; exit 1; }
setclaim "$F3c" S-other "$(iso $(( $(date -u +%s) + 1500 )))"; wait "$LRPP"
[ "$(cat "$T/lrp.rc")" = 1 ] && grep -q 'held by S-other meanwhile; nothing released' "$T/lrp.err" && [ "$(csess "$F3c")" = S-other ] \
  && [ -n "$(ls "$LRA"/lanework-lease/S-rel/*/"$C3c" 2>/dev/null)" ] || { echo "3c: own release rc $(cat "$T/lrp.rc"), holder $(csess "$F3c"), err: $(cat "$T/lrp.err")"; cat "$F3c"; exit 1; }
RC=0; CO=$(CLAUDE_CODE_SESSION_ID=S-rel CLAUDE_PID="$LPID" TMPDIR="$LRA" "$LS" check "$LB" "$C3c" --model smoke 2>/dev/null) || RC=$?
[ "$CO$RC" = lost3 ] && [ "$(records "$C3c" "**Lease lost**")" = 1 ] || { echo "3c: check after the refused release: '$CO' $RC, records $(records "$C3c" "**Lease lost**")"; exit 1; }
# --force, the holder changed during the pause: exit 1, the new holder kept, no force record
C3f=$(lcard "Three f"); F3f=$(lcf "$C3f"); L S-hold stake "$LB" "$C3f" --model smoke >/dev/null; LRF=$(mktemp -d "$T/lease-rel-f.XXXXXX")
LRP "$LRF" S-owner release "$LB" "$C3f" --force || { echo "3c: the forced release never read the card"; exit 1; }
setclaim "$F3f" S-third "$(iso $(( $(date -u +%s) + 1500 )))"; wait "$LRPP"
[ "$(cat "$T/lrp.rc")" = 1 ] && [ "$(csess "$F3f")" = S-third ] && [ "$(records "$C3f" "**Lease released by force**")" = 0 ] \
  || { echo "3c: forced release over a new holder: rc $(cat "$T/lrp.rc"), holder $(csess "$F3f"), force records $(records "$C3f" "**Lease released by force**")"; exit 1; }
# --force, the holder released during the pause: exit 0, already released, no force record
C3r=$(lcard "Three r"); F3r=$(lcf "$C3r"); L S-hold stake "$LB" "$C3r" --model smoke >/dev/null; LRG=$(mktemp -d "$T/lease-rel-g.XXXXXX")
LRP "$LRG" S-owner release "$LB" "$C3r" --force || { echo "3c: the forced release never read the second card"; exit 1; }
perl -0pi -e 's/^claimed:.*\n(?:[ \t].*\n)*//m' "$F3r"; wait "$LRPP"
[ "$(cat "$T/lrp.rc")" = 0 ] && grep -q 'was already released; nothing released by force' "$T/lrp.out" && ! grep -q '^claimed:' "$F3r" \
  && [ "$(records "$C3r" "**Lease released by force**")" = 0 ] || { echo "3c: forced release of a released card: rc $(cat "$T/lrp.rc"), out: $(cat "$T/lrp.out"), force records $(records "$C3r" "**Lease released by force**")"; exit 1; }
validate "$LB" >/dev/null
ok "lease: a release held while claimed changes clears only its holder's claim: own release over another session exits 1 and the next check records the loss once; --force over a new holder exits 1 with no record; --force on a card released meanwhile exits 0 with no record"

# 4. another session's live lease is refused
HS1=$(shasum < "$F1"); RC=0; L S-four stake "$LB" "$C1" --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 1 ] && [ "$HS1" = "$(shasum < "$F1")" ] || { echo "stake over a live lease: rc $RC"; exit 1; }
ok "lease: stake over another session's live lease is refused"

# 5. renew: until forward, modified restamped, the body byte for byte
C5=$(lcard "Five"); F5=$(lcf "$C5"); L S-five stake "$LB" "$C5" --model smoke >/dev/null
setclaim "$F5" S-five "$(iso $(( $(date -u +%s) + 600 )))"; U0=$(cuntil "$F5"); B0=$(bodyof "$F5" | shasum)
perl -pi -e 's/^modified: .*$/modified: {at: 2026-01-02T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}/' "$F5"
L S-five renew "$LB" "$C5" --model smoke >/dev/null
[ "$(epoch "$(cuntil "$F5")")" -gt "$(epoch "$U0")" ] && [ "$B0" = "$(bodyof "$F5" | shasum)" ] \
  && grep -q '^modified: {at: 2026-1[1-9]-.*session: "S-five"}}$' "$F5" || { echo "renew:"; cat "$F5"; exit 1; }
ok "lease: renew moves until forward and restamps modified, and leaves the body byte for byte"

# 5b. a body holding a triple brace (a JSON example) is no broken stamp: stake, renew, check (a lapsed own lease), release all write
C5b=$(lcard "Five b"); F5b=$(lcf "$C5b"); printf '\n```json\n{"a": {"b": {"c": 1}}}\n```\n' >> "$F5b"; B0=$(bodyof "$F5b" | shasum)
RC=0; L S-brace stake "$LB" "$C5b" --model smoke >/dev/null 2>&1 || RC=$?; RC2=0; L S-brace renew "$LB" "$C5b" --model smoke >/dev/null 2>&1 || RC2=$?
[ "$RC$RC2" = 00 ] && [ "$(csess "$F5b")" = S-brace ] || { echo "}}} in the body: stake rc $RC, renew rc $RC2"; exit 1; }
setclaim "$F5b" S-brace "$(iso $(( $(date -u +%s) - 60 )))"; RC=0; CO=$(L S-brace check "$LB" "$C5b" --model smoke 2>/dev/null) || RC=$?
[ "$CO$RC" = held0 ] && [ "$(epoch "$(cuntil "$F5b")")" -gt "$(date -u +%s)" ] || { echo "}}} in the body: check '$CO' rc $RC"; exit 1; }
RC=0; L S-brace release "$LB" "$C5b" --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 0 ] && ! grep -q '^claimed:' "$F5b" && [ "$B0" = "$(bodyof "$F5b" | shasum)" ] || { echo "}}} in the body: release rc $RC"; cat "$F5b"; exit 1; }
validate "$LB" >/dev/null; ok "lease: a card with }}} in its body is staked, renewed, checked and released, the body byte for byte"
# 5b2. stamp values: lease.sh quotes --name and --model by lib.sh by_of; a value it cannot carry is refused with nothing written. A session id with a quote, brace or backslash is refused (the id is also a directory name)
for sv in '{n}' 'a"b' 'a\' 'a\"}}}' 'x: y' '#x'; do for k in name model session; do
  C5s=$(lcard "Five s"); F5s=$(lcf "$C5s"); cp "$F5s" "$T/5s.before"; SS=S-sv; F5a=(--model smoke); AA=()
  case $k in model) F5a=(--model "$sv") ;; name) F5a+=(--name "$sv") ;; session) SS="$sv" ;; esac
  RC=0; L "$SS" stake "$LB" "$C5s" "${F5a[@]}" >/dev/null 2>&1 || RC=$?
  if [ $RC -eq 0 ]; then validate "$LB" >/dev/null && [ "$(csess "$F5s")" = "$SS" ] || { echo "lease stake $k=$sv: exit 0, board or claimed wrong"; cat "$F5s"; exit 1; }; L "$SS" release "$LB" "$C5s" "${F5a[@]}" >/dev/null 2>&1 || true
  else cmp -s "$F5s" "$T/5s.before" || { echo "lease stake $k=$sv: exit $RC and the card changed"; exit 1; }; fi
done; done
RC=0; L S-sv stake "$LB" "$(lcard "Five n")" --model smoke --name "$(printf 'a\nb')" >/dev/null 2>&1 || RC=$?; [ $RC = 2 ] || { echo "lease stake with a newline name: exit $RC, want 2"; exit 1; }
ok "lease: {n}, a\"b, a\, a\\\"}}}, 'x: y' and #x as --name or --model stake a valid card or are refused untouched; as a session id they are refused untouched; a newline name exits 2"

# 5c. a label whose kind carries an icon ends its line in }}}: valid front matter, copied as read. The guard reads only the lines lease.sh writes
grep -q -F '{type: priority, text: Priority, icon: {glyph: flag}' "$SK/lanework/templates/label-kinds.md" && grep -q -F '{text: Medium, rank: 2}' "$SK/lanework/templates/label-kinds.md" || { echo "label-kinds.md: the iconed priority kind moved"; exit 1; }
# the line as the app and the scripts write it on real boards (compact, quoted): 102 characters, ending in }}}
C5c=$(lcard "Five c"); F5c=$(lcf "$C5c"); LBL='labels: [{text: "Medium", rank: 2, kind: {type: "priority", text: "Priority", icon: {glyph: "flag"}}}]'
perl -pi -e 's/^(order: .*)$/$1\n'"$LBL"'/' "$F5c"; grep -qxF "$LBL" "$F5c" && validate "$LB" >/dev/null || { echo "fixture: iconed label"; exit 1; }
RC=0; L S-icon stake "$LB" "$C5c" --model smoke >/dev/null 2>&1 || RC=$?; RC2=0; L S-icon renew "$LB" "$C5c" --model smoke >/dev/null 2>&1 || RC2=$?
setclaim "$F5c" S-icon "$(iso $(( $(date -u +%s) - 60 )))"; RC3=0; CO=$(L S-icon check "$LB" "$C5c" --model smoke 2>/dev/null) || RC3=$?
[ "$RC$RC2$RC3$CO" = 000held ] && [ "$(epoch "$(cuntil "$F5c")")" -gt "$(date -u +%s)" ] && grep -qxF "$LBL" "$F5c" || { echo "iconed label: stake $RC, renew $RC2, check $RC3 '$CO'"; cat "$F5c"; exit 1; }
RC=0; L S-icon release "$LB" "$C5c" --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 0 ] && ! grep -q '^claimed:' "$F5c" && grep -qxF "$LBL" "$F5c" && validate "$LB" >/dev/null || { echo "iconed label: release rc $RC"; cat "$F5c"; exit 1; }
# control: a model ending in }}} is quoted by by_of, so the stamp lease.sh writes is valid; the stake lands and the board validates
C5d=$(lcard "Five d"); F5d=$(lcf "$C5d"); RC=0; L S-icon stake "$LB" "$C5d" --model 'x}}}' >/dev/null 2>&1 || RC=$?
[ $RC = 0 ] && grep -qF 'model: "x}}}"' "$F5d" && validate "$LB" >/dev/null || { echo "a model ending in }}} was not quoted or not staked: rc $RC"; cat "$F5d"; exit 1; }
L S-icon release "$LB" "$C5d" --model smoke >/dev/null 2>&1 || true
ok "lease: a card whose iconed label ends in }}} is staked, renewed, checked and released and validates; a model ending in }}} is written quoted and validates"

# 6. a changed by: the timer finds the loss and posts one record; then no further write
TP=$(mpid $SID1 "$C1"); setclaim "$F1" S-other "$(iso $(( $(date -u +%s) + 1500 )))"
waitfor '[ "$(records "$C1" "**Lease lost**")" = 1 ]' || { echo "no Lease lost record within 20 s"; exit 1; }
waitfor '! alive "$TP"' || { echo "the timer outlived the loss"; exit 1; }
R=$(grep -l -F '**Lease lost**' "$(dirname "$F1")"/comments/*/index.md)
for w in "session $SID1 no longer holds this card; session S-other does" "branch lease-br" "directory $GR" "wip.txt" "This session writes this card no more."; do
  grep -q -F -- "$w" "$R" || { echo "Lease lost record lacks '$w':"; cat "$R"; exit 1; }; done
grep -q "session: \"$SID1\"" "$R" && validate "$LB" >/dev/null || { echo "loss record not signed by the loser, or the board fails"; exit 1; }
HS1=$(shasum < "$F1"); RC=0; L "$SID1" renew "$LB" "$C1" --model smoke >/dev/null 2>&1 || RC=$?
RC2=0; CO=$(L "$SID1" check "$LB" "$C1" --model smoke 2>/dev/null) || RC2=$?
[ $RC = 3 ] && [ $RC2 = 3 ] && [ "$CO" = lost ] && [ "$HS1" = "$(shasum < "$F1")" ] && [ "$(records "$C1" "**Lease lost**")" = 1 ] \
  || { echo "after the loss: renew rc $RC, check rc $RC2 '$CO', records $(records "$C1" "**Lease lost**")"; exit 1; }
C6g=$(lcard "Six gone"); F6g=$(lcf "$C6g"); L S-six stake "$LB" "$C6g" --model smoke >/dev/null; TP=$(mpid S-six "$C6g")
perl -0pi -e 's/^claimed:.*\n(?:[ \t].*\n)*//m' "$F6g"; waitfor '! alive "$TP"' || { echo "the timer outlived a removed claimed"; exit 1; }
H6=$(shasum < "$F6g"); RC=0; L S-six stake "$LB" "$C6g" --model smoke >/dev/null 2>&1 || RC=$?; RC2=0; CO=$(L S-six check "$LB" "$C6g" --model smoke 2>/dev/null) || RC2=$?
[ "$RC$RC2$CO" = 33lost ] && [ "$H6" = "$(shasum < "$F6g")" ] && [ "$(records "$C6g" "**Lease lost**")" = 1 ] \
  || { echo "stake on a remembered card with claimed gone: stake rc $RC, check rc $RC2 '$CO', records $(records "$C6g" "**Lease lost**")"; cat "$F6g"; exit 1; }
# staking a remembered card now held by another session, live or lapsed: the loss, no takeover notice (its timer stopped first, so stake finds it)
for u in 1500 -60; do
  C6o=$(lcard "Six other $u"); F6o=$(lcf "$C6o"); L S-sixo stake "$LB" "$C6o" --model smoke >/dev/null; TP=$(mpid S-sixo "$C6o"); kill "$TP"; waitfor '! alive "$TP"'
  setclaim "$F6o" S-other "$(iso $(( $(date -u +%s) + u )))"; H6=$(shasum < "$F6o"); RC=0; L S-sixo stake "$LB" "$C6o" --model smoke >/dev/null 2>&1 || RC=$?
  [ $RC = 3 ] && [ "$H6" = "$(shasum < "$F6o")" ] && [ "$(records "$C6o" "**Lease lost**")" = 1 ] && [ "$(records "$C6o" "**Takeover notice**")" = 0 ] \
    && grep -q -F "session S-other does" "$(grep -l -F '**Lease lost**' "$(dirname "$F6o")"/comments/*/index.md)" \
    || { echo "stake on a remembered card held by another (until now$u s): rc $RC, lost $(records "$C6o" "**Lease lost**"), notices $(records "$C6o" "**Takeover notice**")"; exit 1; }
done
ok "lease: a changed by yields one Lease lost record naming branch, directory and files, and no further write; staking a remembered card whose claimed is gone, or held by another, live or lapsed, is the same loss"

# 6b. the timer and six concurrent checks find one loss: exactly one record
C6r=$(lcard "Six race"); F6r=$(lcf "$C6r"); L S-sixr stake "$LB" "$C6r" --model smoke >/dev/null; TP=$(mpid S-sixr "$C6r")
setclaim "$F6r" S-other "$(iso $(( $(date -u +%s) + 1500 )))"; RPS=()
for i in 1 2 3 4 5 6; do L S-sixr check "$LB" "$C6r" --model smoke >/dev/null 2>&1 & RPS+=("$!"); done
wait "${RPS[@]}" || true; waitfor '! alive "$TP"' || { echo "the timer outlived the raced loss"; exit 1; }
[ "$(records "$C6r" "**Lease lost**")" = 1 ] || { echo "timer and six checks: $(records "$C6r" "**Lease lost**") loss records, want 1"; exit 1; }
ok "lease: the timer and six concurrent checks racing on one loss post exactly one Lease lost record"

# 6c. a loss record that cannot land (a read-only comments folder) leaves the loss unmarked; once writable, the next check posts it once
C6w=$(lcard "Six ro"); F6w=$(lcf "$C6w"); L S-sixw stake "$LB" "$C6w" --model smoke >/dev/null; TP=$(mpid S-sixw "$C6w"); kill "$TP"; waitfor '! alive "$TP"'
mkdir -p "$(dirname "$F6w")/comments"; chmod 555 "$(dirname "$F6w")/comments"; setclaim "$F6w" S-other "$(iso $(( $(date -u +%s) + 1500 )))"
RC=0; CO=$(L S-sixw check "$LB" "$C6w" --model smoke 2>/dev/null) || RC=$?
[ "$CO$RC" = lost3 ] && [ "$(records "$C6w" "**Lease lost**")" = 0 ] && [ ! -d "$(mem S-sixw "$C6w").lost" ] || { echo "unlanded loss record: '$CO' $RC, marked: $([ -d "$(mem S-sixw "$C6w").lost" ] && echo yes || echo no)"; chmod 755 "$(dirname "$F6w")/comments"; exit 1; }
chmod 755 "$(dirname "$F6w")/comments"; RC=0; CO=$(L S-sixw check "$LB" "$C6w" --model smoke 2>/dev/null) || RC=$?; RC2=0; L S-sixw check "$LB" "$C6w" --model smoke >/dev/null 2>&1 || RC2=$?
[ "$CO$RC$RC2" = lost33 ] && [ "$(records "$C6w" "**Lease lost**")" = 1 ] && [ -d "$(mem S-sixw "$C6w").lost" ] || { echo "after chmod back: '$CO' $RC $RC2, records $(records "$C6w" "**Lease lost**")"; exit 1; }
ok "lease: a loss record that fails to land is not marked; the next check posts exactly one"

# 7. clock guard: an until over 35 minutes ahead is no lease
C7=$(lcard "Seven"); F7=$(lcf "$C7"); setclaim "$F7" S-skew "$(iso $(( $(date -u +%s) + 3600 )))"
L S-seven stake "$LB" "$C7" --model smoke >/dev/null || { echo "stake over a skewed lease was refused"; exit 1; }
[ "$(csess "$F7")" = S-seven ] && [ "$(records "$C7" "**Lease ignored**")" = 1 ] || { echo "clock guard: holder $(csess "$F7")"; exit 1; }
C7b=$(lcard "Seven b"); F7b=$(lcf "$C7b"); setclaim "$F7b" S-skew "$(iso $(( $(date -u +%s) + 2000 )))"; RC=0
L S-seven stake "$LB" "$C7b" --model smoke >/dev/null 2>&1 || RC=$?; [ $RC = 1 ] || { echo "an until 33 minutes ahead must still hold: rc $RC"; exit 1; }
C7c=$(lcard "Seven c"); F7c=$(lcf "$C7c"); setclaim "$F7c" S-skew X; perl -ni -e 'print unless /^  until: X$/' "$F7c"; [ -z "$(cuntil "$F7c")" ] && [ "$(csess "$F7c")" = S-skew ] || { echo "fixture: no until"; exit 1; }
L S-seven stake "$LB" "$C7c" --model smoke >/dev/null || { echo "stake over a claimed with no until was refused"; exit 1; }
[ "$(csess "$F7c")" = S-seven ] && [ "$(records "$C7c" "**Lease ignored**: until none was")" = 1 ] || { echo "no until: holder $(csess "$F7c"), ignored records $(records "$C7c" "**Lease ignored**")"; exit 1; }
ok "lease: an until over 35 minutes ahead, or none, is no lease; stake posts Lease ignored"

# 8. takeover: a live holder answers the notice and the taker backs off; an unanswered notice is taken over
C8=$(lcard "Eight"); F8=$(lcf "$C8"); L S-holder stake "$LB" "$C8" --model smoke >/dev/null
setclaim "$F8" S-holder "$(iso $(( $(date -u +%s) - 60 )))"; sleep 1
RC=0; NW=2 L S-taker stake "$LB" "$C8" --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 1 ] && [ "$(csess "$F8")" = S-holder ] && [ "$(epoch "$(cuntil "$F8")")" -gt "$(date -u +%s)" ] && [ "$(records "$C8" "**Takeover notice**")" = 1 ] \
  || { echo "takeover vs live holder: rc $RC, holder $(csess "$F8")"; cat "$F8"; exit 1; }
grep -q -F "session S-taker takes this card from session S-holder" "$(grep -l -F '**Takeover notice**' "$(dirname "$F8")"/comments/*/index.md)" || { echo "notice wording"; exit 1; }
C8b=$(lcard "Eight b"); F8b=$(lcf "$C8b"); setclaim "$F8b" S-dead "$(iso $(( $(date -u +%s) - 60 )))"
mkdir -p "$(dirname "$F8b")/comments/c0000000-0000-4000-8000-0000000000aa"
printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: claude, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: claude, kind: agent, model: smoke}}\n---\n**START: the dead holder began here.**\n\n- plan\n' > "$(dirname "$F8b")/comments/c0000000-0000-4000-8000-0000000000aa/index.md"
t0=$(date +%s); O=$(L S-taker stake "$LB" "$C8b" --model smoke) || { echo "takeover of a dead lease refused"; exit 1; }
[ "$(csess "$F8b")" = S-taker ] && [ "$(( $(date +%s) - t0 ))" -ge 1 ] && grep -q -F '**START: the dead holder began here.**' <<<"$O" && [ "$(records "$C8b" "**Takeover notice**")" = 1 ] \
  || { echo "takeover: holder $(csess "$F8b"), output: $O"; exit 1; }
validate "$LB" >/dev/null; ok "lease: takeover posts the notice and waits; the holder renewing makes the taker back off; no change makes it stake"

# 9. check: held, lost, never-held
C9=$(lcard "Nine"); F9=$(lcf "$C9"); L S-nine stake "$LB" "$C9" --model smoke >/dev/null
[ "$(L S-nine check "$LB" "$C9" --model smoke)" = held ] || { echo "check: not held"; exit 1; }
setclaim "$F9" S-nine "$(cuntil "$F9")" fixer; [ "$(cname "$F9")" = fixer ] && [ "$(L S-nine check "$LB" "$C9" --model smoke)" = held ] || { echo "check compared by.name"; exit 1; }
TP=$(mpid S-nine "$C9"); kill "$TP"; waitfor '! alive "$TP"'; setclaim "$F9" S-nine "$(iso $(( $(date -u +%s) - 60 )))"
[ "$(L S-nine check "$LB" "$C9" --model smoke)" = held ] && [ "$(epoch "$(cuntil "$F9")")" -gt "$(( $(date -u +%s) + 1700 ))" ] \
  && TQ=$(mpid S-nine "$C9") && [ "$TQ" != "$TP" ] && alive "$TQ" || { echo "check: lapsed own lease not renewed or timer not restarted"; cat "$F9"; exit 1; }
S9=$(shasum < "$F9"); RC=0; CO=$(L S-stranger check "$LB" "$C9" --model smoke) || RC=$?
C9f=$(lcard "Nine free"); F9f=$(lcf "$C9f"); S9f=$(shasum < "$F9f"); RC2=0; CO2=$(L S-stranger check "$LB" "$C9f" --model smoke) || RC2=$?
[ "$CO$RC$CO2$RC2" = never-held4never-held4 ] && [ "$S9" = "$(shasum < "$F9")" ] && [ "$S9f" = "$(shasum < "$F9f")" ] \
  && [ "$(records "$C9" Lease)" = 0 ] && [ ! -e "$LT/lanework-lease/S-stranger" ] || { echo "check never-held: '$CO' $RC, '$CO2' $RC2"; exit 1; }
C9g=$(lcard "Nine gone"); F9g=$(lcf "$C9g"); L S-nine stake "$LB" "$C9g" --model smoke >/dev/null; TP=$(mpid S-nine "$C9g"); kill "$TP"; waitfor '! alive "$TP"'
perl -0pi -e 's/^claimed:.*\n(?:[ \t].*\n)*//m' "$F9g"
RC=0; CO=$(L S-nine check "$LB" "$C9g" --model smoke) || RC=$?; RC2=0; CO2=$(L S-nine check "$LB" "$C9g" --model smoke) || RC2=$?
[ "$CO$RC$CO2$RC2" = lost3lost3 ] && [ "$(records "$C9g" "**Lease lost**")" = 1 ] || { echo "check lost (claimed gone): '$CO' $RC, '$CO2' $RC2"; exit 1; }
validate "$LB" >/dev/null
ok "lease: check prints held, lost or never-held; renews a lapsed lease of its own and restarts a dead timer; compares the session id, not by.name; and writes nothing for a card this session never staked, free or held by another"

# 9b. the loss record's prefix is lib.sh's constant
LLP=$(. "$SK/lanework/scripts/lib.sh"; printf '%s' "${LEASE_LOST_PREFIX:-}"); [ "$LLP" = '**Lease lost**:' ] || { echo "LEASE_LOST_PREFIX: '$LLP'"; exit 1; }
for c in "$C1" "$C9g"; do R=$(grep -l -F 'Lease lost' "$(dirname "$(lcf "$c")")"/comments/*/index.md); bodyof "$R" | head -1 | grep -q -F -- "$LLP" || { echo "loss record does not open with the prefix"; cat "$R"; exit 1; }; done
ok "lease: the loss record opens with LEASE_LOST_PREFIX"

# 9c. three leases at once
CA=$(lcard "A"); CB=$(lcard "B"); CC=$(lcard "C"); for c in "$CA" "$CB" "$CC"; do L S-multi stake "$LB" "$c" --model smoke >/dev/null; done
PA=$(mpid S-multi "$CA"); PB=$(mpid S-multi "$CB"); PC=$(mpid S-multi "$CC")
[ "$(ls "$(dirname "$(mem S-multi "$CA")")" | grep -c -E '^[0-9a-f-]{36}$')" = 3 ] && alive "$PA" && alive "$PB" && alive "$PC" && [ "$PA" != "$PB" ] && [ "$PB" != "$PC" ] || { echo "three leases: files or timers"; exit 1; }
# a stale pid in B's memory that is now A's timer: release must stop only a timer of B's own board and card
perl -pi -e "s/^pid=.*/pid=$PA/" "$(mem S-multi "$CB")"
L S-multi release "$LB" "$CB" --model smoke >/dev/null; waitfor '! alive "$PB"' || { echo "release left B's timer"; exit 1; }
alive "$PA" || { echo "releasing B stopped A's timer through a stale pid"; exit 1; }
[ "$(L S-multi check "$LB" "$CA" --model smoke)$(L S-multi check "$LB" "$CC" --model smoke)" = heldheld ] && [ -z "$(csess "$(lcf "$CB")")" ] && alive "$PA" && alive "$PC" \
  || { echo "releasing one of three disturbed the others"; exit 1; }
ok "lease: one session holds three leases at once: three files, three timers, and releasing one leaves the other two held, even through a stale pid"

# 10. release
C10=$(lcard "Ten"); F10=$(lcf "$C10"); L S-ten stake "$LB" "$C10" --model smoke >/dev/null; TP=$(mpid S-ten "$C10")
L S-ten release "$LB" "$C10" --model smoke >/dev/null
[ -z "$(csess "$F10")" ] && ! grep -q '^claimed:' "$F10" && waitfor '! alive "$TP"' && [ ! -e "$(mem S-ten "$C10")" ] && grep -q '^modified: .*session: "S-ten"}}$' "$F10" \
  || { echo "release:"; cat "$F10"; exit 1; }
S10=$(shasum < "$F10"); O=$(L S-ten release "$LB" "$C10" --model smoke) && [ -z "$O" ] && [ "$S10" = "$(shasum < "$F10")" ] || { echo "release of no lease: '$O'"; exit 1; }
C10b=$(lcard "Ten b"); F10b=$(lcf "$C10b"); L S-ten stake "$LB" "$C10b" --model smoke >/dev/null; TP=$(mpid S-ten "$C10b"); S10=$(shasum < "$F10b")
RC=0; L S-owner release "$LB" "$C10b" --model smoke >/dev/null 2>&1 || RC=$?; [ $RC = 1 ] && [ "$S10" = "$(shasum < "$F10b")" ] || { echo "release of another's lease: rc $RC"; exit 1; }
L S-owner release "$LB" "$C10b" --model smoke --force >/dev/null
R=$(grep -l -F '**Lease released by force**' "$(dirname "$F10b")"/comments/*/index.md)
! grep -q '^claimed:' "$F10b" && grep -q -F "session S-ten held it until" "$R" && waitfor '! alive "$TP"' || { echo "forced release"; exit 1; }
validate "$LB" >/dev/null; ok "lease: release removes claimed and stops the timer; another session's release is refused; --force releases and records it"

# 11. the timer: renews by elapsed time, answers a notice within one poll, exits with CLAUDE_PID or the lease
C11=$(lcard "Eleven"); F11=$(lcf "$C11"); RE=5 L S-eleven stake "$LB" "$C11" --model smoke >/dev/null; U0=$(cuntil "$F11")
waitfor '[ "$(cuntil "$F11")" != "$U0" ]' || { echo "the timer did not renew after 5 polls"; exit 1; }
C11n=$(lcard "Eleven n"); F11n=$(lcf "$C11n"); L S-eleven stake "$LB" "$C11n" --model smoke >/dev/null; sleep 1.1; U0=$(cuntil "$F11n")
NI=$(uuidgen | tr A-Z a-z); mkdir -p "$(dirname "$F11n")/comments/$NI"; NA=$(date -u +%FT%TZ)
printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: %s, by: {name: claude, kind: agent, model: smoke, session: "S-x"}}\nmodified: {at: %s, by: {name: claude, kind: agent, model: smoke, session: "S-x"}}\n---\n**Takeover notice**: session S-x takes this card from session S-eleven at %s unless the lease is renewed first. It lapsed at %s.\n' "$NA" "$NA" "$NA" "$U0" > "$(dirname "$F11n")/comments/$NI/index.md"
t0=$(date +%s); waitfor '[ "$(cuntil "$F11n")" != "$U0" ]' || { echo "the timer did not answer the notice"; exit 1; }
standin; P11=$SP; C11p=$(lcard "Eleven p"); LPID=$P11 L S-eleven stake "$LB" "$C11p" --model smoke >/dev/null; TP=$(mpid S-eleven "$C11p")
alive "$TP" && kill "$P11" && waitfor '! alive "$TP"' || { echo "the timer outlived its CLAUDE_PID"; exit 1; }
ok "lease: the timer renews by elapsed time, answers a notice within one poll, and exits when its CLAUDE_PID is gone or the lease is lost"

# 11b. a renewal held between its read and its compare (LEASE_TEST_WRITE_PAUSE) while another write lands in place: it lands only
# on the card as it read it, else reads again. LWP <tmpdir> <session>: renewing at every poll, under a TMPDIR of each half's own, so
# the paused renewal's stage is the only one there; inpause waits for its read copy (lease-write.*/read), the pause follows it
LWP() { local d="$1" s="$2"; shift 2; CLAUDE_CODE_SESSION_ID="$s" CLAUDE_PID="$LPID" TMPDIR="$d" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_POLL=0.2 \
  LEASE_TEST_RENEW_EVERY=1 LEASE_TEST_WRITE_PAUSE=1 "$@"; }
inpause() { PD="$1"; waitfor '[ -n "$(ls "$PD"/lease-write.*/read 2>/dev/null)" ]'; }
ppid_of() { sed -n 's/^pid=//p' "$1/lanework-lease/$2/$(printf '%s' "$(cd "$LB" && pwd -P)" | shasum | cut -c1-16)/$3"; }
# inplace <file>: another script's write, staged and renamed over the card, no folder move: waiting dropped, order to the top (-5)
inplace() { perl -ne 'print unless /^waiting:/' "$1" | perl -pe 's/^order: .*$/order: -5/' > "$1.w" && mv "$1.w" "$1"; }
LPA=$(mktemp -d "$T/lease-pause-a.XXXXXX"); C11w=$(lcard "Eleven w"); F11w=$(lcf "$C11w")
perl -pi -e 's/^(order: .*)$/order: 999\nwaiting: {for: owner, since: 2026-01-01T00:00:00Z, comment: 00000000-0000-4000-8000-000000000000}/' "$F11w"
LWP "$LPA" S-pause "$LS" stake "$LB" "$C11w" --model smoke >/dev/null; inpause "$LPA" || { echo "11b: no renewal began"; exit 1; }
U0=$(cuntil "$F11w"); inplace "$F11w"
waitfor '[ "$(cuntil "$F11w")" != "$U0" ]' || { echo "11b: the held renewal never landed"; exit 1; }
! grep -q '^waiting:' "$F11w" && grep -q '^order: -5$' "$F11w" && [ "$(csess "$F11w")" = S-pause ] || { echo "11b: a renewal undid an in-place write:"; cat "$F11w"; exit 1; }
LWP "$LPA" S-pause "$LS" release "$LB" "$C11w" --model smoke >/dev/null
# the same pause, claimed changed to another session during it: the renewal writes nothing; the next poll posts one loss record
LPB=$(mktemp -d "$T/lease-pause-b.XXXXXX"); C11x=$(lcard "Eleven x"); F11x=$(lcf "$C11x")
LWP "$LPB" S-pausex "$LS" stake "$LB" "$C11x" --model smoke >/dev/null; TP=$(ppid_of "$LPB" S-pausex "$C11x")
inpause "$LPB" || { echo "11b: no renewal began on the second card"; exit 1; }
setclaim "$F11x" S-other "$(iso $(( $(date -u +%s) + 1500 )))"; H11x=$(shasum < "$F11x")
waitfor '! alive "$TP"' || { echo "11b: the timer outlived the changed claimed"; exit 1; }
[ "$H11x" = "$(shasum < "$F11x")" ] && [ "$(csess "$F11x")" = S-other ] && [ "$(records "$C11x" "**Lease lost**")" = 1 ] \
  || { echo "11b: a renewal over another session's claimed: records $(records "$C11x" "**Lease lost**")"; cat "$F11x"; exit 1; }
validate "$LB" >/dev/null
ok "lease: a renewal held through another script's in-place write keeps that write (no waiting, the new order); over another session's claimed it writes nothing and the next poll posts one Lease lost record"

# 11c. a memory file holding pid= empty (the timer started, its id not saved yet): the timer waits for its id, alive two polls later
C11e=$(lcard "Eleven e"); L S-epid stake "$LB" "$C11e" --model smoke >/dev/null; TP=$(mpid S-epid "$C11e")
perl -pi -e 's/^pid=.*/pid=/' "$(mem S-epid "$C11e")"; sleep 0.5
alive "$TP" || { echo "11c: the timer exited on an empty pid"; exit 1; }
L S-epid release "$LB" "$C11e" --model smoke >/dev/null; waitfor '! alive "$TP"' || { echo "11c: the timer outlived the release"; exit 1; }
ok "lease: a timer whose memory holds an empty pid keeps running, and still exits on release"

# 11d. TMPDIR on another volume than the board (a RAM disk mounted on a mktemp folder; skipped with a note when one cannot be made):
# the stage cannot be renamed over the card (EXDEV), so the write goes through a temp file at the board root, and none is left behind
RAMD=""; RAMM=$(mktemp -d "$T/lease-ram.XXXXXX")
ram_off() { [ -z "$RAMD" ] || { umount "$RAMM" 2>/dev/null || umount -f "$RAMM" 2>/dev/null; hdiutil detach "$RAMD" -quiet -force 2>/dev/null; RAMD=""; } || true; }
trap 'ram_off; lease_cleanup' EXIT
RAMD=$(hdiutil attach -nomount ram://8192 2>/dev/null | awk 'NR==1 {print $1}') || RAMD=""
if [ -n "$RAMD" ] && newfs_hfs -v leasesmoke "$RAMD" >/dev/null 2>&1 && mount -t hfs "$RAMD" "$RAMM" 2>/dev/null \
  && [ "$(stat -f %d "$RAMM")" != "$(stat -f %d "$LB")" ]; then
  LX() { local s="$1"; shift; CLAUDE_CODE_SESSION_ID="$s" CLAUDE_PID="$LPID" TMPDIR="$RAMM" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_POLL=0.2 \
    LEASE_TEST_RENEW_EVERY="${RE:-1}" "$LS" "$@"; }
  C11v=$(lcard "Eleven v"); F11v=$(lcf "$C11v"); RC=0; LX S-vol stake "$LB" "$C11v" --model smoke >/dev/null 2>"$T/lx.err" || RC=$?
  [ $RC = 0 ] && [ "$(csess "$F11v")" = S-vol ] || { echo "11d: stake across volumes: rc $RC, $(cat "$T/lx.err")"; ram_off; exit 1; }
  U0=$(cuntil "$F11v"); sleep 1.1
  waitfor '[ "$(cuntil "$F11v")" != "$U0" ]' || { echo "11d: the timer never renewed across volumes"; ram_off; exit 1; }
  RC=0; LX S-vol release "$LB" "$C11v" --model smoke >/dev/null 2>"$T/lx.err" || RC=$?
  [ $RC = 0 ] && ! grep -q '^claimed:' "$F11v" || { echo "11d: release across volumes: rc $RC, $(cat "$T/lx.err")"; ram_off; exit 1; }
  # an in-place write while the renewal holds its temp file, between the first compare and the second: the write survives
  C11y=$(lcard "Eleven y"); F11y=$(lcf "$C11y"); RE=1000 LX S-vol2 stake "$LB" "$C11y" --model smoke >/dev/null; U0=$(cuntil "$F11y"); sleep 1.1
  ( RC=0; LEASE_TEST_WRITE_PAUSE=1 RE=1000 LX S-vol2 renew "$LB" "$C11y" --model smoke >/dev/null 2>"$T/lx.err" || RC=$?; echo "$RC" > "$T/lx.rc" ) & RNP=$!
  waitfor '[ -n "$(ls "$LB"/.lease-write.*.lanework-tmp 2>/dev/null)" ]' || { echo "11d: the renewal never held a temp file"; ram_off; exit 1; }
  perl -pe 's/^Body line one\.$/Body edited in place./' "$F11y" > "$F11y.w" && mv "$F11y.w" "$F11y"; wait "$RNP"
  [ "$(cat "$T/lx.rc")" = 0 ] && grep -qx 'Body edited in place.' "$F11y" && [ "$(csess "$F11y")" = S-vol2 ] && [ "$(cuntil "$F11y")" != "$U0" ] \
    || { echo "11d: a renewal across volumes undid an in-place write: rc $(cat "$T/lx.rc"), $(cat "$T/lx.err")"; cat "$F11y"; ram_off; exit 1; }
  RE=1000 LX S-vol2 release "$LB" "$C11y" --model smoke >/dev/null
  # a SIGKILL of lease.sh while perl holds the temp file: the name carries perl's pid, so the sweep by another write leaves it and the write lands
  C11k=$(lcard "Eleven k"); F11k=$(lcf "$C11k"); C11m=$(lcard "Eleven m"); RE=1000 LX S-vol5 stake "$LB" "$C11k" --model smoke >/dev/null; U0=$(cuntil "$F11k"); sleep 1.1
  CLAUDE_CODE_SESSION_ID=S-vol5 CLAUDE_PID="$LPID" TMPDIR="$RAMM" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 LEASE_TEST_WRITE_PAUSE=3 \
    "$LS" renew "$LB" "$C11k" --model smoke >/dev/null 2>"$T/lx.err" & KLS=$!
  waitfor '[ -n "$(ls "$LB"/.lease-write.*.lanework-tmp 2>/dev/null)" ]' || { echo "11d: the kill case never held a temp file"; wait "$KLS"; ram_off; exit 1; }
  KF=$(ls "$LB"/.lease-write.*.lanework-tmp | head -1); KP=${KF%.lanework-tmp}; KP=${KP##*.}
  KPP=""; case "$KP" in ''|*[!0-9]*) ;; *) [ "$KP" -gt 1 ] && KPP=$(ps -o ppid= -p "$KP" 2>/dev/null | tr -d ' ') ;; esac
  if [ -z "$KPP" ] || [ "$KPP" = "$KP" ] || [ "$KPP" != "$KLS" ] || ! ps -ww -p "$KPP" -o command= 2>/dev/null | grep -qF "$LS"; then
    echo "11d: the temp file's pid ($KP, parent '$KPP') is not a process whose parent is the lease.sh started ($KLS)"; wait "$KLS"; ram_off; exit 1
  fi
  kill -9 "$KLS"; wait "$KLS" 2>/dev/null || true
  RE=1000 LX S-vol6 stake "$LB" "$C11m" --model smoke >/dev/null     # a second lease write on the board runs the sweep
  waitfor '[ "$(cuntil "$F11k")" != "$U0" ] && [ -z "$(ls "$LB"/.lease-write.*.lanework-tmp 2>/dev/null)" ]' 10 \
    || { echo "11d: the write of a SIGKILLed lease.sh was dropped (until unchanged or a temp file left)"; ram_off; exit 1; }
  RE=1000 LX S-vol5 release "$LB" "$C11k" --model smoke >/dev/null; RE=1000 LX S-vol6 release "$LB" "$C11m" --model smoke >/dev/null
  sleep 0.5; [ -z "$(find "$LB" -name '.lease-write.*.lanework-tmp' 2>/dev/null)" ] || { echo "11d: a temp file was left:"; find "$LB" -name '.lease-write.*'; ram_off; exit 1; }
  validate "$LB" >/dev/null
  ok "lease: with TMPDIR on another volume than the board, stake, the timer's renewal and release all write; a write landing while the temp file waits survives; no temp file is left"
else
  echo "# skip 11d: no RAM disk volume could be made; the cross-volume lease write is untested in this run"
fi
ram_off

# 11e. lease leftovers: odd session ids refused, the release pointer, the sweep of a dead write's temp file
C11e=$(lcard "Eleven e"); F11e=$(lcf "$C11e")
for sid in 'S,x' 'S}x' 'S\x'; do
  RC=0; L "$sid" stake "$LB" "$C11e" --model smoke >/dev/null 2>"$T/l11e.err" || RC=$?
  [ $RC = 2 ] && grep -qF "$sid" "$T/l11e.err" && ! grep -q '^claimed:' "$F11e" || { echo "11e: stake as '$sid': rc $RC, $(cat "$T/l11e.err")"; exit 1; }
done
L S-own stake "$LB" "$C11e" --model smoke >/dev/null; RC=0; L S-other release "$LB" "$C11e" --model smoke >/dev/null 2>"$T/l11e.err" || RC=$?
[ $RC = 1 ] && grep -qF 'lease.sh list' "$T/l11e.err" || { echo "11e: another session's release: rc $RC, $(cat "$T/l11e.err")"; exit 1; }
( : ) & DP=$!; wait "$DP"; sleep 600 </dev/null >/dev/null 2>&1 & LV=$!; LSP+=("$LV")
DW="$LB/.lease-write.$C11e.$DP.lanework-tmp"; LW="$LB/.lease-write.$C11e.$LV.lanework-tmp"; : > "$DW"; : > "$LW"
P1W="$LB/.lease-write.$C11e.1.lanework-tmp"; : > "$P1W"          # pid 1 is live but not signalable as this user (kill -0 fails with EPERM)
L S-own renew "$LB" "$C11e" --model smoke >/dev/null
[ -e "$P1W" ] || { echo "11e: sweep: a live pid this user may not signal (1) had its temp file deleted"; exit 1; }
rm -f "$P1W"
[ ! -e "$DW" ] && [ -e "$LW" ] || { echo "11e: sweep: dead file present=$([ -e "$DW" ] && echo y || echo n), live file present=$([ -e "$LW" ] && echo y || echo n)"; exit 1; }
rm -f "$LW"; L S-own release "$LB" "$C11e" --model smoke >/dev/null; kill "$LV" 2>/dev/null || true
ok "lease: a session id with a comma, closing brace or backslash is refused (exit 2) with no claim written; another session's release names lease.sh list; a write sweeps the temp file of a dead pid and leaves a live one"

# 11f. find_card on a card in transit between lanes (renamed while the glob expands: in no lane): lease.sh's own function, run with
# a sleep that lands the card in Shaping (or, FDROP set, removes that copy of a card in two lanes), so its first look always
# misses, or always sees two. It looks again and finds the one; a card gone stays 1, a card in two lanes for good 2
FC=$(awk '/^find_card\(\) \{/,/^\}/' "$LS"); SHL2=$(dirname "$(lane_of "$LB" Shaping)"); FDROP=""
fc() { ( BOARD="$LB"; CID="$1"; eval "$FC"
  sleep() { if [ -d "$T/l11f-hold" ]; then /bin/mv "$T/l11f-hold" "$SHL2/$CID"; elif [ -n "$FDROP" ]; then rm -rf "$FDROP"; fi; command sleep "$@"; }
  find_card ); }
C11f=$(lcard "Eleven f"); mv "$LL/$C11f" "$T/l11f-hold"; RC=0; O=$(fc "$C11f") || RC=$?
[ $RC = 0 ] && [ "$O" = "$SHL2/$C11f/index.md" ] || { echo "11f: find_card on a card in transit: rc $RC, '$O'"; exit 1; }
cp -R "$SHL2/$C11f" "$LL/$C11f"; FDROP="$LL/$C11f"; RC=0; O=$(fc "$C11f") || RC=$?; FDROP=""
[ $RC = 0 ] && [ "$O" = "$SHL2/$C11f/index.md" ] || { echo "11f: find_card on a card in two lanes for a moment: rc $RC, '$O'"; exit 1; }
RC=0; fc 00000000-0000-4000-8000-000000000000 >/dev/null || RC=$?; [ $RC = 1 ] || { echo "11f: find_card on no card: rc $RC"; exit 1; }
cp -R "$SHL2/$C11f" "$LL/$C11f"; RC=0; fc "$C11f" >/dev/null || RC=$?; [ $RC = 2 ] || { echo "11f: find_card on a card in two lanes: rc $RC"; exit 1; }
rm -rf "$LL/$C11f"
ok "lease: find_card looks again for a card in transit between lanes, or in two for a moment, and finds it; no card is still 1, a card in two lanes 2"

# 11g. the timer across moves: a card moved between lanes ten times, then out of the board for 1 s (longer than find_card's
# retry, a few polls), keeps its timer; a card deleted ends it within a few polls
C11g=$(lcard "Eleven g"); L S-elg stake "$LB" "$C11g" --model smoke >/dev/null; TP=$(mpid S-elg "$C11g")
for i in 1 2 3 4 5; do mv "$LL/$C11g" "$SHL2/$C11g"; sleep 0.15; mv "$SHL2/$C11g" "$LL/$C11g"; sleep 0.15; done
mv "$LL/$C11g" "$T/l11g-hold"; sleep 1; mv "$T/l11g-hold" "$SHL2/$C11g"; sleep 1
alive "$TP" || { echo "11g: the timer exited while its card moved between lanes"; exit 1; }
rm -rf "$SHL2/$C11g"; waitfor '! alive "$TP"' || { echo "11g: the timer outlived its deleted card"; exit 1; }
# a card found but not readable (moved between the find and the read), or whose comment is gone when read (moved between the
# find and the thread read): shims on the timer's PATH, cat on the card and awk on its comment, each fail once. Neither ends it
CSH="$T/l11g-shim"; mkdir -p "$CSH"; printf '%s\n' '#!/bin/bash' \
  'case "${1:-}" in */"$L11G_CID"/index.md) [ ! -f "$L11G_ONCE" ] || { rm -f "$L11G_ONCE"; exit 1; } ;; esac; exec /bin/cat "$@"' > "$CSH/cat"
printf '%s\n' '#!/bin/bash' \
  'case "${@: -1}" in */"$L11G_CID"/comments/*/index.md) [ ! -f "$L11G_AONCE" ] || { rm -f "$L11G_AONCE"; exit 2; } ;; esac; exec /usr/bin/awk "$@"' > "$CSH/awk"; chmod +x "$CSH/cat" "$CSH/awk"
C11r=$(lcard "Eleven r"); NI=$(uuidgen | tr A-Z a-z); mkdir -p "$(dirname "$(lcf "$C11r")")/comments/$NI"
printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\nmodified: {at: 2026-01-01T00:00:00Z, by: {name: smoke, kind: agent, model: smoke}}\n---\nA note.\n' > "$(dirname "$(lcf "$C11r")")/comments/$NI/index.md"
( export PATH="$CSH:$PATH" L11G_CID="$C11r" L11G_ONCE="$T/l11g-once" L11G_AONCE="$T/l11g-aonce"; L S-elr stake "$LB" "$C11r" --model smoke >/dev/null )
TP=$(mpid S-elr "$C11r"); : > "$T/l11g-once"; waitfor '[ ! -e "$T/l11g-once" ]' || { echo "11g: the cat shim never ran"; exit 1; }
sleep 0.6; alive "$TP" || { echo "11g: the timer exited on one unreadable read of its card"; exit 1; }
: > "$T/l11g-aonce"; waitfor '[ ! -e "$T/l11g-aonce" ]' || { echo "11g: the awk shim never ran"; exit 1; }
sleep 0.6; alive "$TP" || { echo "11g: the timer exited on one comment gone while its thread was read"; exit 1; }
L S-elr release "$LB" "$C11r" --model smoke >/dev/null; waitfor '! alive "$TP"' || { echo "11g: the timer outlived the release"; exit 1; }
ok "lease: the timer outlives its card's moves between lanes, a second out of the board, one failed read of the card and one of a comment, and exits once the card is deleted"

# 12. list
C12l=$(lcard "Lapsed one"); setclaim "$(lcf "$C12l")" S-gone "$(iso $(( $(date -u +%s) - 600 )))"
C12v=$(lcard "Voided one"); setclaim "$(lcf "$C12v")" S-skew "$(iso $(( $(date -u +%s) + 7200 )))"
C12u=$(lcard "Unreadable one"); setclaim "$(lcf "$C12u")" S-skew "soon"
L S-multi renew "$LB" "$CA" --model smoke >/dev/null   # staked many cases back: renewed here, so "29 or 30 min left" never hangs on the cases' run time
LO=$("$LS" list "$LB"); line() { awk -F'\t' -v c="$1" '$1==c' <<<"$LO"; }
[ "$(line "$C12l" | cut -f2-)" = "$(printf 'claude (S-gone)\t10 min lapsed\tlapsed\tLapsed one')" ] || { echo "list lapsed: $(line "$C12l")"; exit 1; }
line "$C12v" | grep -q -E "$(printf '^[^\t]*\tclaude \\(S-skew\\)\t1[12][0-9] min left\tvoided\tVoided one$')" || { echo "list voided: $(line "$C12v")"; exit 1; }
line "$C12u" | grep -q -E "$(printf '\t-\tvoided\tUnreadable one$')" || { echo "list unreadable: $(line "$C12u")"; exit 1; }
line "$CA" | grep -q -E "$(printf '^%s\tclaude \\(S-multi\\)\t(29|30) min left\tlive\tA$' "$CA")" || { echo "list live: $(line "$CA")"; exit 1; }
[ -z "$(line "$C10")" ] && [ -z "$(line "$C2")" ] || { echo "list printed a card with no lease"; exit 1; }
ok "lease: list prints held cards with holder, time left, lapsed and voided, the title last"

# work: the card-writing scripts check the lease first (post-comment, move-card, post-ask), on the lease board, before 13 releases
# what is left. LW <session> <cmd...>: the command as that session, with L's stand-in CLAUDE_PID, TMPDIR and knobs; LN: no session id
LW() { local s="$1"; shift; CLAUDE_CODE_SESSION_ID="$s" CLAUDE_PID="$LPID" TMPDIR="$LT" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_NOTICE_WAIT=1.5 \
  LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 "$@"; }
LN() { env -u CLAUDE_CODE_SESSION_ID CLAUDE_PID="$LPID" TMPDIR="$LT" "$@"; }
lw_fail() { echo "$1"; exit 1; }
PCS="$SK/work/scripts/post-comment.sh"; MCS="$SK/work/scripts/move-card.sh"; PAS="$SK/work/scripts/post-ask.sh"
cdir() { dirname "$(lcf "$1")"; }
ncom() { { ls "$(cdir "$1")/comments" 2>/dev/null || true; } | grep -c . || true; }
landed() { [ -n "$2" ] && [ -f "$(cdir "$1")/comments/$2/index.md" ]; }
# lostcard <session> <title>: a card that session staked, its timer stopped (so the script's own check finds the loss), now S-other's
lostcard() { local c tp; c=$(lcard "$2"); L "$1" stake "$LB" "$c" --model smoke >/dev/null; tp=$(mpid "$1" "$c"); kill "$tp"; waitfor '! alive "$tp"'
  setclaim "$(lcf "$c")" S-other "$(iso $(( $(date -u +%s) + 1500 )))"; echo "$c"; }

# 1. held: the comment lands, the card file (claimed with it) byte for byte
K1=$(lcard "PC held"); FK1=$(lcf "$K1"); L SW-one stake "$LB" "$K1" --model smoke >/dev/null; H=$(shasum < "$FK1")
RC=0; O=$(LW SW-one "$PCS" "$LB" "$K1" --body "$T/pc.md" --model smoke) || RC=$?
[ $RC = 0 ] && landed "$K1" "$O" && [ "$(ncom "$K1")" = 1 ] && [ "$H" = "$(shasum < "$FK1")" ] && [ "$(csess "$FK1")" = SW-one ] \
  || lw_fail "post-comment on a held card: rc $RC, comment '$O', comments $(ncom "$K1")"
ok "post-comment.sh on a card this session holds writes the comment and leaves the card, claimed with it, as it was"

# 2. a lapsed lease still this session's, its timer dead: renewed (until 30 minutes out, a new timer), then the comment lands
K2=$(lcard "PC lapsed"); FK2=$(lcf "$K2"); L SW-two stake "$LB" "$K2" --model smoke >/dev/null; TP=$(mpid SW-two "$K2"); kill "$TP"; waitfor '! alive "$TP"'
setclaim "$FK2" SW-two "$(iso $(( $(date -u +%s) - 60 )))"
RC=0; O=$(LW SW-two "$PCS" "$LB" "$K2" --body "$T/pc.md" --model smoke) || RC=$?; TQ=$(mpid SW-two "$K2")
[ $RC = 0 ] && landed "$K2" "$O" && [ "$(epoch "$(cuntil "$FK2")")" -gt $(( $(date -u +%s) + 1700 )) ] && [ "$TQ" != "$TP" ] && alive "$TQ" \
  || lw_fail "post-comment on a lapsed own lease: rc $RC, until $(cuntil "$FK2"), timer $TQ (was $TP)"
ok "post-comment.sh on a lapsed lease still this session's renews it, restarts its timer, and writes"

# 3. lost (another session's by on a card this session staked): exit 3, only the Lease lost record lands; a second call writes nothing
K3=$(lostcard SW-three "PC lost"); FK3=$(lcf "$K3"); H=$(shasum < "$FK3")
RC=0; O=$(LW SW-three "$PCS" "$LB" "$K3" --body "$T/pc.md" --model smoke 2>"$T/lw-err.txt") || RC=$?
[ $RC = 3 ] && [ -z "$O" ] && grep -q 'lost' "$T/lw-err.txt" && [ "$(records "$K3" "**Lease lost**")" = 1 ] && [ "$(ncom "$K3")" = 1 ] \
  && [ "$(records "$K3" 'Checked the clock rule')" = 0 ] && [ "$H" = "$(shasum < "$FK3")" ] \
  || lw_fail "post-comment on a lost lease: rc $RC, out '$O', comments $(ncom "$K3"), err: $(cat "$T/lw-err.txt")"
RC=0; LW SW-three "$PCS" "$LB" "$K3" --body "$T/pc.md" --model smoke --ahead 2 >/dev/null 2>&1 || RC=$?
[ $RC = 3 ] && [ "$(ncom "$K3")" = 1 ] && [ "$H" = "$(shasum < "$FK3")" ] || lw_fail "post-comment, a second call on a lost lease: rc $RC, comments $(ncom "$K3")"
ok "post-comment.sh on a lost lease exits 3 with the reason on stderr; only the Lease lost record lands, and a second call writes nothing at all"

# 4. not blocked: a free card, another session's lease this session never held, and no session id (even on the card lost in 3)
K4=$(lcard "PC free"); FK4=$(lcf "$K4"); H=$(shasum < "$FK4")
RC=0; O=$(LW SW-four "$PCS" "$LB" "$K4" --body "$T/pc.md" --model smoke) || RC=$?
[ $RC = 0 ] && landed "$K4" "$O" && [ "$H" = "$(shasum < "$FK4")" ] && [ ! -e "$LT/lanework-lease/SW-four" ] || lw_fail "post-comment on a free card: rc $RC"
K4o=$(lcard "PC another's"); FK4o=$(lcf "$K4o"); L SW-four-o stake "$LB" "$K4o" --model smoke >/dev/null; H=$(shasum < "$FK4o")
RC=0; O=$(LW SW-four "$PCS" "$LB" "$K4o" --body "$T/pc.md" --model smoke) || RC=$?
[ $RC = 0 ] && landed "$K4o" "$O" && [ "$H" = "$(shasum < "$FK4o")" ] && [ "$(csess "$FK4o")" = SW-four-o ] || lw_fail "post-comment on another session's lease, never held here: rc $RC"
RC=0; O=$(LN "$PCS" "$LB" "$K3" --body "$T/pc.md" --model smoke --ahead 3) || RC=$?
[ $RC = 0 ] && landed "$K3" "$O" && [ "$(ncom "$K3")" = 2 ] || lw_fail "post-comment with no session id: rc $RC (the check must be skipped)"
ok "post-comment.sh writes as today on a free card, on another session's lease this session never held, and with no session id"

# 5. a subagent: the lead's session id, --name fixer, writes under the lead's lease
K5=$(lcard "PC fixer"); FK5=$(lcf "$K5"); L SW-five stake "$LB" "$K5" --model smoke >/dev/null; H=$(shasum < "$FK5")
RC=0; O=$(LW SW-five "$PCS" "$LB" "$K5" --body "$T/pc.md" --model smoke --name fixer) || RC=$?
[ $RC = 0 ] && landed "$K5" "$O" && grep -q '^created:  {at: [^,]*, by: {name: fixer, kind: agent, model: smoke}}$' "$(cdir "$K5")/comments/$O/index.md" && [ "$H" = "$(shasum < "$FK5")" ] \
  || lw_fail "post-comment as fixer under the lead's lease: rc $RC"
ok "post-comment.sh as a subagent (the session's id, --name fixer) writes under its session's lease"

# 6. --session is a stamp label, never the holder: it neither rescues a lost lease nor blocks a held one
RC=0; LW SW-three "$PCS" "$LB" "$K3" --body "$T/pc.md" --model smoke --session SW-four-o --ahead 4 >/dev/null 2>&1 || RC=$?
[ $RC = 3 ] && [ "$(ncom "$K3")" = 2 ] || lw_fail "--session on a lost lease: rc $RC, comments $(ncom "$K3")"
RC=0; O=$(LW SW-one "$PCS" "$LB" "$K1" --body "$T/pc.md" --model smoke --session "some label" --ahead 2) || RC=$?
[ $RC = 0 ] && landed "$K1" "$O" && grep -q 'session: "some label"}}$' "$(cdir "$K1")/comments/$O/index.md" || lw_fail "--session on a held lease: rc $RC"
ok "post-comment.sh checks the environment's session id: --session neither rescues a lost lease nor blocks a held one"

# 7. --release: the comment lands, then claimed is gone and the timer has exited; on a lost lease nothing is released
K7=$(lcard "PC release"); FK7=$(lcf "$K7"); L SW-seven stake "$LB" "$K7" --model smoke >/dev/null; TP=$(mpid SW-seven "$K7")
RC=0; O=$(LW SW-seven "$PCS" "$LB" "$K7" --body "$T/pc.md" --model smoke --release) || RC=$?
[ $RC = 0 ] && landed "$K7" "$O" && ! grep -q '^claimed:' "$FK7" && waitfor '! alive "$TP"' && [ ! -e "$(mem SW-seven "$K7")" ] \
  || lw_fail "post-comment --release: rc $RC, comment '$O'"
K7l=$(lostcard SW-seven "PC release lost"); FK7l=$(lcf "$K7l"); H=$(shasum < "$FK7l")
RC=0; LW SW-seven "$PCS" "$LB" "$K7l" --body "$T/pc.md" --model smoke --release >/dev/null 2>&1 || RC=$?
[ $RC = 3 ] && [ "$H" = "$(shasum < "$FK7l")" ] && [ "$(csess "$FK7l")" = S-other ] && [ "$(ncom "$K7l")" = 1 ] || lw_fail "post-comment --release on a lost lease: rc $RC"
# the comment first: a comments folder that refuses the mv leaves the lease held, its timer alive (a release before the mv would not)
K7r=$(lcard "PC release ro"); FK7r=$(lcf "$K7r"); L SW-seven stake "$LB" "$K7r" --model smoke >/dev/null; TP=$(mpid SW-seven "$K7r")
mkdir -p "$(cdir "$K7r")/comments"; chmod 555 "$(cdir "$K7r")/comments"
RC=0; LW SW-seven "$PCS" "$LB" "$K7r" --body "$T/pc.md" --model smoke --release >/dev/null 2>&1 || RC=$?; chmod 755 "$(cdir "$K7r")/comments"
[ $RC != 0 ] && [ "$(ncom "$K7r")" = 0 ] && [ "$(csess "$FK7r")" = SW-seven ] && alive "$TP" && [ -f "$(mem SW-seven "$K7r")" ] || lw_fail "post-comment --release whose comment did not land released the lease: rc $RC"
# a free card and another session's lease never held here: the comment lands, nothing is released, a note says so
K7f=$(lcard "PC release free"); FK7f=$(lcf "$K7f"); K7o=$(lcard "PC release other's"); FK7o=$(lcf "$K7o"); L SW-seven-o stake "$LB" "$K7o" --model smoke >/dev/null
for c in "$K7f" "$K7o"; do f=$(lcf "$c"); H=$(shasum < "$f")
  RC=0; O=$(LW SW-seven "$PCS" "$LB" "$c" --body "$T/pc.md" --model smoke --release 2>"$T/lw-err.txt") || RC=$?
  [ $RC = 0 ] && landed "$c" "$O" && [ "$H" = "$(shasum < "$f")" ] && grep -q 'nothing released' "$T/lw-err.txt" || lw_fail "post-comment --release on a card never held here: rc $RC, err: $(cat "$T/lw-err.txt")"; done
[ "$(csess "$FK7o")" = SW-seven-o ] || lw_fail "post-comment --release released another session's lease"
ok "post-comment.sh --release lands the comment, then claimed is gone and the timer has exited; a comment that does not land releases nothing; on a lost lease, a free card and another's lease it releases nothing"

# 8. every existing refusal stays a no-op, lease untouched: a lapsed own lease (a check that ran would renew it) under a bad ask,
# a body with frontmatter, a taken second (every second from now to 10 s ahead seeded) and two cards with one uuid
K8=$(lcard "PC refusals"); FK8=$(lcf "$K8"); D8=$(cdir "$K8"); L SW-eight stake "$LB" "$K8" --model smoke >/dev/null; TP=$(mpid SW-eight "$K8"); kill "$TP"; waitfor '! alive "$TP"'
setclaim "$FK8" SW-eight "$(iso $(( $(date -u +%s) - 60 )))"; H=$(shasum < "$FK8"); M8=$(shasum < "$(mem SW-eight "$K8")")
printf '@owner maybe ship it; worth a try? and also this?\n' > "$T/lw-badask.md"
RC=0; LW SW-eight "$PCS" "$LB" "$K8" --body "$T/lw-badask.md" --model smoke >/dev/null 2>&1 || RC=$?; [ $RC = 1 ] || lw_fail "a failing ask under a lease: want exit 1, got $RC"
RC=0; LW SW-eight "$PCS" "$LB" "$K8" --body "$T/fm.md" --model smoke >/dev/null 2>&1 || RC=$?; [ $RC = 1 ] || lw_fail "a body with frontmatter under a lease: want exit 1, got $RC"
n=$(date -u +%s); for i in 0 1 2 3 4 5 6 7 8 9 10; do s=$(iso $((n + i))); mkdir -p "$D8/comments/00000000-8888-4888-8888-0000000000$((10 + i))"
  printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: %s}\nmodified: {at: %s}\n---\nseed\n' "$s" "$s" > "$D8/comments/00000000-8888-4888-8888-0000000000$((10 + i))/index.md"; done
RC=0; LW SW-eight "$PCS" "$LB" "$K8" --body "$T/pc.md" --model smoke --ahead 5 >/dev/null 2>"$T/lw-err.txt" || RC=$?
[ $RC = 1 ] && grep -q -- '--ahead' "$T/lw-err.txt" || lw_fail "a taken second under a lease: want exit 1 naming --ahead, got $RC"
rm -rf "$D8"/comments/00000000-8888-*
DUP8="$LB/00000000-0000-4000-8000-0000000000d8"; mkdir -p "$DUP8"; cp -R "$D8" "$DUP8/"
RC=0; LW SW-eight "$PCS" "$LB" "$K8" --body "$T/pc.md" --model smoke >/dev/null 2>&1 || RC=$?; rm -rf "$DUP8"; [ $RC = 2 ] || lw_fail "two cards with one uuid under a lease: want exit 2, got $RC"
[ "$H" = "$(shasum < "$FK8")" ] && [ "$(ncom "$K8")" = 0 ] && [ "$M8" = "$(shasum < "$(mem SW-eight "$K8")")" ] && ! alive "$TP" && [ "$(records "$K8" Lease)" = 0 ] \
  || lw_fail "a refused post touched the lease or wrote: comments $(ncom "$K8")"
ok "post-comment.sh stays a no-op on every existing refusal (bad ask, frontmatter, a taken second, two cards with one uuid), the lease untouched"

# move-card: held moves; lost is exit 3, nothing moved or posted; another's lease, a free card and no session id move as today
SHL=$(dirname "$(lane_of "$LB" Shaping)"); printf 'Moved on.\n\n**Evidence**: none needed.\n' > "$T/lw-mc.md"
M1=$(lcard "MC held"); L SW-m stake "$LB" "$M1" --model smoke >/dev/null
RC=0; O=$(LW SW-m "$MCS" "$LB" "$M1" Shaping --model smoke --comment "$T/lw-mc.md") || RC=$?
[ $RC = 0 ] && [ -f "$SHL/$M1/index.md" ] && [ ! -e "$LL/$M1" ] && [ "$(csess "$SHL/$M1/index.md")" = SW-m ] && [ "$(ncom "$M1")" = 1 ] || lw_fail "move-card on a held card: rc $RC, '$O'"
M2=$(lostcard SW-m "MC lost"); H=$(shasum < "$LL/$M2/index.md")
RC=0; LW SW-m "$MCS" "$LB" "$M2" Shaping --model smoke --comment "$T/lw-mc.md" >/dev/null 2>"$T/lw-err.txt" || RC=$?
[ $RC = 3 ] && grep -q 'lost' "$T/lw-err.txt" && [ -f "$LL/$M2/index.md" ] && [ ! -e "$SHL/$M2" ] && [ "$H" = "$(shasum < "$LL/$M2/index.md")" ] \
  && [ "$(ncom "$M2")" = 1 ] && [ "$(records "$M2" "**Lease lost**")" = 1 ] || lw_fail "move-card on a lost lease: rc $RC, comments $(ncom "$M2"), err: $(cat "$T/lw-err.txt")"
M3=$(lcard "MC another's"); L SW-m-o stake "$LB" "$M3" --model smoke >/dev/null; M4=$(lcard "MC free")
for c in "$M3" "$M4"; do RC=0; LW SW-m "$MCS" "$LB" "$c" Shaping --model smoke >/dev/null || RC=$?; [ $RC = 0 ] && [ -f "$SHL/$c/index.md" ] || lw_fail "move-card on a card never held here: rc $RC"; done
[ "$(csess "$SHL/$M3/index.md")" = SW-m-o ] && [ ! -e "$(mem SW-m "$M4")" ] || lw_fail "move-card on a card never held here touched its lease"
RC=0; LN "$MCS" "$LB" "$M2" Shaping --model smoke >/dev/null || RC=$?; [ $RC = 0 ] && [ -f "$SHL/$M2/index.md" ] || lw_fail "move-card with no session id: rc $RC"
validate "$LB" >/dev/null
ok "move-card.sh checks the lease before it moves: held moves; lost exits 3, nothing moved or posted; another's lease, a free card and no session id move as today"

# post-ask: on a lost lease neither the ask nor waiting lands; held (the control) lands both
A1=$(lostcard SW-a "PA lost"); FA1=$(lcf "$A1"); H=$(shasum < "$FA1")
RC=0; LW SW-a "$PAS" "$LB" "$A1" --body "$T/ask1.md" --for anyone --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 3 ] && [ "$H" = "$(shasum < "$FA1")" ] && ! grep -q '^waiting:' "$FA1" && [ "$(ncom "$A1")" = 1 ] && [ "$(records "$A1" "**Lease lost**")" = 1 ] \
  && [ "$(records "$A1" 'Ship the thing today')" = 0 ] || lw_fail "post-ask on a lost lease: rc $RC, comments $(ncom "$A1")"
A2=$(lcard "PA held"); FA2=$(lcf "$A2"); L SW-a stake "$LB" "$A2" --model smoke >/dev/null
RC=0; O=$(LW SW-a "$PAS" "$LB" "$A2" --body "$T/ask1.md" --for anyone --model smoke) || RC=$?
[ $RC = 0 ] && landed "$A2" "$O" && grep -q "^waiting: {for: anyone, since: [^,]*, comment: $O}\$" "$FA2" && [ "$(csess "$FA2")" = SW-a ] || lw_fail "post-ask on a held lease: rc $RC"
validate "$LB" >/dev/null
ok "post-ask.sh on a lost lease writes neither the ask nor waiting (exit 3, the Lease lost record only); on a held one both land"

# label-card: the lease check first. Lost: exit 3, nothing written to the card; held: labels land and the claim stays; no session id: as today
LCS="$SK/work/scripts/label-card.sh"
Y1=$(lostcard SW-l "LC lost"); FY1=$(lcf "$Y1"); H=$(shasum < "$FY1")
RC=0; LW SW-l "$LCS" "$LB" "$FY1" "tagged" --model smoke >/dev/null 2>"$T/lw-err.txt" || RC=$?
[ $RC = 3 ] && grep -q 'lost' "$T/lw-err.txt" && [ "$H" = "$(shasum < "$FY1")" ] && ! grep -q 'tagged' "$FY1" && [ "$(records "$Y1" "**Lease lost**")" = 1 ] \
  || lw_fail "label-card on a lost lease: rc $RC, err: $(cat "$T/lw-err.txt")"
Y2=$(lcard "LC held"); FY2=$(lcf "$Y2"); L SW-l2 stake "$LB" "$Y2" --model smoke >/dev/null
RC=0; LW SW-l2 "$LCS" "$LB" "$FY2" "tagged" --model smoke >/dev/null || RC=$?
[ $RC = 0 ] && grep -q '^labels: \[{text: "tagged"' "$FY2" && [ "$(csess "$FY2")" = SW-l2 ] || lw_fail "label-card on a held card: rc $RC"
RC=0; LN "$LCS" "$LB" "$FY1" "tagged" --model smoke >/dev/null || RC=$?
[ $RC = 0 ] && grep -q '^labels: \[{text: "tagged"' "$FY1" || lw_fail "label-card with no session id: rc $RC"
validate "$LB" >/dev/null
ok "label-card.sh checks the lease before it writes: lost exits 3 and the card is untouched; held labels it and keeps the claim; no session id writes as today"

# 10. another copy of the board: a card this session holds on LB, the same uuid on a copy made before the stake, is never held
# there; the write to the copy passes and posts no loss, and the lease on LB stays held (also through a symlink and a trailing slash)
KC=$(lcard "PC board copy"); FKC=$(lcf "$KC"); LBC="$T/Lease copy.lanework"; cp -R "$LB" "$LBC"; ln -s "$LB" "$T/lease-link"
L SW-copy stake "$LB" "$KC" --model smoke >/dev/null; TP=$(mpid SW-copy "$KC"); FCC=$(ls "$LBC"/*/"$KC"/index.md)
RC=0; O=$(LW SW-copy "$PCS" "$LBC" "$KC" --body "$T/pc.md" --model smoke --name fixer) || RC=$?
[ $RC = 0 ] && [ -n "$O" ] && [ -f "$(dirname "$FCC")/comments/$O/index.md" ] && ! grep -rqs -F '**Lease lost**' "$(dirname "$FCC")/comments" \
  || lw_fail "post-comment on a copy of the board: rc $RC (want a never-held write, no loss record)"
RC=0; CO=$(L SW-copy check "$LB" "$KC" --model smoke 2>/dev/null) || RC=$?; RC2=0; O=$(LW SW-copy "$PCS" "$LB" "$KC" --body "$T/pc.md" --model smoke) || RC2=$?
CL=$(L SW-copy check "$T/lease-link/" "$KC" --model smoke 2>/dev/null || true)
[ "$CO$RC$RC2$CL" = held00held ] && landed "$KC" "$O" && alive "$TP" && [ "$(csess "$FKC")" = SW-copy ] && [ "$(records "$KC" "**Lease lost**")" = 0 ] \
  || lw_fail "after a write to a copy: check '$CO' $RC, post rc $RC2, via a symlink '$CL', timer $(alive "$TP" && echo alive || echo gone)"
rm -rf "$LBC" "$T/lease-link"
ok "lease: the memory is keyed by board too: a write to a copy of the board passes as never held, and the lease on the board itself stays held, its timer alive, through a symlink and a trailing slash"

# 11. lanework/scripts/lease.sh missing beside work: post-comment and move-card skip the check with a note on stderr and write as today
SOLO="$T/solo/skills"; mkdir -p "$SOLO/lanework/scripts"; cp "$SK/lanework/scripts/lib.sh" "$SOLO/lanework/scripts/"; cp -R "$SK/work" "$SOLO/work"
# both on a lost lease (K3 is SW-three's loss), so a check that ran would refuse
KS=$(lostcard SW-solo "MC solo")
RC=0; O=$(LW SW-three "$SOLO/work/scripts/post-comment.sh" "$LB" "$K3" --body "$T/pc.md" --model smoke --ahead 6 2>"$T/lw-err.txt") || RC=$?
[ $RC = 0 ] && landed "$K3" "$O" && [ "$(grep -c 'lease.sh' "$T/lw-err.txt")" = 1 ] || lw_fail "post-comment with no lease.sh: rc $RC, err: $(cat "$T/lw-err.txt")"
RC=0; LW SW-solo "$SOLO/work/scripts/move-card.sh" "$LB" "$KS" Shaping --model smoke >/dev/null 2>"$T/lw-err.txt" || RC=$?
[ $RC = 0 ] && [ -f "$SHL/$KS/index.md" ] && grep -q 'lease.sh' "$T/lw-err.txt" || lw_fail "move-card with no lease.sh: rc $RC, err: $(cat "$T/lw-err.txt")"
rm -rf "$T/solo"; validate "$LB" >/dev/null
ok "post-comment.sh and move-card.sh with no lanework/scripts/lease.sh beside work skip the check with one note on stderr and write as today"

# script headers (lanework group): found-board render failure, usage strings, and usage errors exit 2
HB="$T/hdr-lw"; rm -rf "$HB"; mkdir -p "$HB"; HFB="$SK/lanework/scripts/found-board.sh"
HFA=(--index "$SK/lanework/templates/pipeline-index.md" --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=x --model smoke)
# item 3: a template with a slot no --var fills exits 2 and writes nothing; before the fix exit 255 and an empty folder. An existing folder stays.
RC=0; HO=$("$HFB" "$HB/Slot.lanework" "${HFA[@]}" 2>&1) || RC=$?
[ $RC = 2 ] && [ ! -e "$HB/Slot.lanework" ] && [[ "$HO" == *unfilled* ]] || { echo "unfilled slot: rc $RC, $(ls -d "$HB"/Slot* 2>&1): $HO"; exit 1; }
mkdir "$HB/Pre.lanework"; RC=0; "$HFB" "$HB/Pre.lanework" "${HFA[@]}" >/dev/null 2>&1 || RC=$?
[ $RC = 2 ] && [ -d "$HB/Pre.lanework" ] && [ -z "$(ls -A "$HB/Pre.lanework")" ] || { echo "unfilled slot, existing empty folder: rc $RC"; exit 1; }
ok "found-board.sh: a template that fails to render exits 2 with its message and creates no folder; an existing empty folder is left as it was"
# item 6: the non-board usage line names --ignore-board-copy
HE=$(python3 -B "$SK/lanework/scripts/heal-board.py" "$HB" 2>&1 >/dev/null) || true
[[ "$HE" == *--ignore-board-copy* ]] || { echo "heal-board usage: $HE"; exit 1; }
ok "heal-board.py: the usage line printed for a non-board names --ignore-board-copy"
# item 7: _timer with a wrong argument count says so; --force appears once in the usage
HL="$SK/lanework/scripts/lease.sh"
RC=0; HE=$("$HL" _timer a b 2>&1 >/dev/null) || RC=$?; [ $RC = 2 ] && [[ "$HE" == *"_timer is internal"* ]] || { echo "_timer a b: rc $RC: $HE"; exit 1; }
RC=0; HE=$("$HL" bogus 2>&1 >/dev/null) || RC=$?; HU=${HE#*usage: }
[ $RC = 2 ] && [ "$(grep -o -e '\[--force\]' <<<"$HU" | wc -l | tr -d ' ')" = 1 ] || { echo "lease usage: rc $RC: $HE"; exit 1; }
ok "lease.sh: a wrong _timer argument count prints that it is internal and exits 2; the usage lists [--force] once, under release"
# option C: usage errors exit 2 and write nothing (found-board.sh: unknown argument, a flag with no value, no argument; read-board.sh: no or unknown argument; not a board stays 1)
for bad in "--bogus" "--index" "--lanes" "--title" "--var" "--labels" "--model" "--name"; do
  rm -rf "$HB/Bad.lanework"; RC=0; "$HFB" "$HB/Bad.lanework" "${HFA[@]}" $bad >/dev/null 2>&1 || RC=$?
  [ $RC = 2 ] && [ ! -e "$HB/Bad.lanework" ] || { echo "found-board.sh ... $bad: rc $RC"; exit 1; }
done
RC=0; "$HFB" >/dev/null 2>&1 || RC=$?; [ $RC = 2 ] || { echo "found-board.sh no argument: rc $RC"; exit 1; }
HR="$SK/lanework/scripts/read-board.sh"
RC=0; "$HR" >/dev/null 2>&1 || RC=$?; [ $RC = 2 ] || { echo "read-board.sh no argument: rc $RC"; exit 1; }
RC=0; "$HR" "$LB" --bogus >/dev/null 2>&1 || RC=$?; [ $RC = 2 ] || { echo "read-board.sh unknown argument: rc $RC"; exit 1; }
RC=0; "$HR" "$HB/none.lanework" >/dev/null 2>&1 || RC=$?; [ $RC = 1 ] || { echo "read-board.sh not a board: rc $RC"; exit 1; }
ok "found-board.sh and read-board.sh: an unknown argument, a flag with no value or no argument exits 2 and writes nothing; read-board.sh on a non-board stays 1"

# 9. the prose: under skills/work/ no START is read as a claim; START is defined once, in writing.md, and linked; the lease is named to subagents
printf '%s\n' '- **A START / plan comment is a claim.**' | grep 'START' | grep -q -i 'claim' || lw_fail "the START-claim pattern misses the line it retired"
SC=$(grep -rn 'START' "$SK/work" | grep -i 'claim' || true); [ -z "$SC" ] || lw_fail "a START read as a claim under skills/work/: $SC"
[ "$(grep -c '^## START$' "$SK/work/references/writing.md" || true)" = 1 ] && [ -z "$(grep -rl '^#* START' "$SK/work" | grep -v '/references/writing\.md$' || true)" ] \
  || lw_fail "START is not defined once, in writing.md"
for f in companions fixer lead; do grep -q -F '`writing.md` § START' "$SK/work/references/$f.md" || lw_fail "$f.md does not link writing.md § START"; done
grep -q '^Lease: ' "$SK/work/templates/farmed-prompt.md" && grep -q -i 'never run the lease script to stake' "$SK/work/templates/farmed-prompt.md" \
  && grep -q 'A fixer never stakes' "$SK/work/references/fixer.md" && grep -q 'stakes and releases leases' "$SK/work/references/team.md" \
  || lw_fail "the lease is not named in farmed-prompt.md, fixer.md or team.md"
ok "work prose: no START read as a claim; START defined once, in writing.md, and linked from companions, fixer and lead; the farmed prompt names the lease; a fixer never stakes"

# plan: claim-ticket.sh stakes and resolve-ticket.sh checks and releases, through lease.sh, on a plan board of their own. PLS <session>
# <cmd...>: the command as that session, under CLAUDE_PID=PCP (a stand-in of its own, else L's), L's TMPDIR and the test knobs
PB="$T/Lease Plan.lanework"; "$PS/found-plan-board.sh" "$PB" --model smoke >/dev/null; PBR=$(cd "$PB" && pwd -P)
PLS() { local s="$1"; shift; CLAUDE_CODE_SESSION_ID="$s" CLAUDE_PID="${PCP:-$LPID}" TMPDIR="$LT" LEASE_TEST_STAKE_WAIT=0.3 LEASE_TEST_NOTICE_WAIT="${NW:-1.5}" \
  LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 "$@"; }
ptk() { bfirst "$PS/file-ticket.sh" "$PB" "$1" --type research --body "$T/t.md" --model smoke; }
pf() { ls "$PB"/*/"$1"/index.md; }
plb() { sed -n 's/^title: "\(.*\)"$/\1/p' "$(dirname "$(dirname "$(pf "$1")")")/index.md"; }
pmem() { printf '%s' "$LT/lanework-lease/$1/$(printf '%s' "$PBR" | shasum | cut -c1-16)/$2"; }
pmpid() { sed -n 's/^pid=//p' "$(pmem "$1" "$2")"; }
pcount() { { grep -l -F -- "$2" "$(dirname "$(pf "$1")")"/comments/*/index.md 2>/dev/null || true; } | grep -c . || true; }
pclaim() { PLS "$1" "$PS/claim-ticket.sh" "$PB" "$2" --model smoke >/dev/null; }
pres() { local s="$1" c="$2"; shift 2; PLS "$s" "$PS/resolve-ticket.sh" "$PB" "$c" --resolution "$T/res1.md" --model smoke "$@"; }
pl_fail() { echo "$1"; exit 1; }
# released <session> <card> <timer pid>: no claimed key in any layout, the timer gone, the memory file gone, no Lease lost record
released() { [ -n "$3" ] && ! grep -q -E '^(claimed:|  (by|until):)' "$(pf "$2")" && fm_parses "$(pf "$2")" && waitfor "! alive $3" && [ ! -e "$(pmem "$1" "$2")" ] \
  && [ "$(pcount "$2" "**Lease lost**")" = 0 ]; }

# P1. claim stakes, then moves
PC1=$(ptk "Staked"); RC=0; PLS S-pa "$PS/claim-ticket.sh" "$PB" "$PC1" --model smoke >/dev/null || RC=$?
F=$(pf "$PC1"); U=$(cuntil "$F"); D=$(( $(epoch "${U:-1970-01-01T00:00:00Z}") - $(date -u +%s) ))
[ $RC = 0 ] && [ "$(plb "$PC1")" = Working ] && [ "$(csess "$F")" = S-pa ] && [ "$D" -ge 1790 ] && [ "$D" -le 1801 ] && [ "$(pcount "$PC1" '**Claimed** by')" = 1 ] \
  && alive "$(pmpid S-pa "$PC1")" || pl_fail "plan claim: rc $RC, lane $(plb "$PC1"), session '$(csess "$F")', until '$U'"
validate "$PB" >/dev/null; PLS S-pa "$LS" release "$PB" "$PC1" --model smoke
ok "plan claim stakes a lease and moves to Working: claimed.by.session is the session, until 30 minutes ahead, one Claimed comment, the board validates"

# P2. a Frontier ticket another session holds: the claim backs off, writing nothing, the holder named
PC2=$(ptk "Held"); PLS S-pholder "$LS" stake "$PB" "$PC2" --model smoke >/dev/null; H=$(sum "$PB")
RC=0; PLS S-pa "$PS/claim-ticket.sh" "$PB" "$PC2" --model smoke >/dev/null 2>"$T/pl-err.txt" || RC=$?
[ $RC = 1 ] && [ "$(plb "$PC2")" = Frontier ] && [ "$(pcount "$PC2" '**Claimed**')" = 0 ] && [ "$(csess "$(pf "$PC2")")" = S-pholder ] && [ "$H" = "$(sum "$PB")" ] \
  && grep -q S-pholder "$T/pl-err.txt" && ! grep -q 'not released' "$T/pl-err.txt" && [ ! -e "$(pmem S-pa "$PC2")" ] || pl_fail "plan claim over a held ticket: rc $RC, lane $(plb "$PC2"), err: $(cat "$T/pl-err.txt")"
PLS S-pholder "$LS" release "$PB" "$PC2" --model smoke
ok "plan claim backs off a Frontier ticket another session holds: exit 1, the holder on stderr, the board byte for byte"

# P2b. a claim ended (TERM) during its stake: the stake lands, then the claim's trap releases it. A long stake wait opens the window
PC2b=$(ptk "Ended"); F=$(pf "$PC2b")
env CLAUDE_CODE_SESSION_ID=S-pterm CLAUDE_PID="$LPID" TMPDIR="$LT" LEASE_TEST_STAKE_WAIT=3 LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 \
  "$PS/claim-ticket.sh" "$PB" "$PC2b" --model smoke >/dev/null 2>"$T/pl-err.txt" & CLP=$!
waitfor 'grep -q "^claimed" "$F"' || pl_fail "plan claim TERM: the stake never wrote claimed"
kill -TERM "$CLP"; RC=0; wait "$CLP" 2>/dev/null || RC=$?
[ "$RC" != 0 ] && [ "$(plb "$PC2b")" = Frontier ] && ! grep -q -E '^(claimed:|  (by|until):)' "$(pf "$PC2b")" && [ ! -e "$(pmem S-pterm "$PC2b")" ] \
  && waitfor '[ -z "$(pgrep -f "$LS _timer $PBR $PC2b " || true)" ]' && [ "$(pcount "$PC2b" '**Claimed**')" = 0 ] && [ "$(pcount "$PC2b" "**Lease lost**")" = 0 ] \
  || pl_fail "plan claim TERM during the stake: rc $RC, lane $(plb "$PC2b"), session '$(csess "$(pf "$PC2b")")', err: $(cat "$T/pl-err.txt")"
ok "plan claim ended during its stake releases what the stake left: Frontier, no claimed, no timer, no memory, no Claimed comment"

# P2c. a claim ended once its own move has put the card in Working has landed: it keeps the lease. Shims on that one claim's
# PATH hold it at a set point (each marks a file, then waits for the release file PL_SHIM_GO, 30 s at most): mv just after the
# card's own move into Working, mkdir on the comments folder after it. The TERM lands there every time, the release after it
PSH="$T/plan-shim"; mkdir -p "$PSH"
printf '%s\n' '#!/bin/bash' 'r=0; /bin/mv "$@" || r=$?' \
  'hold() { : > "$PL_SHIM_MARK"; local e=$((SECONDS + 30)); until [ -f "$PL_SHIM_GO" ] || [ $SECONDS -ge $e ]; do sleep 0.1; done; }' \
  'case "${@: -1}" in *"/${PL_SHIM_MV:-none}") hold ;; esac' 'exit $r' > "$PSH/mv"
printf '%s\n' '#!/bin/bash' 'hold() { : > "$PL_SHIM_MARK"; local e=$((SECONDS + 30)); until [ -f "$PL_SHIM_GO" ] || [ $SECONDS -ge $e ]; do sleep 0.1; done; }' \
  'case "${@: -1}" in */comments) [ -z "${PL_SHIM_DIR:-}" ] || hold ;; esac' \
  'exec /bin/mkdir "$@"' > "$PSH/mkdir"; chmod +x "$PSH/mv" "$PSH/mkdir"
WLN=$(basename "$(dirname "$(lane_of "$PB" Working)")")
for hold in move comment; do
  PC2c=$(ptk "Landed $hold"); rm -f "$T/pl-mark" "$T/pl-go"; SV=PL_SHIM_MV; SVV="$WLN/$PC2c"; [ $hold = move ] || { SV=PL_SHIM_DIR; SVV=1; }
  env PATH="$PSH:$PATH" "$SV=$SVV" PL_SHIM_MARK="$T/pl-mark" PL_SHIM_GO="$T/pl-go" CLAUDE_CODE_SESSION_ID=S-pkeep CLAUDE_PID="$LPID" TMPDIR="$LT" LEASE_TEST_STAKE_WAIT=0.3 \
    LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 "$PS/claim-ticket.sh" "$PB" "$PC2c" --model smoke >/dev/null 2>"$T/pl-err.txt" & CLP=$!
  waitfor '[ -f "$T/pl-mark" ]' 30 || { : > "$T/pl-go"; pl_fail "plan claim landed ($hold): the shim never held the claim"; }
  kill -TERM "$CLP"; : > "$T/pl-go"; RC=0; wait "$CLP" 2>/dev/null || RC=$?
  [ "$RC" != 0 ] && [ "$(plb "$PC2c")" = Working ] && [ "$(csess "$(pf "$PC2c")")" = S-pkeep ] && [ -f "$(pmem S-pkeep "$PC2c")" ] && alive "$(pmpid S-pkeep "$PC2c")" \
    && [ "$(pcount "$PC2c" "**Lease lost**")" = 0 ] || pl_fail "plan claim ended at the $hold: rc $RC, lane $(plb "$PC2c"), session '$(csess "$(pf "$PC2c")")', err: $(cat "$T/pl-err.txt")"
  PLS S-pkeep "$LS" release "$PB" "$PC2c" --model smoke
done
validate "$PB" >/dev/null
ok "plan claim ended during or after its own move into Working keeps its lease: claimed, the timer and the memory stay"

# P2e. a card moved out of Frontier into Working by someone else while the stake waits: the claim refuses and releases its stake
PC2e=$(ptk "Moved away"); F=$(pf "$PC2e"); RC=0
env CLAUDE_CODE_SESSION_ID=S-pmoved CLAUDE_PID="$LPID" TMPDIR="$LT" LEASE_TEST_STAKE_WAIT=2 LEASE_TEST_POLL=0.2 LEASE_TEST_RENEW_EVERY=1000 \
  "$PS/claim-ticket.sh" "$PB" "$PC2e" --model smoke >/dev/null 2>"$T/pl-err.txt" & CLP=$!
waitfor 'grep -q "^claimed" "$F"' || pl_fail "plan claim moved away: the stake never wrote claimed"
mv "$(dirname "$F")" "$(dirname "$(lane_of "$PB" Working)")/$PC2e"; wait "$CLP" 2>/dev/null || RC=$?
[ $RC = 1 ] && [ "$(plb "$PC2e")" = Working ] && ! grep -q -E '^(claimed:|  (by|until):)' "$(pf "$PC2e")" && [ ! -e "$(pmem S-pmoved "$PC2e")" ] \
  && grep -q 'is in Working, not Frontier' "$T/pl-err.txt" && [ "$(pcount "$PC2e" '**Claimed**')" = 0 ] || pl_fail "plan claim on a card moved away: rc $RC, err: $(cat "$T/pl-err.txt")"
ok "plan claim on a card moved into Working by someone else during the stake exits 1 and releases its stake"

# P2d. a stake refused with exit 2 (a session id with a space) leaves nothing to release: no false "release by hand"
PC2d=$(ptk "Bad session"); H=$(sum "$PB")
RC=0; env CLAUDE_CODE_SESSION_ID='a b' CLAUDE_PID="$LPID" TMPDIR="$LT" "$PS/claim-ticket.sh" "$PB" "$PC2d" --model smoke >/dev/null 2>"$T/pl-err.txt" || RC=$?
[ $RC = 1 ] && [ "$H" = "$(sum "$PB")" ] && grep -q 'stake exit 2' "$T/pl-err.txt" && ! grep -q 'by hand' "$T/pl-err.txt" \
  || pl_fail "plan claim on a stake exit 2: rc $RC, err: $(cat "$T/pl-err.txt")"
ok "plan claim refused by a stake exit 2 writes nothing and prints no release by hand"

# P3. two claims at once from two sessions: one holder, one Claimed comment
PC3=$(ptk "Raced")
( RC=0; PLS S-pra "$PS/claim-ticket.sh" "$PB" "$PC3" --model smoke >/dev/null 2>&1 || RC=$?; echo "$RC" > "$T/pr-a" ) & RPA=$!
( RC=0; PLS S-prb "$PS/claim-ticket.sh" "$PB" "$PC3" --model smoke >/dev/null 2>&1 || RC=$?; echo "$RC" > "$T/pr-b" ) & RPB=$!
wait "$RPA" "$RPB"; RA=$(cat "$T/pr-a"); RB=$(cat "$T/pr-b"); WIN=$(csess "$(pf "$PC3")")
{ { [ "$RA$RB" = 01 ] && [ "$WIN" = S-pra ]; } || { [ "$RA$RB" = 10 ] && [ "$WIN" = S-prb ]; }; } && [ "$(plb "$PC3")" = Working ] && [ "$(pcount "$PC3" '**Claimed**')" = 1 ] \
  || pl_fail "plan claim race: a=$RA b=$RB holder=$WIN lane $(plb "$PC3") claimed comments $(pcount "$PC3" '**Claimed**')"
LOSER=S-pra; [ "$WIN" = S-pra ] && LOSER=S-prb; [ ! -e "$(pmem "$LOSER" "$PC3")" ] && [ "$(pcount "$PC3" "**Lease lost**")" = 0 ] || pl_fail "plan claim race: the loser kept a lease memory or a loss was recorded"
PLS "$WIN" "$LS" release "$PB" "$PC3" --model smoke; validate "$PB" >/dev/null
ok "plan claim race leaves one holder: one exit 0, one exit 1, one Claimed comment, the lease naming the winner"

# P4. no session id, or no CLAUDE_PID: exit 1, nothing written (--session is a stamp label, never the holder)
PC4=$(ptk "Sessionless"); H=$(sum "$PB")
RC=0; env -u CLAUDE_CODE_SESSION_ID CLAUDE_PID="$LPID" TMPDIR="$LT" "$PS/claim-ticket.sh" "$PB" "$PC4" --model smoke --session s1 >/dev/null 2>&1 || RC=$?
RC2=0; env -u CLAUDE_PID CLAUDE_CODE_SESSION_ID=S-pa TMPDIR="$LT" "$PS/claim-ticket.sh" "$PB" "$PC4" --model smoke >/dev/null 2>&1 || RC2=$?
[ "$RC$RC2" = 11 ] && [ "$H" = "$(sum "$PB")" ] && [ "$(plb "$PC4")" = Frontier ] || pl_fail "plan claim without a session id or CLAUDE_PID: rc $RC $RC2"
ok "plan claim without a session id (--session given or not) or a CLAUDE_PID exits 1 and writes nothing"

# P5. resolve drops claimed (the flow line of a short session id, the 3-line block of a real one) with waiting, and stops the timer
SIDP=$(uuidgen | tr A-Z a-z); PC5=$(ptk "Flow lease"); PC5b=$(ptk "Block lease")
pclaim S-pa "$PC5"; pclaim "$SIDP" "$PC5b"; grep -q '^claimed: {' "$(pf "$PC5")" && grep -q '^claimed:$' "$(pf "$PC5b")" || pl_fail "plan resolve: the fixtures are not one flow and one block claimed"
for e in "S-pa $PC5" "$SIDP $PC5b"; do
  read -r s c <<<"$e"; TP=$(pmpid "$s" "$c"); F=$(pf "$c"); awk -v w="$WBLOCK" '{print} /^order:/ {print w}' "$F" > "$T/pw.md"; mv "$T/pw.md" "$F"
  RC=0; pres "$s" "$c" --session R-label >/dev/null 2>"$T/pl-err.txt" || RC=$?
  # one write: the card's last stamp is the resolve's own (--session R-label), never a release clearing claimed after it
  [ $RC = 0 ] && [ "$(plb "$c")" = Resolved ] && ! grep -q -E '^(waiting:|  (for|since|comment):)' "$(pf "$c")" && released "$s" "$c" "$TP" \
    && grep -q '^modified: {at: [0-9TZ:-]*, by: {name: claude, kind: agent, model: smoke, session: "R-label"}}$' "$(pf "$c")" \
    || { cat "$(pf "$c")"; pl_fail "plan resolve did not release ($s): rc $RC, err: $(cat "$T/pl-err.txt")"; }
done
validate "$PB" >/dev/null; ok "plan resolve releases the lease: no claimed in flow or block form, waiting dropped with it, the timer stopped, no Lease lost record"

# P6. resolve refuses another session's lease, writing nothing: one this session lost (the check posts the one loss record), and one
# it never held, live or lapsed. A Working ticket with no lease (claimed before the lease) still resolves
# the lost one: its timer stopped first, so the resolve's own check finds the loss (else the timer may post the record first)
PC6=$(ptk "Lost"); pclaim S-pa "$PC6"; TP=$(pmpid S-pa "$PC6"); kill "$TP" 2>/dev/null || true; waitfor "! alive $TP"; setclaim "$(pf "$PC6")" S-pthief "$(iso $(( $(date -u +%s) + 1500 )))"; H=$(shasum < "$(pf "$PC6")")
RC=0; pres S-pa "$PC6" >/dev/null 2>"$T/pl-err.txt" || RC=$?
[ $RC = 1 ] && [ "$(plb "$PC6")" = Working ] && [ "$H" = "$(shasum < "$(pf "$PC6")")" ] && [ "$(pcount "$PC6" "**Lease lost**")" = 1 ] \
  || pl_fail "plan resolve on a lost lease: rc $RC, lane $(plb "$PC6"), loss records $(pcount "$PC6" "**Lease lost**"), err: $(cat "$T/pl-err.txt")"
PLS S-pthief "$LS" release "$PB" "$PC6" --model smoke   # the stand-in thief's claimed, written by hand: gone before the last check
PC6b=$(ptk "Theirs"); pclaim S-powner "$PC6b"
for u in "$(iso $(( $(date -u +%s) + 1500 )))" "$(iso $(( $(date -u +%s) - 60 )))"; do
  setclaim "$(pf "$PC6b")" S-powner "$u"; H=$(sum "$PB"); RC=0; pres S-pa "$PC6b" >/dev/null 2>"$T/pl-err.txt" || RC=$?
  [ $RC = 1 ] && [ "$(plb "$PC6b")" = Working ] && [ "$H" = "$(sum "$PB")" ] && grep -q S-powner "$T/pl-err.txt" \
    || pl_fail "plan resolve over another session's lease (until $u): rc $RC, err: $(cat "$T/pl-err.txt")"
done
PLS S-powner "$LS" release "$PB" "$PC6b" --model smoke
RC=0; pres S-pa "$PC6b" >/dev/null || RC=$?; [ $RC = 0 ] && [ "$(plb "$PC6b")" = Resolved ] || pl_fail "plan resolve of a Working ticket with no lease: rc $RC"
validate "$PB" >/dev/null; ok "plan resolve refuses another session's lease: lost here (one Lease lost record) or never held here, live or lapsed: exit 1, nothing written; a Working ticket with no lease resolves"

# P7. out of scope from Working releases
PC7=$(ptk "Ruled out"); pclaim S-pa "$PC7"; TP=$(pmpid S-pa "$PC7")
RC=0; pres S-pa "$PC7" --to out-of-scope >/dev/null || RC=$?
[ $RC = 0 ] && [ "$(plb "$PC7")" = "Out of scope" ] && released S-pa "$PC7" "$TP" || pl_fail "plan out-of-scope from Working: rc $RC, lane $(plb "$PC7")"
ok "plan out-of-scope from Working releases the lease"

# P8. resume: lease.sh stake on a Working ticket, no move. Refused while the holder's lease is live; staked after a release; a lapsed
# lease of a session that died is taken after the notice (the knob's wait), and the taker resolves
PC8=$(ptk "Resumed"); standin; PCP=$SP pclaim S-pfirst "$PC8"; O8=$(sed -n 's/^order: //p' "$(pf "$PC8")")
RC=0; PLS S-pnext "$LS" stake "$PB" "$PC8" --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 1 ] && [ "$(csess "$(pf "$PC8")")" = S-pfirst ] || pl_fail "plan resume over a live lease: rc $RC, holder $(csess "$(pf "$PC8")")"
PLS S-pfirst "$LS" release "$PB" "$PC8" --model smoke; RC=0; PLS S-pnext "$LS" stake "$PB" "$PC8" --model smoke >/dev/null || RC=$?
[ $RC = 0 ] && [ "$(csess "$(pf "$PC8")")" = S-pnext ] && [ "$(plb "$PC8")" = Working ] && [ "$(sed -n 's/^order: //p' "$(pf "$PC8")")" = "$O8" ] \
  && [ "$(pcount "$PC8" "**Takeover notice**")" = 0 ] || pl_fail "plan resume after a release: rc $RC, holder $(csess "$(pf "$PC8")")"
PLS S-pnext "$LS" release "$PB" "$PC8" --model smoke
PC8b=$(ptk "Orphaned"); standin; DEAD=$SP; PCP=$DEAD pclaim S-pdead "$PC8b"; TP=$(pmpid S-pdead "$PC8b")
kill "$DEAD"; waitfor "! alive $TP" || pl_fail "plan resume: the dead session's timer outlived its CLAUDE_PID"
RC=0; PLS S-pnext "$LS" stake "$PB" "$PC8b" --model smoke >/dev/null 2>&1 || RC=$?
[ $RC = 1 ] && [ "$(csess "$(pf "$PC8b")")" = S-pdead ] || pl_fail "plan resume took a live lease of a dead session: rc $RC"
setclaim "$(pf "$PC8b")" S-pdead "$(iso $(( $(date -u +%s) - 60 )))"
t0=$(date +%s); RC=0; PLS S-pnext "$LS" stake "$PB" "$PC8b" --model smoke >/dev/null || RC=$?
[ $RC = 0 ] && [ "$(( $(date +%s) - t0 ))" -ge 1 ] && [ "$(csess "$(pf "$PC8b")")" = S-pnext ] && [ "$(plb "$PC8b")" = Working ] \
  && [ "$(pcount "$PC8b" "**Takeover notice**")" = 1 ] || pl_fail "plan resume of a lapsed lease: rc $RC, holder $(csess "$(pf "$PC8b")")"
TP=$(pmpid S-pnext "$PC8b"); RC=0; pres S-pnext "$PC8b" >/dev/null || RC=$?
[ $RC = 0 ] && [ "$(plb "$PC8b")" = Resolved ] && released S-pnext "$PC8b" "$TP" || pl_fail "plan resume: the taker's resolve: rc $RC"
validate "$PB" >/dev/null; ok "plan resume stakes a Working ticket without moving it: refused while the lease is live, staked after a release, and a dead session's lapsed lease taken after the notice"

# every plan case released what it staked: no lease on the board, no timer for it
[ -z "$("$LS" list "$PB")" ] && waitfor '[ -z "$(pgrep -f "$LS _timer $PBR " || true)" ]' || pl_fail "plan cases left a lease or a timer: $("$LS" list "$PB")"
ok "plan cases leave no lease and no timer on their board"

# 13. nothing left: release what is held, end the stand-ins; every timer must be gone within a poll
for c in $(awk -F'\t' '$4=="live"{print $1}' <<<"$("$LS" list "$LB")"); do
  s=$(csess "$(lcf "$c")"); L "$s" release "$LB" "$c" --model smoke >/dev/null || true; done
for p in ${LSP[@]+"${LSP[@]}"} "$PSP"; do kill "$p" 2>/dev/null || true; done; LSP=()
waitfor '[ -z "$(pgrep -f "$LS _timer" || true)" ]' || { echo "timers left:"; pgrep -fl "$LS _timer"; exit 1; }
validate "$LB" >/dev/null; ok "lease: no timer process is left after the run"

# usage guard: every script run with no arguments exits 2 (64 for the heal scripts) and its header states that code: in the comment lines (shell) or module docstring (.py) among the first 60 lines.
# A script that needs no arguments is listed in NOARG with its code. Catches a new script with no stated usage code, and a code change
# that leaves its header behind. A floor, not a proof: it does not check refusal codes. GUARD_DIR overrides the scanned skills dir (self-test).
# NOARG: "name=code" words for a script that needs no arguments (bash 3.2 has no associative arrays); none yet
NOARG=""
for ug_s in "${GUARD_DIR:-$SK}"/*/scripts/*; do
  ug_n=$(basename "$ug_s"); [ "$ug_n" != lib.sh ] || continue
  case "$ug_n" in heal-board.py|heal-descriptors.py) ug_want=64 ;; *) ug_want=2 ;; esac
  for ug_e in $NOARG; do [ "${ug_e%%=*}" != "$ug_n" ] || ug_want=${ug_e#*=}; done
  ug_rc=0; env -u CLAUDE_MODEL -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID perl -e 'alarm 10; exec @ARGV' "$ug_s" </dev/null >/dev/null 2>&1 || ug_rc=$?
  [ "$ug_rc" = "$ug_want" ] || { echo "$ug_s with no arguments exits $ug_rc, want $ug_want"; exit 1; }
  # the header's prose only: comment lines of a shell script, the module docstring of a .py (code lines like `exit 2` do not count)
  case "$ug_n" in
    *.py) ug_hdr=$(head -60 "$ug_s" | awk '/"""/ { c += gsub(/"""/, "&") } c >= 1 { print } c >= 2 { exit }') ;;
    *) ug_hdr=$(head -60 "$ug_s" | grep -E '^[[:space:]]*#' || true) ;;
  esac
  grep -qi "exit $ug_want" <<<"$ug_hdr" || { echo "$ug_s: first 60 lines never say 'exit $ug_want'"; exit 1; }
done
ok "usage guard: every script with no arguments exits 2 (64 for heal), and its header says so"

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
