#!/bin/bash
# merge-case.sh: the merge skill's smoke case. One scratch repo, cloned twice; each clone makes
# one instance of every row in merge/references/rules.md; then a merge (or rebase) with the driver
# installed, then merge-board.sh. Exits non-zero on the first failed assertion.
# usage: tests/merge-case.sh <scratch dir> <mode>
#   merge|rebase|nodriver: every row at once (nodriver: the pass alone, after git's markers)
#   clean: git finishing by itself, then a loss it must stop for; rebasemove: a later move in a rebase;
#   dirty: an uncommitted local edit in a conflicted card, carried as ours
#   appside: side B is bytes the Lanework app wrote (tests/fixtures/app-writes/), side A is scripted edits to the same items
#   delete: a whole card deleted on one side, edited or moved on the other: the survivor's whole tree comes back
#   deleteadd: a whole card deleted on one side, a comment, attachment or relation only added on the other: restored whole
#   stamps: a zone-less or loosely written `modified` stamp; interrupt: the pass interrupted at its first write
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; SK="$ROOT/skills"
VAL="$ROOT/Boards/Skills Pipeline.lanework"
T="${1:?usage: merge-case.sh <dir> <mode>}"; MODE="${2:?merge, rebase, nodriver, clean, rebasemove, dirty, appside, delete, deleteadd, stamps or interrupt}"
case "$MODE" in merge|rebase|nodriver|clean|rebasemove|dirty|appside|delete|deleteadd|stamps|interrupt) ;; *) echo "merge-case: unknown mode '$MODE'" >&2; exit 2 ;; esac
. "$SK/lanework/scripts/lib.sh"
MRG="$SK/merge/scripts/lanework-merge.py"
fail() { echo "merge-case ($MODE): $*" >&2; exit 1; }
G() { git -C "$1" "${@:2}"; }

W="$T/merge-$MODE"; rm -rf "$W"; mkdir -p "$W"
O="$W/origin"; mkdir -p "$O/Lanework"; git init -q -b main "$O"
G "$O" config user.email t@t; G "$O" config user.name t
BN="Lanework/Acme Pipeline.lanework"; P="$O/$BN"
"$SK/lanework/scripts/found-board.sh" "$P" --index "$SK/lanework/templates/pipeline-index.md" \
  --lanes "$SK/lanework/templates/pipeline-lanes.md" --var project=Acme --var verified=x --model test >/dev/null
cp -R "$VAL/.schema" "$P/.schema"; cp "$VAL/CLAUDE.md" "$P/CLAUDE.md"
lane() { basename "$(lane_by_title "$1/$BN" "$2")"; }
IDEAS=$(lane "$O" Ideas); APPROVED=$(lane "$O" Approved); ACTIVE=$(lane "$O" Active); DONE=$(lane "$O" Done)

T0=2026-01-01T00:00:00Z; TA=2026-01-02T00:00:00Z; TB=2026-01-03T00:00:00Z; TA2=2026-01-04T00:00:00Z
BY0='{name: owner, kind: human}'; BYA='{name: alice, kind: human}'; BYB='{name: bob, kind: human}'
TXT='kind: {type: text, text: Text, icon: {glyph: tag}}'
PRI='kind: {type: priority, text: Priority, icon: {glyph: flag}}'
for n in T1 Y1 K1 AT1 L1 S1 M1 M2 TR1 TR2 TT AA D1 KC AT R1 RL RT RNA RNB RR RTO LC; do eval "$n=$(uuid)"; done
# two differing leases (lease.sh's block form, real-length session ids): Q6, the later `modified` side's `claimed` wins whole
LSA=$(uuid); LSB=$(uuid)
leaseof() { printf 'claimed:\n  by: {name: claude, kind: agent, model: test, session: "%s"}\n  until: %s' "$1" "$2"; }

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
relation() { # <card dir> <id> <at> <by> <body> [.trash/]; REL= and TO= (a card id) override rel and to
  local d="$1/relations/${6:-}$2"; mkdir -p "$d"
  printf -- '---\nschema: 1\nkind: relation\nrel: "%s"\nto: "lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/%s"\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n%s\n' \
    "${REL:-traces-to}" "${TO:-$K1}" "$T0" "$BY0" "$3" "$4" "$5" > "$d/index.md"
}
setboard() { # <repo> <at> <by> <value:rank>...
  local f="$1/$BN/index.md" at="$2" by="$3" vals="" v; shift 3
  for v in "$@"; do vals="$vals        - text: \"${v%:*}\"\n          rank: ${v#*:}\n"; done
  perl -0pi -e "s/^config:.*?(?=^created:)/config:\n  show-card-body: 3\n  labels:\n    - type: \"status\"\n      text: \"Status\"\n      values:\n$vals/ms; s/^modified: .*\$/modified: {at: $at, by: $by}/m" "$f"
}
cardfile() { echo "$1/$BN/$(cd "$1/$BN" && ls -d */"$2" .trash/"$2" 2>/dev/null | head -1)/index.md"; }

# ---- base
for n in T1 Y1 K1 AT1 L1 S1 M1 M2 TR1 TR2 TT D1 R1 LC; do
  extra=""; [ "$n" = L1 ] && extra="labels: [{text: \"x\", $TXT}]"; ORD=1024; [ "$n" = S1 ] && ORD=5000
  ORD=$ORD card "$O" "$IDEAS" "${!n}" "$n base" "$T0" "$BY0" "$n base body." "$extra"
done
comment "$O/$BN/$IDEAS/$K1" "$KC" "$T0" "$BY0" "K1 base comment."
relation "$O/$BN/$IDEAS/$R1" "$RL" "$T0" "$BY0" "R1 base relation."
relation "$O/$BN/$IDEAS/$R1" "$RT" "$T0" "$BY0" "R1 base trashed relation." .trash/
relation "$O/$BN/$IDEAS/$R1" "$RR" "$T0" "$BY0" "R1 rel relation."
relation "$O/$BN/$IDEAS/$R1" "$RTO" "$T0" "$BY0" "R1 to relation."
A="$O/$BN/$IDEAS/$AT1/attachments/$AT"; mkdir -p "$A"; printf 'base-bytes' > "$A/blob.png"
printf -- '---\nschema: 1\nkind: attachment\ntitle: "shot"\nextension: png\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n' "$T0" "$BY0" "$T0" "$BY0" > "$A/index.md"
setboard "$O" "$T0" "$BY0" Open:1
printf 'base notes\n' > "$P/notes.txt"
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

