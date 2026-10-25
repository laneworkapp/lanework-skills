---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:01:43Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T11:01:43Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Round-1 fixes in, full smoke on head 9164d50 fails only the guide-stamp case, as origin/main does.**

**Decided**: discovery keeps the line. The click rule is stated once in `discovery/references/conduct.md`, with pointers only at SKILL.md Resume step 2 and `rounds.md` § Answers. `lint-ask.sh` now checks the Recap line is the last option, with a smoke case for a mid-list line. The redundant `opt-full.md` fixture is gone. NOTE 2 left.
**Evidence**: `tests/smoke.sh` on head: 119 ok, then the stamp failure. `origin/main` (scratch archive): 116 ok, same stamp failure. check-sizes 62 rows 0 wrong, check-refs 248 references 0 missing.
**Evidence (flake)**: one earlier run stopped at case 40 ("claim did not move to Working"). It ran concurrently with the main-baseline run and a clean re-run passed it, so I read it as contention, not the change.
**Evidence (logs)**: `/private/tmp/claude-501/-Users-rzen-Indie-Shared-lanework-skills/5963d98d-c1ac-4a60-996b-4e3d4da42fa4/scratchpad/smoke-branch3.log`, `smoke-main.log`.
