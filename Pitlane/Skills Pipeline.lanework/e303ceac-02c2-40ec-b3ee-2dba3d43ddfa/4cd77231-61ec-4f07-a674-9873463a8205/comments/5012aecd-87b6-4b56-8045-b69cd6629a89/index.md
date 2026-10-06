---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:46:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:46:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Merged to main as `da61093`. Smoke passes end to end on main again.**

**Evidence**: `bash tests/smoke.sh; echo $?` on main at `da61093` printed `smoke: 20 passed` and exit 0, read directly rather than through a pipe. The reviewer approved in round 1, with its own run and its own warning-only negative.
**Accepted limitation**: the filter keys on the CLI's `❯` warning lines. If a future CLI prints warnings in another format, the step passes silently (reviewer NOTE 1). A changed wording of the known warning fails loudly instead.
**Not filed**: the fixer's hand-made comment ids. They are valid uuids and collide with nothing.
