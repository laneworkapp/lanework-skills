---
schema: 1
kind: card
title: "Guide moved to v120: bump the stamp and re-copy the app-write fixtures"
order: 107520
labels: [{text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T21:00:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T12:32:54Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The app moved this board's agent guide from v118 to v120 in two steps, and the skills are still stamped v118 in the repo's `CLAUDE.md`. Smoke prints a note and `scripts/release.sh` prints a warning on every run until the stamp catches up.

## Evidence

- Board guide, line 1: `lanework-agent-guide v120`. Repo `CLAUDE.md`, line 28: `lanework-agent-guide v118`. Schema is `lanework-schema v1` on both sides.
- v118 to v119, by `diff` against a v118 copy: the version line and the "Ready-made skills" paragraph. v119 points at the plugin in `lanework-marketplace` and names no skills.
- v119 to v120, by comparison with a board still on v119: the app-settings paragraph no longer lists `templates-repo`. `grep -rn templates-repo skills README.md tests` returns nothing.
- No rule about reading or writing a board changed in either step.
- `README.md` lines 151 to 161 still give clone-and-link steps, labelled "By hand, to follow `main` instead". That is an alternative to the plugin install, not a contradiction of the guide, and stays.
- The 0.10.0 release ran with the stamp at v118 and printed the warning.

## Proposal

One change, in the order the repo's `CLAUDE.md` names for a guide move.

- **Read-through**: read the two changed paragraphs against every skill. Expected result: no drift, on the evidence above. Any drift found is fixed in the same branch.
- **Fixtures**: re-copy the app-written files in `tests/fixtures/app-writes/` from fresh app writes in the board's git history, and update the ids at the top of the `appside` case in `tests/merge-case.sh`. The rule asks for this at every bump, and fresh writes exist (the owner's moves of 2026-11-22). `tests/fixtures/app-writes/README.md` gets the new sources.
- **Stamp**: `CLAUDE.md` line 28 to `lanework-agent-guide v120`.

Files touched: `CLAUDE.md`, `tests/fixtures/app-writes/*`, `tests/merge-case.sh`. Nothing under `skills/` unless the read-through finds drift.

## Risks

- The fixture re-copy changes the bytes the merge `appside` case runs on. A new app write could expose a real merge difference: that would be a finding, filed as its own card, not hidden by keeping the old fixtures.
- The guide can move again before this lands. The stamp then goes to whatever the board carries at build time, after the same read of the new diff.

## Verification

- `tests/smoke.sh` passes and prints no note about a newer guide version.
- `scripts/release.sh <next> --dry-run` prints no stamp warning.

## Done when

- `CLAUDE.md` carries the board's guide version.
- The fixtures and their `README.md` sources are from app writes made under that version or later.
- The closing record states the read-through result, one line per changed guide paragraph.

## Release

A guide-version move is a minor bump under the repo's rule, so the next release is 0.11.0. It can ride with other work.

## Open calls

None.
