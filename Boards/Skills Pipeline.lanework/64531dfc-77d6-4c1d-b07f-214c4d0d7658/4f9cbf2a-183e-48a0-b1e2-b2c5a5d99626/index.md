---
schema: 1
kind: card
title: "Scripts leave a plugin signature file in every board they write to"
order: 2048
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-27T17:33:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T17:33:44Z}
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
- **Sources**: `name` and `version` from `.claude-plugin/plugin.json`. The rest from Claude Code's install record, the entry whose install path is the plugin's own folder. A plain checkout has no entry and writes only the always-present keys.

## To settle in shaping

- Which scripts sign: every script that writes to a board, or only the three in the draft (`file-card.sh`, `post-comment.sh`, `move-card.sh`).
- Whether founding a board signs it.
- A symlinked install (`~/.claude/skills/<name>`) has no `plugin.json` beside it: what `version` reads there.
- Whether the validator and the healer on a board accept the new dotfile untouched.
- What `agent` reads when the caller is not Claude Code.

## A draft exists

The app's watch session left an unreviewed sketch outside this repo: `sign-board.py` and `writers.patch` (a `sign_board` helper in `lib.sh` and one call after the landing `mv`). Tried by hand on a scratch board only. Read it as a sketch, not as a start.

## Verified by

- New smoke cases on throwaway boards: the first write creates the file, a second write leaves its bytes alone, a version change rewrites it, an unwritable board folder does not fail the write, and no path or user name appears in it.
- The full `tests/smoke.sh`.

## Done when

- Every board write the scripts make leaves a current `.plugin.lanework-signature`, in the shape above.
- A write still succeeds when the signature cannot be written.
- `writes.md` says what the file is and that agents never edit it by hand.
- The closing record carries the changelog sentence.
