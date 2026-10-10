#!/bin/bash
# smoke.sh: run every skill script against throwaway boards; validate with a board's schema.
# usage: tests/smoke.sh [<scratch dir>]   (default: a fresh mktemp dir, removed on success)
# The validator is borrowed from the Skills Pipeline board's app-installed .schema/.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; SK="$ROOT/skills"
VAL="$ROOT/Lanework/Skills Pipeline.lanework/.schema"
T="${1:-$(mktemp -d "${TMPDIR:-/tmp}/lanework-smoke.XXXXXX")}"
pass=0
ok() { pass=$((pass+1)); echo "ok $pass - $1"; }
validate() {
  local out; out=$(python3 "$VAL/bin/lanework-validate.py" --schema "$VAL" "$1")
  grep -q '^failures    0 ' <<<"$out" && ! grep -q DEPRECATED <<<"$out" || { echo "$out"; return 1; }
  grep -o 'documents   [0-9]*' <<<"$out"
}

for s in "$SK"/*/scripts/*.sh "$ROOT"/scripts/*.sh; do case "$(head -1 "$s")" in *zsh*) zsh -n "$s" ;; *) bash -n "$s" ;; esac; done
for s in "$SK"/*/scripts/*.py; do [ -e "$s" ] || continue; python3 -c 'import ast,sys; ast.parse(open(sys.argv[1]).read(), sys.argv[1])' "$s"; done
ok "syntax check on every script, by its shebang"

# names: the racing names are retired; no skill folder or plugin.json entry may carry them
for n in pitlane pitwall; do
  [ ! -e "$SK/$n" ] || { echo "skill folder skills/$n still exists (renamed to work and watch)"; exit 1; }
  if grep -q "\"./skills/$n\"" "$ROOT/.claude-plugin/plugin.json"; then echo "plugin.json still lists skills/$n"; exit 1; fi
done
ok "no skill folder or plugin.json entry is named pitlane or pitwall"

# folder convention: Lanework/ first, then Boards/, then legacy Pitlane/; the legacy name lives only in finding.md
hits=$(grep -rn Pitlane "$SK" || true)
[ -z "$hits" ] || [ -z "$(grep -v '^[^:]*/lanework/references/finding\.md:[0-9]*:.*legacy' <<<"$hits")" ] \
  || { echo "Pitlane named outside finding.md's legacy entry:"; echo "$hits"; exit 1; }
F="$SK/lanework/references/finding.md"
l=$(grep -n 'Lanework/' "$F" | head -1 | cut -d: -f1); b=$(grep -n 'Boards/' "$F" | head -1 | cut -d: -f1)
[ -n "$l" ] && [ -n "$b" ] && [ "$l" -lt "$b" ] || { echo "finding.md must name Lanework/ before Boards/"; exit 1; }
[ "$(grep -o 'for f in [A-Za-z ]*;' "$F" | head -1)" = "for f in Lanework Boards Pitlane;" ] || { echo "finding.md's find loop must run Lanework Boards Pitlane in that order"; exit 1; }
ok "legacy folder name only in finding.md, which lists Lanework/ first, in the table and the find loop"

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
labels: [{text: Open, rank: 1, color: fern, kind: {type: status, text: Status, icon: {glyph: circle}}}, {text: Closed, rank: 2, kind: {type: status, text: Status, icon: {glyph: circle}}}]
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
component: {text: Sync}
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
labels: [{text: Weird, rank: 9, kind: {type: alien, text: Alien}}, {text: bug, kind: {type: text, text: Text, icon: {glyph: tag}}}]
project: x
created:  $STAMP
modified: $STAMP
EOF
cp -R "$H" "$T/heal-seed"
sum() { find "$1" -type f -print0 | sort -z | xargs -0 shasum | shasum; }
if validate "$H" >/dev/null 2>&1; then echo "seeded damage passed the validator"; exit 1; fi
S0=$(sum "$H"); O=$("$HEAL" "$H")
for k in stale-label single-kind bare-labels string-kind root-key root-key-dropped text-kind bare-glyph bare-stamp title-quote definition added-definition bare-icon retired-key; do
  grep -q " $k " <<<"$O" || { echo "dry run did not list $k:"; echo "$O"; exit 1; }
