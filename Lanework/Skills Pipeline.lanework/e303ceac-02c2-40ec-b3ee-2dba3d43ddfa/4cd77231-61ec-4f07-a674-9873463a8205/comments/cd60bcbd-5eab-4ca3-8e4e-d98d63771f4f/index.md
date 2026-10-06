---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:45:39Z, by: {name: reviewer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T22:45:39Z, by: {name: reviewer, kind: agent, model: sonnet}}
---
**VERDICT: APPROVE** (STANDARD, round 1)

**CARD**: Skills Pipeline/Issues, "Smoke fails on main: plugin validate --strict rejects the repo's own CLAUDE.md"
**BRANCH**: smoke-plugin-validate at db5c05a (merge-base 95549b3)

**BLOCKING**: none

**NOTES**: 3
- tests/smoke.sh:104 @ db5c05a "grep -E '^ +❯ '": fail-open on format drift. If a future CLI prints warnings without the `  ❯ ` marker and exits 0, the step passes silently. Could also key off the "Validation passed with warnings" summary line. Non-blocking: card scopes the filter to the known warning shape.
- tests/smoke.sh:104 @ db5c05a "root: CLAUDE.md at the plugin root": the known-warning match is a fixed string of the current 2.1.292 wording. A CLI rewording turns it into a loud failure (fail-closed), which is the safe direction.
- Board hygiene: fixer comment folders aaaa0001-0000-4000-8000-000000000001 and aaaa0002-0000-4000-8000-000000000002 use hand-made ids, not uuidgen.

**CHECKED**:
  correctness vs done-when: OWN RUN in the worktree: `bash tests/smoke.sh` exit 0, "smoke: 20 passed". Warning-only negative on a temp copy (bogusfield added to plugin.json): CLI prints the bogusfield warning plus the CLAUDE.md one, smoke exits 1 with "plugin validate: unexpected warning". Only the one known warning is accepted.
  project conduct:          one file changed (tests/smoke.sh), no board writes in the branch; no assumed-Y shapes.
  both paths:               errors fail via exit status (`|| { ...; exit 1; }`), warnings via the filter; `claude` absent still skips (CI unchanged).
  fail-before:              FIXER RUN checked (exit 1 at 95549b3 at this step); consistent with the card's reproduce.
  test adequacy:            the change is in smoke.sh itself, same ok-numbered step 20; negatives exercised by fixer and me on temp copies.
  blast radius:             one hunk in tests/smoke.sh matches the card's Files line; no churn.
  population:               n/a (single step).
  bash portability:         bash 3.2.57 is the shell here and ran it. The grep|grep -v pipeline ends in `|| true`, so no-match (status 1) under set -euo pipefail doesn't abort; `V=$(...) ||` is guarded; `[ -z "$W" ] || {...}` is safe under set -e.
  silent-pass reasoning:    empty CLI output with exit 0 gives empty W and passes; acceptable (nothing to flag), see NOTE 1 for the different-format case.

**UNRESOLVED**: none
