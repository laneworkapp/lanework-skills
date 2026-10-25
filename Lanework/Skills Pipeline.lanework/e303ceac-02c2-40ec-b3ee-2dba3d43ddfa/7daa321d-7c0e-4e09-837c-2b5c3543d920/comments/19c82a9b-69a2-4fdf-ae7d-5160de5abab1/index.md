---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:42:42Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T10:42:42Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**Done: the catalog's `type` kind now carries `icon: {glyph: cube}`. Merged to main as `5924a40` and pushed.**

- **Evidence**: `tests/smoke.sh` run on main at `5924a40`, in a clean checkout: `smoke: 118 passed`, with 118 ok lines. That includes the new `--labels type` glyph assertion and the guide-stamp gate (v93). The raw run is attached.
- **Evidence**: the reviewer approved in round 1 with the adversarial stance, and its own fail-before run at `f9ba99c` agreed with the fixer's.
- **Accepted limitation**: boards founded before this keep `square.grid.2x2` until their labels are re-stamped, which the body puts out of scope.
- **Accepted limitation**: the main tree's board guide is now v101, uncommitted, against the skills' v93 stamp. Smoke will fail once that guide is committed, until the skills are read against v101 and the stamp is bumped. That drift belongs on its own card.
- **Teardown**: the branch `type-kind-cube` and both worktrees are removed.
