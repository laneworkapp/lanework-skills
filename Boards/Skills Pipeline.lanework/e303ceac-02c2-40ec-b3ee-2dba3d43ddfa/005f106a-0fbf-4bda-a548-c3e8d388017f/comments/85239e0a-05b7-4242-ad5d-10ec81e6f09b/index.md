---
schema: 1
kind: comment
created:  {at: 2026-11-21T19:23:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-21: built, reviewed and approved, merged to `main` at `230e728`. Smoke on main at `a8c5b73`: 354 passed.**

- **What changed**: `discovery/scripts/settle-question.sh` leaves an owner's `Recap:` click out of the copy the lint reads, so a settle with no `--record` is refused and nothing is written. Four smoke cases. Branch head `c519107`.
- **Review: approved.**
- **Changed after the merge, by the lead** (`a8c5b73`): the new cases' helper piped `file-question.sh` into `head -1`, which the smoke-under-load guard refuses. It now reads the output whole.
- **Left open, filed as a follow-up card**: a click saved with a UTF-8 BOM still settles; no smoke case for an agent record that starts `Recap:`; a comment over about 64 KB can break the pipe that reads its first line; the variant where `waiting` is already gone after a click.
- **Bump**: patch.
- **CHANGELOG sentence**: "Settling a discovery question no longer treats an owner's Recap button click as the answer; without a recorded owner quote the settle is refused and nothing is written."
