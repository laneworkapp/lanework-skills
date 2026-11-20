---
schema: 1
kind: card
title: "settle-question.sh clears waiting with no owner words recorded"
order: 11264
created:  {at: 2026-11-20T20:16:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T21:11:08Z}
---
`discovery/scripts/settle-question.sh` clears a question's `waiting` in two cases where no owner words end up recorded, so the waiting-clear lint reports a miss.

## What happens

Found in review of [discovery records a chat answer in the work skill's quote format](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/738e8765-36c7-44c5-8f8d-34b8452801be), on a throwaway board, branch `discovery-chat-record` at `cf0c2a5`:

- **No `--record`.** Settling or parking a question without `--record` still drops `waiting`. `work/scripts/lint-waiting-clears.sh` then lists the card as NO-QUOTE. The lint is right: an agent cleared `waiting` and nothing shows what the owner said. On a real board, a question the owner deferred in chat and the agent parked would count as a miss.
- **`--record` without `--reply`.** The record is accepted and posted, but with no `in-reply-to` the lint cannot tie it to the ask and reads NO-QUOTE.

## Direction, not yet a proposal

- Require `--reply` with `--record`, or default it to the card's `waiting.comment`.
- For a clear with no record: refuse when `waiting` is set and the newest owner comment is older than `waiting.since`, or require an explicit flag that says the owner answered on the board.

## Smaller, same review

- The record check accepts a `**Given**` line inside the quote and a `>` line inside a code fence; the lint reads both as QUOTED. They agree with each other, so nothing breaks.
- A record file with CRLF line endings is posted as it is, leaving a comment with LF front matter and a CRLF body.
