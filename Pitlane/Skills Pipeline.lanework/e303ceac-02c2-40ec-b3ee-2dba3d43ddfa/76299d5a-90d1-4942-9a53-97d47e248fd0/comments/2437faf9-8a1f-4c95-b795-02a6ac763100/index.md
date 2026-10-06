---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:09:03Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:09:03Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Merged to main as `fc31b4c`. One command heals a damaged board to a clean validator run, with or without the app, and never restamps.**

**Restamp**: the ask went unanswered, so its default B applied at merge. The heal leaves `modified` alone, like the app's heal, and the body line is edited to match.
**Evidence**: `bash tests/smoke.sh; echo $?` on main at `fc31b4c` printed `smoke: 29 passed` and exit 0. The adversarial review approved in round 2 after two blocking parse fixes, and its own runs reproduced both bugs and their fixes. Throwaway copies of two real boards heal clean, and a second run changes nothing.
**Accepted limitation**: `modified-by` with no `modified` folds into a stamp with no `at`. A lane or board whose `modified-by` names a different writer is a skip, so DEPRECATED stays on it. Numbers in a rewritten list lose a trailing `.0`. A title holding ` #` is a skip.
**Cross-post**: [the app's copy](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/9340580b-ccef-4fc4-b439-cc618cd63023) should follow the same rules: it never restamps, delimiters sit at column 0, and records post before files change.
