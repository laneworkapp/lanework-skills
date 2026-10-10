# Records

Written from rulings, never ahead of one, never batched to the end. ADR/PDR cards: filed when the answer is taken, before the question is settled (§ Format). Glossary: at the round's close.

## Glossary: `CONTEXT.md`

- Repo root. `CONTEXT-MAP.md` exists → the topic's context's `CONTEXT.md`. Create on first pinned term.
- Shape: `templates/glossary.md`. Definitions say what a thing **is**, 1–2 sentences.
- Glossary only: no implementation, spec or notes. Project terms only, not general programming.
- Opinionated: one word per concept, the rest under `_Avoid_`. Subheadings only when clusters form on their own.
- Owner uses a term differently, or two words for one thing → next round asks, proposing the canonical term.

## ADR vs PDR

| record | label | settles | e.g. |
|---|---|---|---|
| ADR | `Record: ADR` | how it's built | shape, boundaries, integration patterns, lock-in tech, data ownership, deviations from the obvious technical path, constraints invisible in code |
| PDR | `Record: PDR` | what the product does, for whom | target users, scope + non-goals, behavior + user-facing rules, trade-offs, packaging, success criteria |

- Test: engineer asks "why built like this?" → ADR. User or stakeholder asks "why does it do this?" → PDR.
- Both in one ruling → one each, linked under Related.

## Bar

Write a record only when **all three** hold:

1. **Hard to reverse**: code, data, contracts, habits or promises.
2. **Surprising without context**: a future reader would ask why.
3. **Real trade-off**: genuine alternatives, one chosen for reasons.

Else the Settled card is the record. Explicit no's qualify: a non-goal that will be proposed again is prime PDR material.

## Format

- A record is a card in the **Decisions** lane (`templates/lanes.md`), not a file. `scripts/file-record.sh` files it: `templates/record.md` shape, title `ADR: <title>` / `PDR: <title>`, line 1 links the question (still in Asked when filed), labels `Record` (ADR/PDR) + `Status`. Optional sections only when they earn it.
- Order: answer taken → file the record (question still in Asked) → put its link in the ruling → `settle-question.sh`. A Settled card is never edited, so a record filed after settling cannot be linked from its ruling. The ruling links the card (`templates/ruling.md`); the card links the question. No numbers: links identify.
- `Status`: `accepted | deprecated | superseded`. From a ruling → `accepted`. No `proposed`: a record is only written from a ruling.
- Status or label change = picker-style rewrite of the one `labels` entry (kind `status`, flattened per the guide), never a body edit.

## Superseding

Never edit a record's body to say something new. New card + old card gets status `superseded` + a dated comment linking its replacement + old linked under the new one's Related. The overturning ruling is a new question card linking the old.

## Existing corpus

Project has `DESIGN/`, `SCHEMA.md`, a README terminology section, or its own decision log → write changes there too, in its conventions; the Settled card names the file. Own decision log → write ADRs/PDRs there, not a second log. A `docs/adr/` or `docs/pdr/` of discovery's own old `NNNN-slug.md` files is not such a log: new records go to the lane. Old files are not migrated; a record superseding one links the file.
