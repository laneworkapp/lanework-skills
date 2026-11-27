---
schema: 1
kind: card
title: "Starting a card stakes its lease in one step; a missing lease is reported"
order: 8192
created:  {at: 2026-11-27T05:03:29Z, by: {name: claude, kind: agent, model: fable-5.2, session: "Lanework Pitwall"}}
modified: {at: 2026-11-27T12:38:14Z}
---
## Goal

A session that starts building a card cannot forget to stake its lease, and a card being built with no lease is reported.

## What happened

A watch session built eight Active cards on the app's pipeline board with no lease on any of them. The owner saw it on the board.

- The guides do say to stake: `watch/references/responding.md` ("Stake only the card to work, immediately before the first write or hand-off") and `work/references/lead.md` ("Stake each card before the fixer gets its worktree").
- The session started cards with its own helper script, which moved the card, posted the start record, committed and made the worktree, and never called `lease.sh stake`. Only the one card it started by hand was staked.
- Nothing mechanical noticed. `move-card.sh` into Active passes on `never-held`. `lease.sh release` on a never-held card fails quietly at close. `lint-leases.sh` looks for collisions and lapsed leases, not for a missing one.

So the rule is written down and depends on the agent remembering a separate step. The plan skill does not have this gap: `claim-ticket.sh` stakes and moves in one script.

## Proposed

1. **`work/scripts/start-card.sh`**: one script for a work order. Stakes the lease, moves the card into the board's working lane, posts the START record. Refuses a held card as `claim-ticket.sh` does. The lead guide and the watch's responding guide name it as the way to start a card, in place of three separate steps.
2. **A missing-lease finding**: `lint-leases.sh` (and the watch's arming pass) reports a card in an agent working lane whose latest START record is from a session and which carries no `claimed`. One line per card.
3. **A note at the move**: `move-card.sh` into an agent working lane, with a session id set and the card `never-held`, prints one line on stderr saying the card is unstaked. It still moves.

## Done when

- Starting a card through the skill leaves it leased with no separate step.
- The lint reports the eight-card case above and stays silent on a staked board and on a card at a gate.
- The guides name the one script; the tests for the three scripts cover held, never-held and lost.

## Open

- Whether item 3 should refuse instead of note. Proposed: note only, since replies and lane exits by a session that holds nothing must keep working.
