---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:52:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T02:52:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
**Owner added `round` to the catalog in chat. It joins as discovery's existing definition plus `single: true`, and discovery's board template reads it from the catalog.**

- **Decided, no icon**: entries stamp their kind whole, so a new glyph on the kind would put a stale-label repair on every card of every existing discovery board.
- **Decided, `single: true`**: a question is asked in exactly one round. `single` constrains writers only and is never stamped.
- **Decided, one source**: `found-discovery-board.sh` passes `--labels round`. Discovery's own `record` and `status` kinds stay in its template, because no other board uses them.
