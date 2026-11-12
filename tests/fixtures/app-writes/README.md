# App-written fixtures

Bytes the Lanework app wrote, copied unchanged from this repo's own history of `Lanework/Skills Pipeline.lanework/`. `tests/merge-case.sh <dir> appside` uses them as side B of a two-clone collision: each `*.before.md` is the base, each `*.after.md` is what the app left, and scripted edits to the same items are side A. What marks them as the app's: `modified: {at: …}` with no `by`, keys in the app's order (`kind` after `modified`, or `created` before `kind`), and a human `created` stamp with a quoted name.

Paths below are under `Lanework/Skills Pipeline.lanework/`. `git show <sha>:"<path>"` gives the bytes.

| file | what the app did | before | after |
|---|---|---|---|
| `lane-rewrite.*.md` | rewrote the Shaping lane file with no `by`, adding `width: 3` | `d14e3d6`, `64531dfc-77d6-4c1d-b07f-214c4d0d7658/index.md` | `dc404fe`, `64531dfc-77d6-4c1d-b07f-214c4d0d7658/index.md` |
| `card-move.*.md` | the owner moved a card from Ideas to Shaping: new `order`, unstamped `modified` | `8e7fd1e`, `cdcc9364-…/f322abdb-5f60-40c0-80df-da30b2a03b33/index.md` | `99ac340`, `64531dfc-…/f322abdb-5f60-40c0-80df-da30b2a03b33/index.md` |
| `card-title-edit.*.md` | retitled a card and moved it from Issues to Approved. The same commit also carries an agent's rewrite of its body, so the app's bytes and the body are one file | `ffea864`, `11a646f0-…/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03/index.md` | `704f284`, `f2d53041-…/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03/index.md` |
| `comment-posted.md` | posted an option-button answer: quoted `{name: "Rouslan Z", kind: "human"}` stamp, unstamped `modified`, `in-reply-to`, no final newline | none (new file) | `281c22a`, `301eb20d-…/f322abdb-5f60-40c0-80df-da30b2a03b33/comments/2bbea8c7-8147-4bcc-aa8a-ce8dd41e9598/index.md` |

The `before` column is the parent of the `after` commit; each `before` file is its content at that commit, so `before` and `after` are one app write apart.

Not here: the app clearing `waiting`. Every `waiting` removal in the history was an agent's write.

Re-copy at each guide-version bump (the repo `CLAUDE.md` names the step): find fresh app writes with `git log -p -- "Lanework/Skills Pipeline.lanework"` and look for `modified: {at: …}` with no `by`, then replace these files and the ids at the top of the `appside` case in `tests/merge-case.sh`.
