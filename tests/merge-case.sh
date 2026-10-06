#!/bin/bash
# merge-case.sh: the merge skill's smoke case. One scratch repo, cloned twice; each clone makes
# one instance of every row in merge/references/rules.md; then a merge (or rebase) with the driver
# installed, then merge-board.sh. Exits non-zero on the first failed assertion.
# usage: tests/merge-case.sh <scratch dir> merge|rebase|nodriver   (nodriver: the pass alone, after git's markers)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; SK="$ROOT/skills"
VAL="$ROOT/Pitlane/Skills Pipeline.lanework"
T="${1:?usage: merge-case.sh <dir> merge|rebase|nodriver}"; MODE="${2:?merge, rebase or nodriver}"
. "$SK/lanework/scripts/lib.sh"
MRG="$SK/merge/scripts/lanework-merge.py"
fail() { echo "merge-case ($MODE): $*" >&2; exit 1; }
G() { git -C "$1" "${@:2}"; }

W="$T/merge-$MODE"; rm -rf "$W"; mkdir -p "$W"
O="$W/origin"; mkdir -p "$O/Pitlane"; git init -q -b main "$O"
G "$O" config user.email t@t; G "$O" config user.name t
BN="Pitlane/Acme Pipeline.lanework"; P="$O/$BN"
"$SK/lanework/scripts/found-board.sh" "$P" --index "$SK/lanework/templates/pipeline-index.md" \
  --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Acme --var verified=x >/dev/null
cp -R "$VAL/.schema" "$P/.schema"; cp "$VAL/CLAUDE.md" "$P/CLAUDE.md"
lane() { basename "$(lane_by_title "$1/$BN" "$2")"; }
IDEAS=$(lane "$O" Ideas); APPROVED=$(lane "$O" Approved); ACTIVE=$(lane "$O" Active); DONE=$(lane "$O" Done)

T0=2026-01-01T00:00:00Z; TA=2026-01-02T00:00:00Z; TB=2026-01-03T00:00:00Z; TA2=2026-01-04T00:00:00Z
BY0='{name: owner, kind: human}'; BYA='{name: alice, kind: human}'; BYB='{name: bob, kind: human}'
TXT='kind: {type: text, text: Text, icon: {glyph: tag}}'
PRI='kind: {type: priority, text: Priority, icon: {glyph: flag}}'
for n in T1 Y1 K1 AT1 L1 S1 M1 M2 TR1 TR2 TT AA D1 KC AT; do eval "$n=$(uuid)"; done

# card <repo> <lane> <id> <title> <at> <by> <body> [extra frontmatter lines]
card() {
  local d="$1/$BN/$2/$3"; mkdir -p "$d"
  { printf -- '---\nschema: 1\nkind: card\ntitle: "%s"\norder: %s\n' "$4" "${ORD:-1024}"
    [ -n "${8:-}" ] && printf '%s\n' "$8"
    printf 'created:  {at: %s, by: {name: owner, kind: human, card: "%s"}}\nmodified: {at: %s, by: %s}\n---\n%s\n' "$T0" "$3" "$5" "$6" "$7"
  } > "$d/index.md"
}
comment() { # <card dir> <id> <at> <by> <body>
  mkdir -p "$1/comments/$2"
  printf -- '---\nschema: 1\nkind: comment\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n%s\n' \
    "$T0" "$BY0" "$3" "$4" "$5" > "$1/comments/$2/index.md"
}
setboard() { # <repo> <at> <by> <value:rank>...
  local f="$1/$BN/index.md" at="$2" by="$3" vals="" v; shift 3
  for v in "$@"; do vals="$vals        - text: \"${v%:*}\"\n          rank: ${v#*:}\n"; done
  perl -0pi -e "s/^config:.*?(?=^created:)/config:\n  show-card-body: 3\n  labels:\n    - type: \"status\"\n      text: \"Status\"\n      values:\n$vals/ms; s/^modified: .*\$/modified: {at: $at, by: $by}/m" "$f"
}
cardfile() { echo "$1/$BN/$(cd "$1/$BN" && ls -d */"$2" .trash/"$2" 2>/dev/null | head -1)/index.md"; }

