---
schema: 1
kind: card
title: "Guide moved to v119: bump the stamp; only the Ready-made skills paragraph changed"
order: 3072
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T21:00:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T21:00:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The app moved this board's agent guide from v118 to v119, and the skills are still stamped v118 in the repo's `CLAUDE.md`.

## What changed in the guide

Measured with `diff` between a v118 copy (the Card Lease Discovery board) and this board's v119 guide: two lines differ, the version line and the "Ready-made skills" paragraph.

- v118 named four skills (`lanework`, `pitlane`, `pitwall`, `discovery`) and the `lanework-skills` repo, with clone-and-link install steps.
- v119 points at the plugin in `lanework-marketplace` and its Get started section, and names no skills.

No rule about reading or writing a board changed.

## Change

- Repo `CLAUDE.md`: bump the stamp to v119.
- `tests/fixtures/app-writes/`: no re-copy needed, since no file shape changed. Confirm by reading its `README.md` sources against the board.
- Skills: nothing to fix for drift. Check that nothing under `skills/` or `README.md` still tells a user to clone and link, now that the guide sends them to the marketplace.

## Done when

`tests/smoke.sh` passes and prints no note about a newer guide version.

## Note

A guide-version move is a minor bump under the repo's release rule. It can ride the next release.
