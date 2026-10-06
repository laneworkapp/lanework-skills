---
schema: 1
kind: card
title: "Boards folder: Lanework, then Boards, then legacy Pitlane"
order: 7168
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: pitwall, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-06T22:38:56Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T22:38:56Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
---
Boards live in a `Pitlane/` folder, the one place the racing word stays in daily view after [the skill rename](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb3ae7da-6827-4ae1-b8f5-553c5b794871). The folder itself earns its place: one known location so agents never scan, several boards per repo grouped, and names with spaces kept out of the repo root. Only its name changes.

- **Folder names, in order of preference**: ~~which name, and whether a folder is needed at all~~ **ruled 2026-10-06: keep a folder. Three accepted names, `Lanework/` preferred, `Boards/` second, `Pitlane/` legacy.** The same three apply at `~/` for machine-level boards.
- **Finding**: `lanework/references/finding.md` lists the three in that order, with the glob checking each. A project carrying more than one of them is a project with several boards, not an error. A new board goes in the first folder that exists, else `Lanework/`.
- **Offer to rename**: an agent that finds boards only under `Pitlane/` offers once, in chat, to `git mv` it to `Lanework/`. The owner's no stands for the session. The offer never fires on `Boards/`.
- **Touches**: `lanework/references/finding.md` and `founding.md`, `pitwall/references/arming.md` (name and no-argument lookups), `pitlane/SKILL.md` and `references/sweep.md` where they name the folder, `README.md` (the folder convention paragraph), `CLAUDE.md`, `tests/smoke.sh` (its path to this board's schema).
- **This repo**: `git mv Pitlane Lanework`, in its own commit, after the skills read both.
- **Out of scope**: the skill names, on [the rename card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb3ae7da-6827-4ae1-b8f5-553c5b794871). Whether the app has an opinion on the folder: it opens any `.lanework` folder, so none expected.
- **Verify**: `tests/smoke.sh` passes after this repo's own move. A scratch repo with a board under `Pitlane/` only: `/watch` with no argument finds it and the offer fires. Under `Boards/` only: found, no offer. `grep -rn Pitlane skills` hits only the legacy entry in `finding.md`.
- **Done when**: the above holds and this repo's board lives under `Lanework/`.
