---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:46:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T01:46:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Shaped and moved to Proposed. The scope grew from one script to four: the `unknown` model default was in every stamping script, and no doc passed `--model`.**

- **Decided**: refuse to write without a model, rather than default or omit it. A wrong `by` is a false claim about the writer.
- **Decided**: one `title_str` in `lib.sh` for every script title. `file-record.sh` has the only correct copy today.
- **Evidence**: a grep of `skills/` finds `${CLAUDE_MODEL:-unknown}` in four scripts and `--model` in no SKILL.md or reference call. The quote-only title escape exists only in `file-question.sh:75`.
- **No open calls.**
