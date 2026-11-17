---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:30:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T11:30:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Shaped and moved to Proposed. The bug is one argument in `found-board.sh`, with no open calls.**

- **Evidence**: `grep -rn '{{title}}' skills/*/templates/` finds the heading in three index templates. `found-board.sh:67` renders `title "$TITLE"` raw beside `title_yaml`. Question and record titles go through `title_str` already.
- **Decided**: share one flatten rule between frontmatter and heading, via `flat_str` in `lib.sh`. Rejected: an inline `${TITLE//$'\n'/ }`, which would leave CR and CRLF handling in two places.
- **Merge note**: lands only after the v84 stamp issue [1a63eb6b](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/1a63eb6b-52b3-44b9-8b0a-a1aec41d4dcd), since main's smoke is red until then.
