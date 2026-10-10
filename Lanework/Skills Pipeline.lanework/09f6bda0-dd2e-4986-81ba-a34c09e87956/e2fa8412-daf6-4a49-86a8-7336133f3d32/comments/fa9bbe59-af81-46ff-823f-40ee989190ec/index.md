---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:47:38Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T00:47:38Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**FAIL-BEFORE: the new smoke cases fail on the unchanged skills, at the Decisions lane.**

- **Command**: `bash tests/smoke.sh <scratch>` at merge-base c152c5b (skills unchanged, new cases only in tests/smoke.sh), exit 1.
- **Observable**: the founded discovery board has no Decisions lane. The later cases (config kinds, `file-record.sh`) are never reached; the script does not exist yet.

```
ok 21 - settled with chat record in reply to the ask; parked
ok 22 - discovery board validates
sed: : No such file or directory
Decisions lane missing or out of order
```
