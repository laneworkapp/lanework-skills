---
schema: 1
kind: card
title: "lint-ask.sh checks an ask only when it names the machine's own handle or anyone"
order: 1024
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T12:10:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T13:39:57Z}
---
An ask addressed to a person other than this machine's owner passes `lint-ask.sh` unchecked, and on a board with no handle line the lint still mistakes a quoted handle for an ask.

## Seen

Both by the reviewer of [the guide v118 card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8), on a scratch board carrying the real v118 guide, at `d372ef5`. Both behave the same on 0.8.0.

1. **A gate ask to another person is not linted.** `skills/work/scripts/lint-ask.sh` takes "the human" from `owner_handle`, the handle on the board's guide line. A body whose first line names a different handle (the reviewer's example: `@bob` on a gate) is read as a record: no first-line, 80-word, one-question or Recap check. Since the guide v118 card, `work/references/writing.md` sends a question that belongs to one person to that person's handle, so this path is now a documented one.
2. **No handle line, quoted handle.** On a board with no handle line (the reviewer's example: one holding only `AGENTS.md`), line 21 falls back to the first `@token` in the raw body. A record quoting the anyone handle in backticks is then refused as an ask. The code-span strip added at line 20 is not applied here. `owner_handle` in `lanework/scripts/lib.sh` reads `CLAUDE.md` only, though `guide_version` now falls back to `AGENTS.md`.
3. **A dead fixture.** `tests/smoke.sh` line 681 at `d372ef5` ("We said @anyone should answer, then went on") is overwritten at line 683 before anything reads it.

## Not decided

- How the lint tells a person-addressed ask from a record that mentions a person. Candidates: any handle on line 1 makes the body an ask; or a flag the caller passes.
- Whether `owner_handle` should read `AGENTS.md` when `CLAUDE.md` is absent, or only the lint's fallback changes.

## Size

Small. One script, one helper, smoke cases for each of the two behaviours, one fixture line removed.
