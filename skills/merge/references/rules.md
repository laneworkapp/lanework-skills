# Merge rules

The single source for what `scripts/lanework-merge.py` does.

## Principle

**Content merges, state picks a winner.**

- Content = bodies, comments, labels, attachments: kept from both sides, in place or in a merge comment.
- State = lane, `order`, a card's priority label, `waiting`, trash: the side with the later `modified.at`. Equal stamps → ours.
- No conflict marker survives. The board validates after every merge.

Every rule is 3-way against the merge base: a key changed on one side only → that side, as git would. The tables apply only when both sides changed the same thing.

## Content (one file, both sides changed it)

| what | result |
|---|---|
| `modified` | the later stamp, `at` and `by` together |
| `title` | later wins; the other title in the merge comment |
| `labels`, board `config.labels` values | union, by `text` within a kind. A removal on one side holds |
| single-valued label kinds: priority, component, any kind the board marks `single` | state: the later side's entries of that kind, whole |
| `order`, `waiting`, `hero`, `collapsed`, any other key | later `modified` side wins |
| `created`, `schema`, `kind`, `id`, tracker keys | ours |
| card body | later wins; the earlier body whole in the merge comment, in a `markdown` fence |
| a comment's `index.md` | later `modified` wins; the other body in a merge comment on the card |
| an attachment blob | ours; theirs copied beside it as `blob.theirs.<ext>`, named in the merge comment. `thumb.*` → ours |
| `CLAUDE.md`, `AGENTS.md`, `.schema/*`, `.gitignore` | the higher version line wins, whole file. No version line (the schema JSON) → ours |
| `.log/*` | union of lines, sorted by stamp. These should never be committed |
| lane or board body | later wins; no thread to hold the earlier one, so it goes to `.git/lanework-merge/lost-<stamp>.md`, named in the report |

## Placement (tree level, after git stops)

The pass matches cards by uuid across base, ours and theirs, not by git's rename guess.

| what | result |
|---|---|
| moved to different lanes on both sides | later `modified` decides lane and `order` |
| moved on one side, edited on the other | the merged content at the new path |
| trashed on one side, edited on the other | later `modified` wins: a later trash stays trashed carrying the edit; a later edit restores the card to the lane it held at the base (or the editing side's lane) |
| trashed on both | trashed once |
| same uuid added on both sides | ours; theirs' body in the merge comment |
| deleted for good (`rm`) on one side, edited on the other | the edit kept; the merge comment says the other side deleted it |
| git paired two different cards by similarity (a delete plus an add) | refused: `created` differs. The pass rebuilds both cards by uuid |
| card's lane gone on the winning side | the lane's trashed copy, else ours' location |
| any other unmerged board path | ours, named in the report. The merge always finishes |

## The merge comment

- One record per card that lost anything; none when nothing was lost.
- Stamp: `by: {name: claude, kind: agent, model: <model>, session: "merge"}` with `--model` (or `LANEWORK_MERGE_MODEL`), else `name: merge`.
- Line 1: **Merged two edits to this card.** Then a list, one line per loss and where it is kept. Then each losing body or comment in a `markdown` fence.
- Staged with the resolved card, with the `blob.theirs.*` files.
- A second loss on the same card in the same operation extends that comment, never a second one.

## How it runs

- **Driver** (`merge=lanework` on `**/*.lanework/**`): every pull, merge, rebase and cherry-pick, no agent present. Writes the merged file. Exit 0 = clean.
  - Card folder already in our tree → the merge comment is written in place, untracked until the pass or the user stages it.
  - Card's path changes in this merge → git writes the tree only after every driver call, so the loss waits in `.git/lanework-merge/ledger.jsonl` and the driver prints `merge comment pending`. The next pass posts it.
  - Trash against a possibly later edit → merged file, no markers, exit 1: git stops so the pass can restore the card.
  - Any error → ours, exit 1. Never a half merge.
- **Pass** (`merge-board.sh`): reads base/ours/theirs from `MERGE_HEAD` (base = `git merge-base`), or `REBASE_HEAD` / `CHERRY_PICK_HEAD` (base = its parent). Rebuilds each card with an unmerged path from the three trees, applies both tables, writes one merge comment per card, `git add`s only what it resolved, runs each board's `.schema/bin/lanework-validate.py`. Never commits.
- **Install**: the rule goes in the repo's `.gitattributes` (committed: it travels). The driver is registered per clone in `.git/config`, pointing at a copy in `.git/lanework-merge/`, so a moved or updated skill folder can't break it. The pass refreshes that copy. A clone without it sees plain git markers until the pass runs; the pass resolves those too.

## Limits

- A side that never restamped `modified` loses state ties to the side that did.
- A merge git finishes on its own is never re-placed: only an unfinished merge reaches the pass. A trash against a later edit always stops it.
- No merge base (squash, shallow clone) → ours wins every both-changed file, the other side in a merge comment.
- In a rebase, ours is the upstream: ties and the ours-rows go to it.
