---
schema: 1
kind: comment
created:  {at: 2026-11-27T12:51:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:51:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: the first 50 leased cards ran clean, so the staking ruling stands.**

- **Command**, from `~/Indie/Projects/Lanework`, over every board folder with an `index.md` in the Lanework repos (68 boards, test fixtures and worktrees left out): `lanework-skills/skills/work/scripts/lint-leases.sh <68 boards> --since 2026-11-21T13:14:33Z --first 50`
- **Output**: `leased cards: 50, lease lost: 0, two STARTs: 0, lapsed: 0`, exit 0, nothing on stdout.
- **`--since`**: `2026-11-21T13:14:33Z`, when sessions began staking leases (v0.9.0).
- **By board**: Skills Pipeline 22 (the three boards of this repo alone: 22), Lanework Pipeline 12, the rest across the other repos.
- **Past the 50**: 87 leased cards in all by 2026-11-27, with the same three zeros.
- **Limit, as the body says**: the lint counts START records, so a card built with no lease still counts. Eight such cards on Lanework Pipeline are the subject of [Starting a card stakes its lease in one step](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b9a35b00-3855-47b2-b24d-b19e72c31d2d), now in Approved.
- **The lint and its smoke cases** shipped earlier, in v0.9.0. This card changes no file, so it adds no changelog entry.
