---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:52:11Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:52:11Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Round 1 fixed in the two commits, rebased onto origin/main `a7c1cf2`: `270c28f` (the minimum) and `f84017f` (`post-comment.sh`).**

**Fixed, `lint-stamps.sh`**: (1) `find -mindepth 1`, so `.` inside a board is linted. (2) Quoted (`"` or `'`) and multi-space stamps are read, and the scan is anchored to `created`/`modified` `{at:` and block `at:`, and `waiting`'s `since`, so `by.session: "at: <future>"` is no stamp. (a) `--slack` with no value and no argument exit 2, "no such path" goes to stderr. (c) CRLF files are read.
**Fixed, `writes.md`**: (b) the clock rule is folded into the "Stamp it" bullet; no new bullet. README § Sizes recomputed with `wc -w`.
**Fixed, `post-comment.sh`**: (3) `--ahead` is capped at 30 s (usage line says 0-30), exit 2 beyond it, for a negative, or for a non-number. (4) The card is found by `*/<uuid>/index.md`, exactly one or exit 2; an index-less ghost folder is ignored, two real cards with one uuid are refused, and `comments/` is created only under the real card, without `-p`. (5) The first case now asserts `t0+10 <= created.at <= t1+10`; a typed-constant mutant fails it. (d) The same-second check reads a `created:` line with any spacing and no `by`; header, usage, `writing.md` and `ask.md` say it is a check, not a lock.
**FAIL-BEFORE**: the new lint-stamps cases fail on the round-1 script (`lint-stamps . inside a board: want exit 1, got 0`); the new post-comment cases fail on the round-1 script (`an unknown card: want exit 2, got 1`, then the cap, ghost and spacing cases). Raw outputs in the fixer's scratchpad `failbefore/`.
**Evidence**: scoped run, 15 of 15 ok, twice; `tests/check-sizes.sh` 62 rows 0 wrong; `tests/check-refs.sh` 252 references 0 missing. The full gate has not been run.
**Fault**: three earlier records of mine landed on card 4ada828e's thread. My poster resolved the card by a glob and moved the file without checking the destination; it now requires exactly one `<uuid>/index.md` and a destination that ends in this card's uuid. I did not write the empty comment 8bdc0bdd (my records all carry a body); its `by` matches a sibling fixer's stamp.
