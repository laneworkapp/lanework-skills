# Board

## Find or found

- Name `<Topic> Discovery.lanework`, where the project's boards live (`lanework/references/finding.md`).
- Look first: board the user names, or the topic's existing board → resume. Never duplicate.
- `<Topic> Grill.lanework` (from `grill-me`) = same shape. Resume as-is, don't rename. Its map card is titled "Design tree".
- None fits → `scripts/found-discovery-board.sh`, then open once in the app (installs guide + schema) before filing.
- Small clarification + owner's say-so → lighter mode: plain interview in an existing card's thread, no board.

## Lanes

Brief · Facts · Asked · Settled · Decisions · Parked. Order, collapse, and each lane's entry/exit policy: `templates/lanes.md`.

## Cards

| card | lane | template |
|---|---|---|
| Topic | Brief, order 1024 | `templates/topic-card.md` |
| Discovery map | Brief, order 2048 | `templates/map-card.md` |
| Fact | Facts | `templates/fact-card.md` |
| Question | Asked → Settled / Parked | `templates/question-card.md` |
| Record (ADR/PDR) | Decisions, filed there directly | `templates/record.md` |

Ruling + chat record: `templates/ruling.md`. Templates: `{{key}}` script-filled (fill yourself when writing by hand), `<hint>` hand-filled, stamps per `lanework/references/writes.md`.

## Moves

- Only Asked → Settled / Parked. Only the agent, only after the ruling is in the body.
- Owner never moves cards. A comment or chat reply is the whole gesture.
- Records are filed straight into Decisions by `scripts/file-record.sh`, never via Asked: the move rule above is untouched.
- Brief, Facts, Settled, Decisions cards never leave. Wrong fact → dated correction comment. Change of mind → new question card linking the old one.

## Order

- Placing: `lanework/references/writes.md` § Placing. A moved card goes to the bottom of its destination, so Settled reads as the sequence of rulings.
- Q numbers: global, in filing order. Mint from the highest `Q<n>` across all lanes (`file-question.sh` does).

## Older boards

No Decisions lane on resume → add it before the next record: lane at order 4608 (row in `templates/lanes.md`, stamped per `lanework/references/writes.md`), and the `record` + `status` kinds appended to `config.labels` beside `round` (`templates/board.md`; edit that one subkey, keep the rest).
