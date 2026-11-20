---
schema: 1
kind: card
title: "Waiting-clear trial: what counts toward its ending, and five lint edges"
order: 4096
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T14:42:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T12:03:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
waiting: {for: anyone, since: 2026-11-20T12:03:28Z, comment: 5ae40ae5-e569-47b1-9b26-8645b36e4437}
---
The trial that lets an agent clear `waiting` cannot reach its ending line as written, because the lint already reports three old clears and counts the discovery skill's own chat record as unquoted; both need the owner's call. Five smaller lint edges are listed below them.

From the review of [the waiting-clear card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3), merged to main as `42b5a98`. Not released yet.

## Open calls

**1. The three clears that predate the rule.** `lint-waiting-clears.sh` on this board prints `QUOTED 0, NO-QUOTE 3`, exit 1, before any agent has used the rule. The trial's ending line is "ten `QUOTED`, none `NO-QUOTE`".

| card | ask | what it is |
|---|---|---|
| [4596a2cb](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12) | `5156ff11` | the hand clear of 2026-11-14 named in the trial card's risks record |
| [48fa3910](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/48fa3910-7ff0-4999-93a7-de5429e828c8) | `738d4bc6` | an ask from 2026-10-10 with no answer on the card |
| [c5b171e1](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a) | `e7c4a842` | a "Ruled in chat" record with no quote line |

**Decided, 2026-11-20, by the owner on this card: A.** Count only clears made after 0.9.0 is released. The three stay listed; the trial reads the lint for new lines. No old thread is rewritten. Not taken: fixing the three first (two need the owner's words from a chat that is gone; the third needs an answer).

**2. Discovery's chat record reads as `NO-QUOTE`.** `discovery/templates/ruling.md:19` writes `**Owner answered in chat.** "<words>"`: no `>` line, no `**Given**` line. Measured: `file-question.sh` then `settle-question.sh --record --reply` on a fresh board gives `NO-QUOTE`, exit 1. The trial card's body assumed discovery was "already this shape". The two discovery boards in this repo are silent today.

- A: discovery adopts the new record shape (template and `settle-question.sh`). One shape everywhere; a build card.
- B: the lint also accepts discovery's shape.
- C: discovery boards stay out of the trial's count.

## Lint edges (none blocked the merge)

| # | where | what happens | how sure |
|---|---|---|---|
| 1 | `work/scripts/lint-waiting-clears.sh:36` | any `by` whose kind is not agent counts as human, `kind: shortcut` included, so a shortcut comment after an ask hides an agent clear | measured; no such stamp on today's boards |
| 2 | same, line 35 | a timestamp with fractional seconds or an offset is dropped, so that comment is invisible | measured; none on today's boards |
| 3 | same, lines 31-32 | counted as `QUOTED`: a `>` line inside a code fence, `**Given**` with no colon, both on one line | measured; matches the trial card's wording |
| 4 | `tests/smoke.sh`, the lint case | no case puts `waiting:` in a card body; a script that read it anywhere would pass | measured; the shipped script is right |
| 5 | `work/references/writing.md:53` | cites `work/scripts/lint-waiting-clears.sh` from inside the `work` skill, where the convention is `scripts/…` | read |
