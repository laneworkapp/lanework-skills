---
schema: 1
kind: card
title: "lint-ask.sh checks an ask only when it names the machine's own handle or anyone"
order: 79872
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T12:10:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T22:33:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`lint-ask.sh` skips an ask whose first line starts with a person's handle when that person is not this machine's owner, and on a board with no handle line it mistakes a record that quotes the any-human handle in backticks for an ask. The fix is to treat a handle that starts line 1 as an ask for that person, and to strip code spans and URLs before the no-board fallback picks a handle.

## Today

Both behaviours reproduced on `main` (measured, on throwaway boards under `mktemp -d`). The old body's claim that they also hold on 0.8.0 was not re-checked.

1. **A gate ask to another person is not linted.** `skills/work/scripts/lint-ask.sh:19-24` takes the handle from `owner_handle` (the guide line), or `anyone` on a v117+ board when the body names it. Any other handle never becomes `$handle`, so line 24 exits 0. Measured: a body starting with `@bob`, with options, a hedge, a semicolon and two question marks, linted against a v118 board whose guide line names `kim`: no output, exit 0. The path is documented, since `work/references/writing.md` sends a question that is one person's to that person's handle, and `skills/work/scripts/post-ask.sh:55` calls the lint for `--for <person>` too.
2. **Quoted handle, no handle line.** Line 21 takes the first `@token` of the raw body. Line 20 strips code spans and URLs, but only for the `anyone` check. Measured: on a v118 board holding only `AGENTS.md` (no handle line), a record reading "They now start with `@anyone` on this board" prints `handle @anyone is not on the first line` and exits 1. The same record with no board argument fails the same way. `post-ask.sh:54-56` runs the lint both with and without the board, so its second run takes this path. On a board with a handle line the record passes, as `tests/smoke.sh:692` already covers.
3. **`owner_handle` reads `CLAUDE.md` only** (`skills/lanework/scripts/lib.sh:70`), while `guide_version` (line 77) also reads `AGENTS.md`. Read, not measured. Only `lint-ask.sh:19` and `tests/smoke.sh:988` call it.
4. **A dead fixture.** `tests/smoke.sh:691` writes "We said @anyone should answer, then went on..." to `any-mid.md`, and line 693 overwrites it before anything reads it. Read. The old body gave line 681; the lines have moved.

## Change

One approach. Items 3 and 4 could be dropped without hurting items 1 and 2.

1. **A leading handle makes the body an ask** (`skills/work/scripts/lint-ask.sh`). Detection becomes one step: the body is an ask for handle H when H is the board's owner handle, or `anyone` on a v117+ board (both as today, anywhere in the body), or any handle that starts the first non-blank line. The line-1 test runs on the raw first line, so an `@` in a code span or URL never counts. All existing checks then run for H. A mid-sentence mention of someone else stays a record (measured: "Per @bob we shipped." passes). Rejected: a flag the caller passes. Every caller (`work/scripts/post-comment.sh:62`, `work/scripts/post-ask.sh:55`, `discovery/scripts/file-question.sh`) would need it, and the handle is already the signal. Update the header comment of the script, which says a body that mentions the human is the ask.
2. **The fallback ignores code spans and URLs** (`skills/work/scripts/lint-ask.sh:21`). Put the `sed` strip from line 20 in one variable and use it at lines 20, 21 and 28.
3. **`owner_handle` falls back to `AGENTS.md`** (`skills/lanework/scripts/lib.sh:68-72`), with the same loop as `guide_version`.
4. **Remove the dead fixture** (`tests/smoke.sh:691`).
5. **Smoke cases** (`tests/smoke.sh`, next to the v118 lint cases):
   - a clean `@bob` ask passes and a bad one fails, on a v118 and a v114 board;
   - a record with a mid-sentence `@bob` passes;
   - a record quoting `@anyone` in backticks passes on an `AGENTS.md`-only board, with and without the board argument;
   - `owner_handle` finds the handle in `AGENTS.md` when `CLAUDE.md` is absent.

**How this relates to [Asks no longer need a leading handle once the app draws buttons without one](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/675df1a2-580f-4171-a744-262eca11d380).** That card adds a second way to recognise an ask: the app's rule (two option lines, plus a question mark on line 1 or an `Options:` line), gated on the guide version and waiting on an app build and the guide. This card adds the first-line-handle way and fixes the fallback, and needs neither. Both edit the detection step in `lint-ask.sh`, so build this card first and keep detection in one place; the other card then adds one clause to it. Their behaviour does not overlap: a handle-free ask is that card's scope, a handle on line 1 for someone else is this one's.

## Not in scope

- Handle-free asks, `post-ask.sh` accepting them, and the guide-version gate: the sibling card.
- Changing what an ask must contain (word limit, Recap line, one question).
- Linting a record that names a person mid-body.

## Risks

- A record that starts with a person's handle (`@bob fixed this`) is now linted as an ask and may be refused. Accepted: the app drew buttons on a leading handle too, so it reads as an ask there.
- The sibling card edits the same lines. If it lands first, add the leading-handle clause to its detection step instead.
- `owner_handle` on `AGENTS.md` changes `ask_handle` below v117 for boards that only have `AGENTS.md`. Those boards got no handle before, so this fills a gap.

## Done when

- `tests/smoke.sh` passes, including the new cases.
- A body starting `@bob` with a semicolon and two question marks, linted against a v118 board, prints at least one violation and exits 1. Before the change it prints nothing.
- A record quoting `@anyone` in backticks lints clean against an `AGENTS.md`-only board and with no board.
- `grep -n 'We said @anyone should answer, then went on' tests/smoke.sh` prints nothing.

Bump: patch.
