---
schema: 1
kind: card
title: "Boards folder: Lanework, then Boards, then legacy Pitlane"
order: 3072
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-06T22:38:56Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T23:20:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Boards live in a `Pitlane/` folder, the one place the racing word stays in daily view after [the skill rename](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb3ae7da-6827-4ae1-b8f5-553c5b794871). The folder itself earns its place: one known location so agents never scan, several boards per repo grouped, and names with spaces kept out of the repo root. Only its name changes.

- **Folder names, in order of preference**: ~~which name, and whether a folder is needed at all~~ **ruled 2026-10-06: keep a folder. Three accepted names, `Lanework/` preferred, `Boards/` second, `Pitlane/` legacy.** The same three apply at `~/` for machine-level boards.
- **Finding**: `lanework/references/finding.md` lists the three in that order, with the glob checking each. A project carrying more than one of them is a project with several boards, not an error. A new board goes in the first folder that exists, else `Lanework/`.
- **Offer to rename**: an agent that finds boards only under `Pitlane/` offers once, in chat, to move it to `Lanework/`: `git mv` in a repo, plain `mv` for `~/Pitlane/`. The owner's no stands for the session. The offer never fires on `Boards/`. A watch armed on a moved board must be re-armed.
- **Touches**: `lanework/references/finding.md` and `founding.md`, `pitwall/references/arming.md` (name and no-argument lookups), `pitlane/SKILL.md` and `references/sweep.md` where they name the folder, `README.md` (the folder convention paragraph and the line naming this repo's board), `CLAUDE.md` (layout table, track-the-work line), `tests/smoke.sh` (its path to this board's schema), `scripts/release.sh` (its clean-tree check exempts `Pitlane/`. Left alone, every board write under `Lanework/` blocks a release).
- **This repo**: `git mv Pitlane Lanework`, in its own commit, after the skills read both.
- **Order**: after [the rename card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb3ae7da-6827-4ae1-b8f5-553c5b794871), whose paths this card edits, and after the campaign in Active merges. Open worktrees carry `Pitlane/` paths.
- **Risk**: the app has this board open by path when it moves. The app finds a moved board by its id ([relocation search](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/46b9241f-89e7-4506-b606-f1aec9ab6c6b), shipped), so no prompt is expected.
- **Out of scope**: the skill names, on [the rename card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb3ae7da-6827-4ae1-b8f5-553c5b794871). Whether the app has an opinion on the folder: it opens any `.lanework` folder, so none expected.
- **Verify**: `tests/smoke.sh` passes after this repo's own move. A scratch repo with a board under `Pitlane/` only: `/watch` with no argument finds it and the offer fires. Under `Boards/` only: found, no offer. `grep -rn Pitlane skills` hits only the legacy entry in `finding.md`. `scripts/release.sh X.Y.Z --dry-run` passes with a board write pending under `Lanework/`. The app reopens this board from `Lanework/` without a prompt.
- **Done when**: the above holds and this repo's board lives under `Lanework/`.
- **Accepted limitation**: the owner's other repos and `~/Pitlane/` keep the legacy name until an agent working there makes the offer.
