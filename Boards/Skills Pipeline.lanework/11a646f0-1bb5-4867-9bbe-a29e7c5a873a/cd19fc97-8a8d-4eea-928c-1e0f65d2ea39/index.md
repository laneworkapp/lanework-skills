---
schema: 1
kind: card
title: "Shaping writes a card's label as a block list, which heal flags every run"
order: 7168
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T12:03:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T12:06:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
An agent adding a label to a card by hand leaves `labels` as a two-line block list, where the guide's compact form is one line, so the board's heal flags the card on every run.

## Problem

The `work` skill has no helper that writes a label onto a card. A lead on plugin 0.8.0 wrote card frontmatter with its own inline shell and Python, which hard-coded one block shape for every card:

```yaml
labels:
  - {text: "Issue", rank: 1, kind: {type: "type", text: "Type", icon: {glyph: "cube"}}}
```

With two labels that pass 120 characters the block is right. With one label the compact form (`skills/lanework/references/writes.md` § Every write) is a single flow line, about 95 characters here:

```yaml
labels: [{text: "Issue", rank: 1, kind: {type: "type", text: "Type", icon: {glyph: "cube"}}}]
```

Layout drift only: the label data is right and the validator passes, since both layouts read. Nothing on the write path looks at layout, so only a heal dry run shows it.

Where the skill stands:

- The compact-form rule is already stated in `writes.md`, in 0.8.0 too. The lead did not apply it to its own snippet.
- `work/scripts/file-card.sh` (on `main`, not in 0.8.0) writes a new card in the compact form, but only the lane's default labels. Its header says other labels are written by hand.
- Shaping in a grouped lane (`work/references/sweep.md`) tells the agent to write the entry itself. No script does it.

## Reproduce

On the app repo's Lanework Pipeline board, 2026-11-21, plugin 0.8.0:

```sh
python3 .schema/bin/lanework-heal.py <board>
```

Seven repairs, all `H17 compact-collection labels written in the compact form, 2 lines to 1`, each on a single-label card written after the board's last full heal.

## Direction

Candidates for shaping, not yet chosen:

- A helper that sets a label on a card, new or existing, and writes the result through `compact_fm` in `lanework/scripts/lib.sh`. `file-card.sh` could take extra labels the same way.
- A check on the write path: a heal dry run filtered to the files about to be committed, failing on any line. The healer takes a whole board, so it needs a filter on its output.
- Wording only: point the sweep rule and the label rule in `writes.md` at the compact-form rule.

## Done when

An agent filing or shaping a card with one label gets `labels` on one line without writing the frontmatter by hand, and a heal dry run straight after reports no `H17` on that card.