# ---- base
for n in T1 Y1 K1 AT1 L1 S1 M1 M2 TR1 TR2 TT D1; do
  extra=""; [ "$n" = L1 ] && extra="labels: [{text: \"x\", $TXT}]"; ORD=1024; [ "$n" = S1 ] && ORD=5000
  ORD=$ORD card "$O" "$IDEAS" "${!n}" "$n base" "$T0" "$BY0" "$n base body." "$extra"
done
comment "$O/$BN/$IDEAS/$K1" "$KC" "$T0" "$BY0" "K1 base comment."
A="$O/$BN/$IDEAS/$AT1/attachments/$AT"; mkdir -p "$A"; printf 'base-bytes' > "$A/blob.png"
printf -- '---\nschema: 1\nkind: attachment\ntitle: "shot"\nextension: png\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n' "$T0" "$BY0" "$T0" "$BY0" > "$A/index.md"
setboard "$O" "$T0" "$BY0" Open:1
mkdir -p "$P/.log"; printf '# lanework-board-log v1\n2026-01-01T00:00:00Z info board.open base\n' > "$P/.log/2026-01-01.log"
python3 "$MRG" install "$O" >/dev/null
G "$O" add -A; G "$O" add -f "$BN/.log"; G "$O" commit -qm base
validate_board() {
  local out; out=$(python3 "$VAL/.schema/bin/lanework-validate.py" --schema "$VAL/.schema" "$1/$BN")
  grep -q '^failures    0 ' <<<"$out" && ! grep -q DEPRECATED <<<"$out" || { echo "$out"; fail "$2: board does not validate"; }
}
validate_board "$O" "base"

git clone -q "$O" "$W/A"; git clone -q "$O" "$W/B"
for c in A B; do G "$W/$c" config user.email "$c@t"; G "$W/$c" config user.name "$c"; done
A="$W/A"; B="$W/B"; mvcard() { G "$1" mv "$BN/$2/$3" "$BN/$4/$3"; }
restamp() { perl -pi -e "s/^modified: .*\$/modified: {at: $2, by: $3}/" "$(cardfile "$1" "$4")"; }

# ---- side A (earlier, except TR2)
card "$A" "$IDEAS" "$T1" "T1 alpha" "$TA" "$BYA" "T1 base body."
card "$A" "$IDEAS" "$Y1" "Y1 base" "$TA" "$BYA" "Y1 body TOKEN_A_Y1."
comment "$A/$BN/$IDEAS/$K1" "$KC" "$TA" "$BYA" "K1 comment TOKEN_A_K1."
printf 'A-bytes' > "$A/$BN/$IDEAS/$AT1/attachments/$AT/blob.png"
card "$A" "$IDEAS" "$L1" "L1 base" "$TA" "$BYA" "L1 base body." \
  "labels: [{text: \"x\", $TXT}, {text: \"y\", $TXT}, {text: \"High\", rank: 1, color: \"#E07A1F\", $PRI}]"
ORD=100 card "$A" "$IDEAS" "$S1" "S1 base" "$TA" "$BYA" "S1 base body." \
  "hero: $(uuid)"$'\n'"waiting: {for: alice, since: $TA, comment: $(uuid)}"
mvcard "$A" "$IDEAS" "$M1" "$APPROVED"; restamp "$A" "$TA" "$BYA" "$M1"
mvcard "$A" "$IDEAS" "$M2" "$DONE"; restamp "$A" "$TA" "$BYA" "$M2"
card "$A" "$IDEAS" "$TR1" "TR1 base" "$TA" "$BYA" "TR1 body TOKEN_A_TR1."
card "$A" "$IDEAS" "$TR2" "TR2 base" "$TA2" "$BYA" "TR2 body TOKEN_A_TR2."
mkdir -p "$A/$BN/.trash"; G "$A" mv "$BN/$IDEAS/$TT" "$BN/.trash/$TT"; restamp "$A" "$TA" "$BYA" "$TT"
card "$A" "$IDEAS" "$AA" "AA alpha" "$TA" "$BYA" "AA body TOKEN_A_AA."
card "$A" "$IDEAS" "$D1" "D1 base" "$TA" "$BYA" "D1 body TOKEN_A_D1."
setboard "$A" "$TA" "$BYA" Open:1 Doing:2
sed -i '' '1s/v[0-9][0-9]*/v900/' "$A/$BN/CLAUDE.md"
echo "2026-01-02T00:00:00Z info card.edit alice" >> "$A/$BN/.log/2026-01-01.log"
G "$A" add -A; G "$A" add -f "$BN/.log"; G "$A" commit -qm "side A"

