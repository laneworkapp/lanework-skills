---
schema: 1
title: "Credit Matt Pocock for the ideas the skills draw on"
order: 8192
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created: {at: 2026-11-21T13:16:55Z}
modified: {at: 2026-11-21T13:17:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
kind: card
---
This card makes the credit to Matt Pocock, whose skills several Lanework skills are adapted from, easier to find and complete.

Owner's request, as filed: "i'd like to add a credit to matt pockock about using ideas/inspiration from his skills".

## What exists

`README.md` § Credits, on `main` and in v0.9.0, already says:

- The interview protocol in `discovery` and its glossary and ADR discipline are adapted from Matt Pocock's `grilling` and `domain-modeling` skills (MIT).
- `plan` is adapted from Matt Pocock's `wayfinder` skill (MIT).

The credit arrived with the commits that added those skills (`7f714be`, `8a3dd62`).

## Gaps found

- The credit names him and the skills but does not link to his repository.
- It sits at the bottom of the README only. `discovery/SKILL.md`, `plan/SKILL.md`, `plugin.json`, the marketplace listing and the docs site do not mention it.
- `LICENSE` carries only the `laneworkapp` copyright line. If any of his text was copied, as opposed to ideas reworked, the MIT terms ask for his copyright notice to travel with it. Not checked line by line.
- Other skills (`work`, `watch`, `lanework`, `merge`, `heal`) carry no credit. Whether any of them draws on his work is the owner's knowledge, not something the code shows.

## Change

Depends on the open call below. The smallest version: link his repository from § Credits (URL confirmed at build time, not from memory) and widen the wording to "ideas and inspiration" for anything beyond the three skills named.

## Files

- `README.md` § Credits. `tests/check-sizes.sh` reads only the § Sizes table, so no count changes.
- `skills/`: none, unless the open call picks the option that adds a line to a `SKILL.md`.
- `CHANGELOG.md`: no entry; a credit is not a behavior change.

## Verified

`tests/check-refs.sh` and `tests/check-sizes.sh` pass, and the link opens.

## Done when

§ Credits links his repository and names every skill the owner says draws on his work.

## Risks

- A wrong or incomplete attribution is worse than a short one, so the list of skills comes from the owner.
- A credit line inside a `SKILL.md` is read by agents on every run and costs words there.

## Recommendation

Option A in the ask: keep the credit in the README, add the link, and name any further skills the owner lists.
