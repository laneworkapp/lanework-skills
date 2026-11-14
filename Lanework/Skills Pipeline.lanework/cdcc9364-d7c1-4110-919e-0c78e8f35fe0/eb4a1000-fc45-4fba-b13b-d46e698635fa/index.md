---
schema: 1
kind: card
title: "work: card-writing scripts check the lease, and START shrinks to a short plan"
order: 4096
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Make the `work` skill honor the card lease: its card-writing scripts check the lease before they write, a worker stakes before starting and releases in its closing write, and the START comment shrinks to a short plan that is no longer a claim.

## Files

- `skills/work/scripts/post-comment.sh`: call the lease check first. A lease lapsed and still the caller's is renewed and its timer restarted; another session's `by` stops the write and posts the "lease lost" record.
- `skills/work/references/companions.md`: a START comment stops being a claim; the lease is. Point at `lanework/references/writes.md`.
- `skills/work/references/fixer.md`, `lead.md`, `templates/farmed-prompt.md`: stake before START, release in the closing write. A farmed prompt names the lease its session holds and tells the subagent not to stake.
- `skills/work/references/writing.md`: START's shape: `START: <the plan in one line>`, then at most Scope, Verify and Where, about 40 words. Decisions go to their own records.
- `skills/work/references/sweep.md`: the triage report lists held cards and flags a lapsed lease.
- `tests/smoke.sh`: cases for the check in `post-comment.sh`.

## Verified

- `tests/smoke.sh` passes, with new cases: `post-comment.sh` on a card the caller holds writes; on a card whose lease carries another session's `by` it writes only the "lease lost" record; on a card with no lease, or one the caller never held, it writes as today.
- Prose read through against the board guide: each rule stated once, the rest link.

## Done when

The files above carry the change, no file still calls a START a claim, and smoke is green.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- [Work skill: ship move-card, post-ask and commit-board helpers](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f): `move-card.sh` and `post-ask.sh` gain the same check when they exist.

## Source

- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
- [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
