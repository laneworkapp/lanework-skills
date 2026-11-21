---
schema: 1
kind: comment
created:  {at: 2026-11-21T15:43:43Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to main at `da2bf8a` (branch `lease-leftovers`, head `2ca1594`).

**Changed**: `lease.sh` refuses a session id holding `,`, `}`, `\` or a tab (exit 2, on every subcommand). Another session's refused release points at `lease.sh list <board>` and `--force on the owner's word only`. A `.lease-write.*.lanework-tmp` left by a dead pid is swept on the next write. Header and `writes.md` agree.

**Departures**: one smoke case (11e) covers the three rules, not three cases; the reviewer mutated each rule alone and the case failed each time. `writes.md` gained a Writes sentence on the temp file.

**Review**: approved, adversarial stance, no blocking findings.

**Evidence**: `tests/smoke.sh` on main at `da2bf8a`: `smoke: 331 passed`, rc 0.

**Left open** (filed as one Issues card): the sweep treats a pid it may not signal as dead; the temp file is named with the script's pid, not the writer's; `echo` mangles a backslash id in a failure message; one rule stated twice in `writes.md`.

**CHANGELOG**: `lease.sh` now refuses session ids it cannot store faithfully, and cleans up a temp file a killed write left behind.
