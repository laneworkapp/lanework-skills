---
schema: 1
kind: comment
created:  {at: 2026-11-22T22:39:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T22:39:36Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: every note re-checked against `main` at `6e04933`. 21 still true, none already fixed, 2 not settled by reading, 3 closed as non-defects.**

- **Run, not read**: the Recap BOM and the 200 KB click both still settle; `lint-leases.sh` still reports a shaping handoff as `two STARTs`; the `lib.sh` fallback redirect has no case that would catch its removal.
- **Correction to a note**: the `label-card.sh` hold expiry is a flake, not a false pass. Past 20 s the existing case fails on its exit code.
- **Shape of the build**: one card, three branches merged in order: `settle-question.sh`; process hardening in four scripts; consistency and tests.
- **No smoke case for four items**: the `setsid` failure, the two signal windows and the memory-file race cannot be forced deterministically. Each gets the code fix and a line saying why there is no case.
- **Decision in the body**: an unreadable `--body`, `--ask`, `--index` or `--lanes` exits 2 everywhere. `file-card.sh` and `found-board.sh` move from 1 to 2.
- **Open calls**: none.
- **Release**: minor.