done
[ "$S0" = "$(sum "$H")" ]; ok "heal dry run lists every kind of damage and writes nothing"
"$HEAL" "$H" --apply --name fixer --model test >/dev/null; validate "$H" >/dev/null
hfail() { echo "heal check failed: $1"; exit 1; }
c() { sed -n '2,/^---$/p' "$HL/c0000000-0000-4000-8000-00000000000$1/index.md"; }
c 1 | grep -qF 'labels: [{text: "Open", rank: 1, color: "fern", kind: {type: "status", text: "Status", icon: {glyph: "circle"}}}]' || hfail stale-label
c 2 | grep -q '^labels: \[{text: "Open"' && ! c 2 | grep -q Closed && grep -q 'Kept `Open`; dropped `Closed`' "$HL"/c*02/comments/*/index.md || hfail single-kind
c 3 | grep -qF 'labels: [{text: "bug", kind: {type: "text", text: "Text", icon: {glyph: "tag"}}}]' || hfail bare-labels
c 4 | grep -qF '{text: "Closed", rank: 2, kind: {type: "status"' || hfail string-kind
for p in 'text: "High"' 'rank: 1' 'color: "#E07A1F"' 'glyph: "exclamationmark"' 'type: "priority"' 'text: "Sync"' 'color: "aluminum"' 'type: "component"'; do
  c 5 | grep -qF "$p" || hfail "root-key ($p)"; done
! c 5 | grep -q '^priority:' && ! c 6 | grep -q '^priority:' && c 6 | grep -q 'text: "Low"' && ! c 6 | grep -q Urgent \
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
sed -n '/^config:/,/^created:/p' "$H/index.md" | grep -q 'type: "component"' && ! grep -q 'default\|glyph: circle$\|value:' "$H/index.md" || hfail definition
ok "heal --apply repairs each one and the board validates with no DEPRECATED line"
grep -q "^modified: $STAMP$" "$HL"/c*08/comments/d*/index.md && grep -q 'type: alien' "$HL"/c*09/index.md && grep -q '^project: x$' "$HL"/c*09/index.md && grep -q "^modified: $STAMP$" "$HL"/c*09/index.md \
  && grep -q "^modified: $STAMP$" "$HL/index.md" && grep -q "^modified: $STAMP$" "$H/index.md" \
  && cmp -s "$HL"/c*0d/index.md "$T/heal-seed/${HL##*/}"/c*0d/index.md && grep -q '^skip .*c0000000-0000-4000-8000-00000000000d.* #' <<<"$O" || hfail untouched
ok "heal leaves a clean card, a foreign entry, an unknown key, a \` #\` title and every stamp as written"
S1=$(sum "$H"); O=$("$HEAL" "$H" --apply --name fixer --model test); [ "$S1" = "$(sum "$H")" ] && grep -q '^0 repairs' <<<"$O" || { echo "$O"; exit 1; }
ok "a second heal --apply changes nothing"
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
"$HEAL" "$H2" --apply --name fixer --model test >/dev/null
V=$(python3 "$H2/.schema/bin/lanework-validate.py" "$H2"); grep -q '^failures    0 ' <<<"$V" && ! grep -q DEPRECATED <<<"$V" || { echo "$V"; exit 1; }
ok "a board with its own .schema/ heals the same, against its own validator"
cp -R "$VAL" "$H/.schema"; touch "$H/.schema/bin/lanework-heal.py"
if "$HEAL" "$H" 2>/dev/null; then echo "skill copy ran where the board ships its own"; exit 1; fi
ok "heal defers to the board's own .schema/bin/lanework-heal.py"

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
"$SK/discovery/scripts/settle-question.sh" "$D" "$C1" --ruling "$T/r1.md" --record "$T/rec.md" --reply "$A1" --model smoke >/dev/null
"$SK/discovery/scripts/settle-question.sh" "$D" "$C2" --ruling "$T/r1.md" --to parked --model smoke >/dev/null
! grep -q '^waiting:' "$D"/*/"$C1"/index.md && grep -q "in-reply-to: $A1" "$D"/*/"$C1"/comments/*/index.md
ok "settled with chat record in reply to the ask; parked"
validate "$D" >/dev/null; ok "discovery board validates"

# discovery: Decisions lane founded in order, record + status kinds declared, file-record.sh files ADR and PDR cards
lane_order() { sed -n 's/^order: //p' "$(grep -l "^title: \"$1\"\$" "$D"/*/index.md | head -1)"; }
[ "$(lane_order Settled)" = 4096 ] && [ "$(lane_order Decisions)" = 4608 ] && [ "$(lane_order Parked)" = 5120 ] || { echo "Decisions lane missing or out of order"; exit 1; }
ok "Decisions lane founded at 4608, between Settled and Parked"
{ grep -q '{type: round, text: Round, single: true}' "$D/index.md" &&
  grep -q '{type: record, text: Record, single: true, values: \[{text: ADR, rank: 1}, {text: PDR, rank: 2}\]}' "$D/index.md" &&
  grep -q '{type: status, text: Status, single: true, values: \[{text: accepted, rank: 1}, {text: deprecated, rank: 2}, {text: superseded, rank: 3}\]}' "$D/index.md"; } || { echo "record/status label kinds missing from config.labels"; exit 1; }
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
{ grep -qx 'labels: \[{text: ADR, rank: 1, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}\]' "$n1" &&
  grep -qx 'labels: \[{text: PDR, rank: 2, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}\]' "$n2"; } || { echo "record/status labels not flattened"; exit 1; }
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

