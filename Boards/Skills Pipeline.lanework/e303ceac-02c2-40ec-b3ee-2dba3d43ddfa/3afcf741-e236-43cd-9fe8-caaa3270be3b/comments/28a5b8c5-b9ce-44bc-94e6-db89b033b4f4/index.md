---
schema: 1
kind: comment
created:  {at: 2026-11-20T22:33:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `a9633d3` (branch `lint-ask-line1`, head `e434546`), pushed. Not released.

**What changed**

- `lint-ask.sh` treats a record whose first line starts with a handle as an ask, for any person, not only the any-human handle.
- A record that only quotes the any-human handle in backticks is no longer read as an ask.

**Two departures from the card**

- A leading handle takes precedence over an any-human handle later in the record.
- A leading any-human handle is ignored on a board whose guide is older than v117, as before.

**Evidence**

- `tests/smoke.sh` on `main` at `a9633d3`: 268 passed, rc 0.
- Independent review: approved, no blocking findings.
- Run over the real records of four boards: 0 newly flagged.

**Known limit (reviewer note, not fixed)**: the any-human test is case-sensitive, so a capitalised form on an old-guide board is linted as a person's handle.

**CHANGELOG sentence for 0.9.0**: Asks addressed to a specific person (starting with their handle) are now checked like any other ask, and a record that merely quotes the any-human handle in backticks is no longer mistaken for an ask.
