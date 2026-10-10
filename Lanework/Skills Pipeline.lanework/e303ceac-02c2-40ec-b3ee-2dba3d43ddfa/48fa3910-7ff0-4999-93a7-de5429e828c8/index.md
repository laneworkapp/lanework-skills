---
schema: 1
kind: card
title: "watch: re-read the skills when a release lands mid-watch"
order: 45056
labels: [{text: watch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T03:08:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T12:36:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
A watch reads its skill files once, at arming, so a skill change that lands while it runs never reaches it until it is re-armed. The watcher reports the change as an event, and the watch re-reads its rules when that event arrives.

## Seen

Three times on 2026-10-09/10: the Lanework Pipeline watch held a Proposed → Approved move as a gate decision after [0d374675](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0d374675-f23c-4959-95dc-07e10f99d345) shipped, and the Skills Pipeline watch ran without the new arming pass until it re-read by hand.

## Proposal

- **Fingerprint, not version**: a hash of the rule files the watch reads: every `*.md` under `watch/`, `work/SKILL.md`, `work/references/*.md`, and `lanework/references/{authority,board-kinds}.md`. A `plugin.json` version misses unreleased edits that a symlinked install sees on main. A fingerprint catches both installs, because it reads the files the session would read.
- **Skills root**: the folder holding the `watch` skill, resolved through symlinks (`${dir:A}`). A symlinked install resolves into the repo, and a plugin install into its cache.
- **`watch-boards.sh --skills <root>`** (optional, before the state file): the watcher keeps the fingerprint in `<state>.skills`, adds the root to fswatch, and recomputes the fingerprint on each burst. A change emits one line, `SKILLS CHANGED`. On start it compares with the stored value, so a re-arm after a release reports it too. Without `--skills`, behaviour is unchanged.
- **`events.md`**: a new item. On `SKILLS CHANGED`, re-read `work/SKILL.md`, `lanework/references/authority.md`, `board-kinds.md` and the three watch references, re-run the arming pass, and report what changed in one line.
- **`arming.md`**: the Monitor command passes `--skills <skills root>`.

## Touches

`skills/watch/scripts/watch-boards.sh`, `skills/watch/references/events.md`, `skills/watch/references/arming.md`, `tests/smoke.sh`, `README.md` § Sizes (re-measured; `tests/check-sizes.sh` names the rows).

## Verify

`tests/smoke.sh` passes, with two new cases on a scratch skills copy and a scratch board, outside the repo. Editing a rule file while the watcher runs emits `SKILLS CHANGED` once. Restarting with the same state after a rule-file edit emits it at start. A third check: an edit to a non-rule file under the root (a template) emits nothing, and the existing board cases are unchanged.

## Done when

The watcher emits `SKILLS CHANGED` for a rule-file edit, live and across a restart, `events.md` says what to do with it, `arming.md` passes `--skills`, and smoke covers both paths.
