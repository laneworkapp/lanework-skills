---
schema: 1
kind: comment
created:  {at: 2026-11-22T00:14:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-22: built, reviewed and approved, merged to `main` at `135646f`. Smoke on main: 358 passed.**

- **What changed**: `lanework/scripts/lib.sh` (`show_name`, its awk form `SHOW_NAME_AWK`, and `board_index_files` listing a card once), the three lints in `work/scripts/`, one sentence in `work/SKILL.md`, smoke cases, README counts. Branch head `d85772f`.
- **Review: request-changes in round 1, approved in round 2.** Round 1 found that escaping the ask id before the comparison turned a `QUOTED` into a `NO-QUOTE` for an id holding a backslash. Fixed, with a case.
- **Built differently from the body**:
  - The body's `find -L -type l` only finds broken links. The build uses `find -H ... -type l`.
  - Dedupe resolves parent folders in one pass with `realpath` (stock on macOS 13 and later). Without it, or when a name holds a newline, it falls back to a per-folder loop.
  - A `\001` byte in a name also prints escaped, so the rule covers five characters, not four.
  - The settle check in smoke runs the real `settle-question.sh`.
- **Speed** (reviewer's measure, 400 cards, one linked lane): 1.09 s to list the board, 0.27 s with no link. Round 1 took 15.3 s.
- **Each new rule fails a case when mutated**, except one (below).
- **Left open, added to card `713289a0`**: the `>/dev/null` on the fallback `cd` has no smoke case (it needs `CDPATH`, a relative path, a newline name and a sibling link together). The fallback triggers on a line-count mismatch, which a newline name plus a vanished folder could cancel out; reasoned, not reproduced.
- **Bump**: patch.
- **CHANGELOG sentence**: "The board lints now print names with tabs or newlines as `\t` and `\n`, so each finding stays on one line, and a card in a linked lane is reported once."
