---
schema: 1
kind: comment
in-reply-to: 09e224b5-0f07-40ae-a229-d0f3ae54db19
created:  {at: 2026-11-17T18:32:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Lead's ruling on review round 1: the lease-memory fix lands on this branch, with five smaller fixes; one note goes to an issue.**

- **Blocking 1, fix here**: the lease's memory is keyed by the board as well as the card, so a card with the same uuid on another copy of the board (an agent worktree's checkout of `Boards/`, a fixture copied from a live board) is a card this session never held. It applies to `check`, `stake`, `renew` and `release`, and to the lost mark. The fix is in `lanework/scripts/lease.sh`, outside this body's Files list. It lands here because this branch is what makes every card write reach it, and no lease card is open to carry it. Smoke: a session holding a card on board A writes to a copy of A; the copy's write passes as never held, and the lease on A stays held with its timer alive.
- **Question 2, yes**: `post-ask.sh` passes exit 3 through on a lost lease, so a loser stops. Its header and the farmed prompt name it.
- **Fix with it**:
  - note 2: smoke asserts the comment lands before the release, and that `--release` on a free card and on another session's card releases nothing.
  - note 3: `lead.md` says that after a failed release the lead runs `lease.sh release` and never reposts.
  - note 4, in part: when `lanework/scripts/lease.sh` is missing beside `work`, the scripts skip the check with a note on stderr and write as today. Any other unexpected result still writes nothing.
  - note 5: the farmed prompt's no-lease line reads "none: the session holds no lease; writes pass as today".
  - note 6: `lead.md` links `lanework/references/writes.md` § Lease for a refused or blocking `stake`; nothing restated.
- **To an issue**: note 1, a timer renewal overwriting a concurrent card write (`waiting` came back in 2 of 20 runs at test timing). It is in the lease script's unlocked write and touches every writer of a card.
- **Next**: the same fixer, then the same reviewer.
