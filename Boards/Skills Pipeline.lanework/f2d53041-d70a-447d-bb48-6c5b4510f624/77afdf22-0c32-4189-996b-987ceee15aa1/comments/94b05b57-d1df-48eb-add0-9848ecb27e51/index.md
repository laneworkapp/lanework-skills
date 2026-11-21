---
schema: 1
kind: comment
created:  {at: 2026-11-21T18:57:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T18:57:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Eight of the scripts named in the body changed after their items were read, so those items need a fresh check first.**

- **Read at**: `02658be`. The checkout moved on during the day when other branches merged.
- **Changed since**: `discovery/scripts/settle-question.sh`, `lanework/scripts/lease.sh`, `lanework/scripts/lib.sh`, and in `work/scripts/`: `commit-board.sh`, `file-card.sh`, `lint-leases.sh`, `lint-stamps.sh`, `lint-waiting-clears.sh`.
- **Likely stale**: the `commit-board.sh` exit list, the `lint-waiting-clears.sh` garbled header line, the `lease.sh` exit lists, and the `file-card.sh` omissions.
- **New and unread for this card**: `work/scripts/label-card.sh`.
- **Check**: `git diff 02658be HEAD -- <script>` per script, then the header against the current code.
