---
schema: 1
kind: card
title: "found-discovery-board.sh: --labels edge cases match found-board.sh"
order: 5120
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T03:16:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T03:16:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
Two small inconsistencies the review of [2191c5bc](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2191c5bc-0bca-4246-a0a9-058b866632e6) left as notes: `found-discovery-board.sh` takes a second `--labels` over the first, so `--labels type --labels size` drops `type`, and it accepts `--labels ""` where `found-board.sh` exits 2. Round survives both.
