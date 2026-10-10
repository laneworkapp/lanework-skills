---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:51:45Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T00:51:45Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Verified: smoke green and a scratch round settled one ADR card and one PDR card. Commit e38f8f5 on `adr-lane`.**

- **Gate**: `bash tests/smoke.sh; echo $?` in the worktree: `smoke: 42 passed`, exit 0 (cases 23 to 27 are new; `check-refs.sh` case passes).
- **Scratch round** (a board under `$TMPDIR`, not this one): founded a discovery board, filed Q1 and Q2, `file-record.sh` filed `ADR: In-process cache` and `PDR: Entries expire after 5 minutes` into Decisions, each ruling linked its card, both questions settled. Validator: `failures 0`, `deprecated 0`. No `docs/adr` or `docs/pdr` created. Labels on the ADR card: `{text: ADR, rank: 1, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}`.
- **Decided**: `file-record.sh` takes the question's card uuid and runs before `settle-question.sh`, so the ruling can carry the record link. It does not require the question to be in Settled yet.
- **Decided**: older boards get the lane and kinds on resume (`board.md` § Older boards, `SKILL.md` Resume step 3).
- **Decided**: README sizes re-measured with `wc -w`, date now 2026-10-09.
