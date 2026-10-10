---
schema: 1
kind: card
title: "Discovery and founding scripts: escape titles, and stamp a real model"
order: 32768
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T01:09:29Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:09:32Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Two stamping bugs in the shipped scripts. `file-question.sh` writes a backslash in a title unescaped, and four scripts stamp `model: unknown` on every documented call.

## Reproduce

- **Title**: `file-question.sh <board> 'C:\path' --round 1 --body F` writes `title: "C:\path"`, where `\p` is an invalid YAML escape. The round-2 review of the ADR-lane card saw the backslash lost in a question title. `file-record.sh` escapes the same input correctly since `74dbb4c`.
- **Model**: `file-question.sh`, `settle-question.sh`, `file-record.sh` and `found-board.sh` default `MODEL` to `${CLAUDE_MODEL:-unknown}`. No skill doc shows `--model`, so every documented call stamps `model: unknown`.

## Proposal

- **One title helper**: `lanework/scripts/lib.sh` gains `title_str`: CR and LF become a space, then `yaml_str` escaping (backslash, then quote). `file-record.sh` drops its inline copy, and `file-question.sh` uses the helper.
- **A model is required**: each of the four scripts takes `--model`, else `CLAUDE_MODEL`, else exits 2 with its usage line, before writing anything. `unknown` is never stamped.
- **Docs show it**: the script tables in `discovery/SKILL.md` and `lanework/SKILL.md` add `--model m`.
- **Decided**: refuse rather than default. A wrong stamp is worse than a failed call: the guide reads `by` as a claim about who wrote the file.
- **Rejected**: omitting `model` when unknown. The guide asks for all four subkeys, and a silent gap hides the bug.

## Touches

`skills/lanework/scripts/lib.sh`, `skills/lanework/scripts/found-board.sh`, `skills/lanework/SKILL.md`. `skills/discovery/scripts/file-question.sh`, `settle-question.sh`, `file-record.sh`, `found-discovery-board.sh` (passes `--model` through), `skills/discovery/SKILL.md`. `tests/smoke.sh`.

## Verify

`tests/smoke.sh` passes, with two new cases. A question title with a backslash, a quote and a newline goes through `file-question.sh`, round-trips, and the board validates. Each of the four scripts run with no model and no `CLAUDE_MODEL` exits 2 and writes nothing. Existing smoke calls pass `--model`.

## Done when

No script under `skills/` stamps `model: unknown`, every title a script writes goes through `title_str`, and both smoke cases pass.
