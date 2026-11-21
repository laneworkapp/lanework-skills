---
schema: 1
kind: comment
created:  {at: 2026-11-21T01:04:34Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `111ba99` (branch `citation-leftovers`, head `1db82ef`, two rounds), pushed. Not released.

**What changed**

- `stamp_cite` (`lanework/scripts/lib.sh`) refuses an empty prefix and checks that the citation was really stamped; a failure leaves nothing written.
- `file-question.sh` and `file-ticket.sh` count a zero-padded number (`Q08`, `Q010`) as decimal, so the next number no longer collides.
- `next_cite` counts a lowercase, quoted or commented `cite-as` value.
- The legacy title scan stays anchored: a title like "See Q40: …" is not counted.
- Lane text in the discovery and plan templates: a decision card is titled by its citation on a board that draws citations, else `ADR:` or `PDR:`.
- The discovery map card is titled "Every decision, by corner"; `cite-as: Map` kept.

**One departure from the card**: the two old strings in `heal/scripts/heal-descriptors.py` were not reworded. They are predecessor bodies, and that file's rule is to add the body a released template replaces, so the released Brief and Decisions bodies were added instead. A board on the old wording is now replaced by heal; an edited body is left alone.

**Evidence**

- `tests/smoke.sh` on `main` at `111ba99`: 304 passed, rc 0.
- Independent review, two rounds: approved at `1db82ef`. Round 1 found a regression (a title containing the placeholder word was refused on a board that draws citations); fixed and pinned by a case. Every new case fails on its mutant. The added heal bodies match the released templates byte for byte.

**Not changed**: a board that already holds a card titled "Discovery map" keeps that title; heal does not touch titles.

**CHANGELOG sentence for 0.9.0**: Citation numbers on older boards no longer collide after a zero-padded Q or T number, a hand-typed lowercase or commented `cite-as` is now counted, and the discovery map card reads "Every decision, by corner".
