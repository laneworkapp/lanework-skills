---
schema: 1
kind: card
title: "Shaping writes a card's label as a block list, which heal flags every run"
order: 7168
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T12:03:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T12:03:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
The shaping step's label write leaves a card's `labels` as a two-line block list, where the guide's compact form is one line, so the board's heal flags the card on every run.

## Problem

`skills/work/references/sweep.md`, "Shaping in a grouped lane", says to write the entry "as a drop would" and names what goes in it, but not its layout. A lead following it wrote:

```yaml
labels:
  - {text: "Issue", rank: 1, kind: {type: "type", text: "Type", icon: {glyph: "cube"}}}
```

The compact form (`skills/lanework/references/writes.md` § Every write) is one flow line while it fits 120 characters, and this one is about 95:

```yaml
labels: [{text: "Issue", rank: 1, kind: {type: "type", text: "Type", icon: {glyph: "cube"}}}]
```

Layout drift only: the label data is right and the validator passes. The templates that write a label (`plan/templates/ticket-card.md`, the discovery card templates) already use the one-line form, so only this free-hand write drifts. Not confirmed: that this rule is the one the lead followed. It is the only label-writing rule in the `work` skill.

## Reproduce

On the app repo's Lanework Pipeline board, 2026-11-21, plugin 0.8.0:

```sh
python3 .schema/bin/lanework-heal.py <board>
```

Seven repairs, all `H17 compact-collection labels written in the compact form, 2 lines to 1`, on cards shaped after the board's last full heal. Four of them (`23974a68`, `509b735d`, `5f707112`, `aacde781`) got the block form in the commit that first added the label, three in a "shaped; to Proposed" commit and one in a move to Active, and every later write carried it forward.

## Direction

State the layout where the label is written: a link from the sweep rule to the compact-form rule in `writes.md`, or a template line for the entry as the other skills have.

## Done when

An agent shaping a card in a grouped lane writes `labels` in the compact form, and a heal dry run straight after reports no `H17` on that card.
