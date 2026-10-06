---
schema: 1
kind: card
title: "lanework: a healing script that repairs what agents and hand edits break on a board"
order: 2048
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-05T22:44:24Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
modified: {at: 2026-10-06T22:36:07Z}
---
Add a heal script to the `lanework` skill that finds and repairs the known kinds of board damage, as a dry run by default and with `--apply` to write. Today an agent can only detect damage with the board's validator, and repairs it by hand, one card at a time.

- **Heals, first cut**: label stamps that disagree with the current definitions (rank, colour, icon, text casing), several entries of a single kind, bare-scalar stamps and string kinds, root `priority:` / `component:` keys (reserved since guide v82), and free labels with no `kind` or the retired `default` kind. Also missing `by` on stamps, and a title that is not double-quoted.
- **Rules it keeps**: the same as the app's heal. It touches only what it recognises, never a foreign entry, restamps `modified` as the agent running it (never `healer`), and stages outside the board then `mv`s in.
- ~~**Open**: ship it in the skill, or have the app emit it into each board's `.schema/bin/` beside the validator?~~ **ruled 2026-10-06: both. The board's copy wins. The skill's copy serves boards worked without the app.** The app's half is [9340580b](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/9340580b-ccef-4fc4-b439-cc618cd63023), and this card doesn't wait on it.
- **Which copy runs**: the board's `.schema/bin/lanework-heal.py` when it exists, else the skill's `scripts/heal-board.py`.
- **Language**: Python, standard library only, like the validator, so the app can ship the same file.
- **Touches**: `skills/lanework/scripts/heal-board.py` (new), `skills/lanework/SKILL.md` and `references/writes.md` (when to run it, which copy wins), `tests/smoke.sh`.
- **Verify**: against a throwaway board seeded with one of each kind of damage. The dry run lists every one and writes nothing. `--apply` fixes them, and the validator then exits 0 with no `DEPRECATED` line. A second `--apply` changes nothing. A board with no `.schema/` heals too.
- **Done when**: one command heals a damaged board to a clean validator run, with or without the app, and the skill says when to run it and which copy wins.
