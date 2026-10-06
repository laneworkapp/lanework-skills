# Merge rules

The single source for what `scripts/lanework-merge.py` does.

## Principle

**Content merges, state picks a winner.**

- Content = bodies, comments, labels, attachments: kept from both sides, in place or in a merge comment.
- State = lane, `order`, a card's priority label, `waiting`, trash: the side with the later `modified.at`. Equal stamps → ours.
- No conflict marker survives. The board validates after every merge.
- **Stop on loss**: a merge that loses nothing finishes with no stop. One that would lose text stops, so the pass keeps it on the board.

Every rule is 3-way against the merge base: a key changed on one side only → that side, as git would. The tables apply only when both sides changed the same thing.

## Content (one file, both sides changed it)

| what | result |
|---|---|
| `modified` | the later stamp, `at` and `by` together |
| `title` | later wins; the other title in the merge comment (an attachment's: named by its id) |
| `labels`, board `config.labels` values | union, by `text` within a kind. A removal on one side holds |
| single-valued label kinds: priority, component, any kind the board marks `single` | state: the later side's entries of that kind, whole |
| `order`, `waiting`, `hero`, `collapsed`, any other key | later `modified` side wins |
| `created`, `schema`, `kind`, `id`, tracker keys | ours |
| card body | later wins; the earlier body whole in the merge comment, in a `markdown` fence |
| a comment's `index.md` | later `modified` wins; the other body in a merge comment on the card |
| lane or board body | no thread to hold a loser: git's clean 3-way merge (`git merge-file`). Overlapping edits → both inline: the later body, then the earlier under `## Merged from the earlier edit (<stamp>)`. Nothing is lost, so no stop |
| an attachment blob | ours; theirs copied beside it as `blob.theirs.<ext>`, named in the merge comment. `thumb.*` → ours |
| any other board file | ours; theirs beside it as `<name>.theirs.<ext>`, named in the report |
| `CLAUDE.md`, `AGENTS.md`, `.schema/*`, `.gitignore` | the higher version line wins, whole file. No version line (the schema JSON) → ours |
| `.log/*` | union of lines, sorted by stamp. These should never be committed |

## Placement (tree level, after git stops)

The pass matches cards by uuid across base, ours and theirs, not by git's rename guess.

| what | result |
|---|---|
| moved to different lanes on both sides | later `modified` decides lane and `order` |
| moved on one side, edited on the other | the merged content at the new path |
| moved on one side, a comment or attachment added on the other | git leaves the new file behind, in a folder with no `index.md`, and finishes. The pass moves it into the card, staged, even after the merge |
| trashed on one side, edited on the other | later `modified` wins: a later trash stays trashed carrying the edit; a later edit restores the card to the lane it held at the base (or the editing side's lane) |
| trashed on both | trashed once |
| same uuid added on both sides | ours; theirs' body in the merge comment |
| deleted for good (`rm`) on one side, edited on the other | the edit kept; the merge comment says the other side deleted it |
| git paired two different cards by similarity (a delete plus an add) | refused: `created` differs. The pass rebuilds both cards by uuid |
| card's lane gone on the winning side | the lane's trashed copy, else ours' location |
| uncommitted local edits in a card the pass rebuilds | carried as ours, 3-way against theirs, staged, named in the report. Never erased |
| any other unmerged board path | ours, named in the report. The merge always finishes |

## The merge comment

- One record per card that lost anything; none when nothing was lost.
- Stamp: `by: {name: claude, kind: agent, model: <model>, session: "merge"}` with `--model` (or `LANEWORK_MERGE_MODEL`), else `name: merge`.
- Line 1: **Merged two edits to this card.** Then a list, one line per loss and where it is kept. Then each losing body or comment in a `markdown` fence.
- Written by the pass at the card's final path, staged with the resolved card and its `blob.theirs.*` files.

## How it runs

- **Driver** (`merge=lanework` on `**/*.lanework/**`): every pull, merge, rebase and cherry-pick, no agent present. Writes only the merged file git hands it, never anything else.
  - Nothing lost → exit 0, git carries on.
  - A loss, or a trash against a possibly later edit → the merged file with no markers, exit 1: git stops, and the pass keeps the losing side. Git may move the card or finish the operation without the pass, so nothing is ever written in place.
  - Any error → ours, exit 1. Never a half merge.
- **Pass** (`merge-board.sh`): reads base/ours/theirs from `MERGE_HEAD` (base = `git merge-base`), or `REBASE_HEAD` / `CHERRY_PICK_HEAD` (base = its parent). Rebuilds each card with an unmerged path from the three trees, applies both tables, writes one merge comment per card, re-homes files a move left behind, `git add`s only what it touched, runs each board's `.schema/bin/lanework-validate.py`. Never commits. With no operation in progress it only re-homes.
- **Install**: the rule goes in the repo's `.gitattributes` (committed: it travels). The driver is registered per clone in `.git/config` as `python3` from `PATH` running a copy in the git dir (`$(git rev-parse --git-common-dir)/lanework-merge/`), so an interpreter upgrade, a moved repo or an updated skill can't break it. The pass refreshes that copy. A clone without it sees plain git markers until the pass runs; the pass resolves those too.

## Limits

- A side that never restamped `modified` loses state ties to the side that did.
- A clone with no `python3` on `PATH`: the driver can't run, git keeps ours with no markers and stops; the pass resolves it.
- No merge base (squash, shallow clone) → ours wins every both-changed file, the other side in a merge comment.
- In a rebase, ours is the upstream: ties and the ours-rows go to it.
- Criss-cross merges: each clone that merges posts its own merge comment, so one loss can appear twice.
