# App-written fixtures

Bytes the Lanework app wrote, copied unchanged from this repo's own history of the Skills Pipeline board (`Boards/Skills Pipeline.lanework/`, `Lanework/Skills Pipeline.lanework/` before 2026-11-16). `tests/merge-case.sh <dir> appside` uses them as side B of a two-clone collision: each `*.before.md` is the base, each `*.after.md` is what the app left, and scripted edits to the same items are side A. What marks them as the app's: `modified: {at: …}` with no `by`, keys in the app's order (`kind` after `modified`, or `created` before `kind`), and a human `created` stamp with a quoted name.

Paths below are under the board folder of that commit. `git show <sha>:"<board>/<path>"` gives the bytes. Ids are commits on `main`.

| file | what the app did | before | after |
|---|---|---|---|
| `lane-rewrite.*.md` | rewrote the Shaping lane file with no `by`, adding `width: 3` | `aef92c7d`, `64531dfc-77d6-4c1d-b07f-214c4d0d7658/index.md` | `15435304`, `64531dfc-77d6-4c1d-b07f-214c4d0d7658/index.md` |
| `card-move.*.md` | the owner moved a card from Issues to Shaping under guide v120: new `order`, unstamped `modified` | `2df78e44`, `11a646f0-…/28c22261-3d84-4e72-8620-8cc2eb3c7cc2/index.md` | `d7b4f7ac`, `64531dfc-…/28c22261-3d84-4e72-8620-8cc2eb3c7cc2/index.md` |
| `card-title-edit.*.md` | retitled a card and moved it from Issues to Approved. The same commit also carries an agent's rewrite of its body, so the app's bytes and the body are one file | `3e233b24`, `11a646f0-…/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03/index.md` | `72b87dcc`, `f2d53041-…/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03/index.md` |
| `comment-posted.md` | posted an option-button answer: quoted `{name: "Rouslan Z", kind: "human"}` stamp, unstamped `modified`, `in-reply-to`, no final newline | none (new file) | `d1300afc`, `301eb20d-…/f322abdb-5f60-40c0-80df-da30b2a03b33/comments/2bbea8c7-8147-4bcc-aa8a-ce8dd41e9598/index.md` |

The `before` column is the parent of the `after` commit; each `before` file is its content at that commit, so `before` and `after` are one app write apart.

Not here: the app clearing `waiting`. Every `waiting` removal in the history was an agent's write.

Last re-copy, at guide v120: only `card-move.*` is new. The history holds no lane rewrite, retitle or posted answer by the app after the guide moved to v120 (2026-11-22T11:53Z), so the other three keep their bytes, re-pointed at the same commits on the rewritten `main`.

Re-copy at each guide-version bump (the repo `CLAUDE.md` names the step): find fresh app writes with `git log -p -- "Boards/Skills Pipeline.lanework"` and look for `modified: {at: …}` with no `by`, then replace these files and the ids at the top of the `appside` case in `tests/merge-case.sh`.
