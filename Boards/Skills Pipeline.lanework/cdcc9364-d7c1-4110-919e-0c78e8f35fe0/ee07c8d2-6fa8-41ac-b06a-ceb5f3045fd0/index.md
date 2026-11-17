---
schema: 1
kind: card
title: "Retire the dispatch skill and move its arming sweep and a compaction rule into watch"
order: 1024
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T11:33:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-17T11:33:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
Remove the `dispatch` skill, and give `watch` the two things that make a long watch safe without it: the arming sweep and a rule for what to do after the session's context is compacted.

## Why

- **Dispatch was never trialed.** It shipped in 0.7.0, its arming changes shipped in 0.8.0, and the live trial both releases waited on has not run ([Dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4), [Dispatch arming](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ada828e-56a0-4f1a-9b8b-094b330c71b7)). Its flat-context claim is the design's, not a measurement.
- **Watch with autocompact covers the same ground.** Watch re-reads the whole card and thread on every event, so the board is the memory and a compaction drops little that would not be re-read. The Monitor survives a compaction as it survives `/clear`.
- **Two skills double the work.** Every change to watching is made twice: the open lease and move-receipt cards each touch `watch` and `dispatch` together.

## What moves into watch

1. **The arming sweep.** `dispatch/scripts/arm-pass.sh` moves to `watch/scripts/`. At arming, watch runs it and handles each line: an owner comment left unanswered while no watch ran, in any lane but Done; an unclaimed card in an agent lane; a claim that looks abandoned, reported to the owner and never released. Watch has no such sweep today. A new step in `watch/references/arming.md`.
2. **A compaction rule**, beside the `/clear` rule in `watch/references/arming.md`: after a compaction, re-read each board's authority chain before acting, and re-derive in-flight work (running builds, open claims, pending asks) from the board, never from the summary.

## What goes

- `skills/dispatch/` whole: `SKILL.md`, `references/handler.md`, `references/routing.md`, `templates/handler-prompt.md`, `templates/handler-report.md`, `scripts/classify-event.sh`, `scripts/state.sh`.
- The three places a removed skill touches: the folder, the `skills` list in `.claude-plugin/plugin.json`, and the skills table, install commands and § Sizes in `README.md`. Then the board's `Skill` label value and the label list in the board body.
- `skills/watch/SKILL.md` line 11, which points at dispatch as the flat-context mode.
- The `tests/smoke.sh` cases for `classify-event.sh` and `state.sh`. The `arm-pass.sh` cases stay, repointed at `watch/scripts/`.

## Shaping settles

- **Model tiers.** Dispatch holds the ruling that handlers run on Sonnet and builds on Opus (`dispatch/references/routing.md`). Whether watch takes that over, or keeps to `work/references/tiers.md` as it does now.
- **`arm-pass.sh` output.** It prints the seven fields `classify-event.sh` prints, for a router. Whether watch reads them as they are or the script is trimmed.
- **`classify-event.sh`.** Dropped, or kept somewhere for the board runner, which will need to class events without a model.
- **Stale claims against leases.** The lease cards replace claim comments with `claimed: {by, until}`. Which lands first decides what "abandoned" reads.
- **The two Active dispatch cards**: closed as withdrawn with the reason, since the trial they wait on will not run.
- **Open cards that name dispatch**: [the session stakes a lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233) and [read a move receipt](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/42019d3d-d517-40da-956d-6962c771b9a2) lose their dispatch half.
- **Users on `/lanework:dispatch`.** The changelog entry tells them to use `/lanework:watch`.

## Release

A removed skill is a major bump by this repo's rule: 1.0.0.

## Risk

A compaction in the middle of a build cycle the watch session is leading. The rule above is the mitigation; it is untested until a watch session has compacted mid-build and recovered from the board.