# work: lint-ask
printf '@owner Should we ship it?\n\nIf no answer: blocked.\nContext: the comment above.\n' > "$T/good.md"
printf '@owner maybe ship it; worth a try? and also this?\n' > "$T/bad.md"
"$SK/work/scripts/lint-ask.sh" "$T/good.md"; ok "lint-ask passes a clean ask"
if "$SK/work/scripts/lint-ask.sh" "$T/bad.md" >/dev/null; then exit 1; fi; ok "lint-ask fails a hedged, chained ask"

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
  [ ! -e "$T/snap.skills" ] || { echo "no --skills, yet a .skills state file appeared"; exit 1; }; ok "watch-boards: without --skills there is no skills state and no behavior change"

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
else
  echo "skip - fswatch not installed"
fi

# merge: one scratch repo, two clones, every rule row; driver + pass as a merge and as a rebase, and the pass alone
for m in merge rebase nodriver; do "$ROOT/tests/merge-case.sh" "$T" "$m" >/dev/null; ok "merge case: every row resolves with no prompt, as a $m"; done
"$ROOT/tests/merge-case.sh" "$T" clean >/dev/null; ok "merge case: git finishes a lossless merge alone, stops on a loss, and a comment left by a move is re-homed"
"$ROOT/tests/merge-case.sh" "$T" rebasemove >/dev/null; ok "merge case: a rebase with a later move leaves no orphaned folder"
"$ROOT/tests/merge-case.sh" "$T" dirty >/dev/null; ok "merge case: uncommitted edits in a conflicted card are carried as ours, never erased"

