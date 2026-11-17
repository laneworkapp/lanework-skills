---
schema: 1
kind: comment
in-reply-to: c2019158-d9f7-4f62-9a1c-987b927e1df8
created:  {at: 2026-11-17T20:32:29Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T20:32:29Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Round-1 blocking finding 1 is closed. The four notes ruled for this branch are fixed. Three new notes, one of them a measured window the lead should rule on.

- **Stance**: adversarial. Trigger: concurrency, a lease staked, checked and released around a lane move.
- **Round**: 2
- **Card**: [b808e18c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)
- **Branch**: `plan-lease` at `a092a90`

**Blocking**: none.

**Questions for the lead**

1. Note 1 below is a measured failure in unchanged code, so under § Bounding review it is a note, not a block. A TERM that lands during the moves themselves leaves a Working ticket with no lease and no Claimed comment. It is the same defect class as round-1 finding 1. The fix is one line. Fix it before the merge, or file it?

**Notes**

1. `skills/plan/scripts/claim-ticket.sh @ a092a90` "mv "$FRONTIER/$CID" "$DEST/$CID"" … "DONE=1": `DONE` is set only after all three `mv`s. Each `mv` is a child process, and bash holds a TERM until the child finishes. A TERM that lands during the last two `mv`s exits before `DONE=1`, and the trap then releases the lease and deletes the staged Claimed comment. Measured: 30 TERMs at 0.66 to 0.80 s left 3 tickets in Working with no `claimed`, no timer and no Claimed comment. Other sessions skip Working and the claim refuses it, so the ticket waits for a hand stake. One TERM landed after `DONE` and correctly kept the lease, in Working, with exit 143. Round 1 had the same window. Fix direction: set `DONE=1` right after `mv "$FRONTIER/$CID" "$DEST/$CID"`, since the card has landed once it is in Working, and post the comment after that.
2. `skills/plan/scripts/claim-ticket.sh @ a092a90` "case $r in 0|1|3) ;; *) echo …": `STAKED` is now set before the stake. So when the stake exits 2, the trap's release also exits 2, and the claim prints a false "the lease on 6ed59852 was not released (exit 2): lanework/scripts/lease.sh release by hand". Measured with session id `a b`: claim exit 1, board byte for byte, nothing to release. Release exit 2 means usage, so it never means a stranded stake, and it can join the quiet list.
3. `tests/smoke.sh` P1 (unchanged) under 5 parallel smoke runs: 3 of 5 runs failed at P1 with `plan claim: rc 0, lane Working, session 'S-pa'`, two of them mutants that never reached their own case. It was not reproduced at 3 parallel (3 of 3 passed P1) or at 4 in round 1. The cause was not isolated: either `D` (`until` minus now) falls below 1790 when the claim runs over 10 s, or the Note 3 timer race from round 1 (now on the lease issue). The failures came at heavy load only.

**Checked**

- **Blocking 1, closed**: the 10 TERM offsets at 0.40 to 0.90 s from round 1 were re-run. 7 ended with the ticket in Frontier, no `claimed`, no timer, no memory and no Claimed comment. The rest landed past the stake: 1 in the Note 1 window, 2 with the claim done. TERM to the process group during a 3 s stake left the ticket in Frontier with nothing left, 2 of 2.
  - **Refused claim over another session's lease**: 20 of 20 reps had the board byte for byte, the holder's memory file byte for byte, the holder's timer alive, the claimer with no memory, 0 Lease lost records, and no "not released" line.
  - **Race**: 50 reps at `a092a90` (20 simultaneous, 20 staggered 0–0.8 s with a 1 s stake wait, 10 more), winners split 6/4 in the last 10. Every rep had one exit 0, one lane, one Claimed comment, 0 Lease lost records, and the loser with no memory or timer. The winner's timer was alive and its memory present, so the loser's release never touched the winner's lease.
  - **Held before the claim**: an abort after the stake (forced with a `uuidgen` shim) kept that session's lease, same timer pid. A fresh stake was released.
  - **Quiet list**: release exit 1 means another session's `claimed` is on the card, and exit 3 means this session lost it. In neither case did a stake of this session's stay on the card (reasoned from `lease.sh` release lines 277-288), so the quiet list cannot hide a stranded stake.
- **Note 2, closed**: mutant trap release off → fails P2b. Mutant `claimed` kept on the restamp → fails P5's one-write check. Round-1 `STAKED` placement → fails P2b. One clean run each at 3 parallel; the first runs at 5 parallel hit Note 3.
- **Note 3, closed**: P6's `kill "$TP" 2>/dev/null || true`. P2b passed in every clean run (official, plus 2 at load). It took 7.35 s and 8.97 s under 3 to 5 parallel runs. It is timing-safe: the TERM comes once `claimed` shows, within `waitfor`'s 4 s, and 3 s before the stake's read-back.
- **Notes 1, 4, 5, 6, closed**:
  - `sessions.md` step 2: a claim refused on a held Frontier ticket → take the next one.
  - `tickets.md`: names `CLAUDE_PID` beside the session id, and reads "the lease's holder only".
  - § Resolve says to stake first over another session's lease, linking `lanework/references/writes.md` § Lease for the takeover without restating it.
  - README § Sizes matches `wc -w`: 427, 593, total 2,843.
- **Blast radius**: 5 files, as the ruling ordered. `skills/lanework/`, `skills/work/`, CHANGELOG and `plugin.json` are untouched (`git diff --stat 94d2e36 a092a90` empty for them).
- **Smoke**: one full run in the fixer's worktree at `a092a90`, own last line `smoke: 226 passed`.
