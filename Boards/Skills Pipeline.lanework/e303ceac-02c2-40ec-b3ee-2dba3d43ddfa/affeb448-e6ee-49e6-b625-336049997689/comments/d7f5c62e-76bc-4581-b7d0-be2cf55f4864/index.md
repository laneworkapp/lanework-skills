---
schema: 1
kind: comment
created:  {at: 2026-11-28T06:04:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T06:04:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: `heal-board.py` is at heal v6, merged and pushed, and the full test run on `main` is green with the side-by-side comparison running.**

- **Commits on `main`**: `3d6c3488` (the port, rule ids, the later version wins, `writes.md`), `d853e097` (smoke cases, the drift note, the `release.sh` warning, the repo `CLAUDE.md` stamp), `1a969a7f` (one smoke fixture), `c90590f4` and `2060ca33` (the reviewer's notes 1 to 3).
- **Gate (measured, on merged `main` at `2060ca33`)**: all 31 sections, run as five parallel groups, each exit 0: `62 passed` (lease), `113 passed`, `81 passed`, `119 passed`, `67 passed`. The heal cases ran against this board's v6 healer on disk: three rows end "(the same call as the board heal v6)".
- **Review**: approved in one round, with nothing blocking and five notes. The reviewer healed four boards of its own with each healer and found the output, files and records identical. Notes 1 to 3 were then fixed, and the lead read that change.
- **Done differently from the card**:
  - The line saying which copy runs goes to stderr, so stdout keeps the format `HEAL.md` gives.
  - A board copy that cannot be read, or is not a file, heals with the skills' copy and says so in its own line.
  - The old "heal defers" smoke case is replaced by stub healers at v5, no version, v6 and v7.
- **The comparison on GitHub is skipped**: the repo's committed copy of this board's healer is v5, so the run there prints a note and skips the side-by-side cases. The port's own behaviour is still tested there. Committing this board's `.schema/` folder would turn the comparison on; the app wrote those files, so that commit is the owner's.
- **For the app, found on the way** (none fixed here):
  - The app healer accepts `--name anyone`. Its `RESERVED_NAMES` lacks `anyone`; the skills' healer refuses it.
  - An apply interrupted under one healer and finished by the other posts a second record, because the record names the script that ran. Both healers do this.
  - Both healers write through a card folder that is a symlink pointing outside the board.
- **Not checked**: a real board whose `.schema/` the app wrote, opened in the app; `release.sh` run for real (its smoke case only).
- **Changelog sentence, for the next release**: "Board repair by the skills now keeps values it used to drop, records on the card what it replaced, and matches the app's own repair."
- **Not released**: this rides the next minor release, which is the owner's call.
