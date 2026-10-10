# Finding boards

Defaults, not rules. Three folder names, checked in this order, at the repo root and again at `~/`:

| # | folder | note |
|---|---|---|
| 1 | `Lanework/` | preferred |
| 2 | `Boards/` | plain alternative |
| 3 | `Pitlane/` | legacy; offer to rename (below) |

- `<repo root>/<folder>/<Name>.lanework`: a project's boards, in its git repo, so history travels with the code. A work pipeline is typically `<Project> Pipeline.lanework`.
- `~/<folder>/<Name>.lanework`: machine-level boards, no single project.

```bash
for r in "<repo root>" "$HOME"; do for f in Lanework Boards Pitlane; do find -H "$r/$f" -maxdepth 1 -type d -name '*.lanework' 2>/dev/null | sort; done; done; true   # the last is legacy
```

- `find -H`, not a bare `ls` glob: zsh aborts the whole command on one empty glob, and BSD `find` won't enter a symlinked `~/Lanework` (iCloud, Dropbox) without `-H`. `; true` keeps a missing folder from failing the command.
- Boards under more than one folder = several boards, not an error. Take the union, keep the order.
- **New board** → the first folder that exists, else `Lanework/`. Unsure which project or level → ask.
- A path the user names, or a location declared in the project's `CLAUDE.md` or a board's body, beats all of this.
- **Never scan the filesystem.** The project is the work at hand or the one the user names; its three folders are the whole answer.

## Legacy offer

Boards found under the legacy folder and under no other of the three, at one level (repo or `~/`) → offer once, in chat, to move it to `Lanework/`.

- Before moving: no worktree or other session may be writing under the folder. Any → ask first, don't move.
- Repo: `git mv` the folder, commit the move on its own. `~/`: plain `mv`, not a repo.
- No stands for the session: don't ask again.
- Never fires when `Lanework/` or `Boards/` holds a board there; never on `Boards/` alone.
- After moving, re-arm any `/watch` on the moved board: its path changed.
- Tell the owner: open the board once by its new path. The app doesn't find a moved board itself, and keeps the old path as a broken entry in its welcome window (observed 2026-10-10).
