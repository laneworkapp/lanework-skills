---
schema: 1
kind: card
title: "commit-board.sh drops the owner's staged version of a path when a push is rejected"
order: 10240
created:  {at: 2026-11-20T19:07:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T21:11:08Z}
---
When a push is rejected and `commit-board.sh` takes its commit back, the owner's staged version of a named path is replaced by HEAD's, so a later failure leaves their staged work gone while the script says the index is untouched.

## What happens

Found in review of [commit-board.sh drops the owner's staged version of a path when a pre-commit hook fails](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5ca41314-0792-4f4c-8e53-0d771d1a8dca), on branch `commit-board-hook` at `8af5727`. Measured by the reviewer in a throwaway repo, not yet reproduced a second time:

- Owner has `v2` of a path staged and `v3` on disk (status `MM`).
- `commit-board.sh` commits the path, the push is rejected, and the script takes the commit back. `sync_index` after the un-commit (`skills/work/scripts/commit-board.sh:166`) resets the index for the named paths to HEAD.
- On the retry the pre-commit hook fails. Nothing is committed, which is right, but the index now holds HEAD's `v1`: status ` M`, the staged `v2` is gone. The script still prints "the index untouched".
- The same reset runs on "push failed 5 times; nothing committed".

## Scope

- Same kind of loss as the hook case fixed on the card above, on a different path through the script: a rejected push instead of a failed hook.
- Not a regression: the script on `main` before that fix does the same.
- `commit-board.sh` has never shipped; 0.9.0 is its first release.

## Also seen in the same review, smaller

- The header comment at `commit-board.sh:21` says the unprotected window on SIGKILL is "between `git commit` returning and the next line". Measured: it is the whole `git commit`, hooks included. A SIGKILL while the hook runs leaves the commit landed and the path `MM`.
- `skills/work/scripts/lint-ask.sh:15` exits 1 with no arguments, and 1 is also its "violations found" code. The other scripts use 2 for usage.

## Decided

Ruled by the owner on this card, 2026-11-20: **0.9.0 is held until this is fixed too.** Not taken: shipping it in 0.9.1.
