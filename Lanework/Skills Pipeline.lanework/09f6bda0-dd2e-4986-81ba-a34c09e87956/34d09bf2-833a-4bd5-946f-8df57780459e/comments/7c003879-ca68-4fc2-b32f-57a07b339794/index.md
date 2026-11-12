---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:49:18Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:49:18Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Shaped: one line (`tests/smoke.sh:531`) can return 141; the rest of the file cannot. Moved to Proposed.**

**Decided**: fix line 531 only, with `grep -qx '...' "$PL"/*/"$T1"/comments/*/index.md`. The done-when is narrowed from "every `| grep -q` and `| head`" to pipes whose producer writes more than once.
**Rejected**: rewriting the other single-write pipes, and `tests/merge-case.sh`. They cannot fire, and the diff would bury the fix.
**Evidence**: swept all 37 pipe lines in `tests/smoke.sh` under `set -euo pipefail`. Under pipefail, 1500 runs each: `cat` of 4 files into `grep -q` gave 92 failures; one-file `cat`, one-file `sed`, `ls | head -1` and `grep -l | head -1` gave 0. Replacement `grep -qx` over 4 files gave 0 of 1500 and no false pass. The card's line 429 is now 531.
**Accepted limitation**: `tests/smoke.sh` is red on `main` at its last gate (guide v114 against stamp v101), so "smoke passes" in the done-when means every case `ok` until the stamp moves. Cases 1-123 printed `ok`, 2m20s alone.
