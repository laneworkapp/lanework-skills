#!/bin/bash
# label-card.sh: add labels to a card, in the compact form.
# usage: label-card.sh <board> <card-index-or-dir> <label>... --model m [--name n] [--session s]
# A label is `Text` (a free label) or `Text:kind` (stamped from the board's config.labels: `High:priority`).
# `a: b` splits at the LAST colon, so a free label whose text holds one is `a: b:text`.
# Runs union_labels --strict then compact_fm on a staged copy outside the board, restamps `modified` whole
# (guide § Stamping: every write to a card; `at` from the clock, the caller's `by`), validates with the board's
# .schema validator (skipped with a note when the board has none), then one `mv` in. The card must be unchanged
# since it was read (compared just before the rename: a window of a few instructions remains between that compare and the
# `mv`, and no lock is shared with the app or other writers; LABEL_CARD_TEST_HOLD=<dir> holds the script there until <dir>/release exists, for tests).
# A card with CRLF line endings, or an index.md under an attachments/ or dot folder, is refused (exit 1). A label the card already has (text and kind, case aside) is a no-op: exit 0, nothing written.
# Lease (lanework/references/writes.md § Lease): with CLAUDE_CODE_SESSION_ID set, `lease.sh check` first.
# Exit 1, nothing written: not a board or card, CRLF line endings, an undefined kind, a value a closed kind does not list, a different
# value of a `single` kind the card holds, the card changed meanwhile, the validator failed on the staged card.
# Exit 2, nothing written: no model, no label, a bad flag. Exit 3: the lease is lost.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"
USAGE="label-card.sh <board> <card-index-or-dir> <label>... --model m [--name n] [--session s]"
[ $# -ge 2 ] || { echo "usage: $USAGE" >&2; exit 2; }
BOARD="$1"; CARDARG="$2"; shift 2
MODEL=""; NAME="claude"; SESSION=""; LABELS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --model)   need_value "$@"; MODEL="$2"; shift 2 ;;
    --name)    need_value "$@"; NAME="$2"; shift 2 ;;
    --session) need_value "$@"; SESSION="$2"; shift 2 ;;
    -*) echo "label-card.sh: unknown argument: $1" >&2; exit 2 ;;
    *)  LABELS+=("$1"); shift ;;
  esac
done
require_model label-card.sh "$USAGE"
stamp_args_ok "$NAME" "$MODEL" "$SESSION"
[ ${#LABELS[@]} -gt 0 ] || { echo "label-card.sh: no label" >&2; echo "usage: $USAGE" >&2; exit 2; }
[ -f "$BOARD/index.md" ] || { echo "label-card.sh: not a board: $BOARD" >&2; exit 1; }
F="${CARDARG%/}"; [ -d "$F" ] && F="$F/index.md"
BOARD_ABS=$(cd "$BOARD" && pwd -P)
# a card is the depth: <board>/<lane>/<card>/index.md (guide § Layout); `kind` is optional on a short-form card
[ -f "$F" ] && [ "$(basename "$F")" = index.md ] && [ "$(cd "$(dirname "$F")/../.." 2>/dev/null && pwd -P)" = "$BOARD_ABS" ] \
  || { echo "label-card.sh: not a card of $BOARD (want <board>/<lane>/<card>/index.md): $CARDARG" >&2; exit 1; }
# not under an attachments/ or dot folder (what board_index_files prunes: an index.md there is an attachment's or the app's, not a card)
CDIR=$(cd "$(dirname "$F")" && pwd -P); LDIR=$(dirname "$CDIR")
for seg in "$(basename "$CDIR")" "$(basename "$LDIR")"; do
  case "$seg" in attachments|.*) echo "label-card.sh: not a card (under $seg): $CARDARG" >&2; exit 1 ;; esac
done
grep -q $'\r' "$F" && { echo "label-card.sh: $F has CRLF line endings, which this script does not rewrite; nothing written" >&2; exit 1; }
CID=$(basename "$(dirname "$F")")

LEASE="$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lease.sh"
if [ -n "${CLAUDE_CODE_SESSION_ID:-}" ] && [ ! -f "$LEASE" ]; then
  echo "label-card.sh: note: no lanework/scripts/lease.sh beside work; the lease is not checked" >&2
elif [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
  rc=0; "$LEASE" check "$BOARD" "$CID" --model "$MODEL" --name "$NAME" >/dev/null || rc=$?
  case $rc in
    0|4) ;;
    3) echo "label-card.sh: this session's lease on ${CID:0:8} is lost (the Lease lost record is on the card); nothing written" >&2; exit 3 ;;
    *) echo "label-card.sh: lease.sh check failed (exit $rc); nothing written" >&2; exit 1 ;;
  esac
fi
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/work-label.XXXXXX"); trap 'rm -rf "$STAGE"' EXIT
cp "$F" "$STAGE/read" && cp "$F" "$STAGE/index.md"
union_labels --strict "$STAGE/index.md" "$BOARD" "${LABELS[@]}" || { echo "label-card.sh: nothing written" >&2; exit 1; }
cmp -s "$STAGE/read" "$STAGE/index.md" && exit 0     # every label already there
BY=$(by_of "$NAME" "$MODEL" "$SESSION")
LW_M="modified: {at: $(now_utc), by: $BY}" awk '   # ENVIRON, not -v: awk -v interprets backslash escapes in a stamp value
  BEGIN { m = ENVIRON["LW_M"] }
  NR == 1 && $0 == "---" { fm = 1; print; next }
  fm && drop && /^[ \t]/ { next }
  fm { drop = 0 }
  fm && $0 == "---" { if (!sm) print m; fm = 0; print; next }
  fm && /^modified:/ { print m; sm = 1; drop = 1; next }
  { print }' "$STAGE/index.md" > "$STAGE/new" && mv "$STAGE/new" "$STAGE/index.md"
stamp_lines_ok "$STAGE/index.md" modified || { echo "label-card.sh: a brace in the stamp (--model, --name or --session); nothing written" >&2; exit 1; }
compact_fm "$STAGE/index.md"
VAL="$BOARD/.schema/bin/lanework-validate.py"
if [ -f "$VAL" ]; then
  VB="$STAGE/v/Stage.lanework"; mkdir -p "$VB/lane/$CID"   # a one-card board, so the validator finds the card's place
  cp "$BOARD/index.md" "$VB/index.md"; printf -- '---\nkind: lane\n---\n' > "$VB/lane/index.md"; cp "$STAGE/index.md" "$VB/lane/$CID/index.md"
  OUT=$(python3 -I "$VAL" --schema "$BOARD/.schema" "$VB/lane/$CID/index.md" 2>&1) && ! grep -q DEPRECATED <<<"$OUT" || { printf '%s\n' "$OUT" >&2; echo "label-card.sh: the staged card fails the board's validator; nothing written" >&2; exit 1; }
else
  echo "label-card.sh: note: no .schema/bin/lanework-validate.py on the board; card not validated" >&2
fi

if [ -n "${LABEL_CARD_TEST_HOLD:-}" ]; then   # tests only: say "held", wait for "release"
  : > "$LABEL_CARD_TEST_HOLD/held"; n=0; while [ ! -e "$LABEL_CARD_TEST_HOLD/release" ] && [ $n -lt 400 ]; do sleep 0.05; n=$((n+1)); done
fi
# compare against the card as read, then rename into place
cmp -s "$F" "$STAGE/read" || { echo "label-card.sh: the card changed while it was staged; nothing written, run again" >&2; exit 1; }
mv "$STAGE/index.md" "$F"
printf '%s\n' "$(dirname "$F")"
