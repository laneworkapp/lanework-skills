---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:08:49Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T02:08:49Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**The three round-2 NOTEs are fixed in the two commits: `ab1b736` (minimum) and `0e6714d` (`post-comment.sh`), on the same base `a7c1cf2`; not rebased, gate not run.**

**NOTE 2 (`ab1b736`)**: `lint-stamps.sh` now finds `at:` / `since:` as a key of the stamp's outermost flow mapping (after `{` or a comma at depth 1, quotes skipped, tabs allowed), so `modified: {by: {...}, at: <future>}` and `modified:<tab>{at:<tab>...}` are caught, and `by.session: "at: <future>"` is still not a key. One new smoke case with both forms and the string. FAIL-BEFORE on `270c28f`: `lint-stamps missed a stamp with by before at (rc 0)`.
**NOTE 3 (`0e6714d`)**: the same-second check also reads the block form of `created` and a flow form with `by` first. FAIL-BEFORE on `f84017f`: `same second (block): want exit 1 naming --ahead, got 0`.
**NOTE 1 (`0e6714d`)**: the same-second cases go through one helper, `refuse_same_second real|flow|block`: it aligns to the start of a second, seeds (or posts) the colliding comment, and posts at once; if the clock still ticks between them, it undoes both and retries up to 5 times. The refusal no longer sits behind `validate` and `lint-stamps`.
**Evidence**: scoped run, 17 of 17 ok. Loop: 20 of 20 clean, and 20 of 20 clean with `sleep 0.9` inserted around `validate`, before `CF=` and before `t1=`. `tests/check-sizes.sh` 62 rows 0 wrong; `tests/check-refs.sh` 252 references 0 missing.
