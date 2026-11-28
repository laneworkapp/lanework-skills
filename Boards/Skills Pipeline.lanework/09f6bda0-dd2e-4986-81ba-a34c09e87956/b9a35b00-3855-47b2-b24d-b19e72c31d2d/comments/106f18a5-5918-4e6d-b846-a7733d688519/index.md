---
schema: 1
kind: comment
in-reply-to: 0aa67ad0-7794-487c-a702-f1f1c19ee0a4
created:  {at: 2026-11-28T13:40:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T13:40:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Round 2 on `start-card`: the finding now catches the incident's shape, and every note the lead ruled on is fixed. The gate is green at `cf6d49f0`.**

- **Commits** (on `9110ea26`): `1cae44c5` scripts; `ec66b76a` guides and README sizes; `cf6d49f0` smoke.

**Blocking 1: the finding keys on worked, not on START** (`1cae44c5`, measured)

- `lint-leases.sh` and `arm-pass.sh` now report a card when all of these hold:
  - it is in a working lane, with no `claimed` and no `waiting`;
  - it has a comment by `created.by.kind` agent, with a non-empty `created.by.session`, from a name other than board, healer or shortcuts (any case).
- The latest such comment is named, whatever its first line says.
- The lint line is now `<card>: worked without a lease <comment id> <time>`. arm-pass prints `unstaked` with that comment's path.
- The proving cases are the incident's shape, nine cards on one board, in `lint_leases` "the incident's shape" (ok 12 in the gate run) and `arm_pass` (ok 46 in the gate run):
  - Reported: three Active cards whose session-stamped comments open "Building.", "Building it as shaped." and "**Building, in two halves.**", none with START.
  - Silent: a staked card, one at a gate, one with an ask out, and cards whose only comments are a human's, a sessionless agent's, or board/Healer/shortcuts.
  - Silent again once the same three cards are staked.
- `start_card` case 8: real writes, two cards reported, the held and lost ones silent.
- **FAIL-BEFORE**, the new cases against `9110ea26`'s scripts in a scratch copy:
  - lint: stdout empty, `leased cards: 0, lease lost: 0, two STARTs: 0, lapsed: 0, no lease: 0`, exit 0;
  - arm-pass: no `unstaked` line;
  - the earlier cases passed first (11 and 24 ok).

**Note 1: source lane** (`1cae44c5`, measured, `start_card` case 9)

- On a board with an Approved lane, `start-card.sh` refuses a card outside Approved and the working lane: exit 1, the lane named, nothing written.
- Proposed, Ideas and Done were each refused byte for byte.
- Approved (case 2) and a re-start (case 5) still work.
- On a board whose Approved is retitled Ready, a card in Ready starts.

**Note 2: START after the move, and undo** (`1cae44c5`, measured)

- The order is now stake → `move-card.sh` with no `--comment` → `post-comment.sh`.
- On a failure after the stake, best effort:
  - the card goes back to its source lane;
  - a stake this call made is released; a lease held before the call is kept;
  - one stderr line names the state, e.g. `… not started: left in Approved, lease none of this call's, no START posted by this call`.
- The same undo runs from the EXIT trap. The header says so.
- Case 10 (Active lane folder read-only): exit 1, card in Approved, no START, no `claimed`, no memory.
- Case 11 (the card's `comments` folder read-only, so the record fails after the move): the card is back in Approved, no `claimed`, no comment, exit 1, and the board validates.

**Note 3: the note never changes the exit** (`1cae44c5`, measured, `start_card` case 12)

- The form ruled, `{ echo … >&2; } 2>/dev/null || true`, swallows the note itself: case 1 went red with an empty stderr (measured).
- Used instead: `( trap '' PIPE; echo … >&2 ) || true`.
- With `2>&-`, a never-held move and a held move each exit 0 with their new path on stdout. Case 1 still sees the note.

**Note 4: one START per start** (`ec66b76a`)

- The rule now lives once, in `writing.md` § START ("One per start"): the session that starts the card posts it; a worker under that lease posts its plan as a record.
- `fixer.md`, `companions.md`, `lead.md` and `farmed-prompt.md` link to it.
- grep of `skills/` for START outside `writing.md` and scripts: lead.md cycle line, SKILL.md, team.md (records list), writes.md (takeover reads the latest START), arming.md ("not a claim"). None of these tells a worker to post one.

**Note 5: ruled, no code**. `WORKING_LANES` = the exact titles Active and Working, as the lead ruled.

**Note 6** (`ec66b76a`): `lead.md` § Dispatch now shows `--session <label>`. The lease-only commands (`lease.sh stake`, `release`) take no label. `START_ERE` is left as it is.

**Gates** (measured, `cf6d49f0`)

- `bash -n` ok on all six changed `.sh`; `check-refs: 267 references, 0 missing`; `check-sizes: 59 rows, 0 wrong`.
- `smoke: 19 passed (sections: braces)`, exit 0.
- `smoke: 121 passed (sections: lint_leases, watch, arm_pass, start_card, lease)`, exit 0.
- `smoke: 177 passed (sections: static, plan, lint_symlinks, post_comment, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0.
- Three concurrent runs of the gate's 21 sections, each `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only …`.

**Recognition, where it can be wrong now**

- **False positives**:
  - a card the owner leaves in Active after its closing release;
  - the watch's reply (session "board watch") on an Active card nobody holds;
  - a session with a `--session` label but no session id, which cannot lease.
- **False negatives**:
  - work stamped with no `--session` label;
  - work in other agent lanes (Shaping, Mockups, Drafting);
  - a card with `waiting` (skipped on purpose);
  - a voided `claimed`;
  - an agent comment whose `by.kind` is missing.

**Done differently**

- Note 3's form, as above.
- `WORKING_LANES` stays the exact titles Active and Working: a lead ruling.
- The STARTs-per-start rule moved into `writing.md`, with links elsewhere, in place of a line in each file.

**Not checked**

- The full smoke run (only the 21 sections above).
- Fail-before for Notes 1 to 3: the reviewer measured each defect on `9110ea26`; I did not rerun them.
- A signal between the move and the record. The undo is the same EXIT trap: reasoned, not timed.
- A move back that itself fails: the state line says so, but no case stages it.
- The changelog sentence stands from round 1.
