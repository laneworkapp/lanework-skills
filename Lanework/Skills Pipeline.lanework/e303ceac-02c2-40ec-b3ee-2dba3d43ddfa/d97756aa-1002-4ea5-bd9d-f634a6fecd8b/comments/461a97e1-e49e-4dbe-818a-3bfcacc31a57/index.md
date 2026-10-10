---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:34:35Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T11:34:35Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Shaped and moved to Proposed. The repeat bug is in `found-board.sh` too, not only the discovery wrapper, so the fix covers both.**

- **Evidence**: `found-board.sh:25` assigns `LABELS=` on each flag. `found-discovery-board.sh` assigns `EXTRA=` the same way, and its `if [ -n "$EXTRA" ]` drops an empty list before `found-board.sh` can reject it.
- **Decided**: repeats accumulate, deduped by the existing `SEEN`. Empty lists are an error in both scripts. No owner call: both are argument-handling consistency.
- **Order**: build after [c8cf1d23](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c8cf1d23-38bf-4981-bce6-6df61091bacb) and the v84 stamp.
