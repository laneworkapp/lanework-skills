---
schema: 1
kind: comment
in-reply-to: 65ea5e3f-5b1f-4b02-aafc-81e9d9b644db
created:  {at: 2026-11-17T22:04:44Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: merged to main at `ca8863d`, smoke green. Not released.**

- **Merge**: branch `watch-lease` at `19bbaa1` (commits `478a726`, `19bbaa1`), merged with `--no-ff` as `ca8863d` and pushed.
- **Gate**: `tests/smoke.sh` on main after the merge, with the session variables unset: `smoke: 240 passed`, exit 0. Main before was 229: two old arming cases out, 13 in.
- **Review**: adversarial, two rounds. Round 1 asked for changes; round 2 approved at `19bbaa1`.
- **Done-when**:
  - `arm-pass.sh` reads leases through `lease.sh list`, prints `arm`, `held` and `stale`, and no line of it reads a START comment. Met.
  - `watch` stakes before working or handing off a work order, releases at a gate or when done, and never lets a subagent stake; nothing in `skills/watch` treats a START comment as the claim. Met.
  - The arming report lists held and lapsed cards. Met.
  - The eight smoke cases exist and smoke is green. Met, with two the body did not ask for: the join by card id, and a failed `list`.
- **Departures from the body**:
  - The stake comes after the session has read the card and knows it is the one to work, not before; a card staked and then not worked is released at once (the lead's ruling above).
  - When `lease.sh list` fails, the arming pass prints owner comments only, passes the reason through and exits 1. It arms nothing.
  - Smoke cases 5 and 7 pass on the old script too; they guard against a regression.
  - The README's watch row was reworded, since its old wording became false.
- **Left as it is**: step 1 of `responding.md` § A move says "act per the lane body" ahead of the stake in step 2; step 2's wording decides the order (the reviewer's round 2 note).
- **Open outside this card**: the Active lane body in `lanework/templates/pipeline-lanes.md` still says a comment is the claim. Checked against [the Active-lane sentence card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/84bb7548-cb2d-4c8f-a052-3d1f6a170598) next.
- **At release**: a card worked under a START alone reads as free. Cards this session has in Active then are staked.
- **CHANGELOG**, for the release commit: "The watch now treats a card lease as the claim: it stakes a card before working it, reports cards another session holds and leases that have lapsed, and no longer counts a START comment as a claim."
- **Next**: the Active-lane sentence card, then the lease trial card.
