---
schema: 1
kind: card
title: "Waiting-clear trial: what counts toward its ending, and five lint edges"
order: 78848
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T14:42:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T21:51:33Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The waiting-clear trial can only be counted after 0.9.0 if the lint can leave out clears made before it, so `lint-waiting-clears.sh` gets a `--since <timestamp>` option, and its five small edges are fixed or accepted one by one. Both owner calls are ruled and recorded below.

From the review of [the waiting-clear card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3), merged to main as `42b5a98`. Not released yet.

## Decided

**Call 1, ruled by the owner on this card, 2026-11-20: A.** The trial counts only clears made after 0.9.0 is released. The three older clears ([4596a2cb](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12), [48fa3910](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/48fa3910-7ff0-4999-93a7-de5429e828c8), [c5b171e1](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a)) stay listed and no old thread is rewritten. Not taken: fixing the three first.

**Call 2, ruled by the owner on this card, 2026-11-20: A.** Discovery adopts the work skill's record shape. The build is its own card, [discovery records a chat answer in the work skill's quote format](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/738e8765-36c7-44c5-8f8d-34b8452801be), and is out of scope here. Not taken: the lint accepting discovery's shape; discovery boards left out of the count.

## Today

Measured on a throwaway board, and read in `work/scripts/lint-waiting-clears.sh`:

- No time bound. The lint lists every unmarked agent ask on the board, so on this board it prints `QUOTED 0, NO-QUOTE 3`, exit 1, before any agent has used the rule. The trial's ending line, "ten `QUOTED`, none `NO-QUOTE`", cannot be met.
- Edge 1 (line 36): any `by` whose kind is not `agent` counts as human, `kind: shortcut` included. Measured: an agent ask, a quoting-less record, then a shortcut comment prints nothing, so the clear is hidden.
- Edge 2 (line 35): an `at` with fractional seconds (`10:02:00.123Z`) or an offset does not match the timestamp pattern, so that comment is dropped. Measured for fractions: a human comment stamped that way was invisible, and the card showed as a clear.
- Edge 3 (lines 31-32): a `>` line inside a code fence counts as the quote, `**Given**` with no colon counts, and the pattern is not anchored, so `> **Given** x` satisfies both. Measured: a record holding a fenced `> fake` line and `**Given** chat` printed `QUOTED`.
- Edge 4: `tests/smoke.sh` (lint-waiting-clears block, from line 896) has no case with `waiting:` in a card body. The shipped `has_waiting` stops at the closing `---`, so it is right; the test would not catch a regression.
- Edge 5: `skills/work/references/writing.md:53` cites `work/scripts/lint-waiting-clears.sh` from inside the `work` skill, where the convention is `scripts/…` (as `scripts/post-ask.sh` two lines above does). `tests/check-refs.sh` passes both spellings.

## Change

1. **Call 1: `--since <ts>`** in `skills/work/scripts/lint-waiting-clears.sh`. Same format and error as `lint-leases.sh` (`2026-11-14T15:30:00Z`, exit 2 on a bad or missing value). A card's clear time is the newest `created.at` among its ask and the agent comments `in-reply-to` that ask: the record is posted at or after the clear, and an ask with no record falls back to its own time. A card is listed only when that time is at or after `--since`. The tally counts the listed cards only. No flag keeps today's behavior. Chosen over filtering on the ask's time alone, which would drop an old ask cleared after the release. The format check is a pattern match; it does not repeat `lint-leases.sh`'s calendar check, since a stamp that sorts wrong still fails safe by listing too much.
   - `skills/work/references/writing.md` (the trial paragraph): state the ending line once, with the command: `lint-waiting-clears.sh <board> --since <0.9.0 release time>` shows ten `QUOTED` and no `NO-QUOTE`. The release time is filled in when 0.9.0 is cut, from the `stable` tag.
   - Could be dropped only if the owner wants to read the three old lines by eye; the ruling asks for a way to leave them out.

2. **Edge 1, fix.** In `comment_row`, a kind that is neither `agent` nor `human` (and not a missing `by`) is `other`; `other` rows are neither an ask nor an answer. The app clears `waiting` only on a human comment, so a shortcut never counts as one.

3. **Edge 2, fix for fractions, accept offsets.** Allow `.\d+` before the `Z` and cut it off, so ordering stays by whole seconds and the uuid breaks ties as today. An offset stamp is accepted as unread: the guide tells writers to stamp UTC with `Z`, and the app does. Converting offsets in awk is not worth the code.

4. **Edge 3, fix.** Count a quote only outside a fence and only on a `>` line with text after it; count `**Given**:` only at the start of a line, with the colon. This also settles "both on one line", since the two now need two lines.

5. **Edge 4, smoke case only.** Add to `tests/smoke.sh` a card whose body (after the closing `---`) holds a `waiting:` line, with an agent ask and no frontmatter `waiting`: still listed.

6. **Edge 5, fix.** `skills/work/references/writing.md:53`: `work/scripts/lint-waiting-clears.sh` becomes `scripts/lint-waiting-clears.sh`. The script's own header comment keeps its repo-style cite.

`tests/smoke.sh` gets, in the same block: `--since` cases (an old ask and record skipped; a post-`--since` one listed; a record after `--since` on an old ask listed; the tally counts listed cards only; a bad value, a missing value and a repeated flag exit 2), a shortcut-comment case, a fractional-seconds case, a fenced-quote case, an unanchored-`Given` case and a no-colon `Given` case, and the body-`waiting` case.

## Not in scope

- Rewriting or fixing the three old clears.
- Discovery's record shape: its own card, linked above.
- Offset timestamps, and moving `real_time` into `lanework/scripts/lib.sh`.
- Changing what counts as an ask or an agent.

## Risks

- A clear time taken from the record can be a little later than the real clear. The trial's rule makes the record part of the same pass, so the gap is seconds, and only a clear right at the release moment could count a side late.
- Tightening the quote check could turn a real `QUOTED` record into `NO-QUOTE` if an agent writes `**Given** : …` or indents the quote. Both are outside the shape in `skills/work/references/writing.md`; the new `NO-QUOTE` is the lint doing its job.
- The three old lines still print without `--since`, as ruled.

## Done when

- `tests/smoke.sh` passes with the new cases in the lint-waiting-clears block.
- On a throwaway board, an ask and a quoting record both dated before a `--since` value print nothing and exit 0; moved after it they print one `QUOTED` line.
- `lint-waiting-clears.sh <board> --since nonsense` exits 2 with a message on stderr.
- A shortcut comment after an agent clear still prints that clear; a fenced `>` line prints `NO-QUOTE`.
- `grep -n "work/scripts/lint-waiting-clears" skills/work/references/writing.md` prints nothing.
- `tests/check-refs.sh` passes.

Bump: minor.
