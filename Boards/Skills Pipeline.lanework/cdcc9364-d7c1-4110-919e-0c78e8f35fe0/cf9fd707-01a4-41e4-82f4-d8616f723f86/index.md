---
schema: 1
kind: card
title: "Guide moved to v122: read the skills against it and bump the stamp"
order: 1024
created:  {at: 2026-11-24T00:21:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-24T00:21:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The app rewrote this board's guide at `lanework-agent-guide v122` on 2026-11-23. The skills are stamped v120 in the repo's `CLAUDE.md`, so smoke and `scripts/release.sh` now print the drift note.

## What moved

Two app commits since v120, by their messages:

- `d2ed9169b` (2026-11-22): the schema count is corrected to eight files, and the guide now teaches comment `reactions` and the `move-receipts` config key.
- `5bb87c36d` (2026-11-23): the guide writes the config path from `~`, not the home folder.

Which commit is v121 and which is v122 is not checked yet.

## Likely to touch the skills

- **Move receipts.** With `move-receipts: true` the app posts a quiet comment signed `board` on each lane move. `watch` classifies new comments, and the lints read stamps: check that a receipt is not read as an owner comment or as a bad stamp.
- **Reactions.** A new `reactions` list on comments. Check that the comment writers and the merge driver keep it.
- **Home path.** The six app-written guides on disk in this repo were held out of commits because they carried the absolute home path. Check whether the v122 files are clean, which would lift that hold.

## Done when

- Every skill is read against v122 and the drift is fixed.
- The app-written files in `tests/fixtures/app-writes/` are re-copied, as its README says.
- The stamp in the repo's `CLAUDE.md` reads v122 and smoke prints no drift note.
