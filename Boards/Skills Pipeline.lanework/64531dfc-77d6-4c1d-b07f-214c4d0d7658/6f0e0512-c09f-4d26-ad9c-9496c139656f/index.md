---
schema: 1
kind: card
title: "lease.sh leftovers 2: sweep and EPERM, temp file pid, two small wording fixes"
order: 4096
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T16:42:56Z}
---
Reviewer notes from `ae676e47` (approved), not fixed there.

## Items

1. **The sweep treats a pid it may not signal as dead.** `lease.sh:81` `! kill -0 "$sp"`: EPERM counts as dead; a planted `.lease-write.<card>.1.lanework-tmp` (pid 1, live) was deleted. Matters only when another user writes the same board.
2. **The temp file carries the script's pid, not the writer's.** `lease.sh:127`: if `lease.sh` is SIGKILLed while perl is still writing, a concurrent write's sweep deletes perl's temp file, perl's rename fails, and that write is dropped. Reasoned, not run. Fix: name the file from perl's own `$$`.
3. `tests/smoke.sh:2866`: `echo` mangles a backslash id in the failure message; use `printf`.
4. `skills/lanework/references/writes.md`: the Release and Writes bullets both state "another session's claim, exit 1".

## To shape

Reproduce 1 and 2 on a throwaway board. Wait for `f6743778` (stamp values) to merge first: it edits the same session-id check.
