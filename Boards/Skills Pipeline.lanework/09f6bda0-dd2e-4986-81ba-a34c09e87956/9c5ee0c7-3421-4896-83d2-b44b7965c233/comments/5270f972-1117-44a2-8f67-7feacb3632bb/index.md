---
schema: 1
kind: comment
in-reply-to: 1c866317-3ac0-49c0-9dfd-d160f8307685
created:  {at: 2026-11-17T21:46:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Lead's ruling on review round 1: the stake moves to after the session knows the card is its work, and a staked card it then does not work is released. Five notes are fixed with it.**

- **Blocking 1, fix**: `responding.md` § A move into an agent lane reads the card and its lane body first. Only when this card is the one to work does the session stake it, immediately before the first write or hand-off. A session that staked a card and then does not work it (the lane body points elsewhere, the card is waiting, a refusal follows) releases it at once. `events.md` item 5 says the same in its few words. The body's "stake-first" meant before working, not before reading; the ruling it cites is that the session holds the lease while it works.
- **Question 1, accepted**: a card worked under a START alone reads as free once this ships. The body names that risk and gives the release note as its cover. Cards this session has in Active at release are staked then.
- **Fix with it**:
  - note 2: the `arm` wording says "no lease (none, or voided by the clock guard)", and an owner's move of a card with a lapsed lease is the owner asking: the stake takes it over as `lanework/references/writes.md` § Lease says.
  - note 3: the two cites in `responding.md` take the repo's cross-skill form.
  - note 4: `arming.md` § stop: the session's leases outlive the watch; a card the session drops at stop is released. One clause, linked.
  - note 5: smoke pins the uuid join with two cards sharing a title, one leased.
  - note 6: `arm-pass.sh` passes the stderr of a failed `list` through.
- **No change**: notes 7 and 8, both as on main and on boards that are already malformed.
- **Note 1**: the Active lane body in the pipeline template is outside this card. It is checked against [the Active-lane sentence card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/84bb7548-cb2d-4c8f-a052-3d1f6a170598) when that card is built, and filed if that card does not cover it.
- **Next**: the same fixer, then the same reviewer.
