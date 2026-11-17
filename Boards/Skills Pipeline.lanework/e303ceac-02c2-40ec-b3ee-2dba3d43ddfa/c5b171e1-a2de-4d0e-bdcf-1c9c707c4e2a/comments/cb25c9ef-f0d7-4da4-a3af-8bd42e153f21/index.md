---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:53:59Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:53:59Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**APPROVE: README.md:159 and the November 2026 CHANGELOG entry meet done-when; no blocking findings.**

```
VERDICT: APPROVE
STANCE:  STANDARD
ROUND:   1

CARD:   Ideas/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a "Point the README install at lanework-marketplace"
BRANCH: readme-marketplace-c5b171e1 at bb41e5e6de3a3747c9e3381510cd3e183a9e168f

BLOCKING: 0
  none

NOTES: 0
  none

CHECKED:
  correctness vs done-when: diff origin/main...origin/readme-marketplace-c5b171e1 = README.md:159 -> lanework-marketplace.git (line 160 and 168 unchanged, so the grep finds only the manual-install clone); CHANGELOG.md gains **November 2026** above **October 2026** with one entry carrying the three commands (remove, add, install), matching the fixer's measured uninstall behavior. The "stable names only the new URL" and release-notes items follow once merged and released.
  project conduct:          CHANGELOG entry: end-user wording, one sentence, blank-line separated, no bullet or dash, inline code only; no Version 0.8.0 line, as the card says. No "assume Y" shapes.
  both paths:               README install and manual-install paths each handled as the card says; only the plugin path changed.
  fail-before:              FIXER RUN checked: grep of lanework-skills.git in README.md at the merge-base finds 159 and 168, the done-when observable.
  test adequacy:            doc-only change; no test added, none required. Smoke green 125 passed on re-run; first-run red is the known flake tracked by 34d09bf2, outside this diff.
  blast radius:             two files (CHANGELOG.md, README.md), +5 -1, as Phase-1 expected. marketplace.json, CLAUDE.md, tests/ and skills/ untouched.
  population:               grep denominator = 2 hits before, 1 after; check-sizes 62 rows, check-refs 248 refs.

UNRESOLVED: none
```
