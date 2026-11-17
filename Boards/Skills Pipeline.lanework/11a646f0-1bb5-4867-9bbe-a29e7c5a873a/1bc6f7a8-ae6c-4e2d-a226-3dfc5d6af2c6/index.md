---
schema: 1
kind: card
title: "Citation leftovers: an unchecked stamp, a reissue on older boards, stale ADR: lane text"
order: 3072
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: plan, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T14:21:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:21:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Nine edges of the citation work were noted in review and left out of [the citable labels card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12); two of them can put a wrong citation on a board.

## Seen

Measured by the reviewer at `5c5cda9`, merged to main as `12cc105`, unless marked. None is released yet.

| # | where | what happens | how sure |
|---|---|---|---|
| 1 | `lanework/scripts/lib.sh:119`, `stamp_cite` | it does not check that the stamp took. If its perl substitution fails, `cite-as: CITEPENDING` lands on the board and the script prints `cite Q1`, exit 0. If its scan fails, an empty `cite-as: ` lands | measured by mutation; no real input reaches it |
| 2 | `discovery/scripts/file-question.sh:79` and `plan/scripts/file-ticket.sh`, the `MAXQ`/`MAXT` path used on a board below the gate | octal arithmetic on a padded title number. With `Q9: nine` and `Q010: padded`, another `Q9: …` is filed. With `Q08: …`, the script aborts. Same on main before the merge | measured |
| 3 | `discovery/templates/lanes.md:11`, `plan/templates/lanes.md:12`, `heal/scripts/heal-descriptors.py:155-156` | the Decisions lane text says cards are "titled `ADR:` or `PDR:`". On a gated board `file-record.sh` writes a bare title | read |
| 4 | `discovery/templates/topic-card.md`, `fact-card.md` | filled by hand, so the version gate never applies: always a bare title with `cite-as`. On a board with no guide stamp yet, script-filed cards get the old shape | read; a gap in the card's body |
| 5 | `discovery/templates/map-card.md` | `cite-as: Map` above the title "Discovery map": the face reads "Map Discovery map" | read; the body asked for it |
| 6 | `read-board.sh`, `frontier.sh` | a card with both `cite-as: T9` and the title `T9: legacy` prints `T9: T9: legacy` | measured |
| 7 | `next_cite` | matching is case-sensitive, the validator's duplicate check is not: a hand-typed `q7` lets a script mint `Q7`. A trailing YAML comment (`cite-as: Q15 # x`) is not counted | measured |
| 8 | `card_ref` | backticks in a title are not escaped in link text | reasoned; main's escaping, moved unchanged |
| 9 | `tests/smoke.sh`, the cite cases | removing the anchor from the legacy-title regex (`re_t`, `lib.sh:107`) leaves every case green | measured |

## Suggested fixes

1. `stamp_cite` dies if the citation is empty or the placeholder is still in the file.
2. Force base 10 in the older-board path too. Output changes only on a board that reissues or aborts today.
3. Reword the lane text and its heal copy together, so heal does not flag the new wording.
4. Either name both shapes in the two templates, or accept the gap.

## Not decided

Which rows are worth a card. Rows 1 and 2 are the two that can put a wrong or repeated citation on a board; the rest are wording and display.
