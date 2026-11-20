---
schema: 1
kind: card
title: "commit-board.sh drops the owner's staged version of a path when a pre-commit hook fails"
order: 2048
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T13:35:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T13:39:57Z}
---
`commit-board.sh` resets the index for its named paths even when its commit never happened, and five smaller edges of the new work helpers were noted in review and left out of [the helpers card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f).

## Seen

Measured or reasoned by the reviewer at `8647cd8`, merged to main as `e53a5f0`. None is released yet.

| # | where | what happens | how sure |
|---|---|---|---|
| 1 | `commit-board.sh:151`, `HEAD0=1` set before `git commit` | a pre-commit hook fails, nothing is committed, and the exit trap still runs `git reset -q -- <paths>`: the owner's staged version of a named path leaves the index. The work tree is intact | measured |
| 2 | `commit-board.sh:70`, the exit-trap reset | it also runs after the lock was lost, and can collide on `index.lock` with the run now holding the lock | reasoned, not run |
| 3 | `commit-board.sh:144`, `nothing to commit` | every named path was skipped (a glob or a typo that names no file) and the script exits 0; only stderr says "skipped" | measured |
| 4 | `commit-board.sh:43`, `os.path.realpath` | a symlink inside the work tree gets its target committed, not the link | measured |
| 5 | all four helpers and `post-comment.sh`, `${2:?}` | a flag given with no value exits 1, where the headers document 2 | measured on `move-card --model` and `post-ask --for` |
| 6 | `tests/smoke.sh`, the kill-mid-push case | its SIGKILL leg leaves one `work-commit.*` folder in `TMPDIR` on every smoke run | measured |

## Suggested fixes

1. Reset in the trap only when HEAD actually moved.
2. Guard that reset with the same lock-ownership check the commit uses.
3. Exit 1 when every named path was skipped.
4. Refuse a symlink, or commit the link itself.
5. Exit 2 on a missing flag value, in all five scripts.
6. Set `TMPDIR` to the test folder for that leg.

## Not decided

Which of these are worth a card each, and whether 1 should go in before 0.9.0 is cut. Row 1 is the only one that changes what the owner has staged.
