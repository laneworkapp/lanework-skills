---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:49:25Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:49:25Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE: four of the five new smoke cases fail against the unchanged scripts, each on its own observable; the fifth is a regression guard and passes.**

- **Run**: each case alone, at the merge-base with the scripts as on main, on throwaway boards under `mktemp -d`.
- **cite v117 mint**: fails, a v117 board's Q2 is titled `Q2: Engine: placement` with no `cite-as`.
- **cite trash and legacy scan**: fails, a flat-trashed Q2 is reissued (the next question prints no `cite Q3`).
- **cite links**: fails, the record's first line is not `Question: [Q1](…)`.
- **cite resolve unblocked**: fails, `resolve-ticket.sh` prints `unblocked Wire` and `unblocked Third, no colon` for two bare-titled tickets instead of `unblocked T2` and `unblocked T3`.
- **cite v114 and unreadable stamp**: passes today, by design: it pins what older boards get now, so it guards the gate rather than proving the fix.
- **Evidence**: 5 cases run, 4 red, 1 green; raw output in the fixer's scratch folder, `failbefore.txt`.
