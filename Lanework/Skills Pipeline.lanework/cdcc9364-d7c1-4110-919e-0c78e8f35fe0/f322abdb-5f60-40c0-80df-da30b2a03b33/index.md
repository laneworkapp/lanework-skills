---
schema: 1
kind: card
title: "Shaping: assign a label from the kind the lane is grouped by"
order: 7168
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T00:35:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-11-12T00:35:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The owner asked on 2026-11-11 that when a card is shaped, the agent read what the Shaping lane is grouped by and try to give the card a fitting label of that kind. The card then lands in a real section, not the trailing "No <kind>" one.

## Idea

- **Read the lane's `group`** when shaping (`group: {by, kind, direction}`, guide § lanes; the retired `group-by` is read where `group` is absent).
- **Pick a value for the grouped kind:**
  - `by: label` + `kind` → choose one value of that kind. Closed kind = one of its listed values. Open kind = reuse a value already on the board before inventing one.
  - `by: priority` / `by: component` → the same, for that kind.
  - `modified` / `created` / none → nothing to do. `due` → leave it, since a date is the owner's call.
- **Write it the way a drop would**: the flattened `labels` entry of that kind, replacing any the card had (the kinds are `single: true`).
- **When unsure, ask instead of guessing.** Leave the label off and say so in the shaping record, or offer options in the shaping ask.
- **Never overwrite** a value of that kind that the owner already set.

## Open questions for shaping

- Does this apply only to Shaping, or to any lane the agent writes a card into (filing to Ideas or Issues, moving to Proposed)?
- Does it also apply to the `due` grouping, or never?

## Touches

`skills/work/` shaping flow (the shaper's reference), possibly `lanework/` § write rules for the label-entry shape, plus a smoke case if a script writes it.
