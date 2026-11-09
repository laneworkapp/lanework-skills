---
schema: 1
kind: card
title: "Merge driver: merge relation files on the same terms as comment files"
order: 50176
labels: [{text: merge, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-09T08:23:16Z, by: {name: fixer, kind: agent, model: opus-5.5, session: "fe00d484 fixer", role: fixer}}
modified: {at: 2026-11-09T10:34:07Z, by: {name: lead, kind: agent, model: opus-5.5, session: "fe00d484 lead", role: lead}}
---
The merge driver doesn't know relation files yet, so a relation edited on both sides is kept as ours, with theirs dropped beside it as `index.theirs.md`. Relations are `<card>/relations/<uuid>/index.md`, declared in the Lanework format by [Relations 1](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/4f0d9f15-5aea-4f42-a68a-2d29d1c2aa8a) and carried through the app's loader, heal and guide by [Relations 2](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/fe00d484-a737-4bec-9c46-2c92ff578ba2).

## Reproduce

Two clones edit the body of one `relations/<uuid>/index.md` and restamp `modified`, then merge. `doc_kind` returns `None` for the path, so `merge_bytes` treats it as an unclassified board file: ours is kept and theirs is written beside it as `index.theirs.md`, whatever the stamps say.

## What

- `skills/merge/scripts/lanework-merge.py`: `doc_kind` names `relations/<uuid>/index.md` and `relations/.trash/<uuid>/index.md` as `relation`, merged as a comment is. The later `modified` wins, the other body goes in the card's merge comment, and each loss line names the relation by its short id.
- `skills/merge/references/rules.md`: one row for the relation file.
- `tests/merge-case.sh`: a relation edited on both sides, a trashed one edited on both sides, and a new relation on each side.

## Verified by

`tests/smoke.sh`, with the merge cases (merge, rebase and nodriver) covering the relation rows.

## Done when

- A relation edited on both sides merges to the later edit, with the earlier body in the card's merge comment.
- The same holds for a relation in `relations/.trash/`.
- A relation added on each side lands both, with no conflict.
- `tests/smoke.sh` passes.
