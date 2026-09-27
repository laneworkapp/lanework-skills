# Reviewer verdict

Rules: `references/reviewer.md` § Verdict.

```
VERDICT: APPROVE | REQUEST-CHANGES

CARD:   <lane/<uuid> and title>
BRANCH: <branch> at <head sha read off the branch>

FINDINGS: <count>
  <one per line: file:line @ <short sha> "<quoted fragment>": what's wrong, why,
  fix direction. "none" if clean.>

CHECKED:
  correctness vs done-when: <what was compared against the card's observation>
  project conduct:          <repo CLAUDE.md bars checked; any "assume Y" shapes>
  both paths:               <second path handled, flagged, or why only one applies>
  test adequacy:            <fails before the fix: VERIFIED or REASONED>
  blast radius:             <Phase-2 actual vs Phase-1 expected; unexplained churn>
  population:               <every delta arrived with its denominator, or didn't>

UNRESOLVED: <questions for the lead, or "none">
```
