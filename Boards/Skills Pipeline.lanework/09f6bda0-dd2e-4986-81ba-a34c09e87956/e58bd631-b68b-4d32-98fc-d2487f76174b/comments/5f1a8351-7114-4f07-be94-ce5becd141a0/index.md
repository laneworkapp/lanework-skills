---
schema: 1
kind: comment
created:  {at: 2026-11-28T13:16:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T13:16:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: both gaps are confirmed on `main`, the proposal is in the body, and nothing is left open.**

- **Checked**: `heal-descriptors.py` tests `name.strip()` only for empty, then looks up `name.lower()` untrimmed, so `' board'` passes. `found-board.sh` line 13 still lists "empty or control-character --name or --model".
- **Decided**: a padded name is refused, never trimmed, to match `stamp_args_ok`. It exits 64, the code this script already uses for a reserved name.
- **Decided**: the header drops the shared causes and adds no pointer, since the comment at `stamp_args_ok` is the one place they are listed.
- **Size**: two files under `skills/` and one smoke case. A patch-level change.
- **Next**: this waits in Proposed for the owner's review.
