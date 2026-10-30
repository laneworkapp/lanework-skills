---
schema: 1
kind: card
title: "Fact: launchd jobs need a token in the settings env block"
order: 8192
icon: {glyph: doc.text.magnifyingglass}
created:  {at: 2026-10-30T13:48:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-10-30T13:49:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
A launchd job does not see shell exports. A headless run there signs in with `CLAUDE_CODE_OAUTH_TOKEN` from `claude setup-token`, or `ANTHROPIC_API_KEY`, set in the `env` block of `~/.claude/settings.json`. `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` turns off auto-updates and telemetry.

## Source

- code.claude.com/docs/en/env-vars.md, headless.md, read 2026-10-30. Report attached.

## Bears on

- Install: next round
