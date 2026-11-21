---
schema: 1
title: "Credit Matt Pocock for the ideas the skills draw on"
order: 6144
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created: {at: 2026-11-21T13:16:55Z}
modified: {at: 2026-11-21T13:19:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
kind: card
---
This card rewrites the README's credit to Matt Pocock as a general thank-you for inspiration, with a link to his skills, in place of the present list of specific skills.

Owner's request, as filed: "i'd like to add a credit to matt pockock about using ideas/inspiration from his skills".

**Ruled 2026-11-21** (owner, on the card): "dont be specific on which skills we drew from, there was more than one and it was more of an inspiration than specific lifts."

## What exists

`README.md` § Credits, on `main` and in v0.9.0, is specific. It says the interview protocol in `discovery` is adapted from his `grilling` and `domain-modeling` skills, and that `plan` is adapted from his `wayfinder` skill. It has no link.

## Change

`README.md` § Credits: replace both paragraphs with one, along these lines:

> Several of these skills were inspired by [Matt Pocock's skills](https://github.com/mattpocock/skills). The ideas were reworked to run on a Lanework board.

- No skill of his and no skill of ours is named.
- The link was checked on 2026-11-21: `gh repo view mattpocock/skills` returns that URL, MIT licensed.
- Nothing under `skills/` changes, and no credit is added to the docs site or the marketplace listing: the ruling asked for neither.
- `CHANGELOG.md`: no entry. A credit is not a behavior change.

## Verified

- `tests/check-refs.sh` and `tests/check-sizes.sh` pass. The § Sizes table is the only part of the README they count, and it is untouched.
- The link opens.

## Done when

- `grep -n -i 'grilling\|domain-modeling\|wayfinder' README.md` finds nothing.
- § Credits holds one paragraph that names Matt Pocock, links `https://github.com/mattpocock/skills` and names no specific skill.

## Risks

- The new wording says "inspired by" where the old said "adapted from". If any text was in fact copied from his skills, the MIT terms ask for his copyright notice to travel with it, and a general credit would not cover that. The ruling says there were no specific lifts, so the proposal takes that as settled.
- The README on `stable` changes only with the next release.

## Recommendation

Build as written. It is one paragraph in one file.
