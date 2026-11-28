---
schema: 1
kind: comment
created:  {at: 2026-11-28T04:33:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T04:33:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**START: building this in a worktree on branch `healer-v6`.**

- **Base**: `main` at `3a379e98`, with the signature change merged.
- **Plan**: the rules first, one at a time against the board's v6 healer on throwaway boards, with the side-by-side smoke case for each. Then which copy runs, the rule ids in the output, `writes.md`, the drift note and the release warning, and the repo `CLAUDE.md`.
- **Found before starting**: the repo's committed copy of this board's healer is still v5. The v6 file is on disk only, as an uncommitted app write. So a worktree, and the test run on GitHub, both see v5.
- **Decided for that**: the side-by-side cases run when the board's healer is at the version the skills target, and are skipped with a note when it is older. `SMOKE_BOARD_HEALER=<path>` points the cases at another copy, so the worktree is tested against the v6 file on disk. The full run on merged `main` reads the v6 file directly.
- **Left for the owner**: committing this board's `.schema/` folder would let the run on GitHub make the comparison too. The app wrote those files, so that commit is not an agent's to make.
- **Gate**: the heal sections on the branch, the full run on merged `main` as parallel section groups, and a separate reviewer.
