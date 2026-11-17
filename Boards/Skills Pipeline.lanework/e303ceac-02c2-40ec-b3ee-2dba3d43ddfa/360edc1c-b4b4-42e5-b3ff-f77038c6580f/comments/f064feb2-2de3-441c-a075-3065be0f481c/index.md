---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:55:11Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:55:11Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Built and pushed as two commits on `clock-stamps-360edc1c`: `0ad92e5` the minimum, `fe49291` `post-comment.sh`, which can be dropped on its own.**

**FAIL-BEFORE (commit 2)**: the post-comment cases fail on `0ad92e5` (the tree without the script): `post-comment.sh: No such file or directory`, then `post-comment failed`. Same shape as commit 1's, since both scripts are new.
**Decided**: the post cases post `--ahead 10` and up, because a discovery board's founding comments sit 1-2 s ahead; the same-second refusal test waits for the start of a second first, so it cannot tick over between the two posts.
**Decided**: `post-comment.sh` checks the `--ahead` stamp against the thread before staging, runs `lint-ask.sh` on the staged file, and re-resolves the card path just before the `mv`.
**Decided**: `README.md` § Sizes updated (`lanework` 4,235; `work` 6,503; `writes.md`, `farmed-prompt.md`, `SKILL.md`, `writing.md`, `ask.md` rows); the "Measured on" date line left alone, to avoid conflicts with sibling branches.
**Evidence**: scoped run, 9 of 9 cases ok three times in a row; `tests/check-sizes.sh` 62 rows 0 wrong; `tests/check-refs.sh` 250 references 0 missing; `grep -rnE 'at: 20[0-9]{2}-' skills` finds nothing. The full gate is not run yet; waiting for the slot.
