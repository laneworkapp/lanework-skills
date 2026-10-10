---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:55:00Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:55:00Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and green. `bash tests/smoke.sh` exits 0, "smoke: 45 passed", on commit 8628fa7 (rebased onto 3fcec39).**

- **FAIL-BEFORE** at merge-base `ffea864`, unchanged scripts: title case failed with `title: "Q5: C:\path \"x\"` (the backslash unescaped and the title cut at the newline). The no-model case, run with the title case bypassed, failed with `file-question: want exit 2 with usage, got 0`.
- **Evidence**: after the change both cases pass, and `grep -rn 'CLAUDE_MODEL:-unknown\|model: unknown' skills` finds nothing.
- **Other callers updated**: `tests/merge-case.sh` and `skills/lanework/references/founding.md` call `found-board.sh`; both now pass `--model`.
- **Other writers checked**: `heal-board.py` already requires `--model` with `--apply`. `lanework-merge.py` signs `{name: merge, ...}` without a model when none is given; it never stamps `unknown`, so it is left alone. No other script writes a title.