# ---- side B (later, except TR2)
card "$B" "$IDEAS" "$T1" "T1 beta" "$TB" "$BYB" "T1 base body."
card "$B" "$IDEAS" "$Y1" "Y1 base" "$TB" "$BYB" "Y1 body TOKEN_B_Y1."
comment "$B/$BN/$IDEAS/$K1" "$KC" "$TB" "$BYB" "K1 comment TOKEN_B_K1."
printf 'B-bytes' > "$B/$BN/$IDEAS/$AT1/attachments/$AT/blob.png"
card "$B" "$IDEAS" "$L1" "L1 base" "$TB" "$BYB" "L1 base body." \
  "labels: [{text: \"x\", $TXT}, {text: \"z\", $TXT}, {text: \"Low\", rank: 3, icon: {glyph: arrow.down}, $PRI}]"
ORD=200 card "$B" "$IDEAS" "$S1" "S1 base" "$TB" "$BYB" "S1 base body." \
  "hero: $(uuid)"$'\n'"waiting: {for: bob, since: $TB, comment: $(uuid)}"
mvcard "$B" "$IDEAS" "$M1" "$ACTIVE"; restamp "$B" "$TB" "$BYB" "$M1"
card "$B" "$IDEAS" "$M2" "M2 base" "$TB" "$BYB" "M2 body TOKEN_B_M2."
mkdir -p "$B/$BN/.trash"
G "$B" mv "$BN/$IDEAS/$TR1" "$BN/.trash/$TR1"; restamp "$B" "$TB" "$BYB" "$TR1"
G "$B" mv "$BN/$IDEAS/$TR2" "$BN/.trash/$TR2"; restamp "$B" "$TB" "$BYB" "$TR2"
G "$B" mv "$BN/$IDEAS/$TT" "$BN/.trash/$TT"; restamp "$B" "$TB" "$BYB" "$TT"
card "$B" "$IDEAS" "$AA" "AA beta" "$TB" "$BYB" "AA body TOKEN_B_AA."
G "$B" rm -rq "$BN/$IDEAS/$D1"
setboard "$B" "$TB" "$BYB" Open:1 Closed:3
sed -i '' '1s/v[0-9][0-9]*/v901/' "$B/$BN/CLAUDE.md"
echo "2026-01-03T00:00:00Z info card.edit bob" >> "$B/$BN/.log/2026-01-01.log"
G "$B" add -A; G "$B" add -f "$BN/.log"; G "$B" commit -qm "side B"
validate_board "$A" "side A"; validate_board "$B" "side B"

# ---- the merge, in a clone with the driver installed
M="$W/M"; git clone -q "$A" "$M"; G "$M" config user.email m@t; G "$M" config user.name m
if [ "$MODE" != nodriver ]; then
  python3 "$MRG" install "$M" | grep -q 'already carries' || fail "install did not find the committed rule"
fi
G "$M" fetch -q "$B" main
if [ "$MODE" != rebase ]; then
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "expected the merge to stop on a rename/rename"; fi
else
  if G "$M" rebase -q FETCH_HEAD >/dev/null 2>&1; then fail "expected the rebase to stop on a rename/rename"; fi
fi
if [ "$MODE" = nodriver ]; then  # control: a clone without the driver gets git's markers
  grep -rIl '<<<<<<<' "$M/$BN" >/dev/null || fail "control: no conflict marker without the driver"
fi
OUT=$("$SK/merge/scripts/merge-board.sh" "$M" </dev/null) || { echo "$OUT"; fail "merge-board.sh exited non-zero"; }
echo "$OUT" | grep -q '^Board merge' || { echo "$OUT"; fail "no report paragraph"; }
[ -z "$(G "$M" diff --name-only --diff-filter=U)" ] || fail "unmerged paths left"
if [ "$MODE" != rebase ]; then G "$M" commit -q --no-edit; else GIT_EDITOR=true G "$M" rebase --continue >/dev/null 2>&1 || fail "rebase --continue"; fi
[ -z "$(G "$M" status --porcelain -- "$BN")" ] || { G "$M" status --porcelain; fail "board paths left uncommitted"; }

