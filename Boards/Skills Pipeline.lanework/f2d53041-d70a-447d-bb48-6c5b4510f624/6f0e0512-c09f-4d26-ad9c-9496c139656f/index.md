---
schema: 1
kind: card
title: "lease.sh leftovers 2: sweep and EPERM, temp file pid, two small wording fixes"
order: 9216
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T17:13:46Z}
---
The lease write's temp-file sweep stops deleting a live writer's file, and a killed `lease.sh` no longer costs a concurrent write its temp file, with one duplicated sentence in `writes.md` merged.

## Problem

1. **The sweep treats a pid it may not signal as dead.** `write_card` in `skills/lanework/scripts/lease.sh` (the sweep loop at the top) deletes a temp file when `! kill -0 "$sp"`. `kill -0` also fails with EPERM for a live process owned by another user. Reproduced on a throwaway board under `mktemp -d`, made-up session `S-fake`, a planted `.lease-write.<card>.1.lanework-tmp` (pid 1 is live, not signalable as this user): `kill -0 1` prints "operation not permitted" and exits 1, and after `lease.sh stake` the planted file was gone. Matters only when another user writes the same board.
2. **The temp file carries the script's pid, not the writer's.** The perl call in `write_card` is given `"$BOARD/.lease-write.$CID.$$.lanework-tmp"`, and `$$` there is the `lease.sh` pid. If `lease.sh` is SIGKILLed while perl is still writing the cross-volume temp file, the pid in the name is dead and perl is alive, so the next lease write on the board sweeps perl's file, perl's `rename` fails, and that write is dropped. Not reproduced: reasoned from the perl argument list and the sweep loop in `lease.sh` (the cross-volume path needs a second volume; the existing RAM disk case in `tests/smoke.sh` 11d builds one).
3. **`echo` mangles a backslash id in the smoke failure message.** Not real: the script runs under `#!/bin/bash` with `xpg_echo` off, and `bash -c 'sid="S\x"; echo "11e: $sid"'` prints `11e: S\x` unchanged. Dropped.
4. **`references/writes.md` states "another session's claim, exit 1" twice.** The Release bullet says "Another session's live claim: exit 1"; the Writes bullet says "A release that finds another session's claim exits 1". Real, and the Exit codes bullet already holds the code.

## Change

1. `skills/lanework/scripts/lease.sh`, the sweep loop: a pid is dead only when `ps -p "$sp" >/dev/null 2>&1` fails. `ps -p` reports a process of any user and exits 1 only when it does not exist (checked: `ps -p 1` exits 0, `ps -p 999999` exits 1). Keep the numeric-pid guard. Update the sweep comment ("the pid in the name is dead" stays true).
2. `skills/lanework/scripts/lease.sh`, the perl call: pass the prefix `"$BOARD/.lease-write.$CID"` and have perl build `my $tmp = "$pre.$$.lanework-tmp"` from its own `$$` before `fail` is defined. perl is the process that holds the file, so the sweep now tests the right pid: a SIGKILLed `lease.sh` leaves perl alive and its file is skipped; a SIGKILLed perl leaves a dead pid and the file is swept. Update the comment above the perl call and the header paragraph about the sweep only where they name the pid. The TERM, INT and HUP cleanup is unchanged.
3. Dropped, no change.
4. `skills/lanework/references/writes.md`: the Release bullet becomes the one place: another session's claim, found before the write or during it, exits 1 with the memory kept, and the next lease call records the loss. The Writes bullet loses its last "A release that finds another session's claim exits 1, and the next lease call records the loss." sentence. Check `tests/check-refs.sh` and `tests/check-sizes.sh` still pass.

## Verified

New cases in `tests/smoke.sh` beside 11e, none touching the Skills Pipeline board.

1. In 11e, plant `.lease-write.<card>.1.lanework-tmp` next to the existing live-pid plant, run a lease write as the card's session, and assert the pid-1 file is still there. Fails on today's code (the file is deleted, as measured above). Remove it afterwards.
2. In 11d (the RAM disk case, skipped with the existing note when no volume can be made): during the `LEASE_TEST_WRITE_PAUSE` hold, read the pid from the temp file's name and assert it is perl's (`ps -o ppid=` of it is the `lease.sh` process), then `kill -9` that parent, run a second lease write on another card to trigger the sweep, and wait for the held write to finish. Assert the first card's `until` changed (the write landed) and no temp file is left. Fails today: the name carries the killed script's pid, the sweep removes the file and the write is dropped. Record every pid started and kill only those by pid.
3. No case for the wording fix beyond `tests/check-refs.sh` and `tests/check-sizes.sh`.

## Done when

- `bash -n skills/lanework/scripts/lease.sh` is clean and `tests/check-refs.sh` and `tests/check-sizes.sh` pass.
- On a throwaway board, a planted `.lease-write.<card>.1.lanework-tmp` survives `lease.sh stake`, and a planted one with a long-dead pid is still removed (the existing 11e check).
- The 11d kill case passes where a RAM disk can be made, and the smoke run reports the skip note elsewhere.
- `grep -c 'another session' skills/lanework/references/writes.md` shows the exit-1 statement in the Release bullet only, besides the Exit codes bullet.
- `tests/smoke.sh` passes.

## Risks

- Builds after the two branches that also edit `lease.sh` merge: one changes the session-id check and stamp handling (`f6743778`, `stamp_args_ok`), the other `find_card` and the timer loop. This card touches only the sweep loop and the perl call inside `write_card`, so it should rebase cleanly, but write the change on top of main as it is then.
- `ps -p` costs one fork per planted file; there are normally none, so the loop runs no `ps` at all.
- Pid reuse can still make a dead writer's file look live until that pid frees; the file is then swept by a later write. That was already true of `kill -0`.
- The 11d kill case sends SIGKILL to a process it finds from the temp file's name. Guard the ppid read so a failed lookup never kills pid 0 or an empty target.

## Recommendation

Build items 1, 2 and 4; drop item 3 as not real. Items 1 and 2 are small, local to `write_card`, and each has a smoke case that fails without the fix. Item 4 is a one-sentence merge. Build after the two other `lease.sh` branches land.
