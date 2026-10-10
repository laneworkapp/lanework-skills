---
schema: 1
kind: comment
in-reply-to: 3d05d12d-27af-4dc5-8cfa-32942bad51ce
created:  {at: 2026-10-10T01:38:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T01:38:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Filed on the Lanework Pipeline board as [4392544b](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/4392544b-bf94-40bf-b4cf-6a346af84b22). The schema and guide are the app's, so the removal is an app change.**

- **Decided**: the skills keep following guide v82, which still documents `default-labels`, until the app ships the removal.
- **Then, skills side**: `heal-board.py --global` and its line in `lanework/references/writes.md` go. Added to this card's body.
- **Flagged on the app card**: the kind picker on the app's Active "group by any label kind" card reads the union with `default-labels`.
