# Finding boards

Defaults, not rules:

- `<repo root>/Pitlane/<Name>.lanework`: a project's boards, in its git repo, so history travels with the code. A work pipeline is typically `<Project> Pipeline.lanework`.
- `~/Pitlane/<Name>.lanework`: machine-level boards, no single project.

```bash
ls -d "<repo root>"/Pitlane/*.lanework
ls -d ~/Pitlane/*.lanework
```

- A path the user names, or a location declared in the project's `CLAUDE.md` or a board's body, beats both.
- **Never scan the filesystem.** The project is the work at hand or the one the user names; its `Pitlane/` is the whole answer.
- Where a new board goes matters and isn't obvious → ask.
