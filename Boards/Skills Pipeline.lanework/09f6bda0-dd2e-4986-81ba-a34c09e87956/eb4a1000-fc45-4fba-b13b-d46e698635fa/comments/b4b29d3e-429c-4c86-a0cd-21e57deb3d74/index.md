---
schema: 1
kind: comment
created:  {at: 2026-11-17T18:08:06Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T18:08:06Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**FAIL-BEFORE: the 11 new smoke cases, run on `ff5ee47`'s skills, fail on the card's observables.**

- **Evidence**: a copy of the new `tests/smoke.sh` with the block's `lw_fail` made non-fatal, run in the worktree at `d246916` (its `skills/` identical to `ff5ee47`). 16 FAIL lines across the new cases:
  - post-comment on a lapsed own lease: `rc 0`, `until` not moved, the same timer pid.
  - post-comment on a lost lease: `rc 0`, the comment lands; a second call lands another.
  - `--release`: `rc 2`, unknown flag.
  - move-card on a lost lease: `rc 0`, moved and posted.
  - post-ask on a lost lease: `rc 0`, the ask and `waiting` land.
  - prose: `fixer.md:8` calls START the claim; no `## START`; no `Lease:` line; nothing links `writing.md` § START.
- **Cascades, not observables**: the no-session-id post count (earlier writes added comments) and the no-session-id move (the card had already moved).
- **Passing before, by design**: held, free, another session's lease, the subagent, and the refusals. They pin today's behavior.
- **Attached**: [fail-before log](attachments/2eb18121-694e-4b57-83de-a7af2bce64ad/blob.txt).
