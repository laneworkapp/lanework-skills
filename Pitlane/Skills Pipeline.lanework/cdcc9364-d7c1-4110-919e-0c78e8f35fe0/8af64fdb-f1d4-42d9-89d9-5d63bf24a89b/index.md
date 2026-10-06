---
schema: 1
kind: card
title: "merge: a skill that resolves git merge conflicts on a board without a human"
order: 8192
labels: [{text: merge, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
waiting: {for: rzen, since: 2026-10-06T22:44:25Z, comment: 4960b488-2a7a-4e02-a64d-a084501a5b48}
created:  {at: 2026-10-06T22:44:23Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T22:44:25Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
---
Two people editing one board through git collide often: both restamp `modified`, both move the same card, both touch a body. Nearly every such conflict has a mechanical answer, so a new skill, `merge`, resolves them and lets the merge, pull or rebase finish. Its standing rule: when in doubt, keep both edits and move on. It never stops for a human.

- **Principle**: content merges, state picks a winner. Content (bodies, comments, labels, attachments) is kept from both sides. State (lane, `order`, `priority`, `waiting`, trash) goes to the side with the later `modified` stamp, and the losing state is recorded in one merge comment on the card. No conflict marker ever survives.
- **Per-file rules** (3-way, against the merge base): `modified` → the later stamp, `at` and `by` together. `title` → later wins, the other kept in the merge comment. `labels` → union. `order` → later wins. Body → open call below. Lane and board `index.md` → same rules; `config.labels` values union. Comments → never conflict by construction (uuid folders); an edited comment takes the later stamp. App-maintained files (`CLAUDE.md`, `AGENTS.md`, `.schema/`, `.gitignore`) → the higher version line wins. `.log/` → never committed; if conflicted, union of lines.
- **Tree-level rules**: moved to different lanes on both sides → the later `modified` decides the lane. Moved on one side, edited on the other → the edit lands at the new path. Trashed on one side, edited later on the other → the edit wins and the card stays in its lane. Trashed on both → trashed. Same uuid added on both sides → not expected; keep ours, record theirs' body in the merge comment.
- **Body on both sides** (open call): ~~A: later edit wins, the earlier body preserved whole in the merge comment. B: both bodies kept inline, the earlier under a `merged from <side>` heading, for the owner to fold. C: git's own hunk merge, overlapping hunks resolved to the later side, nothing preserved.~~ Recommendation: A.
- **Mechanism**: two layers. A git merge driver for `index.md` files inside a `.lanework` folder, registered by `scripts/install-driver.sh` in a repo's `.git/config` and `.gitattributes`, so ordinary `git pull` resolves content conflicts with no agent present. Plus `scripts/merge-board.sh <board>`, the pass over `git status` that resolves tree-level conflicts after a merge stops, then validates and stages. The driver is python3, stdlib only, which the validator already requires; the wrapper is bash.
- **Invocation**: model-invoked. Triggers when a merge, pull or rebase leaves conflicts under a `.lanework` path, or on "merge the board", "resolve the board conflicts", "install the board merge driver". Short and deterministic, so no `/merge` gate is needed.
- **Writes**: the merge comment is a record, stamped `session: "merge"`, one per card touched, listing what lost and where it is kept. Resolved files are validated with the board's own validator before staging. Stage only the resolved paths. The commit is the user's merge commit; the skill never commits on its own.
- **Touches**: new `skills/merge/` (`SKILL.md`, `references/rules.md`, `scripts/`), `plugin.json` `skills` list, `README.md` table, sizes and install lines, this board's `Skill` label value `merge`. `lanework/references/writes.md` § Git gets one line pointing here.
- **Verify**: smoke case that founds a scratch board, clones it twice, makes each conflict class on each side, merges, and asserts zero conflict markers, a clean validator run, every body and comment from both sides present, and the later-stamped lane for each moved card.
- **Done when**: the smoke case passes for every row in the per-file and tree-level rules, and a real two-clone collision on a scratch board resolves with no prompt.
