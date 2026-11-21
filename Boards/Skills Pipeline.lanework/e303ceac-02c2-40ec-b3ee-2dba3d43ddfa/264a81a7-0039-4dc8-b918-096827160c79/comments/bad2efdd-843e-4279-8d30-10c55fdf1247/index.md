---
schema: 1
kind: comment
created:  {at: 2026-11-21T00:23:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `bd9e93e` (branch `settle-waiting-clear`, head `3209b80`), pushed. Not released.

**What changed**

- `discovery/scripts/settle-question.sh` clears `waiting` only when the owner's words are on the card. It stages the card as it would land and runs `work/scripts/lint-waiting-clears.sh` on it; a `NO-QUOTE` result means exit 1 and nothing written. The message names `--record`.
- `--record` with no `--reply` replies to the card's `waiting.comment`.
- A question with no `waiting` settles as before.
- A record or ruling file with CRLF line ends is written with LF.
- The rule is one paragraph in `discovery/references/rounds.md` § Answers.

**One departure from the direction on the card**: the check uses the newest ask's time, as the lint does, not `waiting.since`. Running the lint itself keeps the script and the lint in agreement.

**Evidence**

- `tests/smoke.sh` on `main` at `bd9e93e`: 285 passed, rc 0 (second run; the first stopped at the plan-claim timing case, a load flake tracked in its own Issues card).
- Independent review: approved, nothing blocking. 27 scenarios compared against the lint on a real board copy: the script refused every clear the lint would call a miss, with the board byte-identical, and agreed on the rest. Nine mutants, each caught by a smoke case.
- Refusals leave nothing behind, also on SIGTERM and with the lint missing.

**Left open (reviewer notes, filed as one follow-up card in Issues)**

- The refusal message blames the reply target when the real cause is an empty or fenced quote.
- `rounds.md` reads as if any owner comment after the ask were an answer; a `Recap:` click is not.
- One dead assertion in smoke; comment attachments are copied for the check; a non-executable lint is reported as missing.

**CHANGELOG sentence for 0.9.0**: Discovery no longer settles or parks a question that is waiting on you unless your answer is recorded on the card, and a chat answer recorded without naming the question it answers now replies to it automatically.
