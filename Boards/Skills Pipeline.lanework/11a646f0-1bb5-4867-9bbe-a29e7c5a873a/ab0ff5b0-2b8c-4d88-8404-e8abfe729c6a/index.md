---
schema: 1
kind: card
title: "commit-board.sh leftovers: staged entries on a retry, unbounded timeout value, uncovered rules, tty prompt"
order: 2048
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T15:44:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Reviewer notes from `647a2050` (approved), not fixed there. All in `skills/work/scripts/commit-board.sh`.

## Items

1. **Staged entries not saved on a retry path.** `:251` `[ "$try" -gt 1 ] || save_owner`: if try 1 takes the retry path and its push is rejected, try 2 commits without the owner's staged entries ever saved; a second rejection loses them. Reasoned, not run. Fix: a "saved once" flag.
2. **A huge bound disables the bound.** `LANEWORK_PUSH_TIMEOUT=99999999999` passes the check, perl's `alarm` fails, and the push runs unbounded. Measured. Cap the value or check `alarm`'s return.
3. **No smoke case** for: INT/TERM/HUP forwarding to the push's process group (`:159`); a git that itself exits 124 not reading as a timeout (`:162`); the sweep's live-pid guard (`:150`); the non-fatal `rm` in `release` (`:118`).
4. **A tty credential prompt waits out the bound.** `git push` sits in a background process group, so a `/dev/tty` prompt stops it and it reports "timed out". Option: `GIT_TERMINAL_PROMPT=0` so it fails fast.

## To shape

Reproduce 1 and 4 on throwaway repos; decide which of 3 are worth a case.
