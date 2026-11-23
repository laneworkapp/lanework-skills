---
schema: 1
title: "Spike: is lanework@lanework skill compatible with AI other than claude? if not, what would it take to make it compatible with all frontier LLMs?"
order: 1024
created: {at: 2026-11-23T16:56:31Z}
modified: {at: 2026-11-23T17:37:21Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
kind: card
---
## Summary

**Goal** (the owner's words): make the `lanework` skills compatible with every modern, relevant LLM, both in how they are installed and in how they are used and perform. This card starts with a Before compatibility matrix and an After matrix for the proposed changes.

"LLM" means two different things here, and they are rated apart:

- **The harness** is the agent program that loads the skills and runs their scripts: Claude Code, Codex CLI, Cursor and so on. The **Install** and **Use** axes are rated per harness.
- **The model** is what runs inside the harness: Claude, GPT, Gemini, Grok or an open-weight model. The **Perform** axis is rated per model family.

**Before**

| axis | state |
|---|---|
| Install | One command, Claude Code only. Every other harness needs hand steps the README does not give. Three of them (Cursor, OpenCode, Amp) happen to read the README's `~/.claude/skills` path. |
| Use | Claude Code: everything works. Elsewhere: `watch` is blocked (it needs the Monitor tool) and `plan` is blocked (its claim needs Claude's session variables). The other five skills lose the lease guard and sign their writes `claude`. |
| Perform | Not measured anywhere, Claude included. There are risk predictions only, reasoned from vendor docs. |

**After** (with the nine work packages below)

| axis | state |
|---|---|
| Install | One documented command or path for each of the seven relevant harnesses. |
| Use | Six skills remain, since `plan` is removed. Four are fully usable everywhere. `work` and `watch` keep the limits listed under Residual limits. |
| Perform | Measured by a board-task eval, run per harness and model. A cell only changes on evidence. |

**Residual limits** (things this repo cannot remove, because the harness lacks the feature):

| limit | where | cause |
|---|---|---|
| `watch` holds the turn while it waits, and each idle wake-up costs a model turn | Codex, Antigravity, Copilot, Cursor, Grok | No tool that wakes the agent on background output |
| The lead and its fixers cannot message each other mid-run, so each phase is a separate subagent run | all but Claude Code | No agent-to-agent messaging |
| A lease ends 30 minutes after the session's last board write, not when the session exits | harnesses that expose no session process | — |

**Plan**: 9 work packages (WP1 to WP9).

- WP1 to WP5 and WP7 change nothing under Claude Code.
- WP6 removes `plan`, which is a major version bump.
- WP8 (the eval) needs the owner's accounts and budget.
- WP9 runs only if the eval shows it is needed.

## Rulings

The owner ruled all five calls on this card on 2026-11-23. The After matrices below already follow them.

| call | ruling |
|---|---|
| Which harnesses are rated | The seven columns; the rest follow for free |
| Lease liveness without a session process | Heartbeat: the lease lapses 30 minutes after the last board write |
| `watch` without Monitor | A one-shot wait the agent loops, keeping the session busy |
| The `plan` name | Neither rename nor keep: "lets remove plan for now, i'll bring it back (maybe) under a different name." |
| Distribution | A generated root plugin manifest, a Codex marketplace entry, an installer script and README lines |

## Harnesses in scope

**Criterion for "relevant"**, all four must hold:

1. It loads Agent Skills from a shared path: `.agents/skills`, `~/.agents/skills` or `.claude/skills`.
2. It has a local shell on the Mac where the board and the app live.
3. It has shipped a release in the last 90 days.
4. It is a frontier lab's own harness, or one of the editors with the largest share, or the main open-weight carrier.

| group | harnesses | why |
|---|---|---|
| **Relevant: the matrix columns** | Claude Code (CC), Codex CLI (CX), Antigravity CLI (AG), GitHub Copilot CLI and agent mode (CP), Cursor (CU), Grok Build (GK), OpenCode (OC) | Frontier labs: Anthropic, OpenAI, Google, xAI. Largest editors: Copilot, Cursor. OpenCode carries open-weight models (Qwen, Kimi, GLM, DeepSeek, gpt-oss) |
| **Follows for free** (behaves like the column named) | Amp, Goose, Zed, Cline, Junie, Auggie, Warp, Devin Desktop (formerly Windsurf) and Factory Droid: like OC or CU. Mistral Vibe, Qwen Code and Kimi Code: like OC. Gemini CLI on paid tiers: like AG | Each reads `.agents/skills` or `.claude/skills` and `AGENTS.md`, and has a shell. Each is fixed by the same work packages. Not rated cell by cell |
| **Follows with one step** | Kiro | Reads only `.kiro/skills`. The installer in WP7 links it |
| **Out of scope** | Roo Code | Shut down on 2026-05-15 |
| | Gemini CLI on unpaid and Google One tiers | Replaced by Antigravity CLI (Gemini CLI docs) |
| | Cloud agents (Copilot cloud agent, Codex cloud, Devin cloud, Factory remote) | Linux sandboxes. The scripts target macOS bash 3.2 and BSD tools, and the app is a Mac app |
| | Chat apps (claude.ai, ChatGPT, the Gemini app) | No shell on the board's machine |

## Evidence

### What the harnesses offer (read 2026-11-23)

(S) marks a secondary source; NV means not verified.

| | skills: paths | explicit invoke | honours `disable-model-invocation` | `AGENTS.md` / `CLAUDE.md` | installs a Claude plugin | subagent model | wakes on background output | multiple-choice ask | session or agent env |
|---|---|---|---|---|---|---|---|---|---|
| CC | `~/.claude/skills`, `.claude/skills`, plugin | `/name` | yes | `CLAUDE.md` | yes | yes | yes (Monitor) | yes | `CLAUDECODE=1`, `CLAUDE_CODE_SESSION_ID`, `CLAUDE_PID` |
| CX | `.agents/skills` (cwd up to the repo root), `~/.agents/skills` | `$name`, `/skills` | no: `agents/openai.yaml` `allow_implicit_invocation` | `AGENTS.md`, 32 KiB combined cap | partly, root `plugin.json` (S) | yes | NV | `request_user_input` (S) | `CODEX_THREAD_ID` (S) |
| AG | `.agents/skills`, `~/.gemini/config/skills` | `/name` | NV | `AGENTS.md` (`GEMINI.md` legacy) | `agy plugin import claude` migrates; no direct install | yes (`inherit`, `flash`, `pro`) | `/tasks`; wake NV | NV | NV |
| CP | `.agents/skills`, `.claude/skills`, `.github/skills`, `~/.agents/skills`, `~/.copilot/skills` | NV | NV | both | reads `.claude-plugin/` plugin and marketplace manifests | yes | NV | NV | `COPILOT_MODEL` only |
| CU | `.agents/skills`, `.cursor/skills`, `.claude/skills`, the `~/` variants | `/name` | yes | `AGENTS.md`; `CLAUDE.md` (S) | no (own and Agent Plugins formats) | yes | the parent polls | NV | NV |
| GK | `.grok/skills`, `~/.grok/skills`, `~/.agents/skills` | `/name` | yes | both (S) | reads Claude marketplaces (S) | parallel (S) | NV | NV | NV |
| OC | `.agents/skills`, `.claude/skills`, `~/.claude/skills`, `~/.agents/skills` | `@id` | yes | `AGENTS.md`; `CLAUDE.md` as fallback | no | yes | **yes**: `background: true`, notified on exit | yes (`question`) | NV |

More facts that shape the design:

- Goose sets `AGENT=goose` and `AGENT_SESSION_ID`.
- Amp sets `AMP_CURRENT_THREAD_ID` (S).
- Devin, Factory, Auggie and Copilot read `.claude-plugin/` manifests. Vibe loads skills and MCP servers from them.
- Codex, Cursor, Copilot, Kiro, Vibe and Qwen read the vendor-neutral Agent Plugins `plugin.json` at the plugin root. For Copilot that root file takes precedence over `.claude-plugin/`.
- No cross-tool session variable exists. `AGENT` and `AI_AGENT` are proposals only (S).

### What in the skills assumes Claude Code

This is the inventory from the first pass, condensed. File and line references are in the thread record.

| # | assumption | where | axis |
|---|---|---|---|
| A1 | Plugin and marketplace exist only as `.claude-plugin/`; the README's hand install goes to `~/.claude/skills` | `plugin.json`, `README.md:142-166` | Install |
| A2 | `plan` is hand-installed in a `lanework-plan` folder while its `name:` stays `plan`. The spec says the name must equal the folder name; Kiro enforces it | `README.md:159,164` | Install |
| A3 | The lease holder and process come from `CLAUDE_CODE_SESSION_ID` and `CLAUDE_PID`. `lease.sh` exits 2 without them, `claim-ticket.sh` exits 1, and move, label and comment skip the lease check silently | 6 scripts, `writes.md`, `tickets.md` | Use |
| A4 | `--name` defaults to `claude` in 13 `.sh` and 2 `.py` files; `lanework-merge.py` hard-codes it. Nothing reads `by.name` back (checked by grep), so the change is to the stamp only | scripts, `companions.md:11`, `team.md:9` | Use |
| A5 | Monitor, `persistent: true`, TaskStop, "survives `/clear`" | `watch/SKILL.md`, `arming.md:32-51`, `events.md:3` | Use |
| A6 | SendMessage between the lead and its fixers | `team.md:20`, `companions.md:8` | Use |
| A7 | Tiers `haiku`, `sonnet`, `opus`, inherit | `tiers.md:7-10`, `team.md:10,42` | Use, Perform |
| A8 | The slash-only guard is the `disable-model-invocation` frontmatter key alone | 4 `SKILL.md` | Use |
| A9 | Smaller harness-specific mentions: `.claude/worktrees/`, `/loop`, "Claude can't start a watch" | `lead.md:35,42`, `discovery/SKILL.md:47`, `plan/SKILL.md:44` | Perform (wording) |
| A10 | Already neutral: bash, python and git scripts with relative calls; asks and rulings go on the card, never through a chat tool; the app writes `AGENTS.md` beside `CLAUDE.md` in every board | — | — |

### Experiments (throwaway boards under `mktemp -d`, 2026-11-23)

| run | result |
|---|---|
| Every `CLAUDE*` variable unset: `found-board.sh`, `file-card.sh`, `move-card.sh` | All exit 0. The card was stamped `name: claude, model: gpt-5-codex`, and the lease check was skipped |
| `lease.sh stake` without the variables | Exit 2. With both variables set by hand: exit 0, held, then released |
| A one-shot prototype watcher (`next.zsh`, kept in scratch): it keeps the snapshot between runs and blocks until the next change or a timeout | A change made while it was not running was reported on the next run. A change during the block was reported in 2 s. An idle 3 s timeout returned `IDLE` in 3 to 4 s |

## Before matrix

The legend is the same for both matrices; letters refer to the footnotes under each table.

- **Install**: ● one documented command or path; ◐ works with steps the README does not give; ○ cannot be installed.
- **Use**: ● works as designed; ◐ works with a loss; ○ the core flow is blocked.
- **Perform**: predicted risk, L (low), M (medium) or H (high). Unmeasured everywhere.

### Install, per harness

| skill | CC | CX | AG | CP | CU | GK | OC |
|---|---|---|---|---|---|---|---|
| lanework | ● | ◐a | ◐a | ◐b | ◐c | ◐a | ◐c |
| work | ● | ◐a | ◐a | ◐b | ◐c | ◐a | ◐c |
| watch | ● | ◐a | ◐a | ◐b | ◐c | ◐a | ◐c |
| discovery | ● | ◐a | ◐a | ◐b | ◐c | ◐a | ◐c |
| plan | ● | ◐ad | ◐ad | ◐bd | ◐cd | ◐ad | ◐cd |
| merge | ● | ◐a | ◐a | ◐b | ◐c | ◐a | ◐c |
| heal | ● | ◐a | ◐a | ◐b | ◐c | ◐a | ◐c |

- **a**: The harness does not read `~/.claude/skills`. The user must link the skills into `~/.agents/skills` themselves; the README does not say so.
- **b**: `copilot plugin install lanework@lanework` should work because Copilot reads `.claude-plugin/`. Not tried, and the marketplace's `url` + `ref: stable` source form is not verified for Copilot.
- **c**: The README's `~/.claude/skills` link happens to work, but the README does not say so.
- **d**: Under a hand install the folder is `lanework-plan` but the skill's `name:` is `plan`, which breaks the spec.

### Use, per harness

| skill | CC | CX | AG | CP | CU | GK | OC |
|---|---|---|---|---|---|---|---|
| lanework | ● | ◐eg | ◐eg | ◐eg | ◐eg | ◐eg | ◐eg |
| work | ● | ◐efg | ◐efg | ◐efg | ◐efg | ◐efg | ◐efg |
| watch | ● | ○h | ○h | ○h | ○h | ○h | ○h |
| discovery | ● | ◐gi | ◐gi | ◐gi | ◐g | ◐g | ◐g |
| plan | ● | ○j | ○j | ○j | ○j | ○j | ○j |
| merge | ● | ◐g | ◐g | ◐g | ◐g | ◐g | ◐g |
| heal | ● | ◐gi | ◐gi | ◐gi | ◐g | ◐g | ◐g |

- **e**: No lease. `lease.sh` exits 2, and the writes no longer guard against another session holding the card.
- **f**: Farming cannot start, because a card must be staked first. The tiers and SendMessage are named for Claude.
- **g**: Every write is signed `name: claude`.
- **h**: Arming needs the Monitor tool.
- **i**: The harness may ignore `disable-model-invocation`, so the skill may start without being typed.
- **j**: `claim-ticket.sh` exits 1, so the work step (one ticket per session) is blocked. Charting still works.

### Perform, per model family

All cells are predictions.

| skill | Claude | GPT | Gemini | Grok | open-weight, large | open-weight, small (≤32k context) |
|---|---|---|---|---|---|---|
| lanework | L | L | L | M | M | M (k) |
| work | L | M (l, m) | M (n) | M | M | H (k) |
| watch | L | M (m) | M | M | M | H (k) |
| discovery | L | M (l) | M (n) | M | M | H (k) |
| plan | L | M (l) | M (n) | M | M | H (k) |
| merge | L | L | L | L | L | M |
| heal | L | L | L | M | M | M |

Notes:

- **k**: A shaping pass reads about 29k tokens before writing anything: the board guide is 80 KB (about 20k tokens), plus `work/SKILL.md`, `authority.md`, `writes.md`, `reading.md`, `writing.md` and `board-kinds.md`. That nearly fills a 32k window.
- **l**: OpenAI's Codex guide says the model defaults to reasonable assumptions over clarifying questions. Our rule is that every owner-only call becomes an ask on the card, which pulls the other way.
- **m**: Codex caps `AGENTS.md` at 32 KiB combined and stops adding files at the cap. The 80 KB board guide is dropped or cut short whenever Codex's working directory is inside a board.
- **n**: No vendor evidence on how well Gemini follows long Markdown procedures. Google's guide says contradictory context makes it fall back on training data.
- **Claude** is rated L only because the skills were written and used there. That is not a measurement either.

## Perform: what the skill text relies on

| trait in our skills | measured here | what the vendors and evals say | risk |
|---|---|---|---|
| **Size**: `SKILL.md` 19 to 58 lines; descriptions 183 to 709 characters, about 2.7k in total; references 3.7 KB (heal) to 38 KB (work); 26k words of Markdown in all | `wc` | agentskills.io and Anthropic: body under 500 lines. Codex lists skills within 2% of the context window and shortens descriptions first. Claude Code truncates at 1,536 characters. Zed has a 50 KB cap on all descriptions together | Low: inside every documented limit |
| **Progressive disclosure**: `SKILL.md` is a hub, 139 cross-file citations | `grep` | Every harness in scope lists the name and description up front and loads the body on use. OpenCode, Zed, Factory and Cline read files only when the text points at them. Anthropic: agents may `head -100` files nested deeper, so put a contents list on any reference over 100 lines | Low to medium: `writes.md` and `writing.md` exceed 100 lines and have no contents list |
| **Telegraphic style**: 209 arrows (`→`), 117 `§` section citations, tables over prose | `grep` | No vendor recommends fragments or sentences either way; all say "concise, imperative, specific". SkillsBench: compact skills +19.0 pp, comprehensive +0.7 pp | Untested. Plausibly fine for frontier models, a risk for small models |
| **Tool names**: Agent, SendMessage, Monitor, TaskStop | inventory A5 to A7 | OpenAI: name tools explicitly, because models prefer their native tools. Microsoft: avoid branching on the model | Medium: these names do not exist elsewhere |
| **Tier names**: haiku, sonnet, opus | A7 | — | Medium: meaningless outside Claude |
| **"The main session", slash commands** | A9, A8 | Invocation syntax differs: `/` (CC, CU, AG, GK, Kiro, Zed, Vibe, Qwen, Devin), `$` (CX, Junie), `@` (OC), `/skill:` (Auggie, Kimi), none (Amp, Gemini CLI) | Medium |
| **Being picked up at all** | — | Vercel's eval (S): the skill was not invoked in 56% of cases, while an `AGENTS.md` index scored 100%. SkillsBench: some harnesses read a skill and then ignore it. Our boards carry `AGENTS.md`, which points at the skills | Medium. It also means the app's guide text drives triggering; that is an app card |
| **Scripts over prose for fragile steps**: every write goes through a script with exit codes | — | agentskills.io and Anthropic: bundle scripts for fragile steps. OpenAI: prefer instructions unless the behaviour must be deterministic | Low: this is the strongest part for every model |

**How performance would be measured** (WP8). Today there is no measurement, only reasoning from docs.

| item | proposal |
|---|---|
| Tasks (12, each on a fresh throwaway board, never this repo) | E1 found a pipeline board · E2 file a card with an open call (record, ask, `waiting`) · E3 shape a Shaping card to the board's bar and move it to Proposed · E4 answer an owner comment with `in-reply-to` · E5 a sweep report against expected lines · E6 build a tiny Approved card in a scratch repo, with closing evidence · E7 `plan`: chart, claim, resolve · E8 a `discovery` round · E9 resolve a prepared board conflict with `merge` · E10 `heal` a damaged board · E11 `watch`: a scripted owner comment arrives after 60 s, and the reply must land within 3 min · E12 two sessions try to take the same card |
| Automatic scoring | `lanework-validate.py` exits 0 · `lint-stamps.sh` · `lint-ask.sh` on each ask · `lint-leases.sh` · `lint-waiting-clears.sh` · per-task assertions: the lane, `waiting`, `in-reply-to`, a `by.name` matching the harness, a lease held and then released, no owner question asked in chat (a transcript check) |
| Optional scoring | A judge model scores body quality against the board's bar, blind to which harness wrote it |
| Runs | 12 tasks × 3 repeats per configuration. The configurations are the 7 harnesses with each one's default model, plus OpenCode with one large and one small open-weight model: 9 in all. SkillsBench found the same model scoring about 8 pp differently between harnesses, so a configuration is a harness and model pair |
| Cost (rough; prices not checked) | About 50k to 150k tokens per task, so about 2 to 5M tokens per configuration, roughly $5 to $60 each and about 3 hours of wall time. It needs the owner's accounts for each harness, and a headless mode in each (`claude -p`, `codex exec`, `opencode run`; the others are not verified) |
| Pass line | A configuration passes a skill when it reaches at least 90% of Claude Code's score on that skill's tasks |

## After matrix

These are the same grids with WP1 to WP7 built. The perform grid is a target: its cells change only on WP8 results.

### Install

| skill | CC | CX | AG | CP | CU | GK | OC |
|---|---|---|---|---|---|---|---|
| the 6 that remain | ● | ● | ● | ● (r1) | ● | ● | ● |

- **r1**: This depends on the Copilot plugin-install trial in WP7. If the trial fails, Copilot uses the installer like the other harnesses.
- `plan` is removed by WP6, so footnote d no longer applies.

### Use

| skill | CC | CX | AG | CP | CU | GK | OC |
|---|---|---|---|---|---|---|---|
| lanework | ● | ● | ●r2 | ●r2 | ●r2 | ●r2 | ●r2 |
| work | ● | ◐r3 | ◐r3 | ◐r3 | ◐r3 | ◐r3 | ◐r3 |
| watch | ● | ◐r4 | ◐r4 | ◐r4 | ◐r4 | ◐r4 | ●r5 |
| discovery | ● | ● | ● | ● | ● | ● | ● |
| plan | removed by WP6 | | | | | | |
| merge | ● | ● | ● | ● | ● | ● | ● |
| heal | ● | ● | ● | ● | ● | ● | ● |

What remains, and why it cannot be fixed on our side:

- **r2**: The harness exposes no session id, or none verified. The agent mints one, records it in its START or Claimed comment, and re-reads it from there after a compaction. The lease ends 30 minutes after the session's last board write, because there is no session process to follow. Codex has `CODEX_THREAD_ID` (S), so it may not need this.
- **r3**: The harness has no agent-to-agent messaging. Each fixer phase becomes its own subagent run that returns a report. The lead cannot grant a heavy-build slot in the middle of a run, so heavy builds run one after another.
- **r4**: The harness has no tool that wakes the agent on background output. The watch runs `watch-boards.sh --next` in a loop:
  - the session is busy while it waits;
  - each idle timeout costs a model turn;
  - the wait is capped by the harness's shell timeout.
- **r5**: OpenCode's background shell notifies the session when the process exits. A `--next` run in the background gives close to Monitor behaviour. Not tested.

### Perform target

Every cell is to be measured by WP8. The predicted change after WP3 is shown here.

| skill | Claude | GPT | Gemini | Grok | open-weight, large | open-weight, small |
|---|---|---|---|---|---|---|
| lanework, merge, heal | L | L | L | L to M | L to M | M |
| work, discovery | L | M → L to M (WP3, and an explicit "ask on the card, never assume" line) | M | M | M | H: residual unless WP9 trims what is read |
| watch | L | M | M | M | M | H |

Residual: a small model cannot hold the 80 KB board guide. Trimming the guide is the app's decision. WP9 can only make the skills read less of it.

## Designs for the points left open before

Each design has alternatives where the choice is the owner's; the ask number (C1 to C7) is given.

| topic | proposed design | alternatives | owner call |
|---|---|---|---|
| **Session identity** | `lib.sh` `session_id` takes the first that is set: `LANEWORK_SESSION_ID`, `CLAUDE_CODE_SESSION_ID`, `CODEX_THREAD_ID`, `AGENT_SESSION_ID` (Goose), `AMP_CURRENT_THREAD_ID`. If none is set, `lease.sh session` mints an id, which the agent puts before every board write and records in its START or Claimed comment | Holder from `--session`: refused today on purpose, because a subagent could pass as its lead | — |
| **Lease liveness** | Claude Code is unchanged: the timer follows `CLAUDE_PID`, or `LANEWORK_SESSION_PID` when given. Elsewhere a heartbeat: every lease-aware write touches the session's memory file, and the timer stops renewing once it has been idle for 15 minutes | (B) Walk up the process tree to the harness process: fragile, because IDE agents share one process across chats. (C) No lease on such harnesses, and so no farming | C2 |
| **Agent name** | `by_of` defaults to `LANEWORK_AGENT_NAME`, else the name detected from the harness (`CLAUDECODE` → `claude`, `CODEX_*` → `codex`, `GEMINI_CLI` → `gemini`, `AGENT=<x>` → `x`), else `agent`. The merge driver gets `--name`. Under Claude Code the stamp stays `claude` | (B) Keep `claude` as the default, overridable. (C) Always `agent` | C3 |
| **Tier vocabulary** | Rename the tiers `mechanical`, `routine`, `complex` and `inherit`. A mapping table lists Claude as `haiku`/`sonnet`/`opus`, and every other harness as its cheapest, default and strongest model. Where a harness cannot pick a model per subagent, the work runs inline | (B) Keep the Claude names and add one line mapping them to the other harnesses | C4 |
| **Lead and fixer channel** | Use the harness's messaging when it has one. Otherwise the fixer returns at each phase and the lead starts the next phase as a new run. The card thread is already the durable record | — | — |
| **`watch` without Monitor** | Add a `watch-boards.sh --next <state> --timeout <s>` mode (the prototype works): the snapshot carries over between runs, so no event is lost. Arming chooses: Monitor when the harness has it, a background `--next` where the harness notifies on exit (OpenCode), otherwise a foreground `--next` loop with a timeout under the harness's shell limit | (B) `watch` stays Claude Code and OpenCode only, and is documented as such | C5 |
| **Slash-only guard** | Each of the 4 slash-only `SKILL.md` files opens with a text guard ("Runs only when the user asked for it by name; otherwise stop"), and gets an `agents/openai.yaml` with `allow_implicit_invocation: false` for Codex. The README gets a table of how each harness invokes a skill | — | — |
| **`plan` against the spec** | Ruled: remove the skill for now. Delete `skills/plan/`, its `plugin.json` entry, its README row and install lines, its smoke cases and every citation of it (`check-refs.sh`), and retire the board's `Skill` label value. Major bump to 1.0.0. It may return later under another name | Rename to `lanework-plan`, keep `plan`, or another name: all set aside by the ruling | ruled |
| **Distribution** | `scripts/release.sh` writes an Agent Plugins `plugin.json` at the repo root from `.claude-plugin/plugin.json`, so the version keeps one source. `lanework-marketplace` gains a Codex `.agents/plugins/marketplace.json`. A repo-root `scripts/install-skills.sh` links the skills into `~/.agents/skills`, and optionally `~/.claude/skills` and `~/.kiro/skills`. The README gives one install line per harness. WP7 tries the Copilot and Codex installs on a scratch machine profile | (B) Documentation and the installer only, relying on harnesses that read `.claude-plugin/`. (C) Option A plus listings in vendor registries (Antigravity official plugins, Kiro Powers) | C7 |

## Work packages

These become the follow-on cards, in this order. "Safe under CC" means no behaviour change for Claude Code users.

| WP | scope | files touched (approx.) | size | depends on | flips | safe under CC | owner ruling |
|---|---|---|---|---|---|---|---|
| WP1 | Session resolver, heartbeat liveness, minted session id | `lib.sh`, `lease.sh`, `move-card.sh`, `label-card.sh`, `post-comment.sh`, `writes.md`, smoke cases (~8; the `plan` scripts only if WP6 has not landed) | M | — | Use e → r2 | yes | ruled |
| WP2 | Agent name resolver, `--name` on the merge driver | `lib.sh`, `heal-board.py`, `heal-descriptors.py`, `lanework-merge.py`, `rules.md`, `writes.md`, `companions.md`, `team.md`, smoke (~10; the 13 shell scripts change through `lib.sh`) | S | — | Use g | yes | C3 |
| WP3 | Prose that does not depend on the harness: capability wording, tier vocabulary, the lead and fixer fallback, the worktree folder, "ask on the card, never assume" | `tiers.md`, `team.md`, `companions.md`, `sweep.md`, `lead.md`, `fixer.md`, `farmed-prompt.md`, `discovery/SKILL.md`, `plan/SKILL.md` (~9) | M | — | Use f → r3; Perform GPT M → L to M | yes, if the Claude names stay in the mapping | C4 |
| WP4 | Slash-only guard: text line and `agents/openai.yaml` | 4 `SKILL.md`, 4 new yaml files (8) | S | — | Use i | yes | — |
| WP5 | `watch --next` mode and arming that picks the mode per harness | `watch-boards.sh`, `arming.md`, `events.md`, `watch/SKILL.md`, smoke case (~5) | M | WP3 | Use h → r4, r5 | yes (the Monitor path is unchanged) | ruled |
| WP6 | Remove `plan` | `skills/plan/` deleted, `plugin.json`, `README.md`, `CHANGELOG.md`, the citing references, the `plan` smoke cases, the board label (~15) | M | — | Install d; the `plan` rows leave both matrices | **no**: the skill and its command go; major bump | ruled |
| WP7 | Distribution: root `plugin.json` written by `release.sh`, Codex marketplace entry, `install-skills.sh`, per-harness README, install trials | `release.sh`, `README.md`, a new root `plugin.json`, a new `scripts/install-skills.sh`, plus `lanework-marketplace` (cross-repo) (~5) | M | WP6 | Install a, b, c | yes, if Claude Code ignores a root `plugin.json` (NV, to be tested) | ruled |
| WP8 | The eval: tasks, scorer and runs | a new `tests/eval/` (~15), outside `skills/` | L | WP1 to WP5 | Perform: predicted → measured | yes | C8 |
| WP9 | Read less (only on WP8 evidence): contents lists on references over 100 lines, guide sections read on demand | `writes.md`, `writing.md`, `authority.md` (~3) | S | WP8 | Perform for small open-weight models | yes | — |

Two app-side items for a `lanework-app` card:

- The guide's "Ready-made skills" line names only Claude Code.
- The 80 KB guide is more than Codex's 32 KiB cap for `AGENTS.md`.

## Done when

- [x] The owner has ruled the harness scope, lease liveness, `watch` without Monitor, the `plan` skill and distribution on this card, and the After matrices follow the rulings.
- [ ] The owner approves these findings (the move out of Proposed).
- [ ] WP1 to WP9 are then filed in Ideas, one card each, every one linked from this card's closing comment. The agent name default, the tier names and the eval budget are asked on WP2, WP3 and WP8.
- Nothing under `skills/` changes on this card.

## Recommendation

- Approve the findings.
- Build in this order: WP4 and WP2 first (small and safe), then WP1, WP3 and WP5, then WP6 and WP7 together as 1.0.0, then WP8 before any claim of "compatible".
- One card is affected now: `33dfa9b7` (plan dependencies as relations) is built and in test. Whether it still lands is asked on that card.
