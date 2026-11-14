---
schema: 1
kind: card
title: "Fact: plan claims a ticket by moving it to Working"
order: 3072
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T04:27:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
The `plan` skill claims a ticket by moving its folder from Frontier to Working and posting "Claimed by <name>". It refuses a card that is no longer in Frontier. A folder move is one rename, so of two sessions moving the same card the second finds it gone. The claim has no end: a session that dies leaves its ticket in Working.

Not tested: two `claim-ticket.sh` runs racing on one card.

## Source

- `skills/plan/scripts/claim-ticket.sh`, read 2026-11-14

## Bears on

- Staking: not asked yet
