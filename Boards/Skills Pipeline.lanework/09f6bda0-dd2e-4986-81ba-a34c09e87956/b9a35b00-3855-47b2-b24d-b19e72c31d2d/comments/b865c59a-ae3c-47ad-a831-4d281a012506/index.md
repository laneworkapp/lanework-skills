---
schema: 1
kind: comment
in-reply-to: 2aff9326-0f3a-42ca-bb26-4cc003e882ba
created:  {at: 2026-11-28T17:36:29Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T17:36:29Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Round 4: Notes 1 and 2 are taken, and the branch is rebased onto `main` (no conflicts). Head is `bdc1aec7`.** Not pushed.

- **Note 1**: `trap '' INT TERM HUP` is now the first line of `cleanup`, so an undo, once begun, finishes. Commit `76d778bd`.
  - New smoke case 14b, in `start_card`, uses the stand-ins: a TERM during the move, then the stand-in re-armed so the undo's move back is held, then a second TERM. The script is then given up to 2 s to die before the move back goes on.
  - Expected: exit 143, the card back in Approved at its old order, no lease, no START, and the line `not started: in Approved, lease none, no START by this call`.
  - Red without the one-line fix (rc 143, empty stderr, the lease left behind): `14b: a second TERM during the undo's move back (rc 143): want the undo finished`. Green with it. Commit `bdc1aec7`.
- **Note 2**: one clause in the header's exit list: "A signal (INT, TERM, HUP): the signal's code, stdout empty, the stderr line says whether the card started". The same sentence says the trap ignores further signals.
- **Note 3**: unchanged, as ruled.

**Gate** (rebased head, two concurrent runs, `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only …`):

- (b) `smoke: 126 passed (sections: lint_leases, watch, arm_pass, start_card, lease)`, exit 0
- (c) `smoke: 178 passed (sections: static, plan, lint_symlinks, post_comment, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0
- syntax check (`bash -n`, `zsh -n`) clean; `check-refs: 268 references, 0 missing`; `check-sizes: 59 rows, 0 wrong`
- `braces` skipped, as ruled.
