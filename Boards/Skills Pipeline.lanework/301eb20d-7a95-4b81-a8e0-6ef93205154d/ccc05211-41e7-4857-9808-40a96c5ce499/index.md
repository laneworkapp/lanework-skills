---
schema: 1
kind: card
title: "Pick the next card by priority"
order: 3072
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-22T22:33:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T22:38:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Owner's suggestion, in chat 2026-11-22: "use priority when picking next card to work on".

When an agent has several cards waiting in a lane it acts on, it takes the highest-priority one first. This card states that rule once, shows priority in the board read, and makes the watch's "top of Approved" follow it.

## Evidence

- `skills/work/references/lead.md:26-28` § Order the work is the only statement of pick order: build-blockers, then "the card's priority, as the board's guide defines it", then lane order. It covers a multi-card build campaign only.
- No other file states an order. `work/SKILL.md`, `work/references/sweep.md` (inventory, lines 11-30: "Approved, unstarted" has no order), `team.md` and `fixer.md` say nothing. `fixer.md` receives one card from the lead.
- Watch is where a pick really happens, and it picks by `order` alone. `watch/scripts/arm-pass.sh:14` and `:101-105` arm only the first card of Approved by `order`. `watch/references/arming.md:25-26`, `watch/references/responding.md:18` ("Approved but not the top") and `lanework/references/board-kinds.md:21` ("take the top into Active") repeat "top". `events.md` states no order.
- There is no `skills/dispatch/` in this repo. The filing's "dispatch" means `lead.md` § Dispatch, which hands a card already picked to a fixer, and `sweep.md` § 4 Farm. Neither picks.
- `plan/references/board.md:42` ("Frontier top = next ticket. Reprioritising = rewrite `order`") and `plan/references/sessions.md:22` (top of Frontier). Tickets carry no priority label and the plan owns its own order by hand. Out of scope. `discovery` asks the whole frontier at once (`rounds.md:5`), so there is nothing to pick. Out of scope.
- Guide (`Boards/Skills Pipeline.lanework/CLAUDE.md:634-638`): a priority is a `labels` entry of kind `priority`, never a root key. Each entry stamps its own `rank` (`:618`), so a reader needs no board config. Lower rank = higher priority (`:222`). A card with several takes its lowest rank (`:186`). A priority with no readable rank, and a card with no priority, are both "No priority" (`:189-192`). A board defines its own scale: the founded default is Urgent 0, High 1, Medium 2, Low 3 (`lanework/templates/label-kinds.md`), and a board with no `priority` kind cannot have one.
- On disk, from a throwaway board founded with `--labels priority` and a card filed with `--label High:priority` (the script writes the block form; the app writes the one-line flow form, both read):

```
labels:
  - text: "High"
    rank: 1
    color: "#E07A1F"
    icon: {glyph: "exclamationmark"}
    kind: {type: "priority", text: "Priority", icon: {glyph: "flag"}}
```

- `read-board.sh:25-27` prints `order`, title and short id only. No script in `skills/lanework/scripts/lib.sh` reads a card's labels or rank. `heal-board.py` has the parser (`Doc`, `normalize_entry`, `entry_of`), which `union_labels` already loads by path.
- Consumers of `read-board.sh` output: only `tests/smoke.sh:83,95` (count `^== ` lines), `:2961` (a regex on a card line with no priority) and `:3711-3715` (exit codes). Prose readers: `lanework/references/reading.md:9`, `work/references/sweep.md:16`, `plan/references/sessions.md:21`, `discovery/SKILL.md:42`.

## Proposal

Rule: among the cards waiting in a lane an agent acts on, take build-blockers first, then the lowest priority rank, then lane order (`order`). A card with no priority or no readable rank sorts after every ranked card, in lane order among themselves. Agents never assign or change a priority (`sweep.md` § Shaping in a grouped lane stays as is).

Home: `skills/lanework/references/reading.md`, a new `## Pick order` section after `## One pass`. It is board fundamentals, it sits beside the reader that shows the data, and `work` and `watch` already cite `lanework/references/`.

Files touched:

