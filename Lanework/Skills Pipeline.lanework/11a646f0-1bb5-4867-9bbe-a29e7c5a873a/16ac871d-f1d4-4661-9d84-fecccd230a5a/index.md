---
schema: 1
kind: card
title: "Smoke's guide-version check has no positive control and skips scripts"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:34:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-12T01:34:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
`tests/smoke.sh` checks that no skill file names a guide version (the stamp lives only in the repo `CLAUDE.md`). The check was widened in the guide v114 catch-up to catch a version written as a floor, such as "v105+", in any skill `.md`.

## Gap

- **No positive control.** Nothing in the suite feeds the check a file that names a version and asserts it is flagged. A broken pattern would pass green. The only control so far was a one-time run against the old `writing.md`.
- **Scripts are not scanned.** The check reads `.md` files only, so a version floor written in a script comment under `skills/` gets through.

## Fix

- Add a control: a temp copy of one skill file with a guide version written in, which the check must flag, and the clean tree, which it must not.
- Extend the scan to scripts under `skills/` (`.sh`, `.py`), keeping the exclusions that already hold for `.md`: `schema v1`, semvers such as `v0.8.0`, and ranges like `v2→v5`.

## Touches

`tests/smoke.sh` only.

## Done when

The suite fails when a guide version is written into any file under `skills/`, `.md` or script, and a case in the suite proves it. `tests/smoke.sh` passes on the clean tree.
