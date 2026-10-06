---
schema: 1
kind: comment
created:  {at: 2026-10-05T22:44:24Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
modified: {at: 2026-10-05T22:44:24Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
---
**Filed at the owner's request, from the Lanework Labels session: "i wonder if we should include a healing script to lanework skill."**

**Context**: the app heals label stamps on touch, and `lanework-migrate-labels` in the app repo repairs in bulk, but neither reaches an agent working a board from the files. Retiring the priority and component root keys ([the retirement card](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/3de46337-1b60-4450-be64-af6224b4cb4a)) adds a migration every board will need, and it also makes the skill's current "root keys, never labels entries" rule (commit 1f59449) wrong once it lands.
