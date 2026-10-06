---
name: merge
description: "Resolves git conflicts on Lanework boards (`*.lanework` folders) with no human: a git merge driver plus a placement pass. Content from both sides is kept, state goes to the later `modified` stamp, and whatever lost lands in a merge comment on the card. Use when a merge, pull, rebase or cherry-pick leaves conflicts under a `.lanework` path, or on 'merge the board', 'resolve the board conflicts', 'install the board merge driver'. Never commits."
---

# Merge

Two people editing one board through git collide often; nearly every collision has a mechanical answer. **When in doubt, keep both edits and move on. Never stop for a human.**

**Base**: `lanework`. Read `lanework/references/authority.md` first: the board's guide wins over these rules.

## Flow

1. **Driver missing** (`git config --get merge.lanework.driver` empty) → `python3 scripts/lanework-merge.py install <repo>`. Adds the `.gitattributes` rule: tell the user to commit it.
2. **Pass**: `scripts/merge-board.sh <repo> --model <your model>`. Resolves every unmerged board path, writes merge comments, stages what it resolved, re-homes files a move left behind, validates each board. Run it also after a pull git finished on its own: that's when a comment posted on a card the other side moved is left behind.
3. **Report**: relay its paragraph. Exit ≠ 0 → a board path is still unmerged or a board fails validation: say which.
4. **Stop.** The merge commit, `git rebase --continue`, or committing a re-home is the user's. Conflicts outside boards are theirs too.

Never hand-edit conflict markers on a board, and never ask the human to pick a side.

## Topics

| topic | file |
|---|---|
| principle, content and placement rules, the merge comment, how it runs, limits | `references/rules.md` |

## Scripts

| script | does |
|---|---|
| `scripts/lanework-merge.py install <repo>` | `.gitattributes` rule + this clone's driver, copied into its git dir |
| `scripts/lanework-merge.py driver …` | git's merge driver: never run by hand |
| `scripts/merge-board.sh <repo> [--model M]` | the placement pass, then a one-paragraph report |
