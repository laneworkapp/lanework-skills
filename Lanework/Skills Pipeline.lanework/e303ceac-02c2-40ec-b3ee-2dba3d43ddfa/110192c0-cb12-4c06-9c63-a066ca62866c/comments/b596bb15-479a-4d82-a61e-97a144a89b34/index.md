---
schema: 1
kind: comment
in-reply-to: 6472739b-8be3-47ab-b6a3-85d387fb1a7c
created:  {at: 2026-11-16T11:30:48Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The round-1 blocking finding is fixed and measured; no blocking, no open notes.

- **Stance**: standard
- **Round**: 2
- **Card**: [Make the guide-version check advisory](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/110192c0-cb12-4c06-9c63-a066ca62866c)
- **Branch**: `card/110192c0-advisory-guide-check` at `0d98c48`

**Blocking**: none.

**Notes**: none. Both round-1 notes are resolved: the repo `CLAUDE.md` read is guarded, and smoke's note now ends `stamp guide vN, schema vM`.

**Checked**

- **Round-1 blocking, re-checked by its text** (`G=$(head -1 "$BD/CLAUDE.md" ... | ver ...)` under `set -euo pipefail`): the diff `007f71d..0d98c48` adds `|| true` to all four board reads and to both stamp reads, and the stamp reads now go through `cat CLAUDE.md 2>/dev/null`.
  - Own run in scratch repos, `--dry-run`, non-main branch, 8 scenarios, each ending `not on main`, exit 1:
    - Normal stamp-behind: both warnings (working tree and HEAD) still print, so `|| true` did not swallow them.
    - Board `CLAUDE.md` gone from HEAD and tree: only `not on main`.
    - `.schema/VERSION` missing from the tree, and from HEAD too: warnings with `schema v?`, then `not on main`.
    - No `Lanework/` folder: one HEAD warning (the folder was still committed), then `not on main`.
    - Unborn HEAD: one warning, then `not on main`.
    - Repo `CLAUDE.md` missing: warnings with `stamp guide v?`, no raw error.
    - Schema ahead only: warns.
    - No git repo at all: warns, git's own fatal message, then `not on main`, exit 1, which is the same as before the change.
- **Fail-before / mutation**: OWN RUN. Removing `|| true` from the working-tree `G=` read and running with the board folder gone from HEAD and tree gives silent exit 1 with no `not on main`, so the new assertion "should reach its own check with no board folder" would fail. The `CLAUDE.md`-missing assertion greps `No such` and `not on main`; the old unguarded form produced exactly that raw error in round 1, so it would fail too (my scripted re-mutation of it hit a missing exec bit and showed nothing; this one is REASONED from round 1).
- **Test adequacy**: the new assertions in case 157 stay in the throwaway repo, no network, and clean up with `$T`.
- **Correctness vs done-when and blast radius**: unchanged from round 1, and only `scripts/release.sh` and `tests/smoke.sh` moved. Full foreground-equivalent `tests/smoke.sh` in the worktree at `0d98c48`: last line `smoke: 158 passed`, rc 0.
