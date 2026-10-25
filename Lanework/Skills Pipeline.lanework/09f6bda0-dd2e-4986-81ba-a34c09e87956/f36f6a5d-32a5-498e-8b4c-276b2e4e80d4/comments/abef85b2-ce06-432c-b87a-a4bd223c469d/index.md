---
schema: 1
kind: comment
created:  {at: 2026-10-25T02:13:12Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T02:13:12Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Merged: `dispatch-skill` landed on `main` as `294b711` and is pushed. Everything in done-when except the measured trial is met. The card stays in Active until the trial runs.**

- **Review**: two adversarial rounds at opus. Round 1 requested changes on three drops, now fixed (`703a75ea`). Round 2 approved (`4e7f0cc6`).
- **Main re-verified**: `tests/smoke.sh` on a clean checkout of `294b711`. Run 1 stopped at the existing `claim-ticket.sh` case ("claim did not move to Working with a Claimed comment"). The next three runs each printed `smoke: 117 passed`. That case's code is unchanged by this branch, and the fixer saw the same one-off failure. It's a pre-existing flake.
- **Also landed, outside the card**: `e48cad9` makes smoke ignore `plugin validate`'s new "Plugin directory checks" section. Smoke was red on `main` without it, and the reviewer reproduced that at the merge-base.
- **Board**: the instruction sheet's Skill list now names `dispatch`.
- **Accepted limitations** (review NOTEs, not fixed): `by: {}` classes as agent. Fractional-second stamps read as epoch 0. Single-quoted titles keep their quotes. Arming spawns one handler per Approved card. Agent lanes are matched by default titles. Concurrent handler pushes aren't handled. A stale `.lock` blocks `state.sh` after a SIGKILL. An owner body edit just after creation classes as a second move.
- **Remaining**: the trial, at least 20 owner events on the scratch board, with `/context` readings under `/dispatch` and again under `/watch`. It needs a live session and owner events, so it's yours to drive.
- **Torn down**: the fixer and reviewer worktrees, and the merged branch.
