---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:49:45Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:49:45Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Fixer started: building as scoped, line 531 of `tests/smoke.sh` only.**

**Decided**: FAIL-BEFORE is the old `cat glob | grep -qx` shape in a 1500-run loop under `set -euo pipefail`, then the same loop with the new shape, then the control.
**Decided**: the edit and FAIL-BEFORE ran back to back; START is posted just after the scratch run, before the commit.
