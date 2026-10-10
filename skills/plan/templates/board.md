---
schema: 1
kind: board
title: {{title_yaml}}
id: {{id}}
icon: {glyph: map}
config: {show-card-body: 3, labels: [{type: ticket, text: Ticket, single: true, values: [{text: Grilling, rank: 1, icon: {glyph: bubble.left.and.bubble.right}}, {text: Research, rank: 2, icon: {glyph: magnifyingglass}}, {text: Prototype, rank: 3, icon: {glyph: hammer}}, {text: Task, rank: 4, icon: {glyph: checklist}}]}, {{label_entries}}{type: record, text: Record, single: true, values: [{text: ADR, rank: 1}, {text: PDR, rank: 2}]}, {type: status, text: Status, single: true, values: [{text: accepted, rank: 1}, {text: deprecated, rank: 2}, {text: superseded, rank: 3}]}]}
created:  {{stamp}}
modified: {{stamp}}
---
# {{title}}

A plan for {{topic}}: finding the way from a loose idea to its destination, one decision per ticket. The destination, the spec, decision or change this plan is finding its way to, heads the Map card and fixes the scope. Each session resolves one ticket and rewrites the map, and the plan is done when nothing is left to decide.

## How this board works

- **The Map is the index.** It names the destination, gives each decision so far one line and a link to its ticket, and sketches what can't be ticketed yet. A decision lives only in its ticket.
- **One ticket, one question.** A ticket asks a question whose answer is a decision, small enough for one session. Grilling tickets are a conversation with the owner, Research tickets are looked up by the agent, Prototype tickets put a rough draft in front of the owner to react to, and Task tickets are work that has to happen before a decision can be made.
- **The frontier is the next work.** A ticket waits in Blocked until every ticket it depends on is resolved, then moves to Frontier on its own. A session claims the top of Frontier by moving it to Working, so sessions running side by side never take the same ticket.
- **Answer on the card or in chat.** A ticket that needs the owner carries one ask in its thread, with the handle on its first line. Reply to that comment. The resolution is written in the owner's words, dated, and a resolved ticket is never edited.
- **Records follow resolutions.** A resolution that settles how the system is built becomes an ADR card in Decisions, one that settles what the product does becomes a PDR card there, and pinned terms go into `CONTEXT.md`.
- **Out of scope is final for this plan.** Work past the destination is ruled out with one line why, and comes back only as a new plan with a redrawn destination.
- **Nothing is built from this board.** When the way is clear and the owner confirms it, work cards are filed on the project's pipeline board and link back here.
- **Git**: this board lives in the project repo. Stage only your own paths, plain commit messages, board writes separate from code changes.
