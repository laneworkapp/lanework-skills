---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:44:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this card as lead. Both cards it depends on have landed.**

- **Dependencies**: `guide_version` is in `lib.sh` (9e04cdec, Done). `--supersedes` is in `file-record.sh` (b0199ddd, Done).
- **One row of the Change table is void**: `skills/dispatch/templates/handler-report.md` was deleted when the dispatch skill was retired. The fixer skips it.
- **Guide**: the body says v117; the board and the repo stamp are now v118. The gate stays "v117 or later".
- **Skipped above this card**: the owner's install move (owner's to run).
- **Branch**: `cite-as`, worktree `.claude/worktrees/cite-as`, cut from main at `e203ecb`.
- **Team**: one fixer, then a reviewer. **Gate**: `tests/smoke.sh` (168 on main).
