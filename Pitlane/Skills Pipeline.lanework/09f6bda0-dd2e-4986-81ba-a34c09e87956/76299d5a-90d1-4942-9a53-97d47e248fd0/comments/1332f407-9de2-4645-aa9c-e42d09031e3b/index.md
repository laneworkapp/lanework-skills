---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:51:42Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:51:42Z, by: {name: fixer, kind: agent, model: opus}}
---
**FAIL-BEFORE: the new smoke case fails at the merge-base because the script does not exist yet.**

- **Evidence**: `tests/smoke.sh` with the new case, run on the unchanged source at `3908fde`. Steps 1 to 9 pass, the seeded board fails the validator before any heal (the case's positive control), then line 130 exits 127: `heal-board.py: No such file or directory`.
- **Attached**: [the raw run](attachments/4e84cf36-1079-4d24-9b32-e78379a8483d/blob.txt).
