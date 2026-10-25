---
schema: 1
title: "Standing Recap option on every ask"
order: 2048
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created: {at: 2026-10-25T01:14:26Z}
modified: {at: 2026-10-25T01:22:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
waiting: {for: rzen, since: 2026-10-25T01:22:39Z, comment: 39c4757d-a08f-4183-b3ef-601ddae51a64}
kind: card
---
Every ask the agents post carries one standing last option, `Recap`, that the owner can click to get a plain-language recap of the question before answering.

## Problem

The owner often finds an ask confusing and types "please explain in simple terms" as a comment. A button does the same in one click and phrases it the same way every time.

## What changes

- **The option**: every ask ends its options with the line `- Recap: Explain this in plain terms first`. The label starts with a letter, as the guide's option rule requires (a `?` label is illegal). A click posts `Recap: Explain this in plain terms first` as the owner's comment.
- **What an agent does on a click**: it is a request, not a ruling.
  1. Post a record, `in-reply-to` the click: the decision in everyday words (what is being decided, why now, what each option does), no new options, no handle.
  2. One second later re-post the same ask as a new comment, with the standing line again.
  3. Set `waiting` to the new ask in the same pass, because the app clears it on any human comment.
  4. Change nothing else: no body edit, no lane exit.
- **The lint**: `lint-ask.sh` fails an ask without the standing line, and leaves that line out of the 80-word count.

## Files touched

| file | change |
|---|---|
| `skills/work/templates/ask.md` | standing line in the shape and the filled example |
| `skills/work/references/writing.md` | § The ask: the standing option and the click rule (the one place the rule lives) |
| `skills/work/scripts/lint-ask.sh` | require the line; exclude it from the word count |
| `skills/watch/references/responding.md` | the Ruling bullet: a `Recap:` click is not a ruling, see `work/references/writing.md` |
| `skills/discovery/scripts/file-question.sh` | append the line to the asks it builds |
| `tests/smoke.sh`, `README.md` | new cases; word counts refreshed by `check-sizes.sh` |

## Verified by

- `tests/smoke.sh` green, including `check-refs.sh` and `check-sizes.sh`.
- New smoke cases: `lint-ask.sh` fails an ask without the line, passes one with it, and passes an ask with 79 words of its own plus the line. The discovery case already lints `file-question.sh` output, so it fails until the script adds the line.
- Prose (`ask.md`, `writing.md`, `responding.md`) read against `lanework-agent-guide` § Use the thread ▸ Questions: label shape, blank line after the list, one clause per sentence.

## Done when

1. `work/templates/ask.md` shows the `Recap` line in both the shape and the filled example.
2. `lint-ask.sh` exits 1 on an ask without the line, and 0 on a clean ask that has it, including one at 79 words of its own.
3. `file-question.sh` output carries the line and lints clean.
4. `work/references/writing.md` § The ask holds the click rule (record, re-post, reset `waiting`, no ruling), and `responding.md` only links to it.
5. `tests/smoke.sh` passes and the README counts match.

## Risks

- **Guide drift**: the in-board guide's ask shape does not list a standing option. This extends the shape and contradicts nothing, but the guide wins if it ever says otherwise.
- **Tighter asks**: with the line excluded from the count, no ask shrinks. If the owner wants it counted, authors lose about 9 words.
- **Button noise**: a lone `Recap` button on an ask with no real options. See the open call.
- **Loop**: a second click on the re-posted ask gets a second recap. Fine, but each click costs an agent turn.

## Open call

Do asks with no options (yes/no or free text) get the line too? **Recommended: yes**, since the owner asked for it on all questions and an ask is where confusion happens. The ask then shows one lone button, and the template's "Options, only when choosing" becomes "Options: the standing line, plus the choices when choosing".

## Recommendation

Build it as above, with the line on every ask.
