---
schema: 1
kind: comment
created:  {at: 2026-10-25T02:07:00Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-25T02:07:00Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review round 2: APPROVE on `dispatch-skill` at `b525659`. All three round-1 BLOCKING findings are fixed, and each fix has a smoke case that fails on the old scripts.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (fixer ran at opus; Phase-1 UNCERTAINTY not "none")
ROUND:   2

CARD:   Active/f36f6a5d "Dispatch skill: a flat-context watch session"
BRANCH: dispatch-skill at b525659 (round 1 reviewed 84bdef4 = ed2af9c after the rebase onto f5c8937)

BLOCKING: 0
  B1 closed. state.sh:54 @ b525659 "# a relayed event too: the follow-up answers what the lead did not"
     queues the event before it prints relay. handler.md § Relayed events tells the lead to answer, and the
     handler prompt names that section. Repro: claim under a lead -> "relay agent-9", then finish -> prints
     "comment owner line", and the card stays in flight for the follow-up.
  B2 closed. classify-event.sh @ b525659 "[ \"$w\" = owner ] || [ $(( ... )) -gt \"$FRESH\" ] || who=$w":
     self and agent stamps are now both gated by age. Repro: a stale handler stamp, then a bare mv ->
     "move Approved owner". A fresh handler move -> "self Approved agent".
  B3 closed. classify-event.sh @ b525659 "then moved=1; out move \"$w\"": a card whose index.md is in the
     burst, created within FRESH -> move, with the author read from created.by.
     Repro: a new owner card in Approved -> "move Approved owner". An old card's body edit -> "body". A card
     a handler filed -> "self".

NOTES: 3
  - classify-event.sh @ b525659 created-in-place branch: an owner edit to a card's body within MOVE_FRESH
    of its creation classes as a second move. Harmless: the claim queues it, or the handler finds the claim
    and no-ops.
  - B1's backstop costs one follow-up sonnet handler after every build that had a relayed event. The
    no-double-answer guarantee rests on the lead replying in-reply-to, which is what responding.md asks.
  - Round-1 NOTEs the lead didn't pick (by: {}, fractional-second epochs, title quoting, arming cost,
    title-based agent lanes, git push races, stale .lock, the f4c8385 tail) stand as filed.

CHECKED:
  correctness vs done-when: reran the B1–B3 repros on a throwaway board ("Real Pipe.lanework") with the new
                            scripts, plus a control for each (above). The done-when items outside the
                            trial hold.
  project conduct:          prose telegraphic; the events.md citation is now consistent (routing.md:
                            items 1–2 are the classifier's, 3–7 the handler's; handler.md: 3–7). README
                            sizes updated, check-sizes green. No new cited files.
  both paths:               a card reaching an agent lane: moved and created in place, both handled. An owner
                            event on an idle vs a lead-held card: both handled.
  fail-before:              OWN RUN agreed with 407ad6a6. The new smoke block fails against the ed2af9c
                            scripts at "a relayed event was not queued for the follow-up". With the new
                            state.sh and the old classifier, it fails at "want 'move ...0b Approved owner',
                            got 'self ...0b Approved agent'". With only the new-card branch removed, it fails
                            at "want 'move ...0d Approved owner', got 'body ...0d Approved owner'".
  test adequacy:            the round-1 survivors are all killed now: grouping, title column and self-move.
                            So are 5 mutants aimed at the new code: the stale-self gate, the new-card branch,
                            the new-card FRESH check, relay queueing and the paths column. 8/8.
  blast radius:             ed2af9c..b525659 touches only dispatch scripts and references, the handler
                            prompt, smoke and README sizes. That matches the findings and the two picked
                            NOTEs.
  population:               smoke 117 passed (114 + 3 new ok lines); check-sizes 62 rows, 0 wrong.
  adversarial only:         round-2 hypotheses: the new-card branch misfires on edits (only within FRESH,
                            NOTE); the age gate breaks fresh self moves (refuted, still self); relay double
                            answers (bounded by the in-reply-to rule, NOTE).

UNRESOLVED: none
```

My run of `tests/smoke.sh` in the fixer worktree at `b525659` exited 0: "check-sizes: 62 rows, 0 wrong", "smoke: 117 passed".
