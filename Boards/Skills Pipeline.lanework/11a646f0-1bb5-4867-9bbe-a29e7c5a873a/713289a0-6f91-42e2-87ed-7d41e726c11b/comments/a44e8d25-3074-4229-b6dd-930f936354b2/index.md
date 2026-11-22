---
schema: 1
kind: comment
created:  {at: 2026-11-22T00:14:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T00:14:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Two more notes, from the lint output review (`f8cc20c4`), 2026-11-22.**

- `lanework/scripts/lib.sh` `board_index_files`: the `>/dev/null` on the fallback `cd` has no smoke case. A case needs `CDPATH` set, a relative board path, a newline in a card name and a sibling-linked lane together. Without the redirect that board lists the card twice (reviewer's run).
- Same function: the fallback runs only when the line counts differ. A newline in one name plus a folder that vanishes before `realpath` reads it would cancel out. Reasoned, not reproduced. Sturdier: fall back whenever the path list holds a newline at all.
