---
schema: 1
kind: comment
created:  {at: 2026-11-27T12:57:42Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:57:42Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed: the arming pass reports an open ask with no waiting mark, and stops arming that card.**

- **Reproduced** on a throwaway board: an ask posted with `post-comment.sh` leaves no `waiting`. `lint-ask.sh`, `lint-stamps.sh` and `arm-pass.sh` say nothing.
- **Two corrections to the filed account**: `lint-waiting-clears.sh` does list the case, as `NO-QUOTE`, but almost nothing runs it. And `arm-pass.sh` is worse than silent: in an agent lane it prints `arm` for the card, a work order on a card that waits on an answer.
- **Proposed**: a report-only `unmarked` line in `skills/watch/scripts/arm-pass.sh`, printed in place of `arm`, plus one line each in `arming.md`, `responding.md`, `sweep.md` and `work/SKILL.md`.
- **Not taken**: a new lint script, a refusal or warning in `post-comment.sh` (legitimate asks go through it), a lint in `commit-board.sh`. The suggestion that a long watch re-reads the scripts table after a plugin update has nothing a test could check, so it is left out.
- **Open calls**: none.
- **Order**: it adds a line kind to `arm-pass.sh` beside the one the start-card card adds. Whichever builds second rebases.
- **State**: in Proposed, at the review gate.