# ---- small cases: git finishing on its own, a rebase with a later move, local edits
cm() { G "$1" add -A; G "$1" commit -qm "$2"; }
mclone() {
  M="$W/M"; D="$M/$BN"; git clone -q "$A" "$M"; G "$M" config user.email m@t; G "$M" config user.name m
  python3 "$MRG" install "$M" | grep -q 'already carries' || fail "install did not find the committed rule"
  G "$M" fetch -q "$B" main
}
lanebody() { # <repo> <lane> <at> <by> <body>
  perl -0pi -e "s/^modified: .*\$/modified: {at: $3, by: $4}/m; s/\n---\n.*\z/\n---\n$5\n/s" "$1/$BN/$2/index.md"
}
inhead() { for tok in "$@"; do G "$M" grep -q -F -- "$tok" HEAD -- "$BN" || fail "not committed: $tok"; done; }
clean_status() { [ -z "$(G "$M" status --porcelain -uall -- "$BN")" ] || { G "$M" status --porcelain -uall; fail "$1: board paths left uncommitted or untracked"; }; }
mcount() { { grep -l 'session: "merge"' "$1"/comments/*/index.md 2>/dev/null || true; } | wc -l | tr -d ' '; }
pass() { OUT=$("$SK/merge/scripts/merge-board.sh" "$M" </dev/null) || { echo "$OUT"; fail "$1: merge-board.sh exited non-zero"; }; }
full() { # <repo> <id> <tag>: a card in Ideas with every kind of child
  local d="$1/$BN/$IDEAS/$2"; card "$1" "$IDEAS" "$2" "$3 base" "$T0" "$BY0" "$3 base body."
  comment "$d" "$(uuid)" "$T0" "$BY0" "$3 base comment one."; comment "$d" "$(uuid)" "$T0" "$BY0" "$3 base comment two."
  mkdir -p "$d/attachments/$(uuid)"; local a; a=$(ls -d "$d"/attachments/*); printf '%s-bytes' "$3" > "$a/blob.png"
  printf -- '---\nschema: 1\nkind: attachment\ntitle: "shot"\nextension: png\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n' "$T0" "$BY0" "$T0" "$BY0" > "$a/index.md"
  relation "$d" "$(uuid)" "$T0" "$BY0" "$3 base relation."
}
allbase() { (cd "$O/$BN/$IDEAS/$1" && find . -type f | sed 's#^\./##' | sort); }
whole() { # <card dir> <id> <what>: every base file of the card there, byte for byte, and one merge comment
  local f; [ -f "$1/index.md" ] || fail "$3: no index.md in ${1#$W/}"
  for f in $(allbase "$2"); do cmp -s "$O/$BN/$IDEAS/$2/$f" "$1/$f" || fail "$3: ${2:0:8}/$f is not the base file, byte for byte"; done
  [ "$(mcount "$1")" = 1 ] || fail "$3: want 1 merge comment, got $(mcount "$1")"
}
case "$MODE" in
clean)
  # phase 1: nothing to lose, so git finishes by itself and leaves nothing behind
  card "$A" "$IDEAS" "$L1" "L1 base" "$TA" "$BYA" "L1 base body." "labels: [{text: \"x\", $TXT}, {text: \"y\", $TXT}]"
  card "$B" "$IDEAS" "$L1" "L1 base" "$TB" "$BYB" "L1 base body." "labels: [{text: \"x\", $TXT}, {text: \"z\", $TXT}]"
  BASEL=$(awk 'f{print} /^---$/{n++; if(n==2) f=1}' "$A/$BN/$IDEAS/index.md")
  lanebody "$A" "$IDEAS" "$TA" "$BYA" "LANE_A_TOP.\n\n$BASEL"; lanebody "$B" "$IDEAS" "$TB" "$BYB" "$BASEL\n\nLANE_B_END."
  lanebody "$A" "$APPROVED" "$TA" "$BYA" "APPR_A replaces the policy."; lanebody "$B" "$APPROVED" "$TB" "$BYB" "APPR_B replaces the policy."
  sed -i '' 's/^title: .*/title: "Approved A"/' "$A/$BN/$APPROVED/index.md"; sed -i '' 's/^title: .*/title: "Approved B"/' "$B/$BN/$APPROVED/index.md"
  mvcard "$A" "$IDEAS" "$M2" "$DONE"; restamp "$A" "$TA" "$BYA" "$M2"; card "$B" "$IDEAS" "$M2" "M2 base" "$TB" "$BYB" "M2 body TOKEN_B_M2."
  cm "$A" a1; cm "$B" b1; mclone
  G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1 || fail "lossless merge: git should finish by itself"
  clean_status "lossless merge"; inhead LANE_A_TOP LANE_B_END APPR_A APPR_B TOKEN_B_M2 '"y"' '"z"'
  grep -q '^## Merged from the earlier edit' "$D/$APPROVED/index.md" || fail "overlapping lane edits: no merged-from heading"
  grep -q '^title: "Approved B"$' "$D/$APPROVED/index.md" && grep -q '^Earlier title: "Approved A"$' "$D/$APPROVED/index.md" || fail "lane titles: later wins, earlier inline"
  [ -f "$D/$DONE/$M2/index.md" ] && grep -q TOKEN_B_M2 "$D/$DONE/$M2/index.md" || fail "moved one side, edited other"
  validate_board "$M" "lossless merge"
  # a comment posted on a card the other side moved: git leaves it behind with no conflict; the pass re-homes it
  mvcard "$M" "$IDEAS" "$S1" "$DONE"; restamp "$M" "$TA2" "$BYA" "$S1"; cm "$M" m1
  comment "$B/$BN/$IDEAS/$S1" "$(uuid)" "$TB" "$BYB" "S1 comment TOKEN_B_S1."; cm "$B" b1c
  G "$M" fetch -q "$B" main; G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1 || fail "comment vs move: git should finish"
  pass "comment vs move"; grep -q 'Re-homed into their moved cards: 1 file' <<<"$OUT" || { echo "$OUT"; fail "comment vs move: not re-homed"; }
  G "$M" commit -qm "Re-home"; clean_status "comment vs move"
  grep -q TOKEN_B_S1 "$D/$DONE/$S1"/comments/*/index.md && [ ! -e "$D/$IDEAS/$S1" ] || fail "comment vs move: comment not in the moved card"
  validate_board "$M" "comment vs move"
  # phase 2: the other side moved the card, both edited its body, ours earlier: git must stop, not finish
  card "$M" "$IDEAS" "$Y1" "Y1 base" "$TA" "$BYA" "Y1 body TOKEN_A_Y1."; cm "$M" m2
  G "$B" mv "$BN/$IDEAS/$Y1" "$BN/$APPROVED/$Y1"; card "$B" "$APPROVED" "$Y1" "Y1 base" "$TB" "$BYB" "Y1 body TOKEN_B_Y1."; cm "$B" b2
  G "$M" fetch -q "$B" main
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "a losing merge finished with the loser only outside the board"; fi
  [ -z "$(G "$M" status --porcelain -uall -- "$BN" | grep '^??' || true)" ] || fail "the driver wrote outside the file git gave it"
  pass "stopped merge"; G "$M" commit -q --no-edit; clean_status "stopped merge"
  inhead TOKEN_A_Y1 TOKEN_B_Y1; [ -f "$D/$APPROVED/$Y1/index.md" ] || fail "Y1 not in the later lane"
  [ "$(mcount "$D/$APPROVED/$Y1")" = 1 ] || fail "Y1: want 1 merge comment"
  validate_board "$M" "stopped merge"
  # (j) a tracked orphan comment, then the app moves its card without a commit: git and the disk disagree
  mkdir -p "$D/$IDEAS/$S1"; comment "$D/$IDEAS/$S1" "$(uuid)" "$TA" "$BYA" "ORPHAN_TOKEN"; cm "$M" orphan
  mv "$D/$DONE/$S1" "$D/$APPROVED/$S1"
  OUT=$("$SK/merge/scripts/merge-board.sh" "$M" </dev/null 2>&1) || true
  grep -q 'Not re-homed: .*disagree' <<<"$OUT" || { echo "$OUT"; fail "(j): the card git and the disk disagree on was not skipped and reported"; }
  grep -rq ORPHAN_TOKEN "$D/$IDEAS/$S1" && [ -f "$D/$APPROVED/$S1/index.md" ] || fail "(j): the orphan or the moved card was touched"
  echo "$OUT"; exit 0 ;;
rebasemove)
  card "$A" "$IDEAS" "$Y1" "Y1 base" "$TA" "$BYA" "Y1 body TOKEN_A_Y1."; cm "$A" a1
  mvcard "$A" "$IDEAS" "$Y1" "$APPROVED"; restamp "$A" 2026-01-05T00:00:00Z "$BYA" "$Y1"; cm "$A" a2
  card "$B" "$IDEAS" "$Y1" "Y1 base" "$TB" "$BYB" "Y1 body TOKEN_B_Y1."; cm "$B" b1
  mclone; n=0
  G "$M" rebase -q FETCH_HEAD >/dev/null 2>&1 && fail "rebase: the losing pick should stop"
  while [ -d "$M/.git/rebase-merge" ] || [ -d "$M/.git/rebase-apply" ]; do
    n=$((n+1)); [ $n -le 4 ] || fail "rebase never finished"
    pass "rebase stop $n"
    grep -qF 'After the rebase finishes, run merge-board.sh once more and commit the re-home.' <<<"$OUT" || { echo "$OUT"; fail "rebase: the report doesn't say to run the pass again"; }
    GIT_EDITOR=true G "$M" rebase --continue >/dev/null 2>&1 || true
  done
  # control: pick 2 moved the card and git left pick 1's merge comment behind, so the board doesn't validate yet
  if python3 "$VAL/.schema/bin/lanework-validate.py" --schema "$VAL/.schema" "$D" 2>&1 | grep -q '^failures    0 '; then
    fail "rebase control: the board validates before the second run, so the second run proves nothing"; fi
  # the documented flow: run merge-board.sh once more, commit the re-home
  pass "after the rebase"; grep -q 'Re-homed into their moved cards: 1 file' <<<"$OUT" || { echo "$OUT"; fail "rebase: nothing re-homed"; }
  G "$M" commit -qm "Re-home merge comment"
  clean_status "rebase"; inhead TOKEN_A_Y1 TOKEN_B_Y1
  [ -f "$D/$APPROVED/$Y1/index.md" ] || fail "Y1 not in the later lane"
  [ ! -e "$D/$IDEAS/$Y1" ] || fail "an orphaned folder of Y1 is left in Ideas"
  [ "$(mcount "$D/$APPROVED/$Y1")" = 1 ] || fail "Y1: want 1 merge comment"
  validate_board "$M" "rebase with a later move"; echo "$OUT"; exit 0 ;;
dirty)
  # moved to different lanes on both sides, so git stops with or without the driver
  mvcard "$A" "$IDEAS" "$K1" "$ACTIVE"; card "$A" "$ACTIVE" "$K1" "K1 base" "$TA" "$BYA" "K1 body TOKEN_A_K1."; cm "$A" a1
  mvcard "$B" "$IDEAS" "$K1" "$APPROVED"; card "$B" "$APPROVED" "$K1" "K1 base" "$TB" "$BYB" "K1 body TOKEN_B_K1."; cm "$B" b1
  mclone; KF="$D/$ACTIVE/$K1/comments/$KC/index.md"
  comment "$D/$ACTIVE/$K1" "$KC" 2026-01-07T00:00:00Z '{name: m, kind: human}' $'Heading\n=======\n\nDIRTY_LOCAL_TOKEN uncommitted, under a setext heading.'
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "dirty: the merge should stop"; fi
  pass "dirty"; grep -rq DIRTY_LOCAL_TOKEN "$D" || fail "dirty: the uncommitted edit was erased"
  grep -q 'Uncommitted edits carried into the merge as ours' <<<"$OUT" || { echo "$OUT"; fail "dirty: the report doesn't name the local edit"; }
  G "$M" commit -q --no-edit; clean_status "dirty"
  grep -q DIRTY_LOCAL_TOKEN "$D/$APPROVED/$K1/comments/$KC/index.md" || fail "dirty: the local edit is not in the merged card"
  # again with no move: git leaves the dirty comment merged and alone, and stops on the body
  card "$M" "$APPROVED" "$K1" "K1 base" 2026-01-04T00:00:00Z "$BYA" "K1 body TOKEN_A2_K1."; cm "$M" m2
  card "$B" "$APPROVED" "$K1" "K1 base" 2026-01-05T00:00:00Z "$BYB" "K1 body TOKEN_B2_K1."; cm "$B" b2
  comment "$D/$APPROVED/$K1" "$KC" 2026-01-08T00:00:00Z '{name: m, kind: human}' "DIRTY_AGAIN_TOKEN uncommitted."
  G "$M" fetch -q "$B" main
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "dirty 2: the merge should stop on the body"; fi
  G "$M" diff --name-only --diff-filter=U | grep -q "$KC" && fail "dirty 2: expected git to leave the comment merged"
  pass "dirty 2"; grep -q 'Uncommitted edits carried' <<<"$OUT" || { echo "$OUT"; fail "dirty 2: not reported"; }
  G "$M" commit -q --no-edit; clean_status "dirty 2"; inhead DIRTY_AGAIN_TOKEN TOKEN_A2_K1 TOKEN_B2_K1
  inhead TOKEN_A_K1; validate_board "$M" "dirty"; echo "$OUT"; exit 0 ;;
appside)
  # Side B is real app writes (unstamped `modified`, keys in the app's order, a quoted human `created`), copied from this
  # board's git history; the base holds each item as it was just before the app wrote it, so git and the driver see the
  # same diffs the app made. Side A is a scripted edit to each of the same items.
  # AE sits after the retitled card's created (01:09:29Z) and before the app's unstamped modified (01:46:22Z), so only that modified decides the title;
  # AL sits after every app write here (the latest, the card move, 2026-11-22T22:35:16Z), so A's edits are the later side
  FX="$ROOT/tests/fixtures/app-writes"; AE=2026-10-10T01:30:00Z; AL=2026-11-23T00:00:00Z
  MOVED=28c22261-3d84-4e72-8620-8cc2eb3c7cc2; DISC=4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03; CMT=2bbea8c7-8147-4bcc-aa8a-ce8dd41e9598
  SHAPING=$(lane "$O" Shaping); ISSUES=$(lane "$O" Issues)
  put() { mkdir -p "$(dirname "$2")"; cp "$FX/$1" "$2"; }
  put lane-rewrite.before.md "$O/$BN/$SHAPING/index.md"
  put card-move.before.md "$O/$BN/$ISSUES/$MOVED/index.md"
  put card-title-edit.before.md "$O/$BN/$ISSUES/$DISC/index.md"
  cm "$O" appbase; validate_board "$O" "appside base"; G "$A" pull -q; G "$B" pull -q
  # side B: what the app wrote
  put lane-rewrite.after.md "$B/$BN/$SHAPING/index.md"
  G "$B" mv "$BN/$ISSUES/$MOVED" "$BN/$SHAPING/$MOVED"; put card-move.after.md "$B/$BN/$SHAPING/$MOVED/index.md"
  G "$B" mv "$BN/$ISSUES/$DISC" "$BN/$APPROVED/$DISC"; put card-title-edit.after.md "$B/$BN/$APPROVED/$DISC/index.md"
  put comment-posted.md "$B/$BN/$IDEAS/$S1/comments/$CMT/index.md"
  cm "$B" "app writes"
  # side A: scripted edits to the same items
  BASEL=$(awk 'f{print} /^---$/{n++; if(n==2) f=1}' "$A/$BN/$SHAPING/index.md")
  lanebody "$A" "$SHAPING" "$AL" "$BYA" "$BASEL\n\nLANE_A_TOKEN."
  printf '\nBODY_A_MOVED.\n' >> "$(cardfile "$A" "$MOVED")"; restamp "$A" "$AL" "$BYA" "$MOVED"
  sed -i '' 's/^title: .*/title: "TITLE_A_DISC"/' "$(cardfile "$A" "$DISC")"; restamp "$A" "$AE" "$BYA" "$DISC"
  mvcard "$A" "$IDEAS" "$S1" "$DONE"; restamp "$A" "$AL" "$BYA" "$S1"
  cm "$A" "scripted edits"
  validate_board "$A" "side A"; validate_board "$B" "side B"
  mclone
  G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1 || true
  pass "appside"
  [ -z "$(G "$M" diff --name-only --diff-filter=U)" ] || fail "appside: unmerged paths left"
  [ -f "$M/.git/MERGE_HEAD" ] || fail "appside: the merge should have stopped for the pass"; G "$M" commit -q --no-edit
  clean_status "appside"
  if grep -rIl '<<<<<<<\|>>>>>>>' "$D" >/dev/null; then fail "appside: a conflict marker survived"; fi
  validate_board "$M" "appside merged"
  one() { [ -f "$D/$1/$2/index.md" ] && [ "$(find "$D" -type d -name "$2" -not -path '*/.trash/*' | wc -l | tr -d ' ')" = 1 ] || fail "appside: $3 is not in one place, $1 ($(cd "$D" && ls -d */"$2" 2>/dev/null))"; }
  # the lane the app rewrote: its width and A's body line both survive
  grep -q '^width: 3$' "$D/$SHAPING/index.md" && grep -q LANE_A_TOKEN "$D/$SHAPING/index.md" && grep -q '^The agent work lane\.' "$D/$SHAPING/index.md" || fail "appside lane: B's width and A's body must both survive"
  # the card the app moved while A edited its body: at the new path, A's body, B's order
  one "$SHAPING" "$MOVED" "moved by the app, edited by A"
  grep -q BODY_A_MOVED "$D/$SHAPING/$MOVED/index.md" && grep -q '^order: 5120$' "$D/$SHAPING/$MOVED/index.md" || fail "appside move: A's body and B's order must both survive"
  # the card the app retitled while A retitled it earlier: B's title kept, A's in the merge comment
  one "$APPROVED" "$DISC" "retitled by the app"
  grep -q '^title: "Discovery and founding scripts: escape titles, and stamp a real model"$' "$D/$APPROVED/$DISC/index.md" || fail "appside title: the later (app) title must win"
  grep -rqF 'TITLE_A_DISC' "$D/$APPROVED/$DISC" || fail "appside title: A's title was lost"
  grep -rqF 'Title: kept "Discovery and founding scripts: escape titles, and stamp a real model"' "$D/$APPROVED/$DISC/comments" || fail "appside title: the merge comment doesn't name the kept title"
  # the comment the app posted on a card A moved: re-homed byte for byte
  one "$DONE" "$S1" "moved by A"; [ ! -e "$D/$IDEAS/$S1" ] || fail "appside comment: an orphan folder is left in Ideas"
  cmp -s "$FX/comment-posted.md" "$D/$DONE/$S1/comments/$CMT/index.md" || fail "appside comment: the app's comment is not in the moved card, byte for byte"
  echo "$OUT"; exit 0 ;;
delete)
  # whole cards (body, comment, attachment, relation) in base; one side runs `git rm -r` on each, the other edits it
  # X1: rm ours, body theirs; X2: the mirror; X3: rm ours, theirs edits the body, removes one comment, adds one;
  # X4: rm ours, comment-only edit theirs; X5: the mirror; X6: rm ours, theirs untouched (control);
  # X7: both edit the body, ours removes a comment theirs left alone (3-way inside a kept card);
  # X8: rm ours, a bare `git mv` to Done theirs (no restamp); X9: the mirror; X10: rm ours, a bare `git mv` into .trash/ theirs
  for n in X1 X2 X3 X4 X5 X6 X7 X8 X9 X10; do eval "$n=$(uuid)"; full "$O" "${!n}" "$n"; done
  cm "$O" delbase; validate_board "$O" "delete base"; G "$A" pull -q; G "$B" pull -q
  c1() { (cd "$1/$BN/$IDEAS/$2/comments" && ls | head -1); }
  for n in X1 X3 X4 X6 X8 X10; do G "$A" rm -rq "$BN/$IDEAS/${!n}"; done
  for n in X2 X5 X9; do G "$B" rm -rq "$BN/$IDEAS/${!n}"; done
  mvcard "$B" "$IDEAS" "$X8" "$DONE"; mvcard "$A" "$IDEAS" "$X9" "$DONE"; mkdir -p "$B/$BN/.trash"; G "$B" mv "$BN/$IDEAS/$X10" "$BN/.trash/$X10"
  card "$B" "$IDEAS" "$X1" "X1 base" "$TB" "$BYB" "X1 body TOKEN_B_X1."
  card "$A" "$IDEAS" "$X2" "X2 base" "$TA" "$BYA" "X2 body TOKEN_A_X2."
  card "$B" "$IDEAS" "$X3" "X3 base" "$TB" "$BYB" "X3 body TOKEN_B_X3."
  X3GONE=$(c1 "$B" "$X3"); G "$B" rm -rq "$BN/$IDEAS/$X3/comments/$X3GONE"; X3NEW=$(uuid); comment "$B/$BN/$IDEAS/$X3" "$X3NEW" "$TB" "$BYB" "X3 added TOKEN_B_X3C."
  X4C=$(c1 "$B" "$X4"); comment "$B/$BN/$IDEAS/$X4" "$X4C" "$TB" "$BYB" "X4 comment TOKEN_B_X4."
  X5C=$(c1 "$A" "$X5"); comment "$A/$BN/$IDEAS/$X5" "$X5C" "$TA" "$BYA" "X5 comment TOKEN_A_X5."
  card "$A" "$IDEAS" "$X7" "X7 base" "$TA" "$BYA" "X7 body TOKEN_A_X7."; X7GONE=$(c1 "$A" "$X7"); G "$A" rm -rq "$BN/$IDEAS/$X7/comments/$X7GONE"
  card "$B" "$IDEAS" "$X7" "X7 base" "$TB" "$BYB" "X7 body TOKEN_B_X7."
  cm "$A" a1; cm "$B" b1; mclone
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "delete: the merge should stop on modify/delete"; fi
  pass "delete"; G "$M" commit -q --no-edit; clean_status "delete"
  if grep -q 'Not re-homed' <<<"$OUT"; then echo "$OUT"; fail "delete: a card was left for re-homing"; fi
  # every base file of a kept card is back byte for byte, unless the survivor changed or removed it
  same() { # <id> <path within the card>...: identical to base
    local id="$1" f; shift
    for f in "$@"; do cmp -s "$O/$BN/$IDEAS/$id/$f" "$D/$IDEAS/$id/$f" || fail "delete: ${id:0:8}/$f is not the base file, byte for byte"; done
  }
  basefiles() { (cd "$O/$BN/$IDEAS/$1" && find . -type f ! -path ./index.md | sed 's#^\./##' | sort); }
  for n in X1 X2 X4 X5; do
    id=${!n}; [ -f "$D/$IDEAS/$id/index.md" ] || fail "delete: $n has no index.md"
    grep -rqF 'The other side deleted this card for good' "$D/$IDEAS/$id/comments" || fail "delete: $n's merge comment doesn't name the delete"
    for f in $(basefiles "$id"); do case "$n:$f" in "X4:comments/$X4C/"*|"X5:comments/$X5C/"*) ;; *) same "$id" "$f" ;; esac; done
  done
  grep -q TOKEN_B_X1 "$D/$IDEAS/$X1/index.md" && grep -q TOKEN_A_X2 "$D/$IDEAS/$X2/index.md" || fail "delete: the body edit was not kept"
  same "$X4" index.md; same "$X5" index.md
  grep -rq TOKEN_B_X4 "$D/$IDEAS/$X4/comments" && grep -rq TOKEN_A_X5 "$D/$IDEAS/$X5/comments" || fail "delete: the comment-only edit was not kept"
  # the survivor's own removal holds and its addition stays
  [ ! -e "$D/$IDEAS/$X3/comments/$X3GONE" ] || fail "delete: X3's comment the survivor removed came back"
  grep -q TOKEN_B_X3C "$D/$IDEAS/$X3/comments/$X3NEW/index.md" || fail "delete: X3's added comment is gone"
  for f in $(basefiles "$X3"); do case "$f" in "comments/$X3GONE"/*) ;; *) same "$X3" "$f" ;; esac; done
  # control: deleted against no change stays gone; a comment removed inside a card both kept stays removed
  [ ! -e "$D/$IDEAS/$X6" ] || fail "delete control: X6 came back"
  [ ! -e "$D/$IDEAS/$X7/comments/$X7GONE" ] || fail "delete: X7's removed comment came back (3-way inside a kept card)"
  # a bare move beats the delete: the whole card where the mover put it, .trash/ included
  for n in X8 X9 X10; do
    id=${!n}; d="$D/$DONE/$id"; [ "$n" = X10 ] && d="$D/.trash/$id"
    whole "$d" "$id" "delete: $n moved bare"; [ ! -e "$D/$IDEAS/$id" ] || fail "delete: $n left a folder in Ideas"
    grep -rqF 'The other side deleted this card for good; the moved card is kept.' "$d/comments" || fail "delete: $n's merge comment doesn't say the moved card is kept"
  done
  validate_board "$M" "delete"; echo "$OUT"; exit 0 ;;
deleteadd)
  # a whole card deleted on one side, a comment, attachment or relation only added on the other: git finishes (or stops
  # elsewhere) with the new file in a folder with no index.md; the pass restores the whole card around it
  # E1: rm ours, comment theirs; E2: the mirror; E3: rm ours, attachment theirs; E4: rm ours, relation theirs; E5: as E1, git stopping on Y1
  for n in E1 E2 E3 E4 E5; do eval "$n=$(uuid)"; full "$O" "${!n}" "$n"; done
  cm "$O" delbase; validate_board "$O" "deleteadd base"; G "$A" pull -q; G "$B" pull -q
  for n in E1 E3 E4; do G "$A" rm -rq "$BN/$IDEAS/${!n}"; done; G "$B" rm -rq "$BN/$IDEAS/$E2"
  EC1=$(uuid); comment "$B/$BN/$IDEAS/$E1" "$EC1" "$TB" "$BYB" "E1 added TOKEN_B_E1."
  EC2=$(uuid); comment "$A/$BN/$IDEAS/$E2" "$EC2" "$TA" "$BYA" "E2 added TOKEN_A_E2."
  EA3=$(uuid); mkdir -p "$B/$BN/$IDEAS/$E3/attachments/$EA3"; printf 'E3-new-bytes' > "$B/$BN/$IDEAS/$E3/attachments/$EA3/blob.png"
  printf -- '---\nschema: 1\nkind: attachment\ntitle: "new"\nextension: png\ncreated:  {at: %s, by: %s}\nmodified: {at: %s, by: %s}\n---\n' "$TB" "$BYB" "$TB" "$BYB" > "$B/$BN/$IDEAS/$E3/attachments/$EA3/index.md"
  ER4=$(uuid); relation "$B/$BN/$IDEAS/$E4" "$ER4" "$TB" "$BYB" "E4 added TOKEN_B_E4."
  cm "$A" a1; cm "$B" b1
  ADDED="$E1:comments/$EC1/index.md $E2:comments/$EC2/index.md $E3:attachments/$EA3/blob.png $E4:relations/$ER4/index.md"
  restored() { # <card id:added path>...: the report, then each card whole in Ideas with its addition ($PH names the phase)
    local x id
    grep -q 'Restored whole against a delete: ' <<<"$OUT" || { echo "$OUT"; fail "$PH: no Restored whole sentence"; }
    if grep -q 'Not re-homed' <<<"$OUT"; then echo "$OUT"; fail "$PH: a Not re-homed line"; fi
    for x in "$@"; do
      id=${x%%:*}; whole "$D/$IDEAS/$id" "$id" "$PH ${id:0:8}"; [ -f "$D/$IDEAS/$id/${x#*:}" ] || fail "$PH: ${id:0:8}'s added ${x#*:} is gone"
      grep -rqF 'a comment or attachment was added on this side, so the whole card is kept' "$D/$IDEAS/$id/comments" || fail "$PH: ${id:0:8}'s merge comment doesn't name the delete"
    done
  }
  # phase 1: a merge git finishes alone
  mclone; PH=merge
  G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1 || fail "merge: git should finish by itself"
  pass "$PH"; restored $ADDED; G "$M" commit -qm "Restore"; clean_status "$PH"; validate_board "$M" "$PH"
  # phase 2: the same in a rebase of side A onto side B
  RM=$M; M="$W/R"; D="$M/$BN"; git clone -q "$A" "$M"; G "$M" config user.email r@t; G "$M" config user.name r
  python3 "$MRG" install "$M" >/dev/null; G "$M" fetch -q "$B" main; PH=rebase
  G "$M" rebase -q FETCH_HEAD >/dev/null 2>&1 || fail "rebase: git should finish by itself"
  pass "$PH"; restored $ADDED; G "$M" commit -qm "Restore"; clean_status "$PH"; validate_board "$M" "$PH"
  # phase 3: git stops on Y1's body; one run resolves Y1 and restores E5
  M=$RM; D="$M/$BN"; PH=stopped
  G "$M" rm -rq "$BN/$IDEAS/$E5"; card "$M" "$IDEAS" "$Y1" "Y1 base" "$TA" "$BYA" "Y1 body TOKEN_A_Y1."; cm "$M" m2
  EC5=$(uuid); comment "$B/$BN/$IDEAS/$E5" "$EC5" "$TB" "$BYB" "E5 added TOKEN_B_E5."; card "$B" "$IDEAS" "$Y1" "Y1 base" "$TB" "$BYB" "Y1 body TOKEN_B_Y1."; cm "$B" b2
  G "$M" fetch -q "$B" main
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "stopped: the merge should stop on Y1"; fi
  pass "$PH"; [ -z "$(G "$M" diff --name-only --diff-filter=U)" ] || fail "stopped: unmerged paths left"
  restored "$E5:comments/$EC5/index.md"; grep -q TOKEN_B_Y1 "$D/$IDEAS/$Y1/index.md" || fail "stopped: Y1 not resolved"
  G "$M" commit -q --no-edit; clean_status "$PH"; validate_board "$M" "$PH"; echo "$OUT"
  # what the pass can't restore is named with its reason: no tree ever held the card's index.md; its files in two folders
  EN=$(uuid); comment "$D/$IDEAS/$EN" "$(uuid)" "$TA" "$BYA" "No card."; ET=$(uuid)
  comment "$D/$IDEAS/$ET" "$(uuid)" "$TA" "$BYA" "Two one."; comment "$D/$DONE/$ET" "$(uuid)" "$TA" "$BYA" "Two two."; cm "$M" orphans
  OUT=$("$SK/merge/scripts/merge-board.sh" "$M" </dev/null 2>&1) || true
  grep -qF "Not restored against a delete: " <<<"$OUT" && grep -qF "${EN:0:8} (no index.md for this card in any tree to restore it from)" <<<"$OUT" \
    && grep -qF "${ET:0:8} (no index.md anywhere, and its files sit in 2 folders)" <<<"$OUT" || { echo "$OUT"; fail "unrestorable folders not named with their reason"; }
  if grep -q 'commit the move first' <<<"$OUT"; then echo "$OUT"; fail "unrestorable folders blamed on a move"; fi
  [ -z "$(G "$M" status --porcelain -uall -- "$BN")" ] || fail "unrestorable folders: the pass wrote something"
  exit 0 ;;
stamps)
  # stamp_at() reads every form the schema's timestamp pattern allows, zone-less as UTC
  python3 -B - "$MRG" <<'PY' || fail "stamp_at: a schema timestamp misread"
import importlib.util, sys, datetime
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('lm', sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
U = datetime.timezone.utc
def at(s):
    return m.stamp_at(m.split_doc('---\nmodified: {at: %s, by: {name: x, kind: human}}\n---\n' % s)[0])
want = {'2026-01-03': datetime.datetime(2026, 1, 3, tzinfo=U), '2026-01-03T00:00:00': datetime.datetime(2026, 1, 3, tzinfo=U),
        '2026-01-03 00:00:00Z': datetime.datetime(2026, 1, 3, tzinfo=U), '2026-01-03t00:00:00Z': datetime.datetime(2026, 1, 3, tzinfo=U),
        '2026-1-3T0:00:00Z': datetime.datetime(2026, 1, 3, tzinfo=U), '2026-01-03T02:00:00+02': datetime.datetime(2026, 1, 3, tzinfo=U),
        '2026-01-03T02:30:00.5+02:30': datetime.datetime(2026, 1, 3, 0, 0, 0, 500000, tzinfo=U), '"2026-01-03 00:00:00 Z"': datetime.datetime(2026, 1, 3, tzinfo=U)}
bad = ['%s -> %r, want %s' % (k, at(k), v) for k, v in want.items() if at(k) != v]
for k in want:
    m.later(m.split_doc('---\nmodified: {at: 2026-01-02T00:00:00Z, by: x}\n---\n')[0], m.split_doc('---\nmodified: {at: %s, by: x}\n---\n' % k)[0])
bad and print('\n'.join(bad)); sys.exit(1 if bad else 0)
PY
  # ours zoned, theirs zone-less and later: the pass finishes and theirs wins
  card "$A" "$IDEAS" "$T1" "T1 base" "$TA" "$BYA" "T1 body TOKEN_A_T1."; cm "$A" a1
  card "$B" "$IDEAS" "$T1" "T1 base" 2026-01-03T00:00:00 "$BYB" "T1 body TOKEN_B_T1."; cm "$B" b1
  mclone
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "stamps: the merge should stop on the body"; fi
  pass "stamps"; G "$M" commit -q --no-edit; clean_status "stamps"
  grep -q TOKEN_B_T1 "$D/$IDEAS/$T1/index.md" || fail "stamps: the later zone-less side did not win"
  grep -rq TOKEN_A_T1 "$D/$IDEAS/$T1/comments" || fail "stamps: the earlier body is not in the merge comment"
  validate_board "$M" "stamps"; echo "$OUT"; exit 0 ;;
interrupt)
  # both edit K1's body; M holds an uncommitted edit of K1's comment; the pass is interrupted at its first write
  card "$A" "$IDEAS" "$K1" "K1 base" "$TA" "$BYA" "K1 body TOKEN_A_K1."; cm "$A" a1
  card "$B" "$IDEAS" "$K1" "K1 base" "$TB" "$BYB" "K1 body TOKEN_B_K1."; cm "$B" b1
  mclone; KF="$D/$IDEAS/$K1/comments/$KC/index.md"
  comment "$D/$IDEAS/$K1" "$KC" 2026-01-07T00:00:00Z '{name: m, kind: human}' "INTERRUPT_LOCAL_TOKEN uncommitted."
  if G "$M" merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; then fail "interrupt: the merge should stop on the body"; fi
  python3 -B - "$MRG" "$M" <<'PY' || fail "interrupt: the harness did not reach the interruption"
import importlib.util, sys
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('lm', sys.argv[1]); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
def stop(*a):
    raise KeyboardInterrupt
m.write_atomic = stop
try:
    m.cmd_resolve([sys.argv[2], '--model', 'test'])
except KeyboardInterrupt:
    sys.exit(0)
sys.exit(1)
PY
  [ -z "$(find "$SK" "$M" -name __pycache__ 2>/dev/null)" ] || fail "interrupt: the harness wrote __pycache__"
  grep -q INTERRUPT_LOCAL_TOKEN "$KF" 2>/dev/null || { G "$M" status --porcelain; fail "interrupt: the uncommitted edit is gone from disk after the interruption"; }
  pass "interrupt rerun"; grep -q 'Uncommitted edits carried' <<<"$OUT" || { echo "$OUT"; fail "interrupt: the rerun doesn't carry the edit"; }
  G "$M" commit -q --no-edit; clean_status "interrupt"; inhead INTERRUPT_LOCAL_TOKEN TOKEN_A_K1 TOKEN_B_K1
  validate_board "$M" "interrupt"; echo "$OUT"; exit 0 ;;
esac

# ---- side A (earlier, except TR2)
card "$A" "$IDEAS" "$T1" "T1 alpha" "$TA" "$BYA" "T1 base body."
card "$A" "$IDEAS" "$Y1" "Y1 base" "$TA" "$BYA" "Y1 body TOKEN_A_Y1."
comment "$A/$BN/$IDEAS/$K1" "$KC" "$TA" "$BYA" "K1 comment TOKEN_A_K1."
printf 'A-bytes' > "$A/$BN/$IDEAS/$AT1/attachments/$AT/blob.png"
relation "$A/$BN/$IDEAS/$R1" "$RL" "$TA" "$BYA" "R1 relation TOKEN_A_RL."
relation "$A/$BN/$IDEAS/$R1" "$RT" "$TA" "$BYA" "R1 trashed relation TOKEN_A_RT." .trash/
relation "$A/$BN/$IDEAS/$R1" "$RNA" "$TA" "$BYA" "R1 new relation TOKEN_A_RNA."
REL=depends-on relation "$A/$BN/$IDEAS/$R1" "$RR" "$TA" "$BYA" "R1 rel relation."
TO=$Y1 relation "$A/$BN/$IDEAS/$R1" "$RTO" "$TA" "$BYA" "R1 to relation."
card "$A" "$IDEAS" "$L1" "L1 base" "$TA" "$BYA" "L1 base body." \
  "labels: [{text: \"x\", $TXT}, {text: \"y\", rank: 2.0, $TXT}, {text: \"High\", rank: 1, color: \"#E07A1F\", $PRI}]"
ORD=100 card "$A" "$IDEAS" "$S1" "S1 base" "$TA" "$BYA" "S1 base body." \
  "hero: $(uuid)"$'\n'"waiting: {for: alice, since: $TA, comment: $(uuid)}"
mvcard "$A" "$IDEAS" "$M1" "$APPROVED"; restamp "$A" "$TA" "$BYA" "$M1"; sed -i '' 's/^order: 1024$/order: 3000/' "$(cardfile "$A" "$M1")"
mvcard "$A" "$IDEAS" "$M2" "$DONE"; restamp "$A" "$TA" "$BYA" "$M2"
card "$A" "$IDEAS" "$TR1" "TR1 base" "$TA" "$BYA" "TR1 body TOKEN_A_TR1."
card "$A" "$IDEAS" "$TR2" "TR2 base" "$TA2" "$BYA" "TR2 body TOKEN_A_TR2."
mkdir -p "$A/$BN/.trash"; G "$A" mv "$BN/$IDEAS/$TT" "$BN/.trash/$TT"; restamp "$A" "$TA" "$BYA" "$TT"
card "$A" "$IDEAS" "$AA" "AA alpha" "$TA" "$BYA" "AA body TOKEN_A_AA."
card "$A" "$IDEAS" "$D1" "D1 base" "$TA" "$BYA" "D1 body TOKEN_A_D1."
card "$A" "$IDEAS" "$LC" "LC base" "$TA" "$BYA" "LC base body." "$(leaseof "$LSA" 2026-01-02T00:30:00Z)"
setboard "$A" "$TA" "$BYA" Open:1 Doing:2
sed -i '' '1s/v[0-9][0-9]*/v900/' "$A/$BN/CLAUDE.md"; printf 'NOTES_A\n' > "$A/$BN/notes.txt"
echo "2026-01-02T00:00:00Z info card.edit alice" >> "$A/$BN/.log/2026-01-01.log"
G "$A" add -A; G "$A" add -f "$BN/.log"; G "$A" commit -qm "side A"

