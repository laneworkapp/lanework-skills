---
schema: 1
kind: comment
created:  {at: 2026-11-07T13:34:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-11-07T13:34:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Both calls are ruled and written into the body, so the proposal moves to Proposed.**

- **Decided**: the check walk is a `review-trace.md` attached to the verdict comment, on adversarial reviews only. A standard review writes none.
- **Decided**: reviewer verdicts only. The fixer phase templates and `work/references/fixer.md` drop out of Files.
- **Evidence**: `tests/smoke.sh` exits 1 with 123 checks ok, and the only failure is the guide gate, v107 against v101. A search of the app's source at `Lanework/` finds no `VERDICT:`.
