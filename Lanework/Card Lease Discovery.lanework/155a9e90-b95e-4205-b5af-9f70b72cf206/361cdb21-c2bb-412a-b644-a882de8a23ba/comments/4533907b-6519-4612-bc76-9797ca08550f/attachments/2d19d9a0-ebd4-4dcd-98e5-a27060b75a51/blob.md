# skills/plan/scripts/claim-ticket.sh, lines 1-7 and the landing

```sh
#!/bin/bash
# claim-ticket.sh: claim a Frontier ticket for this session, before any work on it.
# usage: claim-ticket.sh <board> <card-uuid> --model m [--name n] [--session s]
# Moves the card from Frontier to the bottom of Working (fresh order, `modified` rewritten whole)
# and posts "**Claimed** by <name>". Refuses with exit 1 when the card is not in Frontier
# (claimed by another session, blocked, resolved). Staged outside the board; the card path is
# re-resolved just before landing, and a card that left Frontier meanwhile is refused.
...
37:refuse_unless_frontier
50:refuse_unless_frontier
51:mv "$STAGE/index.md" "$FRONTIER/$CID/index.md"
52:mv "$FRONTIER/$CID" "$DEST/$CID"
```
