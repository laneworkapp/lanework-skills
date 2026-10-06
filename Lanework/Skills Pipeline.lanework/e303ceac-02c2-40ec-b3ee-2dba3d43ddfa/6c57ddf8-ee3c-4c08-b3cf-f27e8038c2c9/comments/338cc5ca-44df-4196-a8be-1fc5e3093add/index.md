---
schema: 1
kind: comment
created:  {at: 2026-09-27T21:37:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T21:37:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in 88bedd3.** The owner asked for this in chat, adding multi-board watching, so triage and review happened there.

- **Decided**: one Monitor and one watcher for all boards, not a Monitor per board. That means one process to arm and tear down, with the board name on every line. Two boards with the same folder name are refused and need separate Monitors.
- **Decided**: arming reads `pitlane/SKILL.md` by path. A skill that can't be model-invoked can't count on Claude loading another skill for it.
- **Deferred**: pitlane stays model-invocable. The owner will look at it separately.
- **Fixed while testing**: the watcher's unique-name check used `${#${(u)names}}`, which counts the characters of the joined string, so it refused every pair of boards. It now counts array elements.
- **Evidence**: a live run on two scratch boards reported a card edit, a comment posted by renaming `.draft/` (the case the snapshot design exists for), and a lane move (old and new path), each tagged with the right board. An unposted draft produced no line. A 25-file burst came out as 2 lines plus `BULK: 23`. Same-name boards, a non-board and no boards were refused with exit 2, and no fswatch process was left running. `tests/smoke.sh`: 16 of 16 passed, including 2 new watcher cases.
