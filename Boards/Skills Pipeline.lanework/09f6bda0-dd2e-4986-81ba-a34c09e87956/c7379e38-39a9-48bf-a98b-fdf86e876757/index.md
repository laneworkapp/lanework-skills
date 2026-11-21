---
schema: 1
kind: card
title: "settle-question.sh: misleading refusal text and four small leftovers"
order: 6144
labels: [{text: "discovery", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T00:23:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:22:21Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`settle-question.sh` refuses with a message that names the real cause and the ask it checked, and drops four small leftovers around it (a vague rule in `rounds.md`, a smoke line that cannot fail, a needless attachment copy, a wrong word).

## Problem

Small leftovers from the review of the waiting-clear guard in `settle-question.sh`. None loses data. All five were re-checked against `main` after the lint exit-2 change.

- **Misleading refusal.** Reproduced on a throwaway discovery board. A question card with `waiting` set, a record file whose quote is a bare `>` plus a `**Given**` line, and the right reply target: `settle-question.sh` exits 1 with "the record does not answer the card's newest ask (--reply <the right ask id>)". The reply is right; the lint rejects the quote because a quote needs text after the `>` and counts only outside a code fence. With `--reply` set to a made-up id the same text appears, and it prints that wrong id rather than the newest ask's id. The lint line `NO-QUOTE <card> <ask uuid>` already holds the newest ask's id (`skills/discovery/scripts/settle-question.sh:83-84`), but the message never uses it.
- **Prose.** Not reproduced: reasoned from `skills/discovery/references/rounds.md:34`, "or an owner comment after the ask already on the card". Any owner comment reads as enough, but a `Recap:` click or an answer to another question is not a ruling (`work/references/writing.md`; `rounds.md:28` already says a `Recap:` click is not an answer).
- **Dead assertion.** Reproduced the mechanism: `bash -c 'set -e; ...; ! grep -q hi f; echo survived'` prints `survived`, since `set -e` ignores a failing `!` command. The line is now `tests/smoke.sh:487`, `perl -ni -e 'print unless /^waiting:/' "$CF6"; ! grep -q '^waiting:' "$CF6"`, in the "no waiting" settle case. The card's old line number (482) has moved; the defect is the same.
- **Cost.** Not a timing problem on this Mac: with a 200 MB attachment under the ask comment, a settle took 0.31 s, because APFS clones the copy. Still real: `settle-question.sh:79` copies `comments/.` whole, attachments included, though `lint-waiting-clears.sh` reads only each `comments/*/index.md` and skips attachments. On a volume without clones the copy would be proportional to the attachment size. Reasoned from `settle-question.sh:79` and the lint's header.
- **Wrong word.** Reproduced: with `work/scripts/lint-waiting-clears.sh` present but `chmod -x`, the script says "waiting is set and <path> is missing (install work beside discovery)". The file is there; the check at line 56 is `-x`, so the message is wrong for the not-executable case.

## Change

- `skills/discovery/scripts/settle-question.sh`, refusal (line 84): when the record is given, take the ask id from the first `NO-QUOTE` line of the lint output and say, telegraphically, that the newest ask is `<id>` and the record has no answer to it: the quote may be a bare `>` or sit inside a code fence, or `--reply` may name another ask. Keep exit 1 and "nothing written". If the id cannot be read, keep today's wording.
- `skills/discovery/scripts/settle-question.sh`, line 79: copy only each comment's `index.md` into the scratch board (loop over `"$CARD"/comments/*/index.md`, `mkdir` the comment folder first). Attachments stay out of the check.
- `skills/discovery/scripts/settle-question.sh`, line 56: split the test. Missing file: "is missing (install work beside discovery)". Present but not executable: "is not executable". Both exit 1, nothing written.
- `skills/discovery/references/rounds.md:34`: replace "an owner comment after the ask already on the card" with "an owner answer to the ask already on the card (a `Recap:` click is not one)". The rule stays in `work/references/writing.md`; this line only points at it.
- `tests/smoke.sh:487`: turn the standalone `! grep -q` into `! grep -q ... || { echo "..."; exit 1; }`, matching the other guard lines in the file.

## Verified

New cases in `tests/smoke.sh`, next to the existing settle-question refusals (around lines 405 to 421). Each fails without its fix.

- **Refusal text.** A waiting card, a record with a bare `>` and a `**Given**` line, the right `--reply`. Assert exit 1, nothing written (board checksum unchanged), and that stderr contains the newest ask's id and the word `fence`. Before the fix stderr has the reply id only when it equals the ask id, and never the word `fence`. A second run with a stale `--reply` asserts the message names the newest ask's id, not the passed one.
- **Attachments not copied.** Copy `skills/` as the existing stub case does, replace `lint-waiting-clears.sh` with a stub that lists the tree it is given (`find "$1"`) and prints `QUOTED x y` with exit 0. Put an `attachments/` folder under an ask comment. Assert the stub's listing holds each comment's `index.md` and no `attachments`. Before the fix the listing includes `attachments`.
- **Not executable.** In the stub copy, `chmod -x` the lint. Assert exit 1, nothing written, and that stderr says `not executable` and not `missing`. A second assertion with the lint deleted says `missing`.
- **Dead assertion.** Mutant check by hand, not a smoke case: put a `waiting:` line back into `$CF6` before the line and confirm smoke fails with the new message; record this in the card's comment.
- `rounds.md` wording: `check-refs.sh` and `check-sizes.sh` stay green; add a `grep` assertion that the line says `Recap` so the rule is not dropped.

## Done when

- `bash tests/smoke.sh` passes with the new cases, and each new case fails when its edit is reverted.
- A bare-`>` record on a waiting card is refused with a message that contains the newest ask's id and the word `fence`.
- `settle-question.sh` stages no `attachments` folder (run it with a stub lint that lists its input).
- A present, non-executable lint is reported as `not executable`; an absent one as `missing`.
- `grep -n 'owner answer' skills/discovery/references/rounds.md` finds the reworded line and it mentions `Recap:`.
- Putting `waiting:` back into the "no waiting" smoke card makes smoke fail.

## Risks

Low. The settle path writes nothing on any refusal, and the changes touch only message text, the staged copy and a test line. The `index.md`-only copy must keep the lint's input identical: the lint reads only `comments/*/index.md`, so verdicts do not change. Wording is checked by substring, so the message can be reworded without breaking smoke as long as the id and `fence` stay.

## Recommendation

Build all five. They are small, independent and share one script and one smoke region. The attachment item is the weakest on its own (0.31 s measured for 200 MB), but it removes a pointless copy at no risk, so keep it with a test that checks what is staged rather than timing.