- `lanework/references/reading.md`: add `## Pick order` with the rule and the reader's output format. Not a copy of the guide's rank wording: link to the guide § Frontmatter (`labels`).
- `work/references/lead.md:27`: replace "the card's priority, as the board's guide defines it, then lane order" with a link to `lanework/references/reading.md` § Pick order. Keep item 1 (build-blockers) in the link's wording, not twice.
- `work/references/sweep.md`: § 2 Inventory row "Approved, unstarted": "farm: build, in pick order (`lanework/references/reading.md` § Pick order)". Same for "Shaping to advance".
- `lanework/references/board-kinds.md:21`: "take the top into Active" becomes "take the first in pick order into Active".
- `watch/references/arming.md:25-26` and `responding.md:18`: "its top card" and "Approved but not the top" become "first in pick order" and link the section. `events.md`: no change.
- `watch/scripts/arm-pass.sh`: in Approved, mark the first card by (rank, order) instead of by `order`; unchanged leased-or-not semantics. Header comment line 14 updated.
- `lanework/scripts/lib.sh`: new `priority_of <card index.md>`: prints `<text>\t<rank>` for the lowest-ranked `priority` entry, `<text>\t-` for a priority with no readable rank, nothing otherwise. Python via `heal-board.py`, one call per board (not per card) for the reader.
- `lanework/scripts/read-board.sh`: print the priority on the card line.
- `tests/smoke.sh`: cases below. `README.md` § Sizes and `tests/check-sizes.sh` counts follow the word changes. `CHANGELOG.md`: one user-facing entry at release.

Reader format: priority appended after the short id, so the existing prefix is byte for byte unchanged. A card with no priority entry prints exactly as today.

```
before:   1024     Card A  [adac52f0]
          2048     Card B  [cd147e61]
after:    1024     Card A  [adac52f0]  priority: High (1)
          2048     Card B  [cd147e61]  priority: Zed (-)      <- priority, no readable rank
          3072     Card C  [a87bffd3]                         <- no priority: unchanged
```

The reader still prints in `order`; it does not re-sort (reading order stays the app's). The agent applies the pick rule from the printed ranks.

## Risks

- Parsing both on-disk forms (block, written by scripts; flow, written by the app) in a new helper. Reusing `heal-board.py`'s parser avoids a second YAML reader.
- `arm-pass.sh` runs every watch pass over every card; a per-card Python start would be slow. Compute once per board.
- Stale card `order` numbers no longer decide the watch's pick, so a card the owner dragged to the top of Approved by hand can be passed over by a higher-priority card below it. Dragging is then not an override: see Decisions.
- Priority is the owner's call; if the reader makes ranks visible, agents might be tempted to set them. The no-assign rule stays in `sweep.md`.
- A board with no `priority` kind: reader prints nothing new, pick order degrades to lane order. That is the intended behavior.

## Verification

Smoke cases, on throwaway boards founded with `--labels priority`, never the pipeline board:

1. `read-board.sh`: cards filed with High, Low, none, and a priority entry with no `rank` hand-written. Assert the exact suffixes above and that the no-priority line equals today's byte for byte.
2. Both forms: one card with the script's block form, one rewritten in the app's flow form, same output.
3. Several priority entries on one card print the lowest rank.
4. A board with no `priority` kind: whole output equals today's (diff against a copy made before the change, or the existing `:2961` regex still passing).
5. `arm-pass.sh`: Approved holds a rank-3 card at order 1024 and a rank-1 card at order 2048: `arm` fires for the rank-1 card only. All unranked: first by `order`, as today. A leased first-in-pick-order card still blocks the next from arming.
6. `check-refs.sh` and `check-sizes.sh` pass (links to the new section exist).

## Done when

- `grep -rn "Pick order" skills` finds the section in `lanework/references/reading.md` and links from `lead.md`, `sweep.md`, `board-kinds.md` and the watch references; no other file states the order.
- `read-board.sh` prints `priority: <text> (<rank>)` per the example, and boards with no priority print unchanged.
- `arm-pass.sh` arms the first Approved card by (rank, order); smoke case 5 passes.
- `tests/smoke.sh`, `check-refs.sh` and `check-sizes.sh` pass; README sizes updated.
- Nothing under `skills/` names a guide version.

## Decisions in this proposal

Each follows from the ask or from a rule already in the skills. Reviewing the proposal reviews them.

- **Priority beats manual order.** Rank first, `order` breaks ties. A card dragged to the top of Approved is passed over by a higher-priority card below it. To put a card first, set its priority.
- **Build-blockers stay first.** A red gate on main comes ahead of priority, as `lead.md` has it today. Stated once, in the new section.
- **Work in progress is not dropped.** A card in Active is finished or released before a higher-priority Approved card is started. A lapsed Active card counts as in progress.
- **Within one lane only.** The lane says who acts, so a Shaping card never jumps an Approved one on priority.
- **The watch script changes in this card.** A rule in prose that `arm-pass.sh` contradicts is worse than none.
- **Plan and discovery boards are out of scope**, said in one line in the rule section.

## Open calls

None.
