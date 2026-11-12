---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:51:37Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:51:37Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**START: building as scoped, on branch `guide-v114-2c29a34f` (worktree `.claude/worktrees/guide-v114-2c29a34f`).**

**Decided**: read the skills against the live board's working-tree guide (v114). The app's v114 `CLAUDE.md`/`AGENTS.md` and `.schema/` stay out of this branch: the lead commits them on `main` before the merge.
**Decided**: `lane-rewrite.*` fixtures re-copied from `dc404fe` (the Shaping lane rewrite, now committed). `card-move.*` from `99ac340`, `comment-posted.md` from `281c22a`. `card-title-edit.*` kept.
**Decided**: `heal-board.py` gets only the four drifts the body names (component, `board`, relations walk). No re-base on heal v5.
**Plan**: smoke cases first and run against the merge-base (FAIL-BEFORE), then the wording, scripts, fixtures and the stamp bump.
