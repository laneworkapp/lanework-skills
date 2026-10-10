---
schema: 1
kind: board
title: {{title_yaml}}
id: {{id}}
icon: {glyph: arrowshape.forward.fill}
config: {show-card-body: 3}
created:  {{stamp}}
modified: {{stamp}}
---
# {{title}}

Where work on {{project}} goes from a raw idea to something built, one card per piece of work. Lanes are stages of commitment, so a card's lane says who acts next.

## How this board works

- **Flow**: Ideas to Shaping to Proposed to Approved to Active to Done, with Issues and Tasks as side entrances.
- **Two human gates**: triage out of Ideas, and review out of Proposed. Agents surface what sits at a gate and never move a card through one. Moving a finished proposal from Shaping into Proposed is the agent's job, not the owner's.
- **Agent lanes**: Shaping, Approved and Active: agents act on cards there unasked. Elsewhere they may read, link, research and answer, but move a card out or start its work only when asked.
- **A card is ready to build** when its body names the files it touches, the command that verifies it, and a done-when a reader could check without asking.
- **Verified means** {{verified}}, run on the current head, with its output quoted in the closing comment.
- **The body is the spec, the thread is the journal.** Edit the body when scope or done-when change, and put everything else in comments.
- **Git**: this board lives in the {{project}} repo. Commit your own board writes with a plain message, stage only your own paths, and keep board writes and code changes in separate commits.
