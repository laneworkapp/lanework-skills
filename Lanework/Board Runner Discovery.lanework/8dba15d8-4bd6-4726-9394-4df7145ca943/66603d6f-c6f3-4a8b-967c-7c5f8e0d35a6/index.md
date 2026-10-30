---
schema: 1
kind: card
title: "Fact: headless runs cap turns exactly, spend only roughly"
order: 3072
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
`--max-turns` stops a headless run with an error at the limit; there is no default limit. `--max-budget-usd` exists but is a client-side estimate that can overshoot. Exit code is non-zero on failure.

## Source

- code.claude.com/docs/en/cli-reference.md, headless.md, read 2026-10-30. Report attached.

## Bears on

- [Q7: What counts as success](lanework://d7e27581-ac3c-4bb3-ab2c-41c3333416d6/30ab959c-6258-462a-932b-05c7261d7067)
