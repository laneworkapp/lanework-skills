---
schema: 1
kind: card
title: "Review leftovers 3: Recap-click edges, lease memory file, commit-board setsid, smoke guard"
order: 2048
labels: [{text: "discovery", kind: {type: "skill", text: "Skill"}}, {text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "work", kind: {type: "skill", text: "Skill"}}, {text: "repo", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T19:23:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T22:35:16Z}
---
Reviewer notes left open when four cards closed on 2026-11-21, none blocking, each from a reviewer's read or run and not yet re-checked.

## Problem

**`discovery/scripts/settle-question.sh`** (from the Recap-click card)

- A `Recap:` click saved with a UTF-8 BOM is not recognised as a click, so it still settles (`:45-46` at the time of review).
- No smoke case covers an agent record whose body starts `Recap:`. A mutant that skips such a comment whoever wrote it passes.
- The first-line read (`tr | awk ... exit`) can die of a broken pipe on a comment over about 64 KB.
- After a click the app clears `waiting`. A settle before the question is asked again is not caught, because the lint is skipped when `waiting` is absent.

**`lanework/scripts/lease.sh`** (from the smoke-under-load card)

- `mem_save` in the timer's notice branch can bring the memory file back just after a release removed it.
- `mem_load` and `mem_save` are the two commands left in the timer loop that can end it under `set -e`.

**`work/scripts/commit-board.sh`** (from the commit-board leftovers card)

- `POSIX::setsid()` is not checked. If it failed, the timeout and the group kill would silently stop working.
- The fallback that signals the child alone, before its `setsid`, has no smoke case.
- A TERM or HUP in the few microseconds before the wrapper installs its handlers is not forwarded.

**`work/scripts/label-card.sh`** (from the label-card card)

- The `LABEL_CARD_TEST_HOLD` test hook gives up after about 20 s, so a case that leans on it can pass by timeout on a slow machine.

**`tests/smoke.sh`**

- The early-reader guard matches `head` and `grep -q/-m` only. `sed q`, `awk ... exit`, `| read` and a script called through a variable are not matched.
- `bq()` discards the script's exit code.

## Done when

Each item is fixed with a smoke case that fails before the fix, or ruled out with a reason in the thread.