D="$M/$BN"
if grep -rIl '<<<<<<<\|>>>>>>>' "$D" >/dev/null; then fail "a conflict marker survived"; fi
validate_board "$M" "merged"
for tok in TOKEN_A_Y1 TOKEN_B_Y1 TOKEN_A_K1 TOKEN_B_K1 TOKEN_B_M2 TOKEN_A_TR1 TOKEN_A_TR2 TOKEN_A_AA TOKEN_B_AA TOKEN_A_D1 \
  '"T1 alpha"' 'T1 beta' A-bytes B-bytes; do grep -rqF -- "$tok" "$D" || fail "lost: $tok"; done
at() { [ -f "$D/$1/$2/index.md" ] || fail "$3: not in $1 ($(cd "$D" && ls -d */"$2" .trash/"$2" 2>/dev/null))"; }
at "$ACTIVE" "$M1" "moved both ways: later lane"; at "$DONE" "$M2" "moved one side, edited other"
at .trash "$TR1" "later trash"; at "$IDEAS" "$TR2" "later edit restores to base lane"; at .trash "$TT" "trashed on both"
at "$IDEAS" "$D1" "deleted vs edited"; at "$IDEAS" "$AA" "added on both"
[ "$(find "$D" -type d -name "$TT" | wc -l | tr -d ' ')" = 1 ] || fail "trashed twice"
[ "$(find "$D" -type d -name "$M1" | wc -l | tr -d ' ')" = 1 ] || fail "M1 in two places"
grep -q '^title: "T1 beta"$' "$D/$IDEAS/$T1/index.md" || fail "title: later wins"
grep -q 'TOKEN_B_Y1' "$D/$IDEAS/$Y1/index.md" || fail "body: later wins"
grep -q 'TOKEN_B_K1' "$D/$IDEAS/$K1/comments/$KC/index.md" || fail "comment: later wins"
L=$(sed -n '/^labels:/,/^created:/p' "$D/$IDEAS/$L1/index.md"); for x in '"x"' '"y"' '"z"' '"Low"'; do grep -qF "$x" <<<"$L" || fail "labels: $x missing: $L"; done
if grep -q High <<<"$L"; then fail "priority: earlier value kept: $L"; fi
grep -q '^order: 200$' "$D/$IDEAS/$S1/index.md" && grep -q 'for: bob' "$D/$IDEAS/$S1/index.md" || fail "state: later wins"
for v in Open Doing Closed; do grep -q "text: \"$v\"" "$D/index.md" || fail "config.labels values: $v"; done
head -1 "$D/CLAUDE.md" | grep -q 'v901' || fail "guide: higher version wins"
[ "$(sed -n 2p "$D/.log/2026-01-01.log" | cut -c1-10)$(sed -n 4p "$D/.log/2026-01-01.log" | cut -c1-10)" = 2026-01-012026-01-03 ] || fail ".log: union sorted"
OURS=A; [ "$MODE" = rebase ] && OURS=B
grep -q "$OURS-bytes" "$D/$IDEAS/$AT1/attachments/$AT/blob.png" || fail "attachment: ours kept"
[ -f "$D/$IDEAS/$AT1/attachments/$AT/blob.theirs.png" ] || fail "attachment: theirs beside it"
# one merge comment per card that lost something, none elsewhere
want=" $T1 $Y1 $K1 $AT1 $AA $D1 "
for c in $(cd "$D" && ls -d */*/ .trash/*/ 2>/dev/null | sed 's#/$##'); do
  id=${c##*/}; is_uuid=$(echo "$id" | grep -c '^[0-9a-f-]\{36\}$' || true); [ "$is_uuid" = 1 ] || continue
  n=$({ grep -l 'session: "merge"' "$D/$c"/comments/*/index.md 2>/dev/null || true; } | wc -l | tr -d ' ')
  case "$want" in *" $id "*) [ "$n" = 1 ] || fail "card $c: $n merge comments, want 1" ;; *) [ "$n" = 0 ] || fail "card $c: $n merge comments, want 0" ;; esac
done
grep -q '^\*\*Merged two edits to this card\.\*\*$' "$D/$IDEAS/$Y1"/comments/*/index.md || fail "merge comment line 1"
echo "$OUT"
