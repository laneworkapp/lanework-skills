---
schema: 1
kind: card
title: "Scripts refuse valid cards that contain a triple closing brace"
order: 5120
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: plan, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T15:55:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T15:55:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`move-card.sh` refuses to move a valid card when a label's kind carries an icon, or when the card's body contains three closing braces, and six more scripts carry the same guard.

Found in the review of [the lease script card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb), where the same guard in `lease.sh` was fixed on its branch.

## What happens

The scripts restamp a card, then abort if the staged file contains three closing braces in a row, to catch a stamp glued together wrongly. The check reads lines the script never wrote.

- **Valid front matter**: `labels: [{text: Low, rank: 3, icon: {glyph: arrow.down}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]`. The board validates it.
- **Valid body**: a JSON example such as `{"a": {"b": {"c": 1}}}`.

## Measured, 2026-11-17, main at `42b5a98`, on a throwaway copy of a board

| script | case | result |
|---|---|---|
| `work/scripts/move-card.sh` | iconed label kind in front matter; board validates, 0 failures | exit 1, "triple brace after the restamp; nothing written" |
| `work/scripts/move-card.sh` | the JSON example in the body | exit 1, same message |

## Not measured, read only

The same check on the whole staged file: `discovery/scripts/settle-question.sh:50`, `plan/scripts/claim-ticket.sh:46`, `plan/scripts/resolve-ticket.sh:56`, `work/scripts/post-ask.sh:90`. On the staged front matter: `discovery/scripts/file-record.sh:62`, `plan/scripts/file-ticket.sh:87` (these write new cards, so the labels are the script's own).

## How many cards

The reviewer counted, across the Lanework repo boards: 497 of 2,323 cards with it in the front matter (all iconed label kinds; 358 of 947 on Lanework Pipeline), 7 with it in the body. On this board: 9 cards.

## Likely fix

Check only the lines the script writes (`modified`, `waiting`, `order`), as the lease script now does. One smoke case per script with an iconed label and a brace body.

## Also from that review, smaller

| # | where | what happens | how sure |
|---|---|---|---|
| 1 | `lanework/scripts/lease.sh`, reading `until` | a lease date with fractional seconds or `+00:00` reads as unreadable, so that lease is staked over with no takeover wait. The script writes only the `Z` form | measured by the reviewer |
| 2 | `lease.sh`, and the other restamping scripts | a body with no trailing newline gains one on the first write | measured by the reviewer for `lease.sh` |
| 3 | `lease.sh`, `move-card.sh` | a card with CRLF line endings that the validator passes is refused with exit 1, "no frontmatter" | measured by the reviewer |
