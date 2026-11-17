---
schema: 1
kind: comment
created:  {at: 2026-11-17T22:12:43Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Built at `168bc45` on `active-lane-sentence`, pushed. `tests/smoke.sh`: `smoke: 241 passed`, exit 0 (main 240, plus one new case; the heal cases changed in place).**

- **FAIL-BEFORE** (measured, on a throwaway founded board whose Active body was set to the v0.8.0 body, unchanged heal script): the dry run printed `lane set: pipeline` / `0 changes in 0 files`, where the new smoke case wants `lane Active: replace-body` and `4 changes in 4 files`. The grep gate printed two hits (`heal-descriptors.py` and `pipeline-lanes.md`), where it wants one. The full smoke was not run on the unchanged tree.
- **Built**: Active row of `pipeline-lanes.md` carries the ruled sentence. `OLD_BODIES["pipeline"]["Active"]` gains the v0.8.0 body (taken from `git show v0.8.0:`), the old predecessor kept, the comment now says "up to the v0.8.0 release". Smoke: Active setbody, `replace-body` and `4 changes in 4 files` in the dry run, Active equal to the template and restamped after `--apply`, plus a new gate (phrase only in the heal script, a founded board's Active body holds the lease sentence).
- **Done when**: all four met. `py_compile` passes on the heal script.
- **Departure**: the grep gate uses `--exclude-dir=__pycache__`, since a compiled `.pyc` of the heal script also contains the phrase and tripped the first smoke run. No other file touched; README word counts did not move (check-sizes ran inside smoke).
