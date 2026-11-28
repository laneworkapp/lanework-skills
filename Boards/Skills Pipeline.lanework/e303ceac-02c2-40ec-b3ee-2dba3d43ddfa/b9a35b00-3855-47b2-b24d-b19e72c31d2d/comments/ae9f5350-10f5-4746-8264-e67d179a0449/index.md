---
schema: 1
kind: comment
in-reply-to: 1cc1aab5-c297-4b78-bb76-114057d8c46e
created:  {at: 2026-11-28T16:11:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T16:11:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Round 3: the blocking finding and all four notes are fixed on `start-card` at `4fed8904`.** Three commits sit on `cf6d49f0`: `d7038548` (the scripts), `1c31213d` (the guides and README) and `4fed8904` (smoke). Not rebased.

**Blocking 1**

- **Cause, measured.** On a TERM with no trap, bash 3.2 does not wait for its foreground child. It runs the EXIT trap at once while the child keeps running. A 3 s `sleep` child, TERMed at 0.5 s, saw the trap fire at 0 s. So the old undo moved the card back and released the lease while `post-comment.sh` was still running, and the record then landed on an unleased card.
- **Fix, part 1: each step is a waited child.** The stake, the move and the record now each run as `& CHILD=$!; wait "$CHILD"`. The trap's first act is `wait "$CHILD"`, so a signal to the script alone lets the step finish before anything is decided.
- **Fix, part 2: "landed" is read from the board.** `PRE` holds the card's comment folders, noted before the stake. `my_start` looks for a comment folder not in `PRE` whose body opens with the first line of `--comment`.
  - If one exists, the start succeeded. The card and lease are kept, nothing is undone, and stderr says `<id8> started, interrupted after the record: in <lane>, lease <state>, START <comment id>; nothing undone`.
  - If none exists, the undo runs.
- **The state line is true at the moment it prints.** Every clause comes from the board:
  - the lane: where the card's folder is;
  - the lease: `lease.sh list`, read as none, this session's, or held by `<holder>`;
  - the START: `my_start`.
- **Unchanged:** `post-comment.sh`'s stdout and exit contract.
- **Smoke, without a timing race.** The tests run on a copy of the skills in which `move-card.sh` and `post-comment.sh` are stand-ins. On a marker, a stand-in holds its first call until `go`. The test sends a TERM to start-card's own pid. It then waits until start-card's temp file is gone, which shows the trap has begun, and only then releases the step.
  - **Case 13 (TERM during the record):** exit 143. The card is in Active, the lease is this session's, there is one START, and the line names that START's id.
  - **Case 14 (TERM during the move):** exit 143. The card is back in Approved at its old order, with no lease and no START, and the line says so.
- **Fail-before:** case 13 against `cf6d49f0`'s `start-card.sh` (the rest of the tree at the new head; cases 10 and 11 given back their old text) is red: `13: TERM to start-card.sh alone during the record (rc 143)`. Its stderr was the old false line, `not started: left in Approved, lease none of this call's, no START posted by this call`.
- **Also widened, same mechanism:** the stake now runs as a waited child too (its stdout goes to a temp file). A signal while it runs no longer lets the release run before the stake lands.

**Note 1.** Before the move, start-card notes the card's `order`. The undo moves the card back with `move-card.sh --order N`, a new flag: a number, exclusive with `--top`/`--bottom`, and a bad value exits 2 (smoke refusal rows in `board_writes`). Case 15 sets up two Approved cards on a board of their own. The top card's start fails at the record: its `order` is unchanged, and `arm-pass.sh` still arms it, not the card below. Case 14 also checks the order.

**Note 2.** When the move back fails, the release is skipped. Stderr ends `(the move back failed, exit N: this call's lease not released, for the tidy-up)`. Case 16 stages this without a race: the stand-in `post-comment.sh` makes Approved read-only, then fails. The result is exit 1, the card in Active, this session's lease and memory kept, no START, and the line as quoted.

**Note 3.** The header now reads "a board with no Approved lane: any lane, unchecked (a board that renames its queue loses this gate)".

**Note 4.** In `writing.md` § START, "One per start" now reads:
- the session starting or shaping the card posts the START;
- a build start goes through `start-card.sh`;
- a shaping start is the shaping session's own record write (`post-comment.sh`), not `start-card.sh`, which refuses a shaping body;
- any other worker posts a record, never a START of either kind.

`farmed-prompt.md` says: no START of either kind unless you are the session starting or shaping the card, linking § START. The rule lives in one file, and the work prose smoke check is green.

**Gate** (on the worktree at `4fed8904`, three concurrent runs, `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only …`):

- (a) `braces`: `smoke: 19 passed (sections: braces)`, exit 0. It took about 50 minutes at a load average near 57: slow, never stuck.
- (b) `lease,start_card,lint_leases,arm_pass,watch`: `smoke: 125 passed (sections: lint_leases, watch, arm_pass, start_card, lease)`, exit 0.
- (c) the 15 generic sections: `smoke: 177 passed (sections: static, plan, lint_symlinks, post_comment, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0.
- `bash -n` (and `zsh -n` for the zsh script) on every script: clean. `check-refs: 268 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`.

**Not done**: the full smoke run; a fail-before for cases 14 to 16 (the old script fails case 13 first; case 14's order check is Note 1's).
