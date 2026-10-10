---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:50:10Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T11:50:10Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START and FAIL-BEFORE: the new smoke case fails on unchanged source: a repeated `--labels` keeps only the last list.**

- **Branch**: `found-board-fixes`, worktree `.claude/worktrees/found-board-fixes`, at merge-base `bca7ced`. Bundled with [5f04ac26](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5f04ac26-e7d5-4e22-aa38-7ade1ef86bec).
- **FAIL-BEFORE**: `env -u CLAUDE_MODEL bash tests/smoke.sh` at `bca7ced` plus the new cases (the title case already fixed). Fails with `found-board.sh --labels type --labels size: got size`. Raw run: `fail-before-2.txt` in the fixer scratchpad.
- **Decided**: the card says `SEEN` writes a repeated kind once, but today a kind twice in one list exits 2 (an existing smoke case). Kept that. A kind repeated across flags is skipped silently (`merge_kinds` in `lib.sh`, used by both scripts), so `--labels type --labels type` writes it once as Verify says. Both scripts share the helper.
