---
schema: 1
kind: comment
in-reply-to: 6d707c62-76b2-4a28-92c6-865e27548910
created:  {at: 2026-11-17T21:17:44Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T21:17:44Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The round-3 blocking finding is closed: a TERM during the card's own move into Working now keeps the lease. The fixer's `MOVING` departure from the ruling is right. Three notes, none blocking.

- **Stance**: adversarial, last narrow re-check of `2dd4a18..4503c85` on the lead's ruling.
- **Round**: 4 (last pass on this card)
- **Card**: [b808e18c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)
- **Branch**: `plan-lease` at `4503c85`

**Blocking**: none.

**Notes**

1. `skills/plan/scripts/claim-ticket.sh:96-97 @ 4503c85` "MOVING=1   # set before the move": a TERM after `index.md` lands and before the folder move begins leaves the ticket in Frontier with no lease. Its `order` and `modified` are restamped: `order` takes Working's next value (2048 → 3072 here), so the ticket can change place in Frontier. Measured by TERMing the process group so the `mv` dies before moving. `2dd4a18` leaves the identical state, so this is not new. It is acceptable: free, valid, in its lane.
2. `skills/plan/scripts/claim-ticket.sh:61 @ 4503c85` "if [ -n "$MOVING" ] && [ -f "$DEST/$CID/index.md" ]; then return 0; fi" (reasoned, not measured): if another hand moves the card into Working in the microseconds between `MOVING=1` and the folder `mv`, the `mv` fails. The trap then sees `MOVING` and the card in Working, and keeps this claim's stake on a card it never moved. The window is one fork. File it only if it ever shows up.
3. `tests/smoke.sh` P1: the board-only mutant's first run, beside one other smoke run, failed at P1 (`rc 0, lane Working, session 'S-pa'`), the load flake already on [the lease issue](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/653217e4-681e-44f5-b6eb-fb0d0b8490ca). Run alone, it failed at P2e as it should.

**Checked**

- **The departure**: right. With the board-only check (mutant), P2e fails: "plan claim on a card moved away: rc 1, err: … is in Working, not Frontier". The trap kept this claim's stake on a card another hand had moved into Working, the outcome `MOVING` exists to prevent.
- **Deterministic `mv` shim at `4503c85`**, with `2dd4a18` alongside:
  - TERM during the `index.md` move: Frontier, no `claimed`, no timer, no memory (same at both).
  - TERM during the card's folder move: Working, `claimed`, timer alive, memory, no Claimed comment, which the ruling allows. `2dd4a18` gave Working with no lease.
  - TERM during the comment's move: everything kept (same at both).
  - TERM before the folder move begins: Note 1.
- **Moved by another hand during the stake**: the card was moved into Working by hand during a 2 s stake wait.
  - The claim: exit 1 ("is in Working, not Frontier"), its stake released, no timer, no memory, no Claimed comment.
  - Another session's lease on a second card: card file and memory file byte for byte, timer alive, 0 Lease lost records on the board.
- **Race**: 20 reps at `4503c85`, outcomes split 14/6.
  - Every rep had one exit 0, one lane (Working), `claimed` naming the winner, one Claimed comment and 0 Lease lost records.
  - The winner had one detached timer and its memory. The loser had none of either and no "by hand" line.
- **A claim that completes**: Working, `claimed`, Claimed comment, timer alive.
- **Smoke cases vs reverted fixes**, each run on a copy:
  - Board-only trap fails P2e (run alone; Note 3 for the first run).
  - Flag set after the move fails P2c's move hold: "plan claim ended at the move: rc 143, lane Working, session ''".
- **Shims**: both live in smoke's `$T/plan-shim` and reach only P2c's two claims through `env PATH=…`. They act only on the named card folder or a `/comments` target with their variable set. The timer those claims start inherits them but only uses `mv`/`mkdir` on other paths or on a loss, and each P2c claim is released in the case.
- **Diff scope**: only `skills/plan/scripts/claim-ticket.sh` and `tests/smoke.sh`.
- **Smoke**: one full run in the fixer's worktree at `4503c85`, own last line `smoke: 229 passed`.
