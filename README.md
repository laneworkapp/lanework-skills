# Lanework agent skills

A Lanework board is just a folder of plain directories and Markdown files that the Lanework macOS app renders live — there is no API and nothing to sync, so an agent works a board by reading and editing its files directly, exactly the same as its human owner does through the app.

## Skills

| skill | what it's for |
|---|---|
| `lanework-boards` | the base the others build on: what a board is, reading one, the write rules every board shares, the default lane sets, and founding a new board |
| `pitlane` | working a board: writing cards and comments, sweeps and triage, farming work to model-tiered subagents, and a lead/fixer/reviewer build cycle |
| `pitwall` | a standing watch on one or more boards, responding to changes as they arrive |
| `discovery` | a guided examination of a project's problem and domain space, run in rounds on a discovery board: questions as cards, rulings in the owner's words, plus the glossary and the ADRs and PDRs the rulings produce |

`discovery` and `pitwall` never start on their own. Type the command first in your message:

- `/discovery <topic>` starts or resumes a discovery session.
- `/pitwall <board> [<board>...]` watches one or more boards, by name or path, until you say stop. With no board named, it watches the project's only board, or asks which.

### Sizes

`SKILL.md` is what loads when a skill starts. The rest of its files are read only when a task needs them.

| skill | files | `SKILL.md` words | words an agent reads |
|---|---|---|---|
| `lanework-boards` | 9 | 319 | 2,474 |
| `pitlane` | 16 | 338 | 5,817 |
| `pitwall` | 4 | 145 | 1,040 |
| `discovery` | 14 | 432 | 2,398 |

Measured with `wc -w` on 2026-09-28, over the Markdown an agent reads: `SKILL.md`, references, and the templates it fills in. Scripts, and the templates only a script reads (the lane sets and board bodies passed to `found-board.sh`), are left out: they never enter context.

#### `lanework-boards`

| file | words |
|---|---|
| `SKILL.md` | 319 |
| `references/authority.md` | 164 |
| `references/board-kinds.md` | 439 |
| `references/finding.md` | 101 |
| `references/format.md` | 143 |
| `references/founding.md` | 388 |
| `references/reading.md` | 142 |
| `references/writes.md` | 702 |
| `templates/index.md` | 76 |
| **total** | **2,474** |

#### `pitlane`

| file | words |
|---|---|
| `SKILL.md` | 338 |
| `references/companions.md` | 148 |
| `references/evidence.md` | 419 |
| `references/fixer.md` | 391 |
| `references/lead.md` | 972 |
| `references/reviewer.md` | 376 |
| `references/sweep.md` | 479 |
| `references/team.md` | 528 |
| `references/tiers.md` | 97 |
| `references/traps.md` | 377 |
| `references/writing.md` | 787 |
| `templates/ask.md` | 244 |
| `templates/farmed-prompt.md` | 116 |
| `templates/fixer-phase1-report.md` | 236 |
| `templates/fixer-phase2-report.md` | 136 |
| `templates/review-verdict.md` | 173 |
| **total** | **5,817** |

#### `pitwall`

| file | words |
|---|---|
| `SKILL.md` | 145 |
| `references/arming.md` | 270 |
| `references/events.md` | 360 |
| `references/responding.md` | 265 |
| **total** | **1,040** |

#### `discovery`

| file | words |
|---|---|
| `SKILL.md` | 432 |
| `references/board.md` | 271 |
| `references/conduct.md` | 126 |
| `references/corners.md` | 171 |
| `references/records.md` | 398 |
| `references/rounds.md` | 262 |
| `templates/fact-card.md` | 48 |
| `templates/glossary.md` | 46 |
| `templates/lanes.md` | 300 |
| `templates/map-card.md` | 92 |
| `templates/question-card.md` | 66 |
| `templates/record.md` | 63 |
| `templates/ruling.md` | 58 |
| `templates/topic-card.md` | 65 |
| **total** | **2,398** |

## Install

Clone this repo, then symlink or copy each folder under `skills/` into `~/.claude/skills/<name>`, for example:

```bash
git clone https://github.com/laneworkapp/lanework-skills.git lanework-skills
ln -s "$(pwd)/lanework-skills/skills/lanework-boards" ~/.claude/skills/lanework-boards
ln -s "$(pwd)/lanework-skills/skills/pitlane" ~/.claude/skills/pitlane
ln -s "$(pwd)/lanework-skills/skills/pitwall" ~/.claude/skills/pitwall
ln -s "$(pwd)/lanework-skills/skills/discovery" ~/.claude/skills/discovery
```

The skills cite and call each other by relative path, so install all four side by side.

The repo is also a Claude Code plugin named `lanework` (`.claude-plugin/plugin.json`), so it can be installed as one unit instead of skill by skill.

`SKILL.md` is the Agent Skills format Claude Code reads; other harnesses that read `SKILL.md` files work the same way.

## Repository layout

The skills live under `skills/`, one folder each, and that folder is all that ships. `Pitlane/Skills Pipeline.lanework` is the Lanework board where work on the skills is tracked, from ideas and issues to shipped changes. `CLAUDE.md` has the conventions for working in the repo.

## Defaults, not rules

The `Pitlane/` folder convention (`<repo root>/Pitlane/<Board>.lanework`, and `~/Pitlane/` for machine-level boards) and the pipeline lane set (Ideas → Shaping → Proposed → Approved → Active → Done, plus Issues) are the defaults these skills ship with, not requirements.

A board's actual folder layout, and each lane's own `index.md` body, always win over the defaults described here — the skills are written to defer to what a board's own files say.

## Versioning

The guide and schema versions this skill set is written against are stamped in one place: `skills/lanework-boards/references/authority.md`, under Versions.

Wherever a skill here disagrees with the in-board guide (`<board>.lanework/CLAUDE.md`, app-maintained and rewritten by Lanework on upgrades), the guide wins.

## Names

`pitlane` and `pitwall` are borrowed from motor racing.

- **Pit lane**: the road beside the track where cars come in and crews work on them. The `pitlane` skill is where the work happens. It files and moves cards, sweeps a board, and sends the work to a crew of subagents. Boards live in a `Pitlane/` folder for the same reason.
- **Pit wall**: the stand between the pit lane and the track. Engineers sit there watching the race live on their screens, and they call the driver in when something changes. The `pitwall` skill watches one or more boards and responds as changes arrive.

## Credits

The interview protocol in `discovery` (a decision tree, a frontier, and rounds with a recommended answer per question) and its glossary and ADR discipline are adapted from Matt Pocock's `grilling` and `domain-modeling` skills (MIT), reworked to run on a Lanework board.

## License

MIT — see `LICENSE`.
