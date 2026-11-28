---
schema: 1
kind: card
title: "heal-descriptors.py accepts a padded signer name, and found-board.sh still lists shared exit causes"
order: 3072
labels: [{text: "heal", kind: {type: "skill", text: "Skill"}}, {text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-27T22:35:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T13:16:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
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
| `skills/heal/scripts/heal-descriptors.py` | Under `--apply`, refuse a `--name` with leading or trailing whitespace (refused, never trimmed, as `stamp_args_ok` does), with exit 64 and nothing written. That is the exit it already uses for a reserved name. |
| `skills/lanework/scripts/found-board.sh` | Drop "empty or control-character --name or --model" from the header's exit-2 list. No behaviour change. |
| `tests/smoke.sh` | A padded-name case beside the existing reserved-name case for `heal-descriptors.py`. |

## Verified by

- `tests/smoke.sh --only heal_descriptors,lane_actors,headers,usage_guard,static` on the branch, then the full run on merged `main`.
- The new case fails against the script as it is now: `--apply --name ' board'` exits 0 and writes.

## Done when

- `heal-descriptors.py --apply --name ' board'`, `'board '` and `' claude'` each write nothing and exit 64.
- A dry run (no `--apply`) with a padded name still lists and exits as before.
- No script header repeats a cause that `stamp_args_ok` lists.

## Risks

- A caller that passes a padded name to `heal-descriptors.py --apply` today starts being refused. Every other writer already refuses it, so no guide shows such a call.
- The header edit changes no behaviour. The smoke `headers` section still has to pass.

## Recommendation

Build it as one small change: two files under `skills/` and one smoke case. Patch-level. Checked on `main` at `6d455f19`: both gaps are still there (`heal-descriptors.py` lines 536 to 539, `found-board.sh` header line 13).
