---
schema: 1
kind: card
title: "The card lease, a shared claim on a card"
order: 1024
icon: {glyph: scope}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:50:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
cite-as: Topic
---
A card lease is a `claimed: {by, until}` key in a card's frontmatter that marks the card as taken until the time it names. This board works out how agents stake, keep, lose and take over a lease, so that two agents never work one card and a card whose agent died gets picked up again. It follows the owner's ruling on [Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1) and a chat on 2026-11-13, where the owner asked for the problem in small pieces: "i dont necessarily want to overengineer it so lets be smart about how far we take it."

## A shared understanding covers

- Problem: what a START comment and a lane move fail at as claims.
- People: how the owner sees a lease and frees one by hand.
- Domain: holder, lease, expiry, renewal, takeover, one word each.
- Scope: one machine or several, and which skills honor the lease.
- Behavior: staking, renewing, finding a lease lost, taking over, releasing.
- Constraints: cooperative only, honored by agents and enforced by nothing.
- Architecture: where the mechanism lives and what writes the key.
- Integrations: the app with a card open, git, the `merge` skill.
- Data: what a lease change writes, stamps and commits.
- Risks: a slow holder taken for dead, a lost renewal, a wrong clock.
- Success: how the lease is judged to work.

## Out of scope

- The runner's other open questions: they stay on Board Runner Discovery.
- Building anything: no work card is filed until the owner confirms the understanding.

## Sources read

- [Q6 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/4b0d0f8b-37d5-492d-8761-66cab79edbd1) and [its ADR](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/a16b166b-23a8-4f32-89bc-34f551f24701): the lease is `claimed: {by, until}`, honored by interactive sessions too.
- [Q14 of Board Runner Discovery](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/fd22121a-ccca-4970-b172-f7288d7272e3), still open there: lease length and expiry. This board takes that question up.
- `CONTEXT.md`: Runner, Job and Lease are pinned terms.
- `skills/work/references/companions.md`: a START comment is today's claim.
- `skills/dispatch/`: the stale-claim report, the in-flight state.
- `skills/plan/scripts/claim-ticket.sh`: a lane move as a claim.
- This board's guide, v117: unknown keys, stamps, `waiting`.
