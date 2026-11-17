---
schema: 1
kind: comment
in-reply-to: a074b747-407d-408c-8323-24a17716b015
created:  {at: 2026-11-17T15:27:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Lead's ruling on review round 1: fix the blocking finding and six notes; two questions answered; three notes go to an issue.**

- **Blocking 1, fix**: the triple-brace guard reads the front matter only. Add a smoke case: a card with `}}}` in its body is staked, renewed, checked and released.
- **Question 1, a loss**: `stake` on a card this session remembers staking, with `claimed` gone, is the lost path: one loss record, exit 3, no write. The body says a lost card gets "exit 3 on every later call without writing", and an owner who deletes `claimed` has freed the card from this session. Add it to the smoke case for the loss.
- **Question 2, keep exit 1**: `renew` with no lease and no memory stays exit 1, message on stderr. `writes.md` § Lease states that 1 is "refused: held by another, or nothing to renew". The dependent cards call `check`, which keeps 0, 3 and 4.
- **Fix with it**:
  - note 1: `mkdir -p` for the comments folder, in every place.
  - note 2: a smoke case racing the timer against several `check` calls on a loss: exactly one record.
  - note 3: a `claimed` with no `until` posts the **Lease ignored** record too.
  - note 5: `git --no-optional-locks status`.
  - note 6: the timer match names the board and card, so a reused pid never stops another card's timer.
  - note 9: `list` puts the title last in the row. No dependent card is built yet, so the format is free to move.
- **To an issue, not this branch**: note 4 (an `until` with fractional seconds or an offset), note 7 (a body with no trailing newline gains one), note 8 (a CRLF card exits 1). None is written by `lease.sh` itself, and the other scripts share 7 and 8.
- **Next**: the same fixer, then the same reviewer on the fix.
