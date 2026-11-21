---
schema: 1
kind: card
title: "A hand-written card label lands as a block list, which heal flags every run"
order: 7168
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}, {text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T12:03:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T13:22:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
An agent that adds a label to a card, new or existing, runs one script instead of writing frontmatter, so `labels` lands in the compact form and a heal dry run has nothing to repair.

## Problem

The cause in the corrected card holds: no script writes a label onto a card, so a lead hand-wrote frontmatter and hard-coded the two-line block shape.

- **Layout drift is real.** Measured: a card with `labels:` over one block entry (`{text: "Issue", rank: 1, kind: {type: "type", ...}}`), run through `compact_fm` from `skills/lanework/scripts/lib.sh`, comes back as the one-line `labels: [{...}]` form. That is the change heal's `compact-collection` pass (H17) reports. A bare two-lane toy board run through `heal-board.py` printed `0 repairs`, so the whole-board H17 report itself is Not reproduced: reasoned from the card's evidence (7 repairs, all H17) and `heal-board.py:1017-1040`.
- **No label writer.** Not reproduced: reasoned from `skills/work/scripts/` (no label script) and the header of `file-card.sh`, which writes only the lane's `card-defaults` labels and says any other label is written by hand.
- **The rule exists but is not on the path.** `writes.md` § Every write states the compact form, and says to copy a label's shape from the guide, never another card. Nothing a writer runs checks it. `sweep.md` (Shaping in a grouped lane) says "write it yourself", which sends the agent to hand-written frontmatter.
- **The lead's handoff note** told it to copy only the `labels:` block from another card. That is the copy-the-shape habit `writes.md` already forbids; a script removes the occasion for it.

Dropped: the candidate "heal dry run filtered to the files about to be committed". The healer takes a whole board and the writer script already emits the compact form, so a second check adds a filter to maintain for no case the script leaves open.

## Change

- `skills/lanework/scripts/lib.sh`: split the merge core of `union_lane_defaults` (own entries, then new ones stamped from `config.labels`, `single` kinds resolved) into `union_labels <staged-fm> <board> <entry>...`, which `union_lane_defaults` then calls. One label model, one place.
- `skills/work/scripts/label-card.sh <board> <card-index-or-dir> <label>... --model m [--name n] [--session s]` (new): a label is `Text` (free label) or `Text:kind` (stamped from the board's `config.labels`; an undefined kind is exit 1). Stages a copy of the card outside the board, runs `union_labels` then `compact_fm`, restamps `modified` from the clock with the caller's `by` (the same stamp shape `lease.sh` writes), validates with the board's validator, then one `mv` in. A label the card already has is a no-op. A `single` kind the card already has a different value of is exit 1, nothing written: the owner's value is never overwritten (the rule in `sweep.md`).
- `skills/work/scripts/file-card.sh`: take repeated `--label` with the same syntax and pass them to `union_labels` ahead of the lane defaults. Drop the "labels beyond the lane's defaults are written by hand" line from its header.
- `skills/work/references/sweep.md` (Shaping in a grouped lane): replace "write it yourself" and the hand-written entry bullet with: run `label-card.sh` with K's value.
- `skills/lanework/references/writes.md`: in the Labels and priority bullet and the lane-defaults bullet, name `label-card.sh` and `file-card.sh --label` as the way to write a label; keep the compact-form bullet as the single statement of the layout rule.
- `skills/work/SKILL.md`: add `label-card.sh` to the board-writes line.

## Verified

Each case runs in `tests/smoke.sh` on a throwaway board copy, never the Skills Pipeline board.

- **label-card, compact form**: a card with no labels gets one stamped label; the file's `labels` is one line, `nothing_to_heal` on the board, `modified` moved to the clock with the caller's `by`, no other file changed. Fails today: the script does not exist.
- **label-card, existing label**: a card with a one-line `labels` gets a second free label; result stays compact (block only past 120 characters), the first entry byte for byte. Fails today for the same reason.
- **label-card, single kind**: adding a different value of a `single` kind the card holds exits 1 with the card unchanged; the same value is a no-op, exit 0.
- **label-card, undefined kind / not a card**: exit 1, nothing written.
- **file-card --label**: a new card with `--label` plus a lane default has both on one line, heal finds nothing. Fails today: `--label` is an unknown argument (exit 2).
- **Refactor guard**: the existing `union_lane_defaults` cases (smoke lines near 2010) still pass unchanged.
- `tests/check-refs.sh` and `tests/check-sizes.sh` pass with the new script cited in `sweep.md`, `writes.md` and `SKILL.md`.

## Done when

- `work/scripts/label-card.sh <board> <card> "Issue:Type" --model m` on a card with no labels leaves one `labels:` line, and `python3 <board>/.schema/bin/lanework-validate.py <card>` exits 0 with no `DEPRECATED` line.
- `python3 skills/lanework/scripts/heal-board.py <board>` straight after reports no H17 for that card.
- `grep -n "write it yourself" skills/work/references/sweep.md` finds nothing.
- `tests/smoke.sh` passes with the cases above.

## Risks

- Refactoring `union_lane_defaults` touches every filing script (`file-card`, `file-ticket`, `file-question`, `file-record`); the existing union cases guard it, but run the whole smoke.
- `modified` is restamped by `label-card.sh` on an existing card. If the guide treats a label edit as no edit, this would be wrong; the guide's stamping rule decides it, not this card.
- Agents that ignore the script and hand-write frontmatter are not stopped; the card fixes the missing tool, not the habit.

## Recommendation

Build all. The script and `file-card --label` are the fix; the prose edits just point at them. The filtered-heal check is dropped as redundant once the writers emit the compact form.
