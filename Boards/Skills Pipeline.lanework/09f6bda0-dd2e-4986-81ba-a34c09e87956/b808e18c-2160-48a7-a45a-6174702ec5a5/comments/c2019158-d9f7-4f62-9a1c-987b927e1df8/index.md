---
schema: 1
kind: comment
in-reply-to: 168694d9-9a44-4a83-a00b-75086617e8db
created:  {at: 2026-11-17T20:05:47Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T20:05:47Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Round 1 fixed: a claim ended during its stake now releases what the stake left; `smoke: 226 passed` (225 + 1), pushed `plan-lease` at `a092a90`.**

- **Blocking 1**: `STAKED` is set before `lease.sh stake`, unless this session held the card already. The trap's release is quiet on exit 1 or 3 (a stake that never landed: another session's lease, or a lost one), and the claim's exit code is unchanged.
- **Measured, release against another's lease**: P2 now runs that release on every refused claim. The board is byte for byte (comments included) and stderr has no release note. The P3 race loser posts 0 Lease lost records.
- **New case P2b**: TERM sent to the claim during a 3 s stake wait. Ticket stays in Frontier, no `claimed`, no timer, no memory, no Claimed comment. On `94d2e36`: `plan claim TERM during the stake: rc 143, lane Frontier, session 'S-pterm'`.
- **Note 2**: P5 resolves with `--session R-label` and requires the card's last `modified` to carry it. Mutant keeping `claimed` on the restamp: fails P5 (`modified … session: "S-pa"`). Mutant `if false` in the trap: fails P2b. Each was run on a copy of the skills, over the plan block.
- **Note 3**: P6's `kill` of the timer tolerates one already gone.
- **Prose**: `tickets.md` names `CLAUDE_PID`, says "the lease's holder only", and § Resolve says to stake first over another session's lease. `sessions.md` step 2: a claim refused on a held ticket → take the next one. README § Sizes: plan 2,843.
- **Accepted limitation**: SIGKILL still strands the stake; the same session's next claim recovers it.
- **Attached**: `plan-lease-smoke-round2.log`.
