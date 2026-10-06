# Reviewer verdict

Rules: `references/reviewer.md` § Verdict, `references/team.md` § Bounding review.

```
VERDICT: APPROVE | REQUEST-CHANGES
STANCE:  STANDARD | ADVERSARIAL (<the trigger>)
ROUND:   <1 | 2 | lead-ruled re-check>

CARD:   <lane/<uuid> and title>
BRANCH: <branch> at <head sha read off the branch>

BLOCKING: <count>
  <one per line: file:line @ <short sha> "<quoted fragment>": the failure scenario
  (input or state -> wrong result), fix direction. "none" if clean.>

NOTES: <count>
  <same anchor, one line each: never blocks; the lead may file it as a card. "none".>

CHECKED:
  correctness vs done-when: <what was compared against the card's observation>
  project conduct:          <repo CLAUDE.md bars checked; any "assume Y" shapes>
  both paths:               <second path handled, flagged, or why only one applies>
  fail-before:              <FIXER RUN checked | OWN RUN agreed | REASONED, and why>
  test adequacy:            <named and located like its neighbours>
  blast radius:             <Phase-2 actual vs Phase-1 expected; unexplained churn>
  population:               <every delta arrived with its denominator, or didn't>
  adversarial only:         <hypotheses written before the reports, and which held>

UNRESOLVED: <questions for the lead, or "none">
```
