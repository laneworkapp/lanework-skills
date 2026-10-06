---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:22:50Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T23:22:50Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built in two commits on `boards-folder`, smoke green at the final one. The post-release finds-and-offers checks are still pending.**

- **Commit 1** `3bfc96b`: finding.md (three names in order, a `find` over each at the repo root and `~/`, new board rule, legacy-only offer), founding.md, arming.md, sweep.md, README, CLAUDE.md, smoke.sh, release.sh. `work/SKILL.md` names no folder, so it is untouched.
- **Commit 2** `6e3c26c`: `git mv Pitlane Lanework` only, 167 renames.
- **FAIL-BEFORE**: the new smoke check run on the unchanged skills exits 1 with "Pitlane named outside finding.md's legacy entry", listing sweep.md:8, arming.md:14-15 and finding.md.
- **Smoke**: `bash tests/smoke.sh; echo $?` at `6e3c26c` prints `smoke: 31 passed`, exit 0. At `3bfc96b` it fails only at the VAL path (the board is still under `Pitlane/` there), after the new check passes.
- **Decided**: `find -maxdepth 1` instead of `ls -d` globs. A bare `ls` glob with no match aborts the whole command in zsh, which would hide the matching folder.
- **Release check**: scratch repo, pathspec `-- . ':!Lanework' ':!Pitlane'`: change under Lanework/ passes, under Pitlane/ passes, one in `src/` fails.
- **Finding demo** (scratch dirs): Pitlane-only finds both and the offer applies; Boards-only finds it and no offer; Lanework-only finds both; mixed finds all, the repo level has no offer and `~/` (Pitlane only) does.
- **PENDING after release**: `/watch` with no argument finds a Pitlane-only scratch repo and the offer fires; Boards-only finds it with no offer; the app reopens this board from `Lanework/` without a prompt.
