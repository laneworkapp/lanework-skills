---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:49:58Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:49:58Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: fixer (sonnet) building on `lane-actors`, worktree `.claude/worktrees/lane-actors`, from 35ba2ce.**

- **Plan**: smoke cases first in `tests/smoke.sh`, run on the unchanged skills for FAIL-BEFORE. Then lane-body edits in the four lane-set templates, the table in `board-kinds.md`, the pipeline sheet line, the watch and work prose fixes (items 1-6), then `skills/heal/` with `heal-descriptors.py`, plugin.json and README. Full `tests/smoke.sh` last.
- **Decided, actor sentence**: in every lane template body the second sentence is the actor/trigger sentence. `heal-descriptors.py` inserts it after the first sentence of a customised body, and treats a body as current when it already carries that sentence.
- **Decided, old bodies**: prior template bodies come from `git log -p` of the four lane tables and are embedded in the script with a comment saying so. A body equal to one of them (or to the current one) is replaced; empty gets the current body.
- **Decided, stamping**: descriptor edits restamp the edited lane's or board's `modified` whole with the running agent (`--model` required, exit 2 without). Data repairs stay with `heal-board.py`.
- **Out of scope here**: version bump, `CHANGELOG.md`, committing board writes: the lead's.
