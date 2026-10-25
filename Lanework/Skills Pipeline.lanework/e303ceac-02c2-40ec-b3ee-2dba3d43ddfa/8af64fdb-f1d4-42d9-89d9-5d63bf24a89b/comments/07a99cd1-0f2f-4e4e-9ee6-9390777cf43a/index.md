---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:48:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:48:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
in-reply-to: 780ff2a5-3b09-46a3-a3dd-bc1042bc0aed
---
**Lead's ruling after round 2: the three open findings each get one more fix, and the reviewer re-checks only those.**

**Why not accept them**: B1 and B4 lose text or leave a board that fails validation, and N1 crashes before the report prints. The card's done-when rules out all three, and each fix is small.
**Decided, B4**: no git hooks. Installing hooks would reach into the user's own hook setup. The rebase report and the skill's step 4 call for a second `merge-board.sh` run after the rebase finishes, and the test runs that documented step as the flow.
**Decided**: a lane or board title changed on both sides keeps the earlier title inline, extending the owner's ruling A from bodies to titles.
**Accepted limitation**: untracked leftovers in an orphan folder (the app's `.draft`, a temp file) stay where they are. Listed under Limits.
