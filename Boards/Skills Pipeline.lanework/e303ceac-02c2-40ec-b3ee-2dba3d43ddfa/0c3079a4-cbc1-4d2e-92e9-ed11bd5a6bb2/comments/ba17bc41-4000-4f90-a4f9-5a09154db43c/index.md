---
schema: 1
kind: comment
created:  {at: 2026-11-24T00:46:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-24T00:46:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Slice 2 landed on main: the suite has 29 named sections, and one can be run alone.**

- **Run alone**: `tests/smoke.sh --list` names the sections. `--only a,b` runs those, in file order, and ends `smoke: <n> passed (sections: a, b)`. A bad name or flag exits 2 before anything runs.
- **Full run unchanged**: `smoke: 419 passed` in 33 min 50 s, which is 418 plus one new case for the runner. The ordered list of case names is otherwise identical to before.
- **Fixtures**: a section names the boards it reads with `needs fixture_<x>` lines. A fixture does nothing in a full run and builds the board under `--only`.
- **Each section alone**: all 29 pass. The per-section counts sum to 419.
- **Found on the way, fixed here**: plan listed a ticket's dependencies in relation-folder order, which is random, so one case failed about half the time alone. Dependencies are now listed by ticket number. The case passed 10 of 10 after the fix and failed 2 of 2 before it.
- **Review**: first pass asked for changes. The tightened kill guard had lost forms the old one caught, such as `pkill -f"x"`. Fixed, with 14 samples in its self-check. One form is knowingly not caught: a comma right after the flag.
- **Not run**: a full suite after the review fixes. The affected sections were each run alone. The next full run closes slice 3.
- **Slice 1 nits**: the guard catches long flags, and its variable is renamed. The 10-minute stand-ins are unchanged.
- **Commits on main:** `cf1f6901`, `65e58381`, `ab2f5acc`, `97249967`.
