---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:09:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:09:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main: every script-written title goes through `title_str`, and no script stamps `model: unknown`. A missing model now fails with exit 2 before any write.**

- **Commits**: `db33e0d` (helpers, five scripts, docs, two smoke cases), `cb26718` (review notes 1-4: env and flag model cases, hostile board and lane titles, usage line, `yaml_str` removed).
- **Evidence**: `bash tests/smoke.sh` on main at `cb26718`, with `CLAUDE_MODEL` unset, printed `smoke: 47 passed`, exit 0. The adversarial review approved with 0 BLOCKING on its own fail-before, 16 hostile titles and 7 mutations under bash 3.2. The fixer's mutation checks for notes 1 and 2 turned smoke red.
- **Done when, checked**: `grep -rn 'model: unknown' skills` finds nothing. Each title writer (`file-question`, `file-record`, `found-board` board and lane titles) calls `title_str`. Both smoke cases pass.
- **Different from the body**: `found-board.sh` is in scope too, along with `tests/merge-case.sh` and `lanework/references/founding.md`, which call it. `yaml_str` is gone. `lanework-merge.py` still signs without a model when none is given, but it never stamps `unknown`.
- **Split out**: review NOTE 5, raw titles in body headings, as [5f04ac26](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5f04ac26-e7d5-4e22-aa38-7ade1ef86bec) in Ideas.
- **Merge order**: landed before `lane-actors` (`0d374675`), which rebases onto it. Its lead was told.
- **Ships**: with the next release.