# lane actors: every lane body names its actor and trigger; the lane -> actor table lives once; heal-descriptors brings old boards to currency
lane_file() { grep -l "^title: \"$2\"\$" "$1"/*/index.md | head -1; }
lane_body() { tail -1 "$(lane_file "$1" "$2")"; }
for b in "$P" "$T/design-loop.lanework" "$T/datapoint.lanework" "$D"; do
  for f in "$b"/*/index.md; do
    lb=$(tail -1 "$f"); { [ -n "$lb" ] && [ "$lb" != --- ] && grep -qE '[.!?] [A-Z`]' <<<"$lb"; } || { echo "lane body missing or one sentence: $f"; exit 1; }
  done
done
ok "every lane of a founded pipeline, design-loop, datapoint and discovery board has a body of two sentences or more"
grep -q 'unasked' <<<"$(lane_body "$P" Approved)" || { echo "the Approved body must say an agent takes the top card unasked"; exit 1; }
for l in Ideas Issues Tasks; do b=$(lane_body "$P" $l)
  ! grep -qiE 'unasked|without waiting|agents? (act|build|shape|fix)|builds? (it|them)|shapes? (it|them)' <<<"$b" || { echo "$l is a holding lane: its body must not have agents act unasked: $b"; exit 1; }
done
grep -q "^- \*\*Agent lanes\*\*: Shaping, Approved and Active: agents act on cards there unasked. Elsewhere they may read, link, research and answer, but move a card out or start its work only when asked" "$P/index.md" || { echo "pipeline board sheet has no Agent lanes line carrying the rule"; exit 1; }
! grep -q 'has passed both' "$P/index.md" || { echo "the sheet still says a Tasks chore has passed both gates"; exit 1; }
ok "Approved takes the top card unasked; Ideas, Issues and Tasks bodies have agents act on nothing; the sheet's Agent lanes line carries the rule"
[ "$(grep -rlE '^\| lane \| who acts \|' "$SK" | sed "s#^$SK/##")" = "lanework/references/board-kinds.md" ] || { echo "the lane -> actor table must live only in lanework/references/board-kinds.md"; exit 1; }
for l in Ideas Issues Tasks Shaping Proposed Approved Active Done; do grep -qE "^\| $l \|" "$SK/lanework/references/board-kinds.md" || { echo "board-kinds.md table has no $l row"; exit 1; }; done
! grep -qE '^\| (Done|Dead ends|Filed|Facts|Settled|Decisions|Parked) \| agent ' "$SK/lanework/references/board-kinds.md" || { echo "a lane an agent only files into is marked agent (a work order for the arming pass): use none"; exit 1; }
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
  - {text: Bug, rank: 1, icon: {glyph: ladybug}, kind: {type: type, text: Type, icon: {glyph: square.grid.2x2}}}
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
[ "$(norm_index "$LD/D Discovery.lanework/index.md")" = "$(sed 's/{type: round, text: Round}/{type: round, text: Round, single: true}/' "$ROOT/tests/fixtures/founded-discovery-index.md")" ] || { norm_index "$LD/D Discovery.lanework/index.md"; exit 1; }
validate "$LD/D Discovery.lanework" >/dev/null
ok "a founded discovery board takes round from the catalog: config byte-identical to the pre-catalog founding except round gains single: true, and it validates"
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
# heal-board.py: embedded SUGGESTED priority and component equal the catalog rows; a copy with no catalog beside it still heals
python3 - "$SK/lanework/scripts/heal-board.py" "$LK" <<'PY' || { echo "heal's embedded SUGGESTED differs from the catalog rows"; exit 1; }
import importlib.util, sys; sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("hb", sys.argv[1]); hb = importlib.util.module_from_spec(spec); spec.loader.exec_module(hb)
rows = {}
for line in open(sys.argv[2]):
    if line.startswith("| ") and line.count("|") >= 3:
        cells = [c.strip() for c in line.strip().strip("|").split("|", 1)]
        if cells[0] in ("priority", "component"): rows[cells[0]] = hb.inline(cells[1])
assert sorted(rows) == ["component", "priority"], rows
assert [s["type"] for s in hb.EMBEDDED_SUGGESTED] == ["priority", "component"]
assert all(s == rows[s["type"]] for s in hb.EMBEDDED_SUGGESTED), (hb.EMBEDDED_SUGGESTED, rows)
assert hb.SUGGESTED == hb.EMBEDDED_SUGGESTED
PY
ok "heal-board.py's embedded SUGGESTED priority and component equal the label-kinds.md rows"
mkdir -p "$LD/solo"; cp "$SK/lanework/scripts/heal-board.py" "$LD/solo/lanework-heal.py"
"$FB" "$LD/Solo.lanework" --index "$LD/idx.md" --lanes "$SK/lanework/templates/datapoint-lanes.md" --model smoke >/dev/null
SC="$LD/Solo.lanework/$(ls "$LD/Solo.lanework" | grep -v -E '^(index.md|\.)' | head -1)"; SCD="$SC/$(uuidgen | tr A-Z a-z)"; mkdir -p "$SCD"
printf '%s\n' '---' 'schema: 1' 'kind: card' 'title: "Old"' 'order: 1024' 'priority: High' 'created:  {at: 2026-10-10T00:00:00Z}' 'modified: {at: 2026-10-10T00:00:00Z}' '---' 'Body.' > "$SCD/index.md"
python3 "$LD/solo/lanework-heal.py" "$LD/Solo.lanework" --apply --name fixer --model smoke >/dev/null
grep -q 'type: "\?priority"\?' "$LD/Solo.lanework/index.md" && grep -q 'Urgent' "$LD/Solo.lanework/index.md" && ! grep -q '^priority:' "$SCD/index.md" || { cat "$LD/Solo.lanework/index.md"; exit 1; }
validate "$LD/Solo.lanework" >/dev/null
ok "heal-board.py run from a copy outside the skill tree (no catalog beside it) uses the embedded copy and heals a missing priority definition"

"$ROOT/tests/check-refs.sh" >/dev/null; ok "every cited skill file exists"
"$ROOT/tests/check-sizes.sh" || { echo "README § Sizes is out of date: fix the rows named above"; exit 1; }; ok "README sizes match wc -w, rows, totals and summary"

# format rules: skills point at the guide, never prescribe priority/component as card keys (retired, guide v82)
H=$({ grep -rn -i -E '\b(priority|component):|(priority|component)[^.]*(root|top-level)|(root|top-level)[^.]*(priority|component)' "$SK" || true; } | grep -v -i 'reserved' || true)
[ -z "$H" ] || { echo "a skill prescribes priority/component as a card key (they are labels entries, see the guide): $H"; exit 1; }
ok "no skill prescribes priority: or component: as a card key"

# versions: no skill names a guide version; the one stamp lives in the repo's CLAUDE.md
H=$({ grep -r -l -i -E 'lanework-(agent-guide|schema) +v[0-9]+' "$SK" || true; })
[ -z "$H" ] || { echo "a skill names a guide version (the stamp lives only in CLAUDE.md): $H"; exit 1; }
S=$({ grep -o -E 'lanework-agent-guide v[0-9]+' "$ROOT/CLAUDE.md" || true; })
[ "$(printf '%s\n' "$S" | grep -c .)" -eq 1 ] || { echo "CLAUDE.md must carry exactly one guide stamp, found: ${S:-none}"; exit 1; }
SV=$({ grep -o -E 'lanework-schema v[0-9]+' "$ROOT/CLAUDE.md" || true; })
[ "$(printf '%s\n' "$SV" | grep -c .)" -eq 1 ] || { echo "CLAUDE.md must carry exactly one schema stamp, found: ${SV:-none}"; exit 1; }
ok "no skill names a guide version; one stamp ($S, $SV), in CLAUDE.md"

# release gate: the Skills Pipeline board's guide and schema must not be newer than the stamp
BG=$(head -1 "$VAL/../CLAUDE.md" | grep -o -E 'lanework-agent-guide v[0-9]+' | grep -o -E '[0-9]+$' || true)
BS=$(head -1 "$VAL/VERSION" | tr -d '\r' | grep -o -E 'lanework-schema v[0-9]+ *$' | grep -o -E '[0-9]+' || true)
[ -n "$BG" ] && [ -n "$BS" ] || { echo "can't read the board's guide or schema version"; exit 1; }
[ "$BG" -le "${S##*v}" ] || { echo "board guide v$BG is newer than the stamp ($S): read every skill against it, fix the drift, then bump the stamp in CLAUDE.md"; exit 1; }
[ "$BS" -le "${SV##*v}" ] || { echo "board schema v$BS is newer than the stamp ($SV): read every skill against it, fix the drift, then bump the stamp in CLAUDE.md"; exit 1; }
ok "the stamp ($S, $SV) is not behind the board's guide v$BG and schema v$BS"

# plugin: manifests agree with the skills folders; one version, in plugin.json
python3 - "$ROOT/.claude-plugin" "$SK" <<'EOF'
import json, os, sys
d, sk = sys.argv[1:]; p = json.load(open(f"{d}/plugin.json")); m = json.load(open(f"{d}/marketplace.json"))
want = sorted(f"./skills/{n}" for n in os.listdir(sk) if os.path.isfile(f"{sk}/{n}/SKILL.md"))
assert sorted(p["skills"]) == want, f"plugin.json skills {p['skills']} != folders {want}"
assert [e["name"] for e in m["plugins"]] == [p["name"]], "marketplace.json must list exactly the plugin in plugin.json"
assert "version" not in m["plugins"][0], "version lives only in plugin.json"
EOF
# claude plugin validate: errors fail (exit status). Warnings fail too, except the one known
# warning: this repo's CLAUDE.md is its dev guide, which sits at the plugin root by design.
# (--strict would turn that warning into an error, and can't be told to skip just it.)
if command -v claude >/dev/null; then
  V=$(claude plugin validate "$ROOT" 2>&1) || { echo "$V"; echo "plugin validate failed"; exit 1; }
  W=$(printf '%s\n' "$V" | grep -E '^ +❯ ' | grep -v -F 'root: CLAUDE.md at the plugin root is not loaded as project context' || true)
  [ -z "$W" ] || { echo "$V"; echo "plugin validate: unexpected warning"; exit 1; }
fi
ok "plugin manifests match the skills folders and validate"

echo "smoke: $pass passed"
[ -n "${1:-}" ] || rm -rf "$T"
