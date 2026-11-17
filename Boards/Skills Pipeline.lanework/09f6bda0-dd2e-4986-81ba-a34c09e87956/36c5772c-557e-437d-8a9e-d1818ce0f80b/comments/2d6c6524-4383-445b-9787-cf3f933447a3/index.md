---
schema: 1
kind: comment
in-reply-to: be20ed05-09f7-44c7-8738-1a23f46c8ac9
created:  {at: 2026-11-17T23:21:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**The lint is on main at `ef2df55`, smoke green. Not released. The card stays in Active until the trial.**

- **Merge**: branch `lint-leases` at `ff974a8` (commits `d92abcc`, `3e4cf59`, `ff974a8`), merged as `c0cb470` and `ef2df55`, pushed.
- **Gate**: `tests/smoke.sh` on main, session variables unset: `smoke: 250 passed`, exit 0. Main before was 241.
- **A red run first**: smoke on `c0cb470` failed one new case. Its fixture times came from separate clock reads and one pair landed 101 s apart, not 100. The lint was right. `ff974a8` takes every time of a case from one read; the lint block then passed 30 of 30 runs. The lead read that diff (`tests/smoke.sh` only) in place of a third review round.
- **Review**: adversarial, two rounds, approved at `3e4cf59`.
- **Done-when so far**: smoke passes with cases 1 to 7, and `check-sizes.sh` passes. Met. The quoted run over the first 50 leased cards is open: no card can be leased on a live board before the release.
- **Read-only run on this repo's three boards, not the trial**: `lint-leases.sh Boards/*.lanework` printed nothing, exit 0, `leased cards: 46, lease lost: 0, two STARTs: 0, lapsed: 0`. The 46 are cards with a START from before leases existed, which is why the trial passes `--since`.
- **Two limits of the spec**, built as the body says, for the owner (the ask below):
  - **Sessions are told apart by stamp label.** No START carries the id that holds the lease. Of 69 STARTs on these boards, 28 carry one label and 25 carry none, so two sessions sharing a label never show as two STARTs, and a lead and fixer with different labels would show as a false one. A real collision still leaves a lease-lost record, which the lint counts.
  - **Lapsed is read from leases still standing.** A dead session's card that another session took over carries a takeover record in its thread, and the lint does not count it.
- **Filed**: [the two lint blind spots](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/6e271bfc-6f99-4a3c-aa1d-502c3a8bc960), from the review's notes.
- **Trial command, once 50 cards are leased**: `skills/work/scripts/lint-leases.sh Boards/*.lanework --since <first stake> --first 50`.
