---
schema: 1
kind: comment
in-reply-to: 448b2549-6212-487f-b3c8-ad97ae66f9d2
created:  {at: 2026-11-17T20:52:03Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T20:52:03Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: the fix for round-2 note 1 narrows the window but does not close it. A TERM that lands while the card's own move into Working runs still leaves a Working ticket with no lease. Note 2's fix holds.

- **Stance**: adversarial, narrow re-check of `a092a90..2dd4a18` on the lead's round-2 ruling.
- **Round**: 3 (narrow re-check, the second REQUEST-CHANGES)
- **Card**: [b808e18c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)
- **Branch**: `plan-lease` at `2dd4a18`

**Blocking**

1. `skills/plan/scripts/claim-ticket.sh:92-93 @ 2dd4a18` "mv "$FRONTIER/$CID" "$DEST/$CID"" then "DONE=1   # landed": `DONE` is set by the command after the move, and `/bin/mv` is a child process.
   - **Mechanism**: bash holds a TERM that arrives during that `mv` until the child exits, then runs the EXIT trap before `DONE=1`. The card is already in Working, `DONE` is still empty, so the trap releases the lease and deletes the staged Claimed comment.
   - **Measured, deterministically**: an `mv` shim on PATH does the real move, then holds when the target is the card's folder in Working, and the claim is TERMed there. At `2dd4a18` the claim exited 143 with the card in Working, no `claimed`, no timer, no memory and no Claimed comment.
   - **Controls in the same harness**: TERM during the `index.md` move left the ticket in Frontier with nothing behind (right). TERM during the comment's move kept `claimed`, timer, memory and comment (right, the fix working). `a092a90` gave the same result as `2dd4a18` for the folder move.
   - **Window**: one `/bin/mv` run, 2.74 ms on average here over 200 runs. The 30 random TERMs at 0.66–0.80 s did not reach it this time (all 30 landed before the move and left Frontier with nothing behind).
   - **Fix direction**: decide in the trap by where the card is, not by a flag set after the fact. If `$DEST/$CID` exists, the claim has landed: keep the lease. Otherwise release. The P2c shim moved onto the folder move would cover it in smoke.

**Notes**: none.

**Checked**

- **Diff scope**: `git diff --stat a092a90 2dd4a18` lists only `skills/plan/scripts/claim-ticket.sh` and `tests/smoke.sh`. No counted prose file changed, so README § Sizes is untouched, rightly.
- **Note 1, other paths**:
  - A claim that completes is unchanged: card in Working, `claimed`, Claimed comment, timer alive.
  - "Left Frontier after the stake": the card was moved to Blocked by hand during a 2 s stake wait. Exit 1 with "is in Blocked, not Frontier", no `claimed`, no timer, no memory.
  - Race: 20 reps at `2dd4a18` (outcomes split 10/10). Every rep had one exit 0, one lane (Working), `claimed` naming the winner, one Claimed comment, 0 Lease lost records. The winner had one detached timer and its memory; the loser had none.
  - Counting check: a first pass counted the timers' command-substitution subshells as extra timers. The recount takes only processes whose parent is 1, and gives 0 bad over 20.
- **Note 2, closed**:
  - Session id `a b` (stake exit 2): claim exit 1, board byte for byte, 0 "by hand" lines.
  - A genuinely failed release (a wrapper making `release` exit 5, then an abort after the stake): claim exit 1 and "the lease on 0e8ca6d2 was not released (exit 5): lanework/scripts/lease.sh release by hand".
- **New smoke cases**: each fails with its fix reverted, on a copy.
  - `DONE=1` moved back after the comment fails P2c: "plan claim ended after landing: rc 143, lane Working, session ''".
  - `0|1|3` restored fails P2d, on the "release by hand" line.
  - P2c's shim stays inside smoke: it lives in `$T/plan-shim` and reaches only that one claim through `env PATH=…`. It acts only on a last argument ending `/comments`. The timer that claim starts inherits the PATH but only uses `mkdir` on a loss, and P2c releases it.
- **Smoke**: one full run in the fixer's worktree at `2dd4a18`, own last line `smoke: 228 passed`.
