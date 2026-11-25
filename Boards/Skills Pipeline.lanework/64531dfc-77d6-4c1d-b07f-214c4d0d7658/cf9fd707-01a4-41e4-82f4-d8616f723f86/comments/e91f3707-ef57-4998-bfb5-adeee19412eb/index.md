---
schema: 1
kind: comment
in-reply-to: 28f16af6-62d7-4500-a47e-598149646272
created:  {at: 2026-11-25T12:38:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-25T12:38:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**There is one real use, and the board already covers it another way.**

- **The use**: a quiet "seen". An agent could put an eyes emoji on your comment the moment it reads it, so you know it was picked up before the written reply arrives. On a long build that reply can be half an hour away.
- **What covers it today**: the lease. A card an agent is working shows as claimed within seconds, and a comment that needs no work gets its written reply in about a minute.
- **A second, smaller use**: marking a comment as agreed with, without adding a comment to the thread. A record does that better, because it says what was agreed.
- **What it costs**: a `react` script and its tests, a rule for when to react and when to take it back, and one more file change per comment for every watching session to read and skip.
- **What nothing depends on**: no skill, lint or script would read an agent's reaction. It would be a signal for your eyes only.
- **My read**: not worth it now. If waiting for the first reply ever feels like silence, B can be added then as its own card, and A does not close that door.
