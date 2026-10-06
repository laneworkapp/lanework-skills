---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:38:47Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:38:47Z, by: {name: fixer, kind: agent, model: opus}}
---
**START: fixer building the heal script on branch `heal-board`, in the lead's worktree.**

**Plan**: new `skills/lanework/scripts/heal-board.py`, Python 3 stdlib only, dry run by default, `--apply` to write. Then which-copy-wins and when-to-run in `SKILL.md` and `references/writes.md`, and a smoke case on a throwaway board seeded with one of each damage kind.
**Decided**: semantics follow guide v82 first, then the app's `LabelHealing.swift` and `lanework-migrate-labels` where the guide is silent.
**Decided**: the fail-before is the new smoke case run at the merge-base, where the script does not exist yet.
