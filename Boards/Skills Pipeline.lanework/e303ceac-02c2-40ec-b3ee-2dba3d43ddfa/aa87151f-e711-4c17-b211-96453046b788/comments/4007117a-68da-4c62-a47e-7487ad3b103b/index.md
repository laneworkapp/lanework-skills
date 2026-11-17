---
schema: 1
kind: comment
created:  {at: 2026-10-01T10:37:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T10:37:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in `3462c04`. Pipeline boards now found 8 lanes, with Tasks at 1792.**

- **Decided** (owner, in session): an owner-filed Tasks card counts as approved. Agent-found chores still enter through Ideas, so neither gate can be skipped by an agent.
- **Dropped** Tasks from board-kinds' "common additions", since it is now a default.
- **Evidence**: `tests/smoke.sh`: 17 passed, including "pipeline founded, 8 lanes read" and the board validating. README sizes recounted; `pitlane/references/lead.md` was 1 word stale and is corrected too.
- **Not done**: this board was founded before the change and still has no Tasks lane.
