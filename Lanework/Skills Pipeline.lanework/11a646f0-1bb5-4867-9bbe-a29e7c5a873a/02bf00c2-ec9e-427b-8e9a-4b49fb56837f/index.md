---
schema: 1
kind: card
title: "A card parked on an owner action carries no waiting mark"
order: 2048
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T03:59:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T03:59:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
When a card waits on something only the owner can do (run a trial, cut a release), the skills let the agent say so in a record, so the card waits on the owner with no `waiting` mark and no count in the lane header.

## Reproduce

All three Active cards on this board on 2026-11-14: each one's last ask was answered and cleared by the app, then a record said "the trial stays with the owner" or "stays in Active until the release". No ask followed, so none showed as waiting.

## Change

- `work/references/writing.md` § When to ask: extend the open-call rule to an **owner action** (something only the owner can do that a card's next step waits on). It becomes an imperative ask with `waiting`, never only a record. Extends [the open-choice card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/22a077d3-d47c-498f-98b2-4f33f82e89d2); no new section.
- `work/references/sweep.md` § 2: the "Active, stalled" row splits off "waiting on an owner action, no `waiting`" → post the ask, then report.

## Verified

`tests/smoke.sh` passes. Each rule is stated once, in `writing.md`, and `sweep.md` links to it.

## Done when

Both files carry the change, nothing restates it, and smoke is green.
