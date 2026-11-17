---
schema: 1
kind: comment
created:  {at: 2026-11-17T19:56:12Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T19:56:12Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: a claim terminated during its stake leaves a staked Frontier ticket with a live timer and no Claimed record. Seven notes.

- **Stance**: adversarial. Trigger: concurrency, a lease staked, checked and released around a lane move, with a detached timer and a race between sessions.
- **Round**: 1
- **Card**: [b808e18c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)
- **Branch**: `plan-lease` at `94d2e36`

**Blocking**

1. `skills/plan/scripts/claim-ticket.sh:60-62 @ 94d2e36` "case "$HOLDER" in \*"($CLAUDE_CODE_SESSION_ID)") ;; \*) STAKED=1 ;; esac": `STAKED` is set only after `lease.sh stake` returns. A SIGTERM that lands while the stake runs (the larger part of a claim's ~1 s) is held by bash until the child finishes, so the stake lands, then the EXIT trap runs with `STAKED` empty and releases nothing. Measured on a fixture board, TERM sent to the claim at 0.40 to 0.90 s (10 offsets): 10 of 10 exited 143 with the ticket in Frontier, `claimed` live for 30 min, the timer alive and the memory file present, and no Claimed comment. Only the 1.0 s offset hit the release path. TERM to the whole process group left `claimed` live with no timer and no memory. The timer then renews for as long as `CLAUDE_PID` lives. Every other session's claim of the top Frontier ticket is refused (`lease.sh stake exit 1`), and `frontier.sh` still lists it first. The header (line 9, "any other abort: exit 1, the lease just staked released") and the body ("a later step aborts, release the lease it just staked") say otherwise. The same session can recover it by running the claim again, which was measured. Fix: set `STAKED` before the stake call unless `HOLDER` is this session. Then the trap's release cleans up whatever the stake left. A refused stake makes release refuse harmlessly (another session's lease: exit 1; lost: exit 3), so quiet that message when the stake did not land. Add a smoke case that aborts after the stake (see Note 2).

**Questions for the lead**

1. A Frontier or Working ticket whose lease has lapsed (from a dead session) now blocks `resolve-ticket.sh`, `--to out-of-scope` included, until someone stakes it. That stake waits out the 2-minute notice. I read this as right under [the takeover ADR](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b): the notice protects a holder whose lease only looks lapsed. `writes.md` § Lease says `never-held` is "not blocked", though, and the fixer's split goes further for resolve. Confirm that this is intended, and say whether `tickets.md` should state it.

**Notes**

1. `skills/plan/scripts/claim-ticket.sh @ 94d2e36` "trap cleanup EXIT": SIGKILL (uncatchable) during or after the stake strands the ticket the same way. Even with the fix, the only recovery is the same session claiming again, or `lease.sh release` by hand. Nothing in `sessions.md` Work step 2 says what to do when a claim refuses a held Frontier ticket (take the next one?).
2. `tests/smoke.sh @ 94d2e36` (new plan block): no case aborts a claim after its stake. A mutant with the trap's release removed (`if false; then` in `cleanup`) passed all 225. A mutant that keeps `claimed` on the restamp (`restamp … "$STAGE/index.md"` with no `claimed`) also passed all 225. In that mutant the later `lease.sh release` clears `claimed` in a second write, so smoke cannot see the body's "same write as the move" requirement. A check that the resolve made exactly one write (for example, that `modified` matches the resolve's own stamp and no release stamp follows) would catch it.
3. `tests/smoke.sh:2356 @ 94d2e36` "kill "$TP"; waitfor": under 4 parallel smoke runs, one run failed here with `kill: (48211) - No such process`. The timer was already gone. Reasoned cause: `lease.sh` `ensure_timer` starts the timer before `mem_save` writes its pid. With `LEASE_TEST_POLL=0.2`, a timer on a loaded machine reads `pid=` empty at its first poll and exits (`[ "$M_PID" = "$$" ] || exit 0`). At the real 60 s poll this is harmless. P6 turns it into a flake: use `kill "$TP" 2>/dev/null || true`. The lanework card should get the pid-before-start ordering.
4. `skills/plan/references/tickets.md:29 @ 94d2e36` "or a session with no `CLAUDE_CODE_SESSION_ID`": the claim also refuses with no `CLAUDE_PID`, as the script does.
5. `skills/plan/references/tickets.md:50 @ 94d2e36` "Working: the claiming session only.": after a takeover, the holder is not the claiming session. Make it "the lease's holder only".
6. `skills/plan/references/tickets.md` § Resolve: the fixer's split (another session's live or lapsed lease → exit 1, "stake it first") appears only in the script header. The prose says only "the lease released in that write".
7. `skills/lanework/scripts/lease.sh:84-85 @ 94d2e36` "f=$(find_card) … mv "$stage/index.md" "$f"" (reasoned, not measured, and outside this card): a timer renewal that builds its staged copy just before `resolve-ticket.sh`'s move and moves it just after will land the pre-resolve file, with `claimed` and without the Resolution, on the Resolved path. The window is one renewal every 15 min. This is for the lanework lease card, not this branch.

**Checked**

- **Correctness vs done-when**: every case was measured on fixture boards under mktemp, with branch scripts extracted by `git archive plan-lease`:
  - Claim with a uuid session id: Working, `claimed` as a 3-line block with `by.session` set to the env id, `until` +30 min, order 1024, `modified` restamped with the `--session` label, one Claimed comment, timer alive and following the card into Working, memory present, board validates.
  - Resolve with block `waiting`: Resolved, no `claimed`, no `waiting`, one `modified`, timer gone, memory gone, 0 Lease lost records.
  - Refusals write nothing (board checksum unchanged): no session id, no `CLAUDE_PID`, a session id with a space or a slash (stake exit 2 → claim exit 1), another session's live lease (holder on stderr), a ticket not in Frontier.
  - Abort after the stake via a failing `uuidgen` shim: a fresh stake is released; a lease held before the claim is kept (`claimed` present, same timer pid).
  - Lost lease on resolve: exit 1, the card byte for byte, one Lease lost record. Another session's live or lapsed lease: exit 1, board unchanged. A voided lease resolves, per the clock guard. No session id with another's lease: exit 1.
  - Subagent (same id, no `CLAUDE_PID`, `--name researcher`): resolves and releases, timer gone, 0 lost records. Out-of-scope from Frontier with a hand-staked lease releases. An own lapsed lease (timer dead) is renewed by the check, then resolved, then released.
  - An unblocked dependent keeps its 3-line `claimed` byte for byte. HITL `lease.sh release` keeps `waiting` and drops `claimed`.
- **Claim race**: two sessions with uuid ids, 20 reps simultaneous (stake wait 0.3 s), plus 20 reps with a random 0–0.8 s stagger (stake wait 1 s). 40 of 40: one exit 0 and one exit 1, the card in one lane (Working), `claimed` names the winner, one Claimed comment, 0 Lease lost records, the loser left no memory and no timer.
- **Existing behaviour**: the same sequence (claim with `--session`/`--name`, resolve with unblock, out-of-scope from Working and from Frontier) was run with main's and the branch's scripts. Stdout was identical and every `index.md` was identical once uuids and timestamps were normalised.
- **Missing `lease.sh`**: claim exit 1, nothing written; resolve notes and resolves. `plan` without `lanework` fails at `lib.sh`, as the brief expected.
- **Project conduct**: no CHANGELOG, `plugin.json`, `skills/lanework/` or `skills/work/` change (`git diff --stat` empty); `frontier.sh` and the templates untouched; no guide version in the diff; citations in `<skill>/<dir>/<file>` form; telegraphic prose. The lead's ruling (holder = env id, `--session` a label) is followed and stated in the header.
- **Both paths**: Frontier and Working resolves, flow and block `claimed`, the held, lost and never-held splits. The signal path is blocking finding 1.
- **Fail-before**: FIXER RUN checked (8 of 8 fail on `f3f0c75` with the card's observables). OWN RUN through mutation instead of a merge-base checkout. On copies of the branch: skip the stake (caught by the script's own pre-move check, smoke stops); stake after the move (caught, "claim did not restamp modified"); staged copy before the stake (caught, the later resolve finds the lease lost); resolve without the check (caught, P5); list-held treated as resolvable (caught by P6 on a rerun, after its first run hit the Note 3 flake); skip the final release (caught, P5). Not caught: drop the trap release, and keep `claimed` on the restamp (Note 2).
- **Test adequacy**: cases P1–P8 sit beside the lease block and use its helpers (`standin`, `setclaim`, `waitfor`). The existing plan cases now run as session `S-plan` and still assert what they did. `T3` is released before the board-empty check.
- **Blast radius**: 8 files, as the START's scope named. README § Sizes rows match `wc -w` (467, 344, 416, 555; total 2,794).
- **Population**: smoke `225 passed`, 216 on main plus 9 new. The new block ran green 3 times (the official run and 2 parallel-load runs of the trap-only mutant); 1 of 4 parallel runs hit the Note 3 flake.
- **Smoke**: one full run in the fixer's worktree at `94d2e36`, own last line `smoke: 225 passed`.

**Hypotheses**, written before reading the [FAIL-BEFORE](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5) and the closing records. 4 of 9 held.

1. A signal during the stake strands a staked Frontier ticket, because the trap flag is set after the stake. Held (Blocking 1).
2. The pre-move `check` renews and the staged copy overwrites it. Refuted: seconds after a stake the lease is live, so `check` writes nothing (reasoned from `own_held`).
3. A timer renewal racing the resolve's move clobbers the Resolution. Reasoned only, in `lease.sh` (Note 7).
4. The claim race gives two winners. Refuted at 40 reps.
5. A lapsed lease of a dead session blocks out-of-scope. Held as behaviour, judged right (Question 1).
6. The new `PSP` EXIT trap in smoke drops an earlier one. Refuted: no earlier trap.
7. An own lapsed lease makes resolve fail. Refuted: it is renewed, then resolved, then released.
8. Smoke cannot tell a one-write drop from release's clear. Held (Note 2).
9. The trap release is untested. Held (Note 2).
