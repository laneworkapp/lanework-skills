---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:51:43Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:51:43Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and verified: `tests/check-sizes.sh` called from smoke case 62; commit 8bba07f on `readme-sizes`. Gate green, three breakages each fail naming the row.**

- **FAIL-BEFORE** (at merge-base 429f243, smoke with the new case, unrefreshed README): `work/references/lead.md: README says 976, wc -w says 977`, `check-sizes: 47 rows, 1 wrong`, exit non-zero. Only 1 row wrong, not the card's 9: main's later edits already refreshed the rest, including the `heal` rows.
- **Refresh**: `lead.md` 977, `work` total and summary 6,294. Measured date was already 2026-10-09.
- **Decided**: separate helper (README parse needs awk; takes an optional repo root so it runs on a scratch copy). Also added to CLAUDE.md's tests row and Verified line.
- **Caught in own test**: first draft globbed `references/*.md` from the wrong directory, so the unlisted-file rule never fired. Fixed before commit; the unlisted case below proves it.
- **Gate**: `env -u CLAUDE_MODEL bash tests/smoke.sh` -> `ok 62 - README sizes match...`, `smoke: 66 passed`, exit 0.
- **Scratch copy breakages** (all exit 1): row 351->350: `lanework/references/finding.md: README says 350, wc -w says 351` plus `lanework/total: README says 3664, sum of rows says 3663`. Added `watch/references/extra.md`: `watch/references/extra.md: no README row (wc -w says 3)`. Total 1,254->1,255: `watch/total: README says 1255, sum of rows says 1254` plus `watch/summary words an agent reads: README says 1254, total row says 1255`.
