---
schema: 1
kind: card
title: "settle-question.sh clears waiting with no owner words recorded"
order: 9216
created:  {at: 2026-11-20T20:16:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T23:45:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`discovery/scripts/settle-question.sh` clears a question's `waiting` in two cases where no owner words end up recorded, so the waiting-clear lint reports a miss.

## What happens

Found in review of [discovery records a chat answer in the work skill's quote format](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/738e8765-36c7-44c5-8f8d-34b8452801be), on a throwaway board, branch `discovery-chat-record` at `cf0c2a5`:

- **No `--record`.** Settling or parking a question without `--record` still drops `waiting`. `work/scripts/lint-waiting-clears.sh` then lists the card as NO-QUOTE. The lint is right: an agent cleared `waiting` and nothing shows what the owner said. On a real board, a question the owner deferred in chat and the agent parked would count as a miss.
- **`--record` without `--reply`.** The record is accepted and posted, but with no `in-reply-to` the lint cannot tie it to the ask and reads NO-QUOTE.

## Direction at filing

- Require `--reply` with `--record`, or default it to the card's `waiting.comment`.
- For a clear with no record: refuse when `waiting` is set and the newest owner comment is older than `waiting.since`, or require an explicit flag that says the owner answered on the board.

## Smaller, same review

- The record check accepts a `**Given**` line inside the quote and a `>` line inside a code fence; the lint reads both as QUOTED. They agree with each other, so nothing breaks.
- A record file with CRLF line endings is posted as it is, leaving a comment with LF front matter and a CRLF body.

## Reproduce

On a throwaway discovery board made with the repo's own scripts (branch `settle-waiting-clear` before the fix, `main` at `7161565`), three questions were filed with `file-question.sh`, so each card had `waiting` set and an ask comment. Then:

- `settle-question.sh <board> <Q1> --ruling r.md --model repro` exited 0 and moved the card to Settled.
- `settle-question.sh <board> <Q2> --ruling r.md --to parked --model repro` exited 0 and moved the card to Parked.
- `settle-question.sh <board> <Q3> --ruling r.md --record rec.md --model repro`, with a well-formed record and no `--reply`, exited 0 and posted the record with no `in-reply-to` line.

No card kept `waiting`. `work/scripts/lint-waiting-clears.sh <board>` then printed `NO-QUOTE` for all three cards, ended with `QUOTED 0, NO-QUOTE 3`, and exited 1. Both cases on the card are confirmed: a clear with no record, and a record that is not tied to the ask.

## Change

`settle-question.sh` now refuses to clear `waiting` unless the owner's words are on the card, and it uses the waiting-clear lint itself to decide.

- When `--record` is given without `--reply`, the record is posted in reply to the card's `waiting.comment`, read from the flow or the block form.
- When the card has `waiting` set, the script builds the card as it would land (the restamped card, its existing comments and the staged record) in a one-card scratch board and runs `work/scripts/lint-waiting-clears.sh` on it. If the lint reads `NO-QUOTE`, the script exits 1 and writes nothing. With no record, the message tells the agent to pass `--record` with the owner's words. With a record, it says the record does not answer the card's newest ask and names the `--reply` used.
- So a clear with no record is allowed only when the lint already excuses the card: an owner (human) comment newer than the card's newest ask, or an owner comment in reply to it. Running the lint itself means the script and the lint cannot disagree.
- A question with no `waiting` settles as it does today, record or not.
- The `--record` and `--ruling` files are written with LF line endings; carriage returns are dropped.
- If `waiting` is set and the lint script is missing (the `work` skill not installed beside `discovery`), the script exits 1 and writes nothing rather than skip the check.
- There is no escape flag. `work/references/writing.md` § The owner's exception already says nothing else lets an agent clear `waiting`. A question the owner deferred in chat is parked with a `--record` of the owner's words, which is what the rule asks for.
- The rule's prose is one paragraph in `discovery/references/rounds.md` § Answers. The script table line in `discovery/SKILL.md` now shows `[--record F]` and points there. The README word counts for both files are updated.
- The smaller item about a `**Given**` line inside the quote and a `>` line inside a code fence is left as it is. The script's own format check is looser than the lint, but the lint now has the last word on every clear, so the two cannot disagree on whether a clear passes.

## Verified

- The reproduction above, rerun on the fixed script: the two record-less clears exit 1 with the `--record` message and leave both cards in Asked with `waiting` set; the record with no `--reply` lands in reply to the ask; the lint prints `QUOTED 1, NO-QUOTE 0` and exits 0.
- New smoke cases, each shown failing on the unfixed script or on a mutant in a scratch copy: refusal of settle and park with no record and no owner answer; refusal of a record in reply to an ask other than the newest; a CRLF record with no `--reply` parked in reply to `waiting.comment`, written LF and read `QUOTED`; a clear with no record after an owner comment on the board; a question with no `waiting` settling with no record.
- Existing smoke cases that settled a waiting card with no record now add an owner comment first, so each still tests what it tested before. The triple-brace refusal case in particular is refused by the brace guard, not by the new check.
- `bash -n`, `tests/check-sizes.sh`, `tests/check-refs.sh` and the full `tests/smoke.sh` pass.

## Done when

- `settle-question.sh` with `waiting` set, no `--record` and no owner comment after the ask exits 1, writes nothing, and its message names `--record`, for both Settled and Parked.
- `settle-question.sh --record F` with no `--reply` posts the record in reply to the card's `waiting.comment`, and `lint-waiting-clears.sh` reads that card as `QUOTED`.
- A record in reply to an ask other than the card's newest is refused with exit 1 and nothing written.
- A clear with no record still succeeds when an owner comment newer than the ask is on the card, and a question with no `waiting` settles as before.
- A record or ruling file with CRLF line endings lands with LF only.
- The rule is written once, in `discovery/references/rounds.md` § Answers; `discovery/SKILL.md`'s script line is accurate; the README sizes match; smoke passes.

## Risks

- The script now depends on `work/scripts/lint-waiting-clears.sh` whenever `waiting` is set. Someone who installed `discovery` without `work` gets an exit 1 on every settle of a waiting card. The skills are documented as installed together, and `file-question.sh` already reaches into `work` for `lint-ask.sh`.
- The lint counts any owner comment after the ask as an answer, including a `Recap:` click or a reply about something else. The script allows a clear with no record in those cases too, because it matches the lint exactly. Telling a real answer from a click is still the agent's job, as `discovery/references/conduct.md` says.
- The check is tied to the card's newest ask, as the lint is, not to `waiting.since`. In normal use the ask is posted with `waiting` in the same pass, so the two agree; a card whose `waiting` points at an older ask is refused until the record answers the newest one.
- Agents that used to settle or park a waiting question with no record will now be stopped and must record the owner's words. That is the intended change, but it will surface as a new exit 1 in existing sessions.
