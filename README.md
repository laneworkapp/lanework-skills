# Lanework agent skills

A Lanework board is just a folder of plain directories and Markdown files that the Lanework macOS app renders live — there is no API and nothing to sync, so an agent works a board by reading and editing its files directly, exactly the same as its human owner does through the app.

## Skills

| skill | what it's for |
|---|---|
| `lanework` | the base the others build on: what a board is, reading one, the write rules every board shares, healing a damaged board, the default lane sets, and founding a new board |
| `work` | working a board: writing cards and comments, sweeps and triage, farming work to model-tiered subagents, and a lead/fixer/reviewer build cycle |
| `watch` | a standing watch on one or more boards, responding to changes as they arrive |
| `discovery` | a guided examination of a project's problem and domain space, run in rounds on a discovery board: questions as cards, rulings in the owner's words, plus the glossary and the ADRs and PDRs the rulings produce |
| `merge` | resolves git merge, pull and rebase conflicts on a board with no human: a merge driver plus a placement pass, keeping both sides' content and the later stamp's state |

`discovery` and `watch` never start on their own. Type the command first in your message:

- `/discovery <topic>` starts or resumes a discovery session.
- `/watch <board> [<board>...]` watches one or more boards, by name or path, until you say stop. With no board named, it watches the project's only board, or asks which.

### Sizes

`SKILL.md` is what loads when a skill starts. The rest of its files are read only when a task needs them.

| skill | files | `SKILL.md` words | words an agent reads |
|---|---|---|---|
| `lanework` | 9 | 328 | 2,790 |
| `work` | 16 | 374 | 6,201 |
| `watch` | 4 | 146 | 1,044 |
| `discovery` | 14 | 422 | 2,388 |
| `merge` | 2 | 336 | 1,420 |

Measured with `wc -w` on 2026-10-06, over the Markdown an agent reads: `SKILL.md`, references, and the templates it fills in. Scripts, and the templates only a script reads (the lane sets and board bodies passed to `found-board.sh`), are left out: they never enter context.

#### `lanework`

| file | words |
|---|---|
| `SKILL.md` | 328 |
| `references/authority.md` | 129 |
| `references/board-kinds.md` | 474 |
| `references/finding.md` | 101 |
| `references/format.md` | 143 |
| `references/founding.md` | 379 |
| `references/reading.md` | 142 |
| `references/writes.md` | 1,018 |
| `templates/index.md` | 76 |
| **total** | **2,790** |

#### `work`

| file | words |
|---|---|
| `SKILL.md` | 374 |
| `references/companions.md` | 148 |
| `references/evidence.md` | 419 |
| `references/fixer.md` | 391 |
| `references/lead.md` | 977 |
| `references/reviewer.md` | 376 |
| `references/sweep.md` | 531 |
| `references/team.md` | 528 |
| `references/tiers.md` | 97 |
| `references/traps.md` | 377 |
| `references/writing.md` | 1,040 |
| `templates/ask.md` | 244 |
| `templates/farmed-prompt.md` | 154 |
| `templates/fixer-phase1-report.md` | 236 |
| `templates/fixer-phase2-report.md` | 136 |
| `templates/review-verdict.md` | 173 |
| **total** | **6,201** |

#### `watch`

| file | words |
|---|---|
| `SKILL.md` | 146 |
| `references/arming.md` | 271 |
| `references/events.md` | 362 |
| `references/responding.md` | 265 |
| **total** | **1,044** |

#### `discovery`

| file | words |
|---|---|
| `SKILL.md` | 422 |
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
| **total** | **2,388** |

#### `merge`

| file | words |
|---|---|
| `SKILL.md` | 336 |
| `references/rules.md` | 1,084 |
| **total** | **1,420** |

## Install

As a Claude Code plugin, which installs all five skills and updates with each release:

```
/plugin marketplace add laneworkapp/lanework-skills
/plugin install lanework@lanework
```

The plugin tracks the `stable` branch, which only moves when a release ships. `/plugin marketplace update lanework` picks up a new one.

By hand, to follow `main` instead: clone this repo, then symlink or copy each folder under `skills/` into `~/.claude/skills/<name>`, for example:

```bash
git clone https://github.com/laneworkapp/lanework-skills.git lanework-skills
ln -s "$(pwd)/lanework-skills/skills/lanework" ~/.claude/skills/lanework
ln -s "$(pwd)/lanework-skills/skills/work" ~/.claude/skills/work
ln -s "$(pwd)/lanework-skills/skills/watch" ~/.claude/skills/watch
ln -s "$(pwd)/lanework-skills/skills/discovery" ~/.claude/skills/discovery
ln -s "$(pwd)/lanework-skills/skills/merge" ~/.claude/skills/merge
```

The skills cite and call each other by relative path, so install all five side by side.

`SKILL.md` is the Agent Skills format Claude Code reads; other harnesses that read `SKILL.md` files work the same way.

## Repository layout

The skills live under `skills/`, one folder each, and that folder is all that ships. `Pitlane/Skills Pipeline.lanework` is the Lanework board where work on the skills is tracked, from ideas and issues to shipped changes. `CLAUDE.md` has the conventions for working in the repo, `CHANGELOG.md` what each release changed, and `scripts/release.sh` cuts a release.

## Defaults, not rules

The `Pitlane/` folder convention (`<repo root>/Pitlane/<Board>.lanework`, and `~/Pitlane/` for machine-level boards) and the pipeline lane set (Ideas → Shaping → Proposed → Approved → Active → Done, plus Issues and Tasks) are the defaults these skills ship with, not requirements.

A board's actual folder layout, and each lane's own `index.md` body, always win over the defaults described here — the skills are written to defer to what a board's own files say.

## Versioning

Releases are numbered `vX.Y.Z`, tagged, and listed on the repo's GitHub releases page with their notes from `CHANGELOG.md`. The version lives in `.claude-plugin/plugin.json` alone.

The guide and schema versions this skill set is written against are stamped in one place: the repo's `CLAUDE.md`, not in the skills. Smoke fails when this repo's Skills Pipeline board's guide or schema is newer than the stamp, so a release waits for a re-read of the skills.

Wherever a skill here disagrees with the in-board guide (`<board>.lanework/CLAUDE.md`, app-maintained and rewritten by Lanework on upgrades), the guide wins.

## Names

The skills are named for what they do. `lanework` is the base, `work` files, sweeps and builds on a board, `watch` stays up and reacts to one, `discovery` examines a problem space, and `merge` resolves git conflicts on a board. The `Pitlane/` folder, where a project keeps its boards, is a separate convention with its own name; it is unchanged.

## Credits

The interview protocol in `discovery` (a decision tree, a frontier, and rounds with a recommended answer per question) and its glossary and ADR discipline are adapted from Matt Pocock's `grilling` and `domain-modeling` skills (MIT), reworked to run on a Lanework board.

## License

MIT — see `LICENSE`.
