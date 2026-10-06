---
schema: 1
kind: card
title: "Skills point at the board's own guide and schema for specifics, starting with priority and component"
order: 1024
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: pitlane, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-05T22:59:48Z, by: {name: claude, kind: agent, model: opus-5.5, session: "Lanework Labels"}}
modified: {at: 2026-10-06T22:37:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The skills restate format rules that the board's own guide and schema already state, and each restatement goes stale when the app changes. Replace each one with a pointer to where the board states it, and keep only procedure and judgement in the skills.

**Owner, 2026-10-05**: "generally skills should reference hard evidence (e.g. included schema) for specifics as much as possible."

- **First, the rule now wrong**: `skills/lanework/references/writes.md:10` says priority and component are root keys, never `labels` entries. The app is retiring those keys ([the retirement card](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/3de46337-1b60-4450-be64-af6224b4cb4a)), so the line goes, with a pointer to the guide's labels section and `.schema/card.json`. `skills/pitlane/references/lead.md:27` ("the board's priority field") becomes "the card's priority, as the board's guide defines it".
- **Then an audit**: every rule under `skills/` that names a key, a value shape or a stamp is either a pointer ("the guide's § X", "`.schema/<file>.json#/…`") or is procedure the guide doesn't cover. A short "why this bites" line may stay beside a pointer.
- **Hard evidence, in order**: the board's `CLAUDE.md`, then `.schema/` and its validator, then the skills. This is already the authority chain in `authority.md`. This card makes the skills stop competing with it.
- **Touches**: `skills/lanework/references/writes.md`, `format.md`, `founding.md`, `skills/pitlane/references/lead.md`, and whatever the audit finds. `tests/smoke.sh` gains a check that no skill file names `priority:` or `component:` as a key.
- **Verify**: the audit list is attached with each line's outcome. Smoke passes. A read-through against the guide the skills target finds no rule stated in both places.
- **Done when**: no skill states a format rule without pointing at the board's guide or schema, and the priority and component claims are gone.
