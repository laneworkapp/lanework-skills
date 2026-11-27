---
schema: 1
kind: card
title: "heal-descriptors.py accepts a padded signer name, and found-board.sh still lists shared exit causes"
order: 1024
labels: [{text: "heal", kind: {type: "skill", text: "Skill"}}, {text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-27T22:35:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T22:35:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Two places still disagree with the signer-name rules `lib.sh` now holds.

## What is off

| # | Where | Gap |
|---|---|---|
| 1 | `skills/heal/scripts/heal-descriptors.py`, the `--name` check under `--apply` | It lowercases the name and does not trim. `--apply --name ' board'` is accepted, while `heal-board.py` and every shell writer refuse it. |
| 2 | `skills/lanework/scripts/found-board.sh`, header | It lists "empty or control-character --name or --model" among its exit-2 causes. The comment at `stamp_args_ok` says the shared causes are listed there only. |

## Scope

| File | Change |
|---|---|
| `skills/heal/scripts/heal-descriptors.py` | Refuse a padded `--name`, and a reserved one after trimming, with the exit code it already uses for a reserved name. |
| `skills/lanework/scripts/found-board.sh` | Drop the two shared causes from the header, or point at `lib.sh`. |
| `tests/smoke.sh` | A padded-name case beside the existing reserved-name case for `heal-descriptors.py`. |

## Verified by

- `tests/smoke.sh --only` the heal section, then the full run.

## Done when

- `heal-descriptors.py --apply --name ' board'` writes nothing and exits as a reserved name does.
- No script header repeats a cause that `stamp_args_ok` lists.
