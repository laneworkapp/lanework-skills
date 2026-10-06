---
schema: 1
kind: card
title: "merge: a skill that resolves git merge conflicts on a board without a human"
order: 4096
labels: [{text: merge, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-06T22:44:23Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T23:56:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
waiting: {for: rzen, since: 2026-10-06T23:56:41Z, comment: c63cf5fc-43c3-42f5-b8f2-d599a6d0dc9b}
---
Two people editing one board through git collide often: both restamp `modified`, both move the same card, both touch a body. Nearly every such conflict has a mechanical answer, so a new skill, `merge`, resolves them and lets the merge, pull or rebase finish. Its standing rule: when in doubt, keep both edits and move on. ~~It never stops for a human.~~ **ruled 2026-10-06: the driver stops the git merge whenever it would otherwise lose text, and `merge-board.sh` places it. Merges that lose nothing still finish on their own.**

## Principle

Content merges, state picks a winner. Content (bodies, comments, labels, attachments) is kept from both sides, in place or in a merge comment. State (lane, `order`, `priority`, `waiting`, trash) goes to the side with the later `modified` stamp. Equal stamps → ours. No conflict marker ever survives, and the board validates after every merge.

Every rule is 3-way against the merge base: a key changed on one side only takes that side, as git would. The rules below apply only when both sides changed the same thing.

## Content rules (one file, both sides changed it)

| what | result |
|---|---|
| `modified` | the later stamp, `at` and `by` together |
| `title` | later wins; the other title in the merge comment |
| `labels`, board `config.labels` values | union, by `text` within a kind |
| `order`, `priority`, `waiting`, `hero`, `collapsed` | later `modified` side wins |
| body | ~~A: later edit wins, the earlier body kept whole in the merge comment. B: both bodies inline. C: hunk merge, nothing preserved.~~ **ruled 2026-10-06: A.** The earlier body goes whole into the merge comment, in a fenced block |
| a lane's or the board's body | **ruled 2026-10-06: A.** Non-overlapping edits merge cleanly. Overlapping ones keep both versions inline, the earlier under a merged-from heading |
| a comment's `index.md` | later `modified` wins; the other body in a merge comment on the card |
| an attachment blob | ours; theirs copied beside it as `blob.theirs.<ext>`, named in the merge comment |
| `CLAUDE.md`, `AGENTS.md`, `.schema/*`, `.gitignore` | the higher version line wins, whole file |
| `.log/*` | union of lines, sorted by stamp; these should never be committed |

## Placement rules (tree level, after git stops)

| what | result |
|---|---|
| moved to different lanes on both sides | later `modified` decides lane and `order` |
| moved on one side, edited on the other | the merged content at the new path |
| trashed on one side, edited on the other | later `modified` wins: a later trash stays trashed carrying the edit; a later edit restores the card to the lane it held at the merge base |
| trashed on both | trashed once |
| same uuid added on both sides | ours; theirs' body in the merge comment. Not expected with random uuids |
| any unmerged path left over | ours, and the merge comment says so. The merge always finishes |

## The merge comment

One record per card that lost anything, stamped `by: {name: claude, kind: agent, model: <model>, session: "merge"}`, or `name: merge` when the driver runs with no agent. Line 1: **Merged two edits to this card.** Then one line per loss and where it is kept, and the losing body or comment in a `markdown` fence. No comment when nothing was lost. Comments and the losing-side attachments are staged with the resolved card.

## Mechanism

- `scripts/lanework-merge.py`: python3, stdlib only (the validator already requires python3). Subcommands: `driver <base> <ours> <theirs> <path>` for git; `resolve <repo>` for the placement pass; `install <repo>`.
- **Driver**: `install` writes `merge=lanework` for `**/*.lanework/**` into the repo's `.gitattributes` (committed, so the rule travels) and the driver command into that clone's `.git/config` (per clone; a clone without it falls back to git's default merge, which is only ever a conflict marker, never a wrong result). Runs on every pull, merge and rebase with no agent present.
- **Pass**: `resolve` walks `git status --porcelain` for unmerged paths under any `.lanework`, applies the placement rules using the base from `git merge-base` or `REBASE_HEAD`, writes merge comments, runs the board's own validator, and `git add`s only the paths it resolved. It never commits: the merge commit is the user's.
- `scripts/merge-board.sh <repo>`: the bash entry the skill calls, which runs `resolve`, then prints a one-paragraph report of what was merged and what the merge comments hold.

## Invocation

Model-invoked. Triggers when a merge, pull or rebase leaves conflicts under a `.lanework` path, or on "merge the board", "resolve the board conflicts", "install the board merge driver". Short and deterministic, so no slash command gate. The skill's own flow: install if the driver is missing, run the pass, report, stop. Committing is the user's.

## Touches

New `skills/merge/`: `SKILL.md`, `references/rules.md` (the two tables above, as the single source), `scripts/lanework-merge.py`, `scripts/merge-board.sh`. `.claude-plugin/plugin.json` `skills` list. `README.md` table, sizes and install lines. `lanework/references/writes.md` § Git: one line pointing at `merge`. This board's `Skill` label value `merge` in the instruction sheet.

## Verify

A new smoke case founds a scratch board in a scratch repo, clones it twice, and on each clone makes one instance of every row in both tables, committing on each side. Then `git merge` with the driver installed, then `merge-board.sh`. Asserts: exit 0 with no prompt; `grep -r '<<<<<<<'` finds nothing; the validator passes with no DEPRECATED line; every body and comment written on either side exists somewhere on the board; each moved card sits in its later-stamped lane; the restored card is back in its base lane; one merge comment per card that lost something and none elsewhere. The same case run as a rebase.

## Done when

The smoke case passes for every row, as a merge and as a rebase. A real two-clone collision on a scratch board, made by hand in the app on one side and by a script on the other, resolves with no prompt.

## Accepted limitations

A side that never restamped `modified` loses state ties to the side that did. A clone without the driver installed sees plain git conflict markers until an agent runs the pass. Three-way merging on a squash or a shallow clone falls back to ours-wins with a merge comment, because there is no base.
