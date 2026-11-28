---
schema: 1
kind: comment
created:  {at: 2026-11-28T04:31:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T04:31:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: every board-writing script now leaves the signature file, merged and pushed, and the full test run on `main` is green.**

- **Commits on `main`**: `4c18a78a` (the writer `sign-board.py`, `sign_board` in `lib.sh`, `writes.md` § Signature), `07afc9d1` (16 scripts sign after a write), `0d7b60ee` and `84d8954c` (smoke cases), `1bbf3b68` (README), `09abbf58` (only regular files are opened, and the round-2 notes), `558da24e` (merge and heal sign only what they wrote), `d95a45ce` (usage error on a wrong argument count).
- **Gate (measured, on merged `main` at `d95a45ce`)**: all 31 sections, run as five parallel groups, each exit 0: `62 passed` (lease), `106 passed`, `81 passed`, `119 passed`, `67 passed`. The runner checked that the groups cover every section `smoke.sh --list` names exactly once.
- **First full run failed**: the serial run on the round-2 merge stopped in `usage_guard` with "sign-board.py with no arguments exits 0, want 2". Nothing was pushed. The fix is `d95a45ce`; given a board, the writer still always exits 0.
- **Review**: round 1 asked for changes, because a named pipe at the signature's path hung every writer. Round 2 approved, with nothing blocking. The lead read the round-3 change (ten lines) and accepted it without a third review round.
- **Done differently from the card**:
  - `merge-board.sh` signs only the boards its pass changed, not every board with staged paths.
  - `heal-descriptors.py` signs only after a written change.
  - The `found-board.sh` call can never fire, because founding refuses a non-empty folder. It is left as a harmless no-op.
- **The one limit, as the card ruled**: a board is signed only where its `.gitignore` holds the app's `.*.lanework-*` line. A board the plugin founded and the app never opened stays unsigned until the app's first open.
- **Left as it is**: a non-UTF-8 byte in a board's `.gitignore` leaves that board unsigned (the reviewer's round-2 note; safe, and the app writes the file in UTF-8).
- **Not checked**: the app reading the file, and a real install record (fake records only).
- **Changelog sentence, for the next release**: "Lanework scripts now leave a small signature file in each board they write to, so the Lanework app can tell which plugin version is working the board."
- **Not released**: this rides the next minor release, which is the owner's call. The app's watch session is being told the shape is on `main`.
