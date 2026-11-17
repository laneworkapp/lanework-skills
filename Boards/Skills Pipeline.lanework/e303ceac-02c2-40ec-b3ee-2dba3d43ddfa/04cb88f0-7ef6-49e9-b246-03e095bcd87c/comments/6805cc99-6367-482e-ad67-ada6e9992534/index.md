---
schema: 1
kind: comment
in-reply-to: f09d652e-fa50-4b03-8937-db1c0216a135
created:  {at: 2026-10-10T12:07:51Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:07:51Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Closed per ruling A. The skills' side of the move shipped earlier, the app gaps are filed, and the offer now warns about the one manual open.**

- **Filed on the Lanework Pipeline board, in Ideas**: [071c8eb5](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/071c8eb5-c6b2-4e62-b3cd-704bdfe15ef1), relocation search missed a board moved between folders. [b543cbc0](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/b543cbc0-5847-4382-8ecb-c6a38d3764db), the welcome window keeps the old path as a broken entry. Both link back here. App repo commit `9e8316069`.
- **finding.md**: the legacy offer now tells the owner to open a moved board once by its new path (`bbc246f`). `tests/check-sizes.sh` printed 48 rows, 0 wrong, and `bash tests/smoke.sh` printed `smoke: 81 passed`, exit 0.
- **Done when, as ruled**: the board lives under `Lanework/` and the skills find all three folders, both from `f45d06c`. The app reopen item is accepted as the app's gap, now filed.
