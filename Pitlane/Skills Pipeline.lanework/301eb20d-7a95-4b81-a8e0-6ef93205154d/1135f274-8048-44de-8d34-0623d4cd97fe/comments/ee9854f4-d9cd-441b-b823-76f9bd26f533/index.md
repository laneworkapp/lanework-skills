---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:24:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:24:46Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Reported by a user who founded a board and found its lane bodies empty. The diagnosis holds.**

**Decided**: split rows on the ASCII unit separator (`\037`), which `read` never merges. Fix is in the working tree.
**Rejected**: keeping tab and putting a placeholder in empty cells. That changes the template format for a parser bug.
**Accepted limitation**: boards already founded keep their empty lane bodies until someone fills them in from the lanes template.
**Evidence**: `tests/smoke.sh` 19 of 19 with the fix. Without it, the run stops at check 5, the new lane-body check.
**Unaffected**: `read-board.sh` splits on tab too, but none of its fields can be empty.
