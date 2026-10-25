# App-written fixtures

Bytes the Lanework app wrote, copied unchanged from this repo's own history of `Lanework/Skills Pipeline.lanework/`. `tests/merge-case.sh <dir> appside` uses them as side B of a two-clone collision: each `*.before.md` is the base, each `*.after.md` is what the app left, and scripted edits to the same items are side A. What marks them as the app's: `modified: {at: …}` with no `by`, keys in the app's order (`kind` after `modified`, or `created` before `kind`), and a human `created` stamp with a quoted name.

Paths below are under `Lanework/Skills Pipeline.lanework/`. `git show <sha>:"<path>"` gives the bytes.

| file | what the app did | before | after |
|---|---|---|---|
| `lane-rewrite.*.md` | rewrote the Shaping lane file with no `by`, adding `width: 2` | `3fcec39` | `6bbfd6e`, `64531dfc-77d6-4c1d-b07f-214c4d0d7658/index.md` |
| `card-move.*.md` | moved the Recap card from Proposed to Approved: new `order`, unstamped `modified` | `4e94081`, `301eb20d-…/5f372bd4-d140-46fa-9566-6ce1d628a728/index.md` | `f0bb998`, `f2d53041-…/5f372bd4-d140-46fa-9566-6ce1d628a728/index.md` |
| `card-title-edit.*.md` | retitled a card and moved it from Issues to Approved. The same commit also carries an agent's rewrite of its body, so the app's bytes and the body are one file | `ffea864`, `11a646f0-…/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03/index.md` | `704f284`, `f2d53041-…/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03/index.md` |
| `comment-posted.md` | posted a comment: quoted `{name: "Rouslan Z", kind: "human"}` stamp, unstamped `modified` | none (new file) | `df595e2`, `301eb20d-…/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b/comments/2a3f847f-a281-42f9-9a52-146f2339e784/index.md` |

Each `before` file is the version at the parent of the commit shown in its column, so `before` and `after` are one app write apart.

Not here: the app clearing `waiting`. Every `waiting` removal in the history was an agent's write.

Re-copy at each guide-version bump (the repo `CLAUDE.md` names the step): find fresh app writes with `git log -p -- "Lanework/Skills Pipeline.lanework"` and look for `modified: {at: …}` with no `by`, then replace these files and the ids at the top of the `appside` case in `tests/merge-case.sh`.
