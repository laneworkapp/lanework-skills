---
schema: 1
kind: comment
created:  {at: 2026-11-21T15:43:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to main at `b01fbc3` (branch `settle-leftovers`, head `e5e2329`).

**Changed**: `settle-question.sh` refusal names the newest ask and why the record did not answer it; stages only comment `index.md` files; tells a missing lint script from one that is not executable. `rounds.md` Recap wording. Smoke cases for each.

**Review**: approved, no blocking findings.

**Evidence**: `tests/smoke.sh` on main at `da2bf8a`: `smoke: 331 passed`, rc 0. check-sizes 57 rows 0 wrong; check-refs 246 references 0 missing.

**Left open**: `rounds.md:34` says a `Recap:` click is not an answer, but a settle with no `--record` still clears a waiting card whose only owner comment is a Recap click. Filed as its own Issues card.

**CHANGELOG**: Refusing a settle now says which ask is the newest and why the record did not answer it.
