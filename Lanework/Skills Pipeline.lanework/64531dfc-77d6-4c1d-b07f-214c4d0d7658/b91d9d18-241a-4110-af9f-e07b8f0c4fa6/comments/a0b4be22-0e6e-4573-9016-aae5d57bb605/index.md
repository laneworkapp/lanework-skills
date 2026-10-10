---
schema: 1
kind: comment
in-reply-to: 75b0f728-69f4-4828-b6f0-592669583ab1
created:  {at: 2026-10-10T01:55:05Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T01:55:05Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Full Codex compatibility is cheap for three skills, a rewrite for `work`'s farming, and likely out of reach for `watch`.** Measured by a grep of `skills/` for Claude Code-only features.

| skill | Claude Code-only dependency | what Codex needs |
|---|---|---|
| `lanework` | none. Plain files, bash, the board's `AGENTS.md` twin | an `agents/openai.yaml` |
| `merge` | none | an `agents/openai.yaml` |
| `discovery` | `disable-model-invocation: true` | yaml with `allow_implicit_invocation: false` |
| `work` | Agent tool farming, haiku/sonnet/opus tiers, `SendMessage` lead↔fixer channels (4, 2 and 2 files) | harness-neutral wording: "spawn a subagent if the harness has one, else run the step inline", tiers as cheap/mid/strong |
| `watch` | `Monitor` streams events into the session, `TaskStop` ends it, and `disable-model-invocation` | a harness push into a live session. Codex has no known equivalent. Fallback: a re-run sweep, not a watch |

- **Already neutral**: the board guide ships as `CLAUDE.md` and an identical `AGENTS.md`, which Codex reads. Scripts are bash plus BSD tools, and `git worktree` is plain git.
- **Unverified**: Codex's current subagent and background-event features. Building option C starts by checking them. If Codex gained a push API, `watch` moves up a row.
- **Size**: about five yaml files, one smoke case, a rewrite of `work`'s farming references (`tiers.md`, `team.md`, `lead.md`, `farmed-prompt.md`), and a README support table.
