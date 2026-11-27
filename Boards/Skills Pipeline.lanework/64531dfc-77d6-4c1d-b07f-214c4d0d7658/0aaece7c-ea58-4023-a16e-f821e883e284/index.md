---
schema: 1
kind: card
title: "Reserved-name check accepts a padded name, and four smaller leftovers from the v122 change"
order: 1024
labels:
  - {text: "lanework", kind: {type: "skill", text: "Skill"}}
  - {text: "merge", kind: {type: "skill", text: "Skill"}}
created:  {at: 2026-11-27T16:51:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T17:33:44Z}
---
Five small gaps the reviewer found in the v122 change, none of which blocked it.

## What is off

| # | Where | Gap |
|---|---|---|
| 1 | `skills/lanework/scripts/lib.sh`, `stamp_args_ok` | The reserved-name check does not trim. `--name ' board'` is accepted and writes `name: " board"`. `heal-board.py` strips before it compares, so the two guards disagree on a padded name. |
| 2 | `tests/smoke.sh`, reserved-name loop | `lease.sh` calls `stamp_args_ok` too and is not in the loop. By hand, `lease.sh check --name board` exits 2. |
| 3 | `skills/merge/scripts/lanework-merge.py`, the `reactions` union | Identical entries with no emoji collapse into one when both sides changed `reactions`. The guide says such an entry is kept untouched. Only a hand edit makes this shape. |
| 4 | `README.md`, the "Measured on" line of the size table | The counts for `lanework`, `watch` and `merge` were re-measured on 2026-11-27, and their dates still read 2026-11-22 and 2026-11-23. `check-sizes.sh` does not read dates. |
| 5 | Headers of the scripts that call `stamp_args_ok` | None lists a reserved name, or a control character, among its exit-2 causes. `writes.md` says each header lists its own. |

## Scope

| File | Change |
|---|---|
| `skills/lanework/scripts/lib.sh` | Trim the name before the reserved-name compare, or refuse a padded name outright. |
| `tests/smoke.sh` | Add `lease.sh` to the reserved-name loop, and a padded-name case. |
| `skills/merge/scripts/lanework-merge.py` | Keep every entry with no emoji, duplicates included. |
| `tests/merge-case.sh` | One `reactions` case with two identical no-emoji entries. |
| `README.md` | Move the three dates. |
| script headers | One pass adding both exit-2 causes, or one line in `writes.md` saying the shared causes live in `lib.sh`. |

## Open call

- Row 5: add the causes to every header, or say once in `writes.md` that the shared ones are not repeated. Shaping picks one and asks only if it matters.

## Verified by

- `tests/smoke.sh --only braces,merge`, then the full run.

## Done when

- `--name ' board'` exits 2 with nothing written, from every script in the loop, `lease.sh` included.
- Two identical no-emoji reaction entries survive a merge where both sides changed `reactions`.
- The README dates match the day each count was measured.
- Row 5 is settled one way and the files agree with it.
