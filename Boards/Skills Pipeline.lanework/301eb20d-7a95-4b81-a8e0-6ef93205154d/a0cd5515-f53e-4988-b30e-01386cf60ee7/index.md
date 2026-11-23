---
schema: 1
title: "Spike: is lanework@lanework skill compatible with AI other than claude? if not, what would it take to make it compatible with all frontier LLMs?"
order: 1024
created: {at: 2026-11-23T16:56:31Z}
modified: {at: 2026-11-23T17:02:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
kind: card
---
## Answer

Partly. Most of the product is agent-neutral: Markdown references, bash and python scripts, and `SKILL.md` folders in the open Agent Skills format, which Codex, Gemini CLI, Cursor and Copilot all load. Under those agents `lanework`, `merge`, `heal` and the board-writing half of `work` and `discovery` run once installed by hand (`plan` keeps charting but loses its work step). Three things block or bend the rest:

- The card lease requires Claude Code's `CLAUDE_CODE_SESSION_ID` and `CLAUDE_PID`, so `plan`'s work step and the stake-before-farm rule fail.
- `watch` needs Claude Code's Monitor tool.
- Every write is signed `name: claude` unless the agent passes `--name`.

Making the skills work under every frontier agent takes:

- harness-neutral session variables, with a fallback to Claude's;
- naming in the prose that does not depend on the harness;
- install docs for the `.agents/skills` path;
- a design for `watch` without Monitor.

## Evidence

### Inventory: what assumes Claude (counts are files under `skills/` unless stated)

| # | item | where | effect on another agent |
|---|---|---|---|
| **a. Packaging and discovery** | | | |
| a1 | Plugin manifest `.claude-plugin/plugin.json`. Marketplace `laneworkapp/lanework-marketplace` `.claude-plugin/marketplace.json` uses source `url` + `ref: stable` | `plugin.json`; `README.md:142-149` | Install path only. Copilot CLI reads `.claude-plugin/` manifests (end-to-end install not tested). Others: **install by hand** |
| a2 | Hand install symlinks into `~/.claude/skills/<name>` | `README.md:151-166` | Others look in `.agents/skills` or `~/.agents/skills` (Codex, Cursor, Copilot, Gemini). **Install-step change only** |
| a3 | Hand install puts `plan` at `lanework-plan`, but its frontmatter keeps `name: plan` | `README.md:159,164` | The spec requires the name to match the folder. Strict loaders may reject it. **Degraded** |
| a4 | `disable-model-invocation: true` on discovery, plan, watch, heal (4 `SKILL.md`) | frontmatter | Claude and Cursor honour it. Codex uses `agents/openai.yaml` `allow_implicit_invocation` instead. Gemini: model-triggered only. Elsewhere the skill may fire unasked. **Degraded** |
| a5 | Slash invocation: `/watch`, `/discovery`, `/heal`, `/lanework:plan` | 4 `SKILL.md`; `README.md:17-22` | Codex uses `$name`; Cursor uses `/`; Gemini has no explicit invoke; Copilot not verified. **Cosmetic or degraded** |
| a6 | README: "Claude Code, the one supported harness" | `README.md:168` | Accurate today. **Cosmetic** |
| **b. Harness tools named in skill text** | | | |
| b1 | Monitor (`persistent: true`), TaskStop, "survives `/clear`" | `watch/references/arming.md:32-51`, `watch/SKILL.md`, `events.md:3`, `watch-boards.sh:15` (4 files) | No verified wake-on-output tool elsewhere. **Blocker for `watch`** |
| b2 | Agent-tool subagents, tiers `haiku`/`sonnet`/`opus`/inherit | `work/references/tiers.md:7-10`, `team.md:9-10,42`, `sweep.md:50`; plan and discovery "subagents" | Codex, Gemini, Cursor and Copilot all have subagents with a per-agent model, but the names are Claude's. **Degraded** (the agent maps the tiers itself) |
| b3 | SendMessage between the lead and its fixers | `team.md:20`, `companions.md:8` | No verified equivalent. The build cycle collapses to a single agent. **Degraded** |
| b4 | Worktrees under `.claude/worktrees/` | `work/references/lead.md:35,42` | Plain `git worktree`; only the folder name. **Cosmetic** |
| b5 | `/loop`, `/clear`, compaction | `companions.md`, `sweep.md`, `arming.md:51` | Context only. **Cosmetic** |
| b6 | "Claude can't start a watch" | `discovery/SKILL.md:47`, `plan/SKILL.md:44` | **Cosmetic** |
| b7 | AskUserQuestion, hooks (Claude) | none. Asks go on the card; `commit-board.sh` hooks are git hooks | **Neutral** |
| **c. Environment the scripts read** | | | |
| c1 | `CLAUDE_CODE_SESSION_ID`: the lease holder | `lease.sh:295-298`; `claim-ticket.sh:42`; checks in `move-card.sh:88`, `label-card.sh:50`, `post-comment.sh:69`, `resolve-ticket.sh:85` (6 scripts, plus `writes.md` and `tickets.md`) | Unset: `lease.sh` exits 2 and `claim-ticket.sh` exits 1. **Blocker for leases, `plan` work and farming.** Move, label and comment silently skip the lease check: **degraded** (no collision guard) |
| c2 | `CLAUDE_PID`: the lease timer lives while this process lives | `lease.sh:192-206,299`; `claim-ticket.sh` | Unset: stake exits 2. **Blocker.** Another harness has no documented equivalent |
| c3 | `CLAUDE_MODEL` fallback for `--model` | `lib.sh:26-29` (16 scripts through `require_model`) | Claude Code does not set it either, so `--model` is always passed. **Cosmetic** |
| c4 | Lease memory under `${TMPDIR}/lanework-lease/<session>/` | `lease.sh:15,303` | Neutral apart from the session key. Nothing under `~/.claude` is read |
| **d. Data written to boards** | | | |
| d1 | `--name` defaults to `claude` | 13 `.sh` (e.g. `file-card.sh:21`, `lease.sh:248,279,285`), `heal-board.py:1192`, `heal-descriptors.py:498` | A GPT or Gemini write is signed `claude` (observed below). **Cosmetic, but the attribution is wrong** |
| d2 | `lanework-merge.py` hard-codes `name: claude` when a model is given | `lanework-merge.py:14,689`; `merge/references/rules.md:56` | No `--name` flag. **Cosmetic, wrong attribution** |
| d3 | Rule: "the main session stamps `claude`" | `companions.md:11`, `team.md:9`, `writes.md:53` | **Cosmetic** |
| **e. Already agent-neutral** | | | |
| e1 | Every script is plain bash 3.2, python3, git, `yq` or `fswatch`; Markdown references and templates; relative `../../lanework/scripts/lib.sh` | all | Works under any agent with a shell |
| e2 | Asks and rulings live on the card, never in a chat tool | `work/references/writing.md` § When to ask | Neutral by design |
| e3 | The in-board guide: the app writes `CLAUDE.md` and `AGENTS.md` byte-identical in every board (v120, 1,353 lines; `cmp` equal) | each board | Codex, Cursor and Copilot read `AGENTS.md`; Gemini reads it once configured. The guide's "Ready-made skills" line points only at the Claude Code plugin; that text is the app's, not this repo's |

Experiment, run 2026-11-23 in a `mktemp -d` board with every `CLAUDE*` variable unset:

| step | result |
|---|---|
| `found-board.sh … --model gpt-5-codex` | exit 0 |
| `file-card.sh` | exit 0; stamped `{name: claude, kind: agent, model: gpt-5-codex}` |
| `move-card.sh` | exit 0; the lease check was skipped |
| `lease.sh stake` | exit 2: `no CLAUDE_CODE_SESSION_ID` |
| with a session id but no PID | exit 2: `no CLAUDE_PID` |
| with both set by hand | exit 0, held; `release` exit 0 |

So prefixing the two variables is a working shim. Its weak point is the PID: it must belong to a process that lives as long as the session.

### Outside world (read 2026-11-23)

| | Agent Skills: where loaded | explicit invoke | `AGENTS.md` | plugins and marketplace | subagents with a per-agent model | wake on background output | multiple-choice ask | session or model env |
|---|---|---|---|---|---|---|---|---|
| **Claude Code** | `~/.claude/skills`, `.claude/skills`, plugin `skills/` | `/name` | no (reads `CLAUDE.md`) | `.claude-plugin/` plugin and marketplace | yes (Agent) | yes (Monitor) | AskUserQuestion | `CLAUDECODE=1`, `CLAUDE_CODE_SESSION_ID`; no model variable |
| **Codex CLI** | `.agents/skills` (cwd up to the repo root), `~/.agents/skills`, `/etc/codex/skills`; follows symlinks | `$name`, `/skills` | yes | root `plugin.json` (Agent Plugins); `.agents/plugins/marketplace.json`; Claude manifests partly accepted (S) | yes, TOML in `.codex/agents/` | not found | `request_user_input` (S) | `CODEX_THREAD_ID` (S) |
| **Gemini CLI** | `~/.gemini/skills`, `.gemini/skills`, `.agents/skills` | none: model-activated after the user confirms | only via `context.fileName` | `gemini-extension.json` (S) | yes, `.gemini/agents/*.md` `model` | background shell returns a PID; wake not stated | `ask_user` (choice) | `GEMINI_CLI=1`; no session id |
| **Cursor** | `.agents/skills`, `.cursor/skills`, `.claude/skills`, `.codex/skills`, plus `~/` variants | `/name`; honours `disable-model-invocation` | yes | `.cursor-plugin/` or root `plugin.json` | yes, `.cursor/agents`, `.claude/agents`; `is_background` | the parent polls; wake not documented | not found | not verified |
| **Copilot** (CLI, cloud agent, IDE agent mode) | `.github/skills`, `.claude/skills`, `.agents/skills`, `~/.copilot/skills`, `~/.agents/skills` | not verified | yes; `CLAUDE.md` is also accepted | reads `.claude-plugin/plugin.json` and `marketplace.json`; `copilot plugin install NAME@MARKETPLACE`; `CLAUDE_PLUGIN_ROOT` aliased | yes, `.agent.md` `model` | not verified | not verified | `COPILOT_MODEL`; no session id found |

**(S)** means a secondary source only. Note that Gemini CLI's own docs say it was replaced by Antigravity CLI for unpaid and Google One tiers from 2026-06-18; Antigravity was not researched. No cross-tool session variable exists: `AGENT` and `AI_AGENT` are proposals only (agentsmd/agents.md issue #136, S).

Sources (primary unless marked):

- agentskills.io/specification
- code.claude.com/docs/en/env-vars, /skills, /plugins-reference, /tools-reference
- learn.chatgpt.com/docs/build-skills, /docs/agent-configuration/agents-md, /docs/agent-configuration/subagents
- developers.openai.com/codex/plugins/build/
- geminicli.com/docs/cli/skills/, /cli/gemini-md/, /core/subagents/, /tools/ask-user/, /tools/shell/
- cursor.com/docs/skills, /docs/context/rules, /docs/plugins, /docs/subagents
- docs.github.com/en/copilot/concepts/agents/about-agent-skills
- docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
- docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference
- docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli
- github.com/agentplugins/agent-plugins-spec

### Compatibility matrix (today, as shipped)

| skill | Claude Code | Codex CLI | Gemini CLI | Cursor | Copilot |
|---|---|---|---|---|---|
| `lanework` | works | install steps; lease blocked | install steps; lease blocked | install steps; lease blocked | install steps (or plugin install, untested); lease blocked |
| `work` | works | **degraded**: file, move, comment and ask work, signed `claude`; no lease guard; farming blocked by the stake rule; tiers and SendMessage unmapped | **degraded**, same | **degraded**, same | **degraded**, same |
| `watch` | works | **blocked** (no Monitor) | **blocked** | **blocked** | **blocked** |
| `discovery` | works | install steps; `$discovery`; implicit-invoke guard missing | **degraded**: no explicit invoke | install steps | install steps; invoke not verified |
| `plan` | works | **degraded**: charting works, work step blocked (`claim-ticket.sh`); hand-install name mismatch | **degraded**, same | **degraded**, same | **degraded**, same |
| `merge` | works | works with install steps; signed `claude` | same | same | same |
| `heal` | works | install steps; signed `claude` by default | **degraded**: no explicit invoke | install steps | install steps |

There is no `dispatch` skill. The seven skills above are the full `skills/` list.

## What it would take

### Cheap and safe now (no behaviour change under Claude Code)

| # | change | files |
|---|---|---|
| 1 | Neutral session variables with a fallback: holder = `LANEWORK_SESSION_ID`, else `CLAUDE_CODE_SESSION_ID`; process = `LANEWORK_SESSION_PID`, else `CLAUDE_PID`. Resolved once in `lib.sh`. The exit-2 message names both | `lib.sh`, `lease.sh`, `move-card.sh`, `label-card.sh`, `post-comment.sh`, `claim-ticket.sh`, `resolve-ticket.sh`, `writes.md`, `tickets.md` (9), plus a smoke case with the `CLAUDE*` variables unset |
| 2 | `--name` default from `LANEWORK_AGENT_NAME`, else `claude` (the default itself unchanged); `lanework-merge.py` takes `--name` | 13 `.sh` through `lib.sh`, 3 `.py`, `rules.md`, `writes.md` (about 18) |
| 3 | Capability wording in the prose, with Claude Code as the named example: "a background watcher that wakes the session (Claude Code: Monitor)", "message the fixer (Claude Code: SendMessage)", worktree folder `<repo>/.worktrees` or the harness's own | `arming.md`, `events.md`, `team.md`, `companions.md`, `sweep.md`, `lead.md`, `discovery/SKILL.md`, `plan/SKILL.md` (8) |
| 4 | README "Other agents" section: symlink into `.agents/skills` or `~/.agents/skills`; set the two session variables; pass `--name` and `--model`; which skills are degraded. The support line at `README.md:168` restated | `README.md` (1) |
| 5 | `agents/openai.yaml` with `allow_implicit_invocation: false` beside the four slash-only skills (Codex's equivalent of `disable-model-invocation`) | 4 new files; `check-refs.sh` unaffected |

### Needs a design decision

| # | decision | why |
|---|---|---|
| 6 | Session identity where the harness gives none: an id the agent mints once and exports, a session file in the board, or no lease (and no farming) on that harness | The lease is the only claim; a PID that dies with each shell call leaves the timer dead and the lease lapses at 30 min |
| 7 | `watch` without Monitor: a blocking `watch-boards.sh --next` that waits for one event and exits, re-run by the agent in a loop; or `watch` stays Claude-only | Works in any agent that allows long shell calls, but it holds the turn and nothing arrives between runs |
| 8 | Tier vocabulary: `haiku`/`sonnet`/`opus` become `mechanical`/`routine`/`complex`, with a per-harness mapping row | Clearer for other agents, but touches `tiers.md`, `team.md` and every place that cites a tier |
| 9 | The `plan` name clash: rename the skill folder `lanework-plan` (a major bump under the repo rule) or keep the hand-install alias | The spec says name equals folder |
| 10 | Which agents to support and test, how to test them (`tests/` cannot run a model), and where to publish (Agent Plugins `plugin.json` at the root, Codex marketplace, Copilot via the existing marketplace) | Owner calls, asked on the README card |

### Not worth doing

- Porting the lead, fixer and reviewer SendMessage protocol to each harness's subagent API. Each API differs, and the single-agent build path already works.
- Per-harness forks of any skill. That breaks "one topic, one file".
- Linux or Windows portability as part of this. Separate work: the repo targets macOS bash 3.2 and BSD tools.
- Gemini CLI first: its docs say Antigravity CLI is replacing it for some tiers.

## Follow-on cards (to file in Ideas)

| title | skill | scope |
|---|---|---|
| Harness-neutral session variables for the lease | `lanework`, `work`, `plan` | Change 1 |
| Agent name from the environment; `--name` on the merge driver | `lanework`, `merge`, `heal` | Change 2 |
| Capability wording for harness tools in skill prose | `work`, `watch`, `discovery`, `plan` | Change 3 |
| README: installing under Codex, Cursor and Copilot | `repo` | Change 4, plus a Copilot CLI plugin-install trial |
| Codex implicit-invocation guard for slash-only skills | `watch`, `discovery`, `plan`, `heal` | Change 5 |
| Watch without Monitor | `watch` | Decision 7, then the build |
| Lease identity on harnesses without a session id | `lanework` | Decision 6 |

Separately, the in-board guide's "Ready-made skills" line names only Claude Code. It is app text, so any change is a `lanework-app` card, not one here.

## Done when

- The owner approves these findings (the move out of Proposed).
- The seven follow-on cards above are then filed in Ideas, each linked from this card's closing comment. Each waits at triage like any other idea.
- Nothing under `skills/` changes on this card.

## Calls left to the follow-on cards

A spike answers a question, so nothing here needs a ruling. These calls are the owner's and are asked when the card that needs them is shaped:

- Which agents to target and test first (the README card). Leaning: Codex CLI and Copilot, since Copilot already reads `.claude-plugin/` manifests.
- Whether to publish outside the Claude Code marketplace (the README card). Leaning: document the hand install and try a Copilot plugin install before adding any manifest.
- Whether the default `by.name` stays `claude` (the agent-name card). Leaning: keep it, overridable.
- What `watch` does without Monitor (its own card). Leaning: Claude-only until the blocking-loop design is shaped.
- Session identity where the harness gives none (its own card).
- The `plan` folder name against the spec, and the tier vocabulary (decisions 8 and 9): no card until an agent is seen rejecting the alias or misreading a tier.
