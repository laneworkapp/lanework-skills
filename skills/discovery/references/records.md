# Records

Written at each round's close, from its rulings. Never ahead of a ruling; never batched to the end.

## Glossary: `CONTEXT.md`

- Repo root. `CONTEXT-MAP.md` exists → the topic's context's `CONTEXT.md`. Create on first pinned term.
- Shape: `templates/glossary.md`. Definitions say what a thing **is**, 1–2 sentences.
- Glossary only: no implementation, spec or notes. Project terms only, not general programming.
- Opinionated: one word per concept, the rest under `_Avoid_`. Subheadings only when clusters form on their own.
- Owner uses a term differently, or two words for one thing → next round asks, proposing the canonical term.

## ADR vs PDR

| record | folder | settles | e.g. |
|---|---|---|---|
| ADR | `docs/adr/` | how it's built | shape, boundaries, integration patterns, lock-in tech, data ownership, deviations from the obvious technical path, constraints invisible in code |
| PDR | `docs/pdr/` | what the product does, for whom | target users, scope + non-goals, behavior + user-facing rules, trade-offs, packaging, success criteria |

- Test: engineer asks "why built like this?" → ADR. User or stakeholder asks "why does it do this?" → PDR.
- Both in one ruling → one each, linked under Related.

## Bar

Write a record only when **all three** hold:

1. **Hard to reverse**: code, data, contracts, habits or promises.
2. **Surprising without context**: a future reader would ask why.
3. **Real trade-off**: genuine alternatives, one chosen for reasons.

Else the Settled card is the record. Explicit no's qualify: a non-goal that will be proposed again is prime PDR material.

## Format

- `templates/record.md`. Optional sections only when they earn it.
- Name `NNNN-slug.md`: highest number in the folder + 1. ADR and PDR numbered independently. Folder created with its first record.
- `status`: `proposed | accepted | deprecated | superseded by ADR-NNNN | PDR-NNNN`. From a ruling → `accepted`.
- Settled card links each record under its ruling (`templates/ruling.md`).

## Superseding

Never edit a record to say something new. New record + old `status: superseded by …` + old linked under the new one's Related. The overturning ruling is a new card linking the old.

## Existing corpus

Project has `DESIGN/`, `SCHEMA.md`, a README terminology section, or its own decision log → write changes there too, in its conventions; the Settled card names the file. Own decision log → write ADRs/PDRs there, not a second log.
