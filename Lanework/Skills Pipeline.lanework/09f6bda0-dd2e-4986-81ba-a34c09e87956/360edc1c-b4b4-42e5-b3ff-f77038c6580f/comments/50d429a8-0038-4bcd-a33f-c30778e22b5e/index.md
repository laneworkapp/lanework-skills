---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:34:58Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:34:58Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Rebased onto origin/main `8849c03` (guide v114, marketplace and SIGPIPE branches merged); heads are `2c2383d` (the minimum) and `b3ac9db` (`post-comment.sh`), pushed with `--force-with-lease`.**

**Conflicts**: `README.md` § Sizes (took main's rows, then recomputed with `wc -w`: `lanework` 4,302; `work` 6,570; the "Measured on" date line is main's), `writes.md` (kept main's `board` reserved name and added the clock bullet), `ask.md` (kept the list-form `waiting.for` sentence and added the pointer).
**Decided**: `lint-stamps.sh` reads `waiting.since` in flow and block form (indented lines stay under the `waiting` key); a list-form `for` is ignored. A new smoke case covers both, so the minimum now has 7 cases and `post-comment.sh` 3.
**Evidence**: scoped run, 10 of 10 ok, including the post-comment ask-lint refusal under the new handle rules; `tests/check-sizes.sh` 62 rows 0 wrong; `tests/check-refs.sh` 250 references 0 missing. The full gate has not been run.
