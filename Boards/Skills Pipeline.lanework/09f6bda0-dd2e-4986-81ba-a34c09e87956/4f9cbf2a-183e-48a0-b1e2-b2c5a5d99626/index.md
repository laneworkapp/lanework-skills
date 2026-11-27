---
schema: 1
kind: card
title: "Scripts leave a plugin signature file in every board they write to"
order: 5120
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-27T17:33:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T21:25:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-27T21:55:20Z
---
The scripts leave a small signature file in every board they write to, so the sandboxed app can read which plugin version is working the board and tell the person when it is behind.

## The file, as agreed on the app's card

- **Path**: `<board>/.plugin.lanework-signature`, beside the board's `index.md`. The name matches `.*.lanework-*` in the board's seeded `.gitignore`, so git never sees it and it stays local to one Mac.
- **Shape**: frontmatter only, no body.

```yaml
---
schema: 1
kind: plugin-signature
name: lanework
version: "0.11.0"
installed: 2026-11-12T10:00:00Z
updated: 2026-11-20T08:30:00Z
commit: 1a2b3c4
scope: user
agent: claude-code
written: 2026-11-27T17:30:00Z
---
```

- **Always present**: `schema`, `kind`, `name`, `version`, `written`.
- **Optional, when the plugin can find them**: `installed`, `updated`, `commit`, `scope`, `agent`.
- **Never in the file**: any path, the user's name, the host name.
- **Values**: timestamps in whole-second UTC with `Z`, `version` quoted, every other value one plain word.
- **Rewrite only when a key other than `written` changed**, so the app's folder watcher is not woken on every board write.
- **Never fails or blocks the write it follows.**

## Scope

| File | Change |
|---|---|
| `skills/lanework/scripts/sign-board.py` (new) | The writer. Finds the plugin root through the script's real path, reads `name` and `version` from `.claude-plugin/plugin.json`, and the optional keys from Claude Code's install record. Compares with the file on the board and rewrites only on a difference other than `written`. Atomic write, temp file removed on failure. Always exits 0 and prints nothing. |
| `skills/lanework/scripts/lib.sh` | `sign_board <board>`: calls the writer, swallows every failure. |
| every script that writes to a board | One `sign_board` call after the landing write, on the success path only: `found-board.sh` (covers the discovery and plan founders), `file-card.sh`, `move-card.sh`, `post-comment.sh`, `post-ask.sh`, `label-card.sh`, `lease.sh` (stake and release, not the timer's renew), `file-question.sh`, `file-record.sh`, `settle-question.sh`, `file-ticket.sh`, `resolve-ticket.sh`, `claim-ticket.sh`, `merge-board.sh`, and `heal-board.py` and `heal-descriptors.py` under `--apply`. |
| `skills/lanework/references/writes.md` | What the file is, that scripts write it and agents never edit or commit it. |
| `tests/smoke.sh` | The cases under Verified by. |
| `README.md` | One line in the key features. |

Not signed: the `import` scripts (they write a CSV, not a board), `commit-board.sh`, the readers, the watcher and the lints. The merge driver itself writes only the file git hands it.

## Decided here, not asked

- **Every writer signs**, not only the three in the draft. A board worked only through tickets or leases would otherwise never be signed.
- **Signed only where the board has its seeded `.gitignore`.** A board the app has never opened has none, so the file would show as untracked and could be committed by mistake. The app is the file's only reader and seeds the `.gitignore` on first open, so the next plugin write after that signs. Cost: on its very first open of a plugin-founded board the app sees no signature.
- **Version source**: the `plugin.json` above the script's real path, so a symlinked skill folder reads the version of the checkout or install it points at. No `plugin.json` found: no file is written.
- **Install record**: the entry whose install path is the plugin's own root gives `installed`, `updated`, `commit` (first 7 characters) and `scope`. A plain checkout has no entry and writes only the always-present keys.
- **`agent`**: `claude-code` when the environment says so (`CLAUDECODE=1`), otherwise left out.
- **The lease timer does not sign** on each renewal. Stake and release do.
- **The draft is a starting point**: its writer matches this spec apart from the commit length, a leftover temp file on a failed write, and wiring only three scripts.

## Risks

- About 17 call sites. A missed one leaves a write path unsigned, never broken. Smoke counts them.
- One extra Python start per write, measured at about 50 ms on a loaded machine.
- Throwaway boards in smoke have no `.gitignore`, so the existing cases run unsigned and unchanged. Only the new cases sign.

## Verified by

- `bash -n` and `python3 -m py_compile` on the changed scripts.
- New smoke cases on throwaway boards that carry the seeded `.gitignore`:
  - the first write creates the file with the always-present keys;
  - a second write leaves its bytes and its modification time alone;
  - a changed version rewrites it;
  - a fake install record fills `installed`, `updated`, `commit` and `scope`, and no path appears in the file;
  - a board folder that cannot be written still gets its card or comment, exit 0;
  - a board with no `.gitignore` gets no file;
  - a failed founding leaves the folder empty;
  - every writer in Scope signs: one loop over them.
- The full `tests/smoke.sh`, with `check-refs.sh` and `check-sizes.sh`.

## Done when

- Every board write the scripts make leaves a current `.plugin.lanework-signature`, in the shape above, on a board that has its seeded `.gitignore`.
- A write still succeeds, with the same exit code and output, when the signature cannot be written.
- No path, user name or host name can reach the file.
- `writes.md` says what the file is and that agents never edit or commit it.
- `tests/smoke.sh` passes in full, and the closing record carries the changelog sentence.
- The app's watch session is told the shape shipped and the one limit: no signature before the app's first open.