# ---- side B (later, except TR2)
card "$B" "$IDEAS" "$T1" "T1 beta" "$TB" "$BYB" "T1 base body."
card "$B" "$IDEAS" "$Y1" "Y1 base" "$TB" "$BYB" "Y1 body TOKEN_B_Y1."
comment "$B/$BN/$IDEAS/$K1" "$KC" "$TB" "$BYB" "K1 comment TOKEN_B_K1."
printf 'B-bytes' > "$B/$BN/$IDEAS/$AT1/attachments/$AT/blob.png"
relation "$B/$BN/$IDEAS/$R1" "$RL" "$TB" "$BYB" "R1 relation TOKEN_B_RL."
relation "$B/$BN/$IDEAS/$R1" "$RT" "$TB" "$BYB" "R1 trashed relation TOKEN_B_RT." .trash/
relation "$B/$BN/$IDEAS/$R1" "$RNB" "$TB" "$BYB" "R1 new relation TOKEN_B_RNB."
REL=supersedes relation "$B/$BN/$IDEAS/$R1" "$RR" "$TB" "$BYB" "R1 rel relation."
TO=$T1 relation "$B/$BN/$IDEAS/$R1" "$RTO" "$TB" "$BYB" "R1 to relation."
card "$B" "$IDEAS" "$L1" "L1 base" "$TB" "$BYB" "L1 base body." \
  "labels: [{text: \"x\", $TXT}, {text: \"z\", $TXT}, {text: \"Low\", rank: 3, icon: {glyph: arrow.down}, $PRI}]"
