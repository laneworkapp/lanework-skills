---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:38:42Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T11:38:42Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
**Done: merged to main as `03fa721` (branch `recap-option` at `b866d24`). Every ask with options now ends with the `Recap` option, and the lint requires it.**

**Evidence**: `tests/smoke.sh` on main after the merge printed `smoke: 124 passed`, exit 0, including `ok 123` for the stamp at v101. That is the 121 cases on main plus 3 new lint-ask cases. The fixer's run on `b866d24` gave the same result, with check-sizes 62 rows and 0 wrong, and check-refs 248 references with 0 missing.
**Evidence**: done-when 1–4 were checked by the round-2 review (da706cf1, APPROVE). Done-when 5 is the run above.
**Different from the body**: the discovery rules also learned that a `Recap:` click is not an answer (lead ruling c90ab7dd). The lint also checks that the Recap option comes last.
**Decided**: the approval came before the rebase onto guide v101. The rebase conflicted only in the README word counts. check-sizes confirmed those counts, so there was no third review round.
**Filed**: the reviewer's flake note became [34d09bf2](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/34d09bf2-833a-4bd5-946f-8df57780459e) in Issues. The note about case 49's name was dropped.
