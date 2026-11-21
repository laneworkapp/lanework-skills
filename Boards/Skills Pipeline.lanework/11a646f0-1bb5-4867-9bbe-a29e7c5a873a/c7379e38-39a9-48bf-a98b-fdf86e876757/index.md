---
schema: 1
kind: card
title: "settle-question.sh: misleading refusal text and four small leftovers"
order: 3072
created:  {at: 2026-11-21T00:23:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T00:23:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
## Problem

Small leftovers from the review of [settle-question.sh clears waiting with no owner words recorded](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/264a81a7-0039-4dc8-b918-096827160c79), branch `settle-waiting-clear` at `3209b80`. None loses data.

- **Misleading refusal.** `discovery/scripts/settle-question.sh:83` says "the record does not answer the card's newest ask" when the reply target is right and the real cause is a quote that is a bare `>`, `>` plus spaces, or `>` inside a code fence. When `waiting.comment` is stale the message also leaves out the newest ask's id, which the lint output already holds.
- **Prose.** `discovery/references/rounds.md:34`, "or an owner comment after the ask already on the card", reads as enough on its own. A `Recap:` click or an answer to another question is not a ruling (`work/references/writing.md`).
- **Dead assertion.** `tests/smoke.sh:482`, a standalone `! grep -q` under `set -e`, can never fail.
- **Cost.** `settle-question.sh:79` copies comment attachments into the scratch board for the check; only each comment's `index.md` is needed.
- **Wrong word.** `settle-question.sh:56` reports a lint script that exists but is not executable as "missing".

## Done when

- The refusal names the newest ask's id and says the quote may be empty or inside a fence; a smoke case for a bare `>` record checks the text.
- `rounds.md` says an owner answer, not a `Recap:` click.
- The smoke line fails on a mutant.
- A 200 MB comment attachment adds no measurable time to a settle.