ORD=200 card "$B" "$IDEAS" "$S1" "S1 base" "$TB" "$BYB" "S1 base body." \
  "hero: $(uuid)"$'\n'"waiting: {for: bob, since: $TB, comment: $(uuid)}"
mvcard "$B" "$IDEAS" "$M1" "$ACTIVE"; restamp "$B" "$TB" "$BYB" "$M1"; sed -i '' 's/^order: 1024$/order: 4000/' "$(cardfile "$B" "$M1")"
card "$B" "$IDEAS" "$M2" "M2 base" "$TB" "$BYB" "M2 body TOKEN_B_M2."
mkdir -p "$B/$BN/.trash"
G "$B" mv "$BN/$IDEAS/$TR1" "$BN/.trash/$TR1"; restamp "$B" "$TB" "$BYB" "$TR1"
G "$B" mv "$BN/$IDEAS/$TR2" "$BN/.trash/$TR2"; restamp "$B" "$TB" "$BYB" "$TR2"
G "$B" mv "$BN/$IDEAS/$TT" "$BN/.trash/$TT"; restamp "$B" "$TB" "$BYB" "$TT"
card "$B" "$IDEAS" "$AA" "AA beta" "$TB" "$BYB" "AA body TOKEN_B_AA."
card "$B" "$IDEAS" "$LC" "LC base" "$TB" "$BYB" "LC base body." "$(leaseof "$LSB" 2026-01-03T00:30:00Z)"
G "$B" rm -rq "$BN/$IDEAS/$D1"
setboard "$B" "$TB" "$BYB" Open:1 Closed:3
sed -i '' '1s/v[0-9][0-9]*/v901/' "$B/$BN/CLAUDE.md"; printf 'NOTES_B\n' > "$B/$BN/notes.txt"
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
for tok in TOKEN_A_RL TOKEN_B_RL TOKEN_A_RT TOKEN_B_RT TOKEN_A_Y1 TOKEN_B_Y1 TOKEN_A_K1 TOKEN_B_K1 TOKEN_B_M2 TOKEN_A_TR1 TOKEN_A_TR2 TOKEN_A_AA TOKEN_B_AA TOKEN_A_D1 \
  '"T1 alpha"' 'T1 beta' A-bytes B-bytes; do grep -rqF -- "$tok" "$D" || fail "lost: $tok"; done
