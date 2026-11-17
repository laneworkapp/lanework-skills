---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:35:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: the four board-write helpers are on main. Not released: they ship with 0.9.0, the owner's to cut.**

- **Merge**: `e53a5f0` on main, from branch `work-helpers` at `8647cd8` (two commits).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 168 passed`, exit 0. Before: 152. Added 16 cases.
- **Review**: adversarial. Round 1 request-changes, round 2 approve at `8647cd8`.
  - Found and fixed: `commit-board.sh` killed mid-push left the reverse of the board change staged. A smoke case now kills it with SIGKILL and SIGTERM.
  - Found and fixed: the same-second ask case caught a broken wait 3 times in 6. Now 8 of 8.
- **Done-when**:
  1. Four scripts under `skills/work/scripts/`, executable, `bash -n` clean. Met.
  2. Smoke cases exist and smoke passes, `check-refs.sh` and `check-sizes.sh` included. Met.
  3. `SKILL.md`, `writing.md`, `traps.md`, `lanework/references/writes.md` cite them; README § Sizes matches `wc -w`. Met. `templates/ask.md` also cites `post-ask.sh`, by lead's ruling.
  4. Every defect D1 to D14 has a failing-then-passing case. Met: 14 of 14 fail on the original scripts, 14 of 14 pass on the new ones.
- **Not covered, a gap in the body**: "the caller's own value of a `single` kind wins" for `file-card.sh`. The script has no label flag, so no case can reach it.
- **Real run on a scratch board** (fixer's record 65c3cda2): file into an empty lane gave `order: 1024`; move posted its record; the ask set `waiting` with `since` equal to the ask time; commit with `--push` and one trailer left origin equal to HEAD.
- **Left in the script, stated in its header**: a SIGKILL between `git commit` returning and the next line shows the path as `MM`; `git reset -q -- <path>` repairs it.
- **Filed**: [six review notes](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/5ca41314-0792-4f4c-8e53-0d771d1a8dca) in Issues.
