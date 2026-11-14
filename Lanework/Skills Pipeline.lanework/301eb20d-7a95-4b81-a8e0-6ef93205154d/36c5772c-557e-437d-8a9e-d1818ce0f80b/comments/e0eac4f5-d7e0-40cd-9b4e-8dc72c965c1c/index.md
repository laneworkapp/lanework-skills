---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:58:24Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:58:24Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Decisions in the body: the lint's three findings are set as flags, none as a ruling.**

- **Lease lost wording**: one constant, `LEASE_LOST_PREFIX`, in `lanework/scripts/lib.sh`, read by both the lint and the lease script, as PDR2 requires one wording.
- **Inside one lease**: two STARTs from different sessions at most 1800 s apart (the lease length of ADR4), `--window`. Only comments carry the evidence, since release deletes `claimed`.
- **Lapsed long ago**: `until` more than 900 s past, `--grace`.
- **The 50**: cards with a START at or after `--since`, the earliest 50 by `--first`, from this repo's boards. The lint only reads, so running it on the Skills Pipeline board is the trial, not a test.
- **Contradicted in the filed card**: it said "No skill prose", but the README word counts that `check-sizes.sh` gates move with any `skills/work/SKILL.md` edit, so the body names that one sentence and the README rows.
