# Lanework agent skills

The agent skills for Lanework boards, published as a Claude Code plugin named `lanework`. The files under `skills/` are the product. Everything else in the repo exists to build and track them.

## Layout

| path | what it is |
|---|---|
| `skills/<name>/` | one skill per folder: `SKILL.md`, plus `references/`, `scripts/` and `examples/` as needed. This is what ships, so nothing about this repo's own process goes in here. |
| `.claude-plugin/plugin.json` | the plugin manifest. Its `skills` list names every folder under `skills/`. |
| `Pitlane/Skills Pipeline.lanework/` | the development pipeline board: ideas, issues and work on the skills |
| `README.md` | the user-facing page: what each skill is for, and how to install it |

`docs/adr/`, `docs/pdr/` and `CONTEXT.md` are created the first time the `discovery` skill is run on this repo. `tests/` is created with the first script test.

## Working on a skill

- **Track the work on the board.** Read `Pitlane/Skills Pipeline.lanework/index.md` (its guide, `CLAUDE.md` inside the board, comes first once the app has opened it) and work cards as the `pitlane` skill describes. A change without a card starts as a card in Ideas, or in Issues if something is broken.
- **Adding, renaming or removing a skill** touches three places together: the folder under `skills/`, the `skills` list in `plugin.json`, and the skills table and install commands in `README.md`. Then add or rename the board's `Skill` label value to match.
- **Skills reference each other by sibling path** (`skills/discovery/scripts/file-question.sh` calls `../../pitlane/scripts/lint-ask.sh`), because users symlink each folder into `~/.claude/skills/<name>`. Keep the skills side by side under `skills/`.
- **Scripts target macOS bash and BSD tools** (`date -v`, `uuidgen`). Check every changed script with `bash -n`, then run it against a throwaway board in a scratch directory. Never test against the Skills Pipeline board.
- **The in-board agent guide wins.** The skills are written against a specific `lanework-agent-guide` version, noted in each `SKILL.md` under Versioning. When the guide moves on, update the skill and bump that note.

## Git

- Keep board writes and skill changes in separate commits, with plain messages.
- Stage paths explicitly, never with `git add -A` or `git add .` at the root, and never stage `.DS_Store`.
