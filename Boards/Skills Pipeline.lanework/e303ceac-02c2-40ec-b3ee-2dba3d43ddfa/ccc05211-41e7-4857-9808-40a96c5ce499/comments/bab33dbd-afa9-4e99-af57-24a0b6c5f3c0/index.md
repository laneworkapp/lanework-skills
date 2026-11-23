---
schema: 1
kind: comment
created:  {at: 2026-11-23T04:03:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T04:03:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: the next card is picked by priority, then lane order.**

- **Rule:** `lanework/references/reading.md` § Pick order, linked from the lead, sweep, board-kinds, arming and responding files. Agents never assign or change a priority.
- **Scripts:** `read-board.sh` ends a card's line with `priority: <text> (<rank>)`; `arm-pass.sh` arms the first Approved card by (rank, order), ranked before unranked.
- **Lane body:** the pipeline template's Approved body says "highest priority first, then in lane order". `heal-descriptors.py` brings an unedited old body to it and leaves an owner-edited body alone, including one that keeps the old sentence.
- **Guard change:** the smoke guard against `priority:` as a card key now allows the printed suffix form only.
- **Evidence:** two review passes, approved; full smoke on the combined tree: 408 passed.
- **CHANGELOG:** Agents now pick the highest-priority card first when choosing what to work on next, then go by lane order.
