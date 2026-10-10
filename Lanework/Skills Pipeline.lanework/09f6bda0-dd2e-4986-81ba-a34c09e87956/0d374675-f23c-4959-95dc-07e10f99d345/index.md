---
schema: 1
kind: card
title: "Agents stall on approved cards: lanes name no actor or trigger"
order: 6144
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: work, kind: {type: skill, text: Skill}}, {text: heal, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T00:53:33Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T02:13:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
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

1. **Every lane body names its actor and trigger.** All lane-set templates (`pipeline-lanes.md`, `design-loop-lanes.md`, `datapoint-lanes.md`, discovery's `lanes.md`), per the lane roles ruling below.
2. **A permission line in the pipeline board sheet** (`templates/pipeline-index.md` and this board): Shaping, Approved and Active are agents' lanes, acted on unasked. Ideas, Issues, Tasks and Proposed wait on the owner.
3. **One lane → actor table**, in `lanework/references/board-kinds.md`. `work/SKILL.md` and `watch/references/events.md` cite it instead of restating.
4. **Watch contradictions out**: `events.md` item 6 drops "a move" from "context, not a reply". The `watch` description drops "requested". `responding.md` gains the move case beside comments.
5. **Arming pass**: `watch/references/arming.md`, after reading lane bodies, one pass over agent lanes acting on what's waiting.
6. **Writing rule**: `work/references/writing.md` or `lanework/references/founding.md`: a lane body that forbids agents an action also says what they may do.
7. **Existing boards**: brought to currency by a new `/heal` skill, below.

- **Ruled 2026-10-10 (owner, in chat), lane roles**: Ideas, Issues and Tasks are holding buckets. Agents may read them, link cards, research and add context, and answer the owner's questions there, but never move a card out or start its work unless the owner explicitly asks. Shaping: the owner places cards for agents to shape. Proposed: agents move shaped cards in for review. Approved: the owner moves cards in for agents to implement. Active: agents move cards in as they start. Done: agents move cards in once done-when is met. Replaces "an issue is shaped or fixed on its own merit" and "Tasks are pre-approved, built straight through Active".
- ~~**Open call, existing boards**: A: agent updates each, one commit per repo. B: list only, the owner edits. C: a script that re-stamps lane bodies from the template.~~ **ruled 2026-10-10: a user-invoked `/heal` skill (owner's comment, then the move to Shaping).**

## /heal

A new skill, `skills/heal/`, `disable-model-invocation: true`, run as `/heal <board> [<board>...]`. Brings each board up to the current skills and guide. Boards resolve as `/watch` does (`lanework/references/finding.md`).

- **Data**: runs the board-damage repair already in `lanework/references/writes.md` § Healing (the app's `.schema/bin/lanework-heal.py` when shipped, else `lanework/scripts/heal-board.py`). The script stays in `lanework`, which cites it for every write.
- **Descriptors**: matches the board's lane titles to a known lane set (pipeline, design loop, datapoint, discovery). For each lane, checks its body names an actor and trigger per the `board-kinds.md` table. A body identical to an older template is replaced with the current one. A customised body is never rewritten: the template's actor line is inserted after its first sentence. Same for the pipeline board sheet's permission line. A board matching no lane set gets data repairs only.
- **Flow**: dry run first, a per-board list of every change, then applied on the user's go in that chat. A user-invoked command confirming its own diff is not a card open call.
- **After**: validate, one commit per board repo staging only healed paths, push. Report per board: what changed, what was skipped and why.
- **Never**: rewrites the guide or `.schema/` (the app's), moves cards, or edits card bodies beyond the data repairs.

## Touches

`skills/lanework/`: `references/board-kinds.md`, `references/founding.md`, `templates/pipeline-index.md`, `templates/pipeline-lanes.md`, `templates/design-loop-lanes.md`, `templates/datapoint-lanes.md`. `skills/work/`: `SKILL.md`, `references/writing.md`, `references/sweep.md`. `skills/watch/`: `SKILL.md`, `references/events.md`, `references/responding.md`, `references/arming.md`. `skills/heal/` (new): `SKILL.md`, `references/descriptors.md`, `scripts/heal-descriptors.py` (lane set match, actor check, template diff). `.claude-plugin/plugin.json` skills list, `README.md` skills table and install commands, `CHANGELOG.md`. This board's sheet gains `heal` in the Skill label list (board commit, separate). The existing boards themselves are healed by the owner running `/heal` after release, not by this card.

## Verify

`tests/smoke.sh` passes. A smoke assertion that every lane in a freshly founded board of each kind has a non-empty body. A smoke case for `heal-descriptors.py`: a scratch pipeline board with one old-template lane body, one customised body and one empty body. Dry run lists three changes and writes nothing. Apply replaces the first, inserts into the second, fills the third, and the board validates. A second run finds nothing. Prose read through against guide v82: no file restates the lane → actor table, and `events.md` has no rule calling a move context only.

## Done when

Every lane-set template body names its actor and trigger. The table lives only in `board-kinds.md`. The watch acts on a bare move into an agent lane and on cards already waiting at arming. `/heal` on a scratch copy of a pre-fix pipeline board leaves every lane body naming its actor and trigger, with customised prose kept.
