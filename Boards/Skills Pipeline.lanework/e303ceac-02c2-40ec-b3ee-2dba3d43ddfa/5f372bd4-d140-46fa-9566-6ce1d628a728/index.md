---
schema: 1
title: "Standing Recap option on every ask"
order: -1024
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created: {at: 2026-10-25T01:14:26Z}
modified: {at: 2026-10-25T11:38:43Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
kind: card
---
Every ask that offers options carries one standing last option, `Recap`, that the owner can click to get a plain-language recap of the question before answering.

## Problem

The owner often finds an ask confusing and types "please explain in simple terms" as a comment. A button does the same in one click and phrases it the same way every time.

## What changes

- **The option**: every ask with options ends them with the line `- Recap: Explain this in plain terms first`. The label starts with a letter, as the guide's option rule requires (a `?` label is illegal). A click posts `Recap: Explain this in plain terms first` as the owner's comment.
- **What an agent does on a click**: it is a request, not a ruling.
  1. Post a record, `in-reply-to` the click: the decision in everyday words (what is being decided, why now, what each option does), no new options, no handle.
  2. One second later re-post the same ask as a new comment, with the standing line again.
  3. Set `waiting` to the new ask in the same pass, because the app clears it on any human comment.
  4. Change nothing else: no body edit, no lane exit.
- **The lint**: `lint-ask.sh` fails an ask whose options lack the standing line, and leaves that line out of the 80-word count. An ask with no options needs no line.

## Files touched

| file | change |
|---|---|
| `skills/work/templates/ask.md` | standing line in the shape and the filled example |
| `skills/work/references/writing.md` | § The ask: the standing option and the click rule (the one place the rule lives) |
| `skills/work/scripts/lint-ask.sh` | require the line; exclude it from the word count |
| `skills/watch/references/responding.md` | the Ruling bullet: a `Recap:` click is not a ruling, see `work/references/writing.md` |
| `skills/discovery/scripts/file-question.sh` | append the line to the options of the asks it builds |
| `skills/discovery/references/conduct.md`, `discovery/SKILL.md`, `discovery/references/rounds.md` | a `Recap:` click is not an answer, and the re-posted ask is the one live ask: rule in `conduct.md`, pointers in the other two |
| `tests/smoke.sh`, `README.md` | new cases; word counts refreshed by `check-sizes.sh` |

## Verified by

- `tests/smoke.sh` green, including `check-refs.sh` and `check-sizes.sh`.
- New smoke cases: `lint-ask.sh` fails an ask with options but no line, passes one with it, passes an ask with no options and no line, and passes an ask with 79 words of its own plus the line. The discovery case already lints `file-question.sh` output, so it fails until the script adds the line.
- Prose (`ask.md`, `writing.md`, `responding.md`) read against `lanework-agent-guide` § Use the thread ▸ Questions: label shape, blank line after the list, one clause per sentence.

## Done when

1. `work/templates/ask.md` shows the `Recap` line in both the shape and the filled example.
2. `lint-ask.sh` exits 1 on an ask whose options lack the line, and 0 on a clean ask that has it (including one at 79 words of its own) and on an ask with no options.
3. `file-question.sh` output with options carries the line and lints clean.
4. `work/references/writing.md` § The ask holds the click rule (record, re-post, reset `waiting`, no ruling), and `responding.md` only links to it.
5. `tests/smoke.sh` passes and the README counts match.

## Risks

- **Guide drift**: the in-board guide's ask shape does not list a standing option. This extends the shape and contradicts nothing, but the guide wins if it ever says otherwise.
- **Tighter asks**: with the line excluded from the count, no ask shrinks. If the owner wants it counted, authors lose about 9 words.
- **Loop**: a second click on the re-posted ask gets a second recap. Fine, but each click costs an agent turn.

## Decided

- **Scope** (owner, 2026-10-25): only asks that already have options carry the line. Yes/no and free-text asks don't get a lone button.

## Recommendation

Build it as above.
