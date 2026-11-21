---
schema: 1
kind: card
title: "Smoke fails under machine load: plan-claim timing cases and a broken pipe from head -1"
order: 7168
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-20T23:06:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T16:42:43Z}
---
Smoke gives the same result on a busy machine as on an idle one, and a lease timer no longer dies silently when its card is moved between lanes under load.

## Problem

Measured on 2026-11-21 by extracting the plan cases P2b, P2c and P3 of `tests/smoke.sh` into a harness under `mktemp -d` and running each repeatedly while busy loops held the load average at 60 to 700.

- `plan claim ended at the move: rc 143` and `plan claim ended at the comment` (case P2c): reproduced. With about 100 busy loops, 7 of 40 runs failed; with 40 loops, 4 of 6 early runs failed. A diagnostic copy of the check showed `mem=y`, memory file present, timer pid recorded, `alive=n`, no loss record, rc 143, card in Working with the right session. So the claim itself behaves correctly (it keeps the lease) and the lease timer process is gone. An instrumented copy of `skills/lanework/scripts/lease.sh` logged the timer exiting at the `f=$(find_card) || exit 0` line while `ls` of the card path succeeded a moment later. Cause: `find_card` (`lease.sh:42`) lists `"$BOARD"/*/"$CID"/index.md` in one glob. A card renamed from Frontier to Working while the glob is being expanded can be missed in both lanes. A standalone loop moving a directory between two lanes while another loop ran the same `ls` missed it in 103 of 574 scans. The timer reads a miss as "released" and exits, which ends the lease keepalive. This is a real race in the script under test, widened by load. The test's timing is not at fault for this line.
- `plan claim ended at the comment`: same cause, same evidence (the shim holds the claim at `mkdir comments` right after the move).
- `plan claim landed (move/comment): the shim never held the claim`: reproduced twice at load above 500. `waitfor` (`tests/smoke.sh:2548`) counts 40 iterations of `sleep 0.1`, so under load its wall time is unbounded but the claim may need longer than 4 seconds of wall time to reach the shim. The shim also holds for a fixed `sleep 3`; if the TERM lands after that the claim finishes with rc 0. Both are the test's timing.
- `plan claim race` (case P3): not reproduced as a race; the one P3 failure in 120 runs was the broken pipe below, raised by `ptk`. Not reproduced: the two-session race logic reads sound from `skills/plan/scripts/claim-ticket.sh` (the stake is the arbiter).
- `file-ticket.sh: line 102: printf: write error: Broken pipe`, rc 141: reproduced with a stand-in (bash 3.2 `printf` of a three-line format into a reader that closes after its first byte failed in 7 of 200 runs) and once in the real P3 run through `ptk`'s `| head -1`. bash 3.2 emits the final `printf` in pieces, so a consumer that closes early can break a later piece. The card has already landed at that point, so only the exit code is wrong. This is the test's fault: closing the pipe early is the consumer's choice. `grep -n '| head -1' tests/smoke.sh` finds the pattern on more than fifty lines, most of them in the `file-ticket.sh`, `file-question.sh` and `file-record.sh` callers (the line numbers quoted in the old card have moved).

## Change

- `skills/lanework/scripts/lease.sh`: `find_card` retries a miss. Look again up to 10 times, 0.05 s apart, before returning "not found". In `timer`, additionally require several consecutive polls without the card (for example 3) before exiting, so a transit that outlasts the retry cannot end the keepalive; a genuinely released or deleted card still ends the timer within a few polls. A first trial with only 4 retries of 0.05 s did not clear failures at load 700, so the longer window and the consecutive-miss rule are both needed.
- `tests/smoke.sh`, P2c: the shim waits for a release file instead of `sleep 3` (`PL_SHIM_GO`, polled every 0.1 s, capped at 30 s). The case touches the file after sending the TERM. The wait for the mark file becomes a wall-clock wait of up to 30 s.
- `tests/smoke.sh`, `waitfor`: bound by wall time (`SECONDS`) instead of an iteration count, with a 20 s default for the plan cases that wait on a marker.
- `tests/smoke.sh`: every call that reads a script's output through `| head -1` captures the whole output first (`out=$(...); first=${out%%$'\n'*}`), including `ptk`, `SQ`, `bfirst`, `bq` and the lines near the end of the plan and discovery cases. A script-side fix is not needed.

## Verified

- New smoke case in the lease section: a card moved back and forth between two lanes in a loop while `find_card` runs (source `lease.sh`'s function or run `lease.sh check` in a loop) must always find it. It fails without the retry (about 18 percent of scans missed in the measurement above).
- New smoke case: a timer whose card is moved between lanes ten times stays alive (`kill -0` on the memory pid) and a timer whose card is deleted exits within a few polls.
- Existing P2c, P2b and P3 cases, run 20 times each while about 100 busy loops run, all pass. This is a manual check, not part of smoke.
- A smoke case that greps `tests/smoke.sh` for `| head -1` with a script under test on the left side and expects no match.

## Done when

- `grep -nE '(file-ticket|file-question|file-record)\.sh.*\| head -1' tests/smoke.sh` prints nothing, and the `ptk` helper does not pipe into `head`.
- Running P2c twenty times with the load average above 50 gives twenty passes.
- `tests/smoke.sh` passes, including the two new lease cases.
- Ten consecutive full smoke runs on `main` pass while a load generator holds the 1-minute load above 50 (the owner or lead runs this, not the shaper).

## Risks

- A longer `find_card` retry delays the error for a card that really is missing by up to 0.5 s, and `card_file` callers see the same delay. Smoke cases that assert a missing card may run slightly slower.
- The consecutive-miss rule changes how fast the timer exits after a release by another path; the release itself removes the memory file, which the timer already checks first, so this should not change the visible behavior.
- Running P2c at load above 600 may still show other timing losses in the test harness; the target is load 50 to 100.

## Recommendation

Build all. The lease timer race is a real script defect that can also hit a user moving a card in the app while a claim runs; the rest is test hardening. The `lease.sh` change touches `lanework` and should carry a patch release note.
