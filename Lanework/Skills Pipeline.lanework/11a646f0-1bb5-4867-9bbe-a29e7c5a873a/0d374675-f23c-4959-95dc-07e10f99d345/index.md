---
schema: 1
kind: card
title: "Agents stall on approved cards: lanes name no actor or trigger"
order: 1024
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: work, kind: {type: skill, text: Skill}}]
waiting: {for: rzen, since: 2026-10-10T00:53:34Z, comment: 667e1741-d2d1-4ad7-a6f0-538f33a6c348}
created:  {at: 2026-10-10T00:53:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T00:53:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
An approved card can sit in Approved with no agent picking it up, because pipeline lanes say what a card is but not who acts on it or when, and the watch skill still contradicts itself on moves.

## Reproduce

A watch is armed on a pipeline board. The owner drags a card from Proposed to Approved with no comment. The watch reads the move as "context", or as a gate needing chat instructions, and does nothing. Seen on [e2fa8412](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/e2fa8412-daf6-4a49-86a8-7336133f3d32), 2026-10-09. Second variant: a card already sits in Approved when the watch is armed. No event fires, so nothing picks it up.

## Cause

- **Board sheet, prohibitions only**: names the two human gates and one agent move (Shaping → Proposed). No line says which lanes are agents' to act on unasked.
- **Lane bodies, state not actor**: Approved said "ready-to-build queue, top is next". Tasks says "built straight through Active". Neither names who acts or what triggers it.
- **Watch, two-key lock**: act only if the lane hands work to agents **and** "standing instructions" cover it, with that term undefined. Read as chat. `work` meanwhile says build Approved and Tasks. Two skills, two answers, the stricter won.

## Already fixed (5fabd13)

`watch/references/events.md` item 5 defines standing instructions as board sheet + lane bodies. The Approved lane template and this board's Approved body say approval is the go-ahead.

## Proposal

1. **Every lane body names its actor and trigger.** All three lane-set templates (`pipeline-lanes.md`, `design-loop-lanes.md`, `datapoint-lanes.md`). Tasks gets "without waiting to be asked".
2. **A permission line in the pipeline board sheet** (`templates/pipeline-index.md` and this board): Shaping, Approved, Tasks and Active are agents' lanes, acted on unasked. Ideas and Proposed wait on the owner.
3. **One lane → actor table**, in `lanework/references/board-kinds.md`. `work/SKILL.md` and `watch/references/events.md` cite it instead of restating.
4. **Watch contradictions out**: `events.md` item 6 drops "a move" from "context, not a reply". The `watch` description drops "requested". `responding.md` gains the move case beside comments.
5. **Arming pass**: `watch/references/arming.md`, after reading lane bodies, one pass over agent lanes acting on what's waiting.
6. **Writing rule**: `work/references/writing.md` or `lanework/references/founding.md`: a lane body that forbids agents an action also says what they may do.
7. **Existing boards**: see the open call.

- **Open call, existing boards**: Approved bodies on Previz, ZoneCanary, Ullage and Indie Pit say only "Implement top-to-bottom", Lanework Sync Service and Lanework Pipeline name no trigger, Lanework Website Pipeline's is empty. A: agent updates each, one commit per repo. B: list only, the owner edits. C: a script that re-stamps lane bodies from the template.

## Touches

`skills/lanework/`: `references/board-kinds.md`, `references/founding.md`, `templates/pipeline-index.md`, `templates/pipeline-lanes.md`, `templates/design-loop-lanes.md`, `templates/datapoint-lanes.md`. `skills/work/`: `SKILL.md`, `references/writing.md`, `references/sweep.md`. `skills/watch/`: `SKILL.md`, `references/events.md`, `references/responding.md`, `references/arming.md`. This board's `index.md` sheet and Tasks lane body (board commit, separate).

## Verify

`tests/smoke.sh` passes. A smoke assertion that every lane in a freshly founded board of each kind has a non-empty body. Prose read through against guide v82: no file restates the lane → actor table, and `events.md` has no rule calling a move context only.

## Done when

Every lane-set template body names its actor and trigger. The table lives only in `board-kinds.md`. The watch acts on a bare move into an agent lane and on cards already waiting at arming. The existing-boards call is ruled and carried out.
