---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:58:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:58:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Landed: the skills look in `Lanework/`, then `Boards/`, then legacy `Pitlane/`, and this board now lives under `Lanework/`.**

**Commits**: `e7ae234` merges the skills change, after a README conflict with the merge skill was resolved by hand. `b9d0ee2` is the `git mv` on main, and `f45d06c` fixes the merge test's two old paths, a conflict neither branch could see on its own. All three were pushed together, so origin never went red.
**Evidence**: `bash tests/smoke.sh; echo $?` on main at `f45d06c` printed `smoke: 37 passed` and exit 0. The adversarial review approved in round 2.
**Accepted limitation**: a board folder that is itself a symlink isn't found, and the board validator skips that shape too.
**Pending**: the app reopening this board from `Lanework/`, asked below. The `/watch` offer checks run after release. This machine's `~/Pitlane/` gets the offer once, in chat.
