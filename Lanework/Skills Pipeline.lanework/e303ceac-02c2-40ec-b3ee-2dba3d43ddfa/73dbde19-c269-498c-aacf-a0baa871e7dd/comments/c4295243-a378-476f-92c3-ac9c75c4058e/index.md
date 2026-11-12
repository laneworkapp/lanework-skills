---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:37:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
*Sample, not a real verdict: the standard APPROVE from the README marketplace card (verdict cb25c9ef), rewritten in the new template as the branch has it at 0085b6d. Every line kept; only the form changed. Three more rewrites (two adversarial APPROVEs, one REQUEST-CHANGES) are on a throwaway board.*

**Verdict: APPROVE.** `README.md:159` and the November 2026 CHANGELOG entry meet the done-when, with no blocking findings and no notes.

- **Stance**: standard
- **Round**: 1
- **Card**: [Point the README install at lanework-marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a)
- **Branch**: `readme-marketplace-c5b171e1` at `bb41e5e6de3a3747c9e3381510cd3e183a9e168f`

**Blocking**: none.

**Notes**: none.

**Checked**

- **Correctness vs done-when**: `git diff origin/main...origin/readme-marketplace-c5b171e1` changes `README.md:159` to `lanework-marketplace.git`. Lines 160 and 168 are unchanged, so the grep finds only the manual-install clone.
  - `CHANGELOG.md` gains **November 2026** above **October 2026** with one entry carrying the three commands (remove, add, install), matching the fixer's measured uninstall behavior.
  - The "stable names only the new URL" and release-notes items follow once merged and released.
- **Project conduct**: the CHANGELOG entry is end-user wording, one sentence, blank-line separated, no bullet or dash, inline code only. No `Version 0.8.0` line, as the card says. No "assume Y" shapes.
- **Both paths**: the README install and manual-install paths are each handled as the card says; only the plugin path changed.
- **Fail-before**: fixer run checked. The grep of `lanework-skills.git` in `README.md` at the merge-base finds lines 159 and 168, the done-when observable.
- **Test adequacy**: a doc-only change; no test added, none required. Smoke green with 125 passed on re-run; the first-run red is the known flake tracked by [34d09bf2](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/34d09bf2-833a-4bd5-946f-8df57780459e), outside this diff.
- **Blast radius**: two files (`CHANGELOG.md`, `README.md`), +5 -1, as Phase-1 expected. `marketplace.json`, `CLAUDE.md`, `tests/` and `skills/` untouched.
- **Population**: the grep denominator is 2 hits before, 1 after; `check-sizes` 62 rows, `check-refs` 248 refs.
