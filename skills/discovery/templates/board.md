---
schema: 1
kind: board
title: {{title_yaml}}
id: {{id}}
icon: {glyph: binoculars}
config: {show-card-body: 3, labels: [{type: round, text: Round}, {type: record, text: Record, single: true, values: [{text: ADR, rank: 1}, {text: PDR, rank: 2}]}, {type: status, text: Status, single: true, values: [{text: accepted, rank: 1}, {text: deprecated, rank: 2}, {text: superseded, rank: 3}]}]}
created:  {{stamp}}
modified: {{stamp}}
---
# {{title}}

Discovery on {{topic}}: its problem and domain space, examined one question per card. The agent asks in rounds, the owner rules, and the ruling is written into the card in the owner's words. Brief holds the topic and the discovery map, Facts holds what was looked up, and Settled is the record a later session resumes from. Rulings that clear the bar also become ADR and PDR cards in the Decisions lane.

## How this board works

- **The body holds the question; the ask comment is where it is answered.** Every question card carries one ask in its thread, with the handle on its first line, restating the question, its options and the recommendation. Reply to that comment. No other comment on the card mentions the handle.
- **Answer anywhere.** A comment on the card, or a reply in chat. The agent records a chat answer as a comment quoting it, then writes the ruling into the body under `## Ruling` and moves the card.
- **A ruling is the owner's words**, dated. "As recommended" is a ruling. A deferral or a refusal is a ruling too, and parks the card with the reason.
- **One question, one decision.** A round is every question whose prerequisites are settled. Questions number globally in the order asked; the round is the `Round` label.
- **Facts are cited.** A Facts card names its source and attaches the report; a question that leans on one links it under Depends on.
- **Records follow rulings.** At the close of each round, rulings that settle how the system is built become ADR cards in Decisions, rulings that settle what the product does become PDR cards there, and pinned terms go into `CONTEXT.md`. The Settled card links each record card, and each record card links its question.
- **Nothing is built from this board.** When the frontier is empty and the owner confirms the understanding, work cards are filed on the project's pipeline board and link back here.
- **Git**: this board lives in the project repo. Stage only your own paths, plain commit messages, board writes separate from code changes.
