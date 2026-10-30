# Headless `claude -p`: facts for an unattended runner

Read 2026-10-30 from code.claude.com docs. "Silent" = the fetched pages did not say.

## 1. Headless flags
- `--output-format text|json|stream-json`. `json` = one result object. `stream-json` = newline-delimited events, needs `--verbose`. (headless.md)
- stream-json emits `system/init`, `assistant` and `user` messages, `stream_event` deltas with `--include-partial-messages`, `system/api_retry`, `permission_denied`, and a final `result` line. Subagent text and thinking only with `--forward-subagent-text`. Main-conversation thinking blocks in stream-json: silent. (headless.md, cli-reference.md)
- `--max-turns`: print mode only, exits with an error at the limit. No default limit. (cli-reference.md)
- `--max-budget-usd`: print mode only. Client-side estimate, can overshoot; subagent spend counts. (cli-reference.md)
- `--model`, `--append-system-prompt(-file)`, `--system-prompt(-file)`. `--bare` skips hooks, skills, plugins, MCP and CLAUDE.md, so it would drop `/lanework:*`. (cli-reference.md, headless.md)
- `--settings <file-or-json>`; `--setting-sources user,project,local`; `--add-dir` grants file access only. (cli-reference.md)

## 2. Permissions
- `--permission-mode`: `default` (alias `manual`), `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. (permission-modes.md)
- `-p` with no mode set starts in Manual. Project settings' `permissions.defaultMode` cannot set `auto` or `bypassPermissions`. (permission-modes.md)
- `--allowedTools` / `--disallowedTools` use rule syntax, e.g. `Bash(git commit *)`. (headless.md, cli-reference.md)
- `--dangerously-skip-permissions` = `--permission-mode bypassPermissions`; refused as root/sudo unless a sandbox is detected. (permission-modes.md)
- In `-p`, a tool needing approval is denied unless an allow rule, hook, `canUseTool` or `--permission-prompt-tool` approves it. The run continues. `--permission-prompts none` stops retries. Denials appear as `permission_denied` events and in the result's `permission_denials`. (permission-modes.md, headless.md)
- `dontAsk` denies everything that would prompt; reads, allow-listed tools and read-only commands still run. (permission-modes.md)

## 3. Sessions
- `--session-id <uuid>`, `--resume <id|name|path>`, `--continue`, `--fork-session`. `--resume <id>` works from any directory. (cli-reference.md, sessions.md)
- `-p` sessions are hidden from the picker and `--continue`, except `claude -p --continue`. (sessions.md)
- Transcripts: `~/.claude/projects/<cwd, non-alphanumerics → ->/<session-id>.jsonl`, kept 30 days (`cleanupPeriodDays`). `--no-session-persistence` disables. Format internal; may change. (sessions.md)
- Resume in `-p` does not restore `--mcp-config`, `--settings`, `--plugin-dir`, `--fallback-model`, `--add-dir`: pass again. (sessions.md)

## 4. Skills and plugins in -p
- User-invoked skills work in `-p`: `/skill-name` at the start of the prompt. (headless.md)
- Plugin-namespaced skills (`/lanework:work`) in `-p`: silent. `disable-model-invocation` in `-p`: silent. (headless.md, skills.md)

## 5. Result and exit
- json result: `result`, `session_id`, `total_cost_usd`, per-model cost, `structured_output` with `--json-schema`. (headless.md)
- `num_turns`, `is_error`, `subtype` (e.g. `error_max_turns`): not confirmed.
- Exit 0 success, non-zero failure. SIGTERM → 143, no result for the turn in progress; SIGINT ends the turn cleanly. (headless.md)

## 6. Concurrency, isolation, environment
- `--worktree <name>` works with `-p`: `.claude/worktrees/<name>` on branch `worktree-<name>`; `-p` runs don't clean up. (worktrees.md)
- Limits on concurrent `claude -p` processes or rate limits: silent.
- Auth under launchd: `ANTHROPIC_API_KEY` overrides the subscription in `-p`. `claude setup-token` → `CLAUDE_CODE_OAUTH_TOKEN` for automation. `--bare` never reads OAuth or keychain. (env-vars.md, headless.md)
- Shell exports don't reach launchd jobs: use the `env` block of `~/.claude/settings.json`. (env-vars.md)
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` disables auto-updates, telemetry, flag fetches. Also `CLAUDE_CODE_MAX_TURNS`, `BASH_DEFAULT_TIMEOUT_MS`, `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`. `-p` waits up to 10 minutes idle for background work. (env-vars.md, headless.md)

## 7. Overlapping built-ins
- `/loop` and session cron: need an open session, expire after 7 days. Desktop scheduled tasks: local, need the machine awake. Cloud routines: Anthropic cloud, fresh clone, no local files. (scheduled-tasks.md)
- Hooks: in-session lifecycle events; no general file-watch trigger. (hooks.md)
- Agent SDK: a library with the same loop; no scheduler. (agent-sdk/overview.md)
- None triggers a headless run on a file event.
