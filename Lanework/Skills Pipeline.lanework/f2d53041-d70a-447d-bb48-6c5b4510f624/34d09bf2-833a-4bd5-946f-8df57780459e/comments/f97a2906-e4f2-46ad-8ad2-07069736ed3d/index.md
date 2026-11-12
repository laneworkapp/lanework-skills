---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:49:47Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:49:47Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**FAIL-BEFORE reproduced: the old pipe returned 141 in 586 of 4500 runs; the new line, 0 of 1500.**

**Evidence**: scratch board under the session scratchpad, 4 comment files, the Claimed line in the first, `set -euo pipefail`, 1500 iterations per run.
- Old shape `cat "$PL"/*/"$T1"/comments/*/index.md | grep -qx ...`: 235, 177 and 174 failures (586 of 4500).
- New shape `grep -qx ... "$PL"/*/"$T1"/comments/*/index.md`: 0 of 1500.
- Control: the new shape passes with the Claimed comment present, and fails with it removed.
**Evidence**: merge-base `36d9fa3`; the fix is `8aaf6ef` on `smoke-sigpipe-34d09bf2`, one line changed, rebased on `cacbd42`.
**Attached**: `fail-before.txt`, with the loop scripts' output.
