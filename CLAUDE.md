# Lanework agent skills

The agent skills for Lanework boards, published as a Claude Code plugin named `lanework`. The files under `skills/` are the product. Everything else in the repo exists to build and track them.

## Layout

| path | what it is |
|---|---|
| `skills/<name>/` | one skill per folder: `SKILL.md`, plus `references/`, `templates/` and `scripts/` as needed. This is what ships, so nothing about this repo's own process goes in here. |
| `.claude-plugin/plugin.json` | the plugin manifest. Its `skills` list names every folder under `skills/`. Its `version` is the only version. |
| `.claude-plugin/marketplace.json` | lists the plugin, sourced from the `stable` branch, so plugin installs only see releases |
| `CHANGELOG.md` | user-facing release notes, in the `app-changelog` format |
| `scripts/release.sh` | cuts a release; `.github/workflows/smoke.yml` runs smoke on every push and pull request |
| `Pitlane/Skills Pipeline.lanework/` | the development pipeline board: ideas, issues and work on the skills |
| `tests/` | `smoke.sh` runs every script on throwaway boards and validates them; `check-refs.sh` checks every cited skill file exists |
| `README.md` | the user-facing page: what each skill is for, and how to install it |

`docs/adr/`, `docs/pdr/` and `CONTEXT.md` are created the first time the `discovery` skill is run on this repo.

## Working on a skill

- **Track the work on the board.** Read `Pitlane/Skills Pipeline.lanework/index.md` (its guide, `CLAUDE.md` inside the board, comes first once the app has opened it) and work cards as the `pitlane` skill describes. A change without a card starts as a card in Ideas, or in Issues if something is broken.
- **Adding, renaming or removing a skill** touches three places together: the folder under `skills/`, the `skills` list in `plugin.json`, and the skills table and install commands in `README.md`. Then add or rename the board's `Skill` label value to match.
- **One topic, one file.** `SKILL.md` is a hub: a short flow and a table of topic files. Each rule lives in exactly one file, and every other place links to it. Board fundamentals (authority, reading, writes, founding) live in `lanework`; prose rules (records, asks) in `pitlane/references/writing.md`. The exception is owner-facing board text in templates (board and lane bodies), which stays readable prose even where it restates a rule.
- **Agent-facing text is telegraphic**: fragments, arrows and tables over full sentences, as long as nothing becomes ambiguous.
- **Cite files as `<skill>/<dir>/<file>`** from another skill, and `<dir>/<file>` within one. Scripts reach siblings by relative path (`../../lanework/scripts/lib.sh`, which every script sources), because users symlink each folder into `~/.claude/skills/<name>`. Keep the skills side by side under `skills/`, and install them together.
- **Entries replace; they don't append.** Extend an existing entry first, then merge several into one, and only then add. Project facts (gate commands, what green means, blast radius) never move into a skill: they belong in a board's instruction sheet or a repo's `CLAUDE.md`.
- **Scripts target macOS bash and BSD tools** (`date -v`, `uuidgen`). **Verified** = `tests/smoke.sh` passing (it runs `bash -n`, every script on throwaway boards, the schema validator, and `check-refs.sh`), plus a new smoke case for any new script behavior. Never test against the Skills Pipeline board.
- **The in-board agent guide wins.** The skills target one `lanework-agent-guide` version, stamped only in `skills/lanework/references/authority.md` § Versions (smoke fails on a second stamp anywhere else). When the guide moves on, read every skill against it, fix the drift, then bump the stamp.

## Releasing

- `main` is work in progress; `stable` is what plugin users get. Only `scripts/release.sh` moves `stable`.
- Release = add the user-facing entries to `CHANGELOG.md`, one starting `Version X.Y.Z: `, commit and push, then `scripts/release.sh X.Y.Z --dry-run`, then without `--dry-run`. Cutting a release publishes it: the owner's call.
- Bump: patch for fixes and wording, minor for new behavior or a guide-version move, major for a renamed or removed skill.

## Git

- Keep board writes and skill changes in separate commits, with plain messages.
- Stage paths explicitly, never with `git add -A` or `git add .` at the root, and never stage `.DS_Store`.
