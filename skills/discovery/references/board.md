# Board

## Find or found

- Name `<Topic> Discovery.lanework`, in `<repo root>/Pitlane/`; no project → `~/Pitlane/`.
- Look first: board the user names, or the topic's existing board → resume. Never duplicate.
- `<Topic> Grill.lanework` (from `grill-me`) = same shape. Resume as-is, don't rename. Its map card is titled "Design tree".
- None fits → `scripts/found-discovery-board.sh`, then open once in the app (installs guide + schema) before filing.
- Small clarification + owner's say-so → lighter mode: plain interview in an existing card's thread, no board.

## Lanes

Brief · Facts · Asked · Settled · Parked. Order, collapse, and each lane's entry/exit policy: `templates/lanes.md`.

## Cards

| card | lane | template |
|---|---|---|
| Topic | Brief, order 1024 | `templates/topic-card.md` |
| Discovery map | Brief, order 2048 | `templates/map-card.md` |
| Fact | Facts | `templates/fact-card.md` |
| Question | Asked → Settled / Parked | `templates/question-card.md` |

Ruling + chat record: `templates/ruling.md`. Templates: `{{key}}` script-filled (fill yourself when writing by hand), `<hint>` hand-filled, stamps per guide.

## Moves

- Only Asked → Settled / Parked. Only the agent, only after the ruling is in the body.
- Owner never moves cards. A comment or chat reply is the whole gesture.
- Brief, Facts, Settled cards never leave. Wrong fact → dated correction comment. Change of mind → new question card linking the old one.

## Order

- New card → bottom of its lane: max order + 1024 (empty lane: 1024). Moved card → bottom of its destination, so Settled reads as the sequence of rulings.
- Q numbers: global, in filing order. Mint from the highest `Q<n>` across all lanes (`file-question.sh` does).
