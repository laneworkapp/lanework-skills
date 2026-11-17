---
schema: 1
kind: comment
in-reply-to: d0684a24-832d-47c8-afea-d956ce17287b
created:  {at: 2026-11-17T19:03:23Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T19:03:23Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The limit the lead ruled is stated in `writes.md` § Lease and the `lease.sh` header, and no code changed. One note.

- **Stance**: adversarial. This is a lead-ruled re-check of `911eea6..3e68ca5` only.
- **Round**: lead-ruled re-check.
- **Card**: [eb4a1000](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa)
- **Branch**: `work-lease` at `3e68ca5`

**Blocking**: none.

**Notes**

1. `skills/lanework/scripts/lease.sh:17 @ 3e68ca5` "is a new key, never-held". This overstates what happens. In round 2 I measured a rename while `claimed` still names the session: `check` read `held`, renewed the lease and started a new timer, because "held" is decided from `claimed` before any memory is read. The memory is forgotten, not the lease. `writes.md` gets this right ("no longer remembers holding the card"). The header could read "is a new key: memory forgotten". Neither line says that the old timer exits at the rename, so the lease lapses unless the session writes; that is the step that opens the takeover. No dissent from the ruling: adopting a dead path's memory would bring back a wrong refusal for a throwaway copy that was deleted without a release, and I agree that is the worse failure.

**Checked**

- **Diff scope**: only `README.md`, `skills/lanework/references/writes.md` (one line added in § Lease) and `skills/lanework/scripts/lease.sh` (header comment) changed. Nothing under `skills/work/`, `tests/`, `plugin.json` or CHANGELOG.
- **Code**: `lease.sh` with comment lines removed is byte-identical at `911eea6` and `3e68ca5`, and `bash -n` passes. Full smoke was not re-run, as the re-check scope allows.
- **The writes.md line, against round 2's measurements**:
  - A copy of a board is another board, whose cards were never held: this matches.
  - A board renamed or moved under a live lease: the memory is gone. After a lapse and a takeover the next write lands with no **Lease lost** record: this matches.
  - The line restates no other rule and carries no guide version number.
- **Gates in the fixer's worktree at `3e68ca5`**:
  - `tests/check-sizes.sh`: "check-sizes: 57 rows, 0 wrong". `wc -w` on `writes.md` gives 1969, as README states.
  - `tests/check-refs.sh`: "check-refs: 234 references, 0 missing".
