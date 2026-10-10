---
schema: 1
kind: card
title: "Map"
order: 1024
icon: {glyph: flag.checkered}
---
A spec for two-way tracker sync, ready to hand to the pipeline board as work cards.

## Notes

- Swift app, iCloud documents. Read `CONTEXT.md` before naming anything.

## Decisions so far

- [T1: Where the engine runs](lanework://<board>/<card>): in the app, no server
- [T3: Rate limits per tracker](lanework://<board>/<card>): 5000/h GitHub, 60/min Jira

## Not yet specified

- Conflict handling once both sides edit a title. Waits on the field mapping.

## Out of scope

- Jira Server: cloud trackers only for this plan. [T4: Jira Server auth](lanework://<board>/<card>)
