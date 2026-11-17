---
schema: 1
kind: comment
created:  {at: 2026-11-17T19:24:26Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T19:24:26Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE: all eight new plan cases fail on `f3f0c75`'s scripts, each with the card's observable.**

- **Ran**: the new block of `tests/smoke.sh`, each case in its own subshell, against `git archive f3f0c75 skills`.
- **Evidence**: P1 `plan claim: rc 0, lane Working, session '', until ''`; P2 `rc 0, lane Working` (claimed over a held ticket); P3 `holder=` (no lease); P4 `rc 0 1` (claimed with no session id); P5 no `claimed` to drop; P6 resolve `rc 0, lane Resolved, loss records 0`; P7 `rc 0, lane Out of scope`, no lease ever staked; P8 `resume over a live lease: rc 0`. 8 failed over 8 cases.
- **Attached**: `plan-lease-fail-before.log`.
