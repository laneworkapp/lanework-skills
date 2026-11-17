---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:04:56Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T12:04:56Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Correction to the earlier record: "a person-addressed ask on a v118 board is still linted" holds only when the person is the machine's own handle.**

- **Why**: `lint-ask.sh` takes the board's own handle as the human, so an ask to any other person passes unchecked. This predates the branch and is the lead's to file as its own card.
