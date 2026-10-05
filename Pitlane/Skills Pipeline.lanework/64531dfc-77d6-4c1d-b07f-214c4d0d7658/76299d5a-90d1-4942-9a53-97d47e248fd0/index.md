---
schema: 1
kind: card
title: "lanework: a healing script that repairs what agents and hand edits break on a board"
order: 3072
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-05T22:44:24Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
modified: {at: 2026-10-05T23:00:04Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
---
Add a script to the `lanework` skill that finds and repairs the known kinds of board damage, as a dry run by default and with `--apply` to write. Today an agent can only detect damage with the board's validator, and repairs it by hand, one card at a time.

- **Heals, first cut**: label stamps that disagree with the current definitions (rank, colour, icon, text casing), several entries of a single kind, bare-scalar stamps and string kinds, and the root `priority:` / `component:` keys once [the retirement card](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/3de46337-1b60-4450-be64-af6224b4cb4a) lands. Also missing `by` on stamps, and a title that is not double-quoted.
- **Rules it keeps**: the same as the app's heal. It touches only what it recognises, never a foreign entry, restamps `modified` as itself, and stages outside the board then `mv`s in.
- **Touches**: `skills/lanework/scripts/` (new), `skills/lanework/SKILL.md` and `references/writes.md` (when to run it), `tests/smoke.sh`.
- **Verify**: against a throwaway board seeded with one of each kind of damage. The dry run lists every one, `--apply` fixes them, and the validator then exits 0 with no `DEPRECATED` line.
- **Open**: ship it in the skill, or have the app emit it into each board's `.schema/bin/` beside the validator, so it always matches the board's schema version? Python like the validator, or shell like the other scripts?
- **Done when**: one command heals a damaged board to a clean validator run, and the skill tells agents when to run it.
