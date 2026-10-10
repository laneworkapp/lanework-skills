---
schema: 1
kind: card
title: "Templates: a line break in a board title splits its body heading"
order: 1024
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T02:09:31Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T11:30:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
`found-board.sh` writes a board title raw into the body heading, `# {{title}}`, so a line break in the title splits the heading over two lines. The frontmatter title is already flattened and escaped by `title_str`.

## Cause

`found-board.sh:67` passes two forms of the title to the index template: `title_yaml` (escaped, flattened) for frontmatter, and `title` (raw) for the heading. The three templates that use `# {{title}}` are `lanework/templates/index.md`, `pipeline-index.md` and `discovery/templates/board.md`.

## Proposal

- **One flatten helper**: `lanework/scripts/lib.sh` gains `flat_str`, which turns CR, LF and CRLF into one space. `title_str` becomes `flat_str` then the YAML escaping, so both share one flatten rule.
- **Heading uses it**: `found-board.sh` passes `title "$(flat_str "$TITLE")"`. The heading is Markdown, not YAML, so it gets no escaping.
- **Out of scope**: question and record titles. `file-question.sh` and `file-record.sh` already pass `title_str` output, and their templates have no body heading.

## Touches

`skills/lanework/scripts/lib.sh`, `skills/lanework/scripts/found-board.sh`, `tests/smoke.sh`.

## Verify

`tests/smoke.sh` passes with a new case. `found-board.sh` with a board title carrying LF and CRLF writes a single `# <title>` line, words joined by one space. The board validates. A mutation that passes the raw title again turns smoke red.

## Done when

No template heading receives a raw title, and the smoke case passes.
