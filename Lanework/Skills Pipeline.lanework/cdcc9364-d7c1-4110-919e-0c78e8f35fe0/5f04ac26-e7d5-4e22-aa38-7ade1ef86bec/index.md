---
schema: 1
kind: card
title: "Templates: a line break in a board title splits its body heading"
order: 2048
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T02:09:31Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:09:31Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Board templates write `# {{title}}` into the body with the raw title, so a line break in a board title splits the heading over two lines. The frontmatter title is escaped by `title_str` since `db33e0d`. Only the body heading is affected, and the board still validates.

- **Where**: the `# {{title}}` line in `lanework/templates/board.md`, `pipeline-index.md` and `index.md`, rendered by `found-board.sh`.
- **Likely fix**: render the heading from a flattened title (CR/LF to a space, no YAML escaping), plus a smoke case.
