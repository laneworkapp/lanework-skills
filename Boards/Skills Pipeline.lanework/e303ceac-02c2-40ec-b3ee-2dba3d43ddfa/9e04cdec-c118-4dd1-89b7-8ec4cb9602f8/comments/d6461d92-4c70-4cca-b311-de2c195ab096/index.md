---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:15:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-17T11:15:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Evidence from the field: 0.8.0 shipped without this card, and agents following it still address asks to the machine's handle. Reported by the Lanework Main session at the owner's ask, 2026-11-17.**
- **Seen** (that session's report): asks written with the owner's own handle on line 1 and in `waiting.for` on a board whose guide is v118, on a Lanework app Pipeline card and in that session's own asks.
- **Confirmed here on `main` at 0.8.0**: `grep -rn '@anyone\|for: anyone' skills` finds nothing. `work/templates/ask.md` lines 3 and 6, `work/references/writing.md` § The ask and `work/scripts/lint-ask.sh` all take the handle from the board's guide.
- **Already in this card's body**: the `@anyone` default with the v117 version condition, `ask_handle` in `lib.sh`, `lint-ask.sh` checking an `@anyone` ask, `file-question.sh`, and `anyone` as a reserved name.
- **Swept, nothing to add**: `watch` and `dispatch` write no handle. Their only mention is "No handle" on a record, in `watch/references/responding.md` line 11.
- **Not in the body, for the build to take or decline**: (1) `writing.md` saying outright that the handle is never taken from the guide's "answers to" line and that agents never act on `@anyone`; (2) `lint-ask.sh` warning when a v117+ ask names the machine's handle. The second needs a way to tell a question that is one person's from a default, which the body does not have.
- **State**: Proposed, at the owner's gate. The owner believed 0.8.0 carried this; it rides the release after.
