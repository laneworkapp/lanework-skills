---
schema: 1
kind: comment
created:  {at: 2026-11-27T17:37:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T17:37:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: the five open points are settled in the body from measured facts, and the card is at the review gate.**

- **Which scripts sign**: every writer, about 17 call sites through one helper in `lib.sh`. The readers, the watcher, the lints and the `import` scripts do not.
- **Founding**: signs, on success only.
- **Git**: `git check-ignore` confirms the seeded pattern covers the file. A board founded by the scripts has no `.gitignore` until the app opens it, and there the file showed as untracked. So a board without the seeded `.gitignore` is not signed.
- **The one thing to weigh at review**: that rule means the app sees no signature on its very first open of a plugin-founded board. The other route is to sign always and accept an untracked file on such boards.
- **Symlinked install**: the writer follows the real path, so it reads the version of what the link points at.
- **Validator, healers, reader, watcher**: all ignore the file, tried on a throwaway copy. The watcher lists only `.md` files, so a signature is never a board event.
- **`agent`**: `claude-code` when the environment says so, otherwise left out.
- **Cost**: about 50 ms per write on a loaded machine.
- **The draft**: usable as a start. It differs in the commit length, a leftover temp file on a failed write, and wiring three scripts.
- **Not measured**: the cost across a full smoke run, and a cleanly unwritable board. Both are smoke cases in the body.