at() { [ -f "$D/$1/$2/index.md" ] || fail "$3: not in $1 ($(cd "$D" && ls -d */"$2" .trash/"$2" 2>/dev/null))"; }
at "$ACTIVE" "$M1" "moved both ways: later lane"; at "$DONE" "$M2" "moved one side, edited other"
at .trash "$TR1" "later trash"; at "$IDEAS" "$TR2" "later edit restores to base lane"; at .trash "$TT" "trashed on both"
at "$IDEAS" "$D1" "deleted vs edited"; at "$IDEAS" "$AA" "added on both"
[ "$(find "$D" -type d -name "$TT" | wc -l | tr -d ' ')" = 1 ] || fail "trashed twice"
[ "$(find "$D" -type d -name "$M1" | wc -l | tr -d ' ')" = 1 ] || fail "M1 in two places"
grep -q '^order: 4000$' "$D/$ACTIVE/$M1/index.md" || fail "M1: later side's order"
grep -q TOKEN_A_TR1 "$D/.trash/$TR1/index.md" || fail "later trash: the trashed card doesn't carry the edit"
grep -q '^title: "T1 beta"$' "$D/$IDEAS/$T1/index.md" || fail "title: later wins"
grep -q 'TOKEN_B_Y1' "$D/$IDEAS/$Y1/index.md" || fail "body: later wins"
grep -q 'TOKEN_B_K1' "$D/$IDEAS/$K1/comments/$KC/index.md" || fail "comment: later wins"
# two differing leases: the later side's claimed, whole, in the 3-line block form (no merge comment: the loop below wants none on LC)
LCL=$(awk 'NR>1 && /^---$/ {exit} /^claimed:/ {c=1; print; next} c && /^[ \t]/ {print; next} c {exit}' "$D/$IDEAS/$LC/index.md")
[ "$LCL" = "$(leaseof "$LSB" 2026-01-03T00:30:00Z)" ] || fail "lease: the later side's claimed must win whole: $LCL"
grep -q "^modified: {at: $TB, by: $BYB}\$" "$D/$IDEAS/$LC/index.md" || fail "lease: the later modified must win"
# a relation merges as a comment does, live or in relations/.trash: the later edit in place, the earlier body in the merge comment
R="$D/$IDEAS/$R1/relations"
grep -q 'TOKEN_B_RL' "$R/$RL/index.md" || fail "relation: later wins"
grep -q 'TOKEN_B_RT' "$R/.trash/$RT/index.md" || fail "trashed relation: later wins"
grep -qF "Relation ${RL:0:8}: kept the later edit" "$D/$IDEAS/$R1"/comments/*/index.md || fail "relation: the merge comment doesn't name the relation"
grep -qF "Relation ${RT:0:8}: kept the later edit" "$D/$IDEAS/$R1"/comments/*/index.md || fail "trashed relation: the merge comment doesn't name it"
[ -z "$(find "$R" -name '*.theirs*')" ] || fail "relation: a file beside it, as if unclassified: $(find "$R" -name '*.theirs*')"
grep -q TOKEN_A_RNA "$R/$RNA/index.md" && grep -q TOKEN_B_RNB "$R/$RNB/index.md" || fail "relation: one added on each side, not both kept"
# a rel or to changed on both sides: the later in place, the earlier value in the merge comment
grep -q '^rel: "supersedes"$' "$R/$RR/index.md" || fail "relation rel: later wins"
grep -qF "Relation ${RR:0:8}: rel: kept \"supersedes\"; the other side's was \"depends-on\"." "$D/$IDEAS/$R1"/comments/*/index.md \
  || fail "relation rel: the losing value is not in the merge comment"
grep -q "^to: \"lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/$T1\"$" "$R/$RTO/index.md" || fail "relation to: later wins"
grep -qF "Relation ${RTO:0:8}: to: kept \"lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/$T1\"; the other side's was \"lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/$Y1\"." \
  "$D/$IDEAS/$R1"/comments/*/index.md || fail "relation to: the losing value is not in the merge comment"
L=$(sed -n '/^labels:/,/^created:/p' "$D/$IDEAS/$L1/index.md"); for x in '"x"' '"y"' '"z"' '"Low"'; do grep -qF "$x" <<<"$L" || fail "labels: $x missing: $L"; done
if grep -q High <<<"$L"; then fail "priority: earlier value kept: $L"; fi
grep -qF '{text: "y", rank: 2, kind:' <<<"$L" || fail "labels: a whole-number float not written as the heal writes it (2, not 2.0): $L"
grep -q '^order: 200$' "$D/$IDEAS/$S1/index.md" && grep -q 'for: bob' "$D/$IDEAS/$S1/index.md" || fail "state: later wins"
for v in Open Doing Closed; do grep -q "text: \"$v\"" "$D/index.md" || fail "config.labels values: $v"; done
# merged labels and config come back in the compact form: the board's own heal finds no layout repair (H17)
H17=$(python3 "$D/.schema/bin/lanework-heal.py" "$D" | grep ' H17 ' || true); [ -z "$H17" ] || fail "merged keys not in the compact form: $H17"
head -1 "$D/CLAUDE.md" | grep -q 'v901' || fail "guide: higher version wins"
[ "$(sed -n 2p "$D/.log/2026-01-01.log" | cut -c1-10)$(sed -n 4p "$D/.log/2026-01-01.log" | cut -c1-10)" = 2026-01-012026-01-03 ] || fail ".log: union sorted"
OURS=A; [ "$MODE" = rebase ] && OURS=B
grep -q "$OURS-bytes" "$D/$IDEAS/$AT1/attachments/$AT/blob.png" || fail "attachment: ours kept"
[ -f "$D/$IDEAS/$AT1/attachments/$AT/blob.theirs.png" ] || fail "attachment: theirs beside it"
cat "$D/notes.txt" "$D/notes.theirs.txt" | tr '\n' ' ' | grep -q "NOTES_$OURS NOTES_" || fail "unclassified file: ours kept, theirs beside it"
# one merge comment per card that lost something, none elsewhere
want=" $T1 $Y1 $K1 $AT1 $AA $D1 $R1 "
for c in $(cd "$D" && ls -d */*/ .trash/*/ 2>/dev/null | sed 's#/$##'); do
  id=${c##*/}; is_uuid=$(echo "$id" | grep -c '^[0-9a-f-]\{36\}$' || true); [ "$is_uuid" = 1 ] || continue
  n=$({ grep -l 'session: "merge"' "$D/$c"/comments/*/index.md 2>/dev/null || true; } | wc -l | tr -d ' ')
  case "$want" in *" $id "*) [ "$n" = 1 ] || fail "card $c: $n merge comments, want 1" ;; *) [ "$n" = 0 ] || fail "card $c: $n merge comments, want 0" ;; esac
done
grep -q '^\*\*Merged two edits to this card\.\*\*$' "$D/$IDEAS/$Y1"/comments/*/index.md || fail "merge comment line 1"
echo "$OUT"
