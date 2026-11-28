---
schema: 1
kind: comment
in-reply-to: 106f18a5-5918-4e6d-b846-a7733d688519
created:  {at: 2026-11-28T15:05:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-28T15:05:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: REQUEST-CHANGES.** Round 1's Blocking 1 is fixed, and so are Notes 1 to 4. One new blocking finding is in this round's undo: a signal that reaches only the script, while the record is being posted, leaves a START with no lease and a stderr line saying there is none. Four notes.

- **Stance**: adversarial (lease release, signal and undo paths)
- **Round**: 2
- **Card**: [Starting a card stakes its lease in one step; a missing lease is reported](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b9a35b00-3855-47b2-b24d-b19e72c31d2d)
- **Branch**: `start-card` at `cf6d49f0`

**Blocking**

1. `skills/work/scripts/start-card.sh:100 @ cf6d49f0` "`STEP=record; "$HERE/post-comment.sh" … || rc=$?`" with the EXIT-trap undo: a TERM or HUP sent to the start-card process alone (not its group) while `post-comment.sh` runs leaves a START on an unleased card in Approved (measured, 4 of 4). Bash 3.2 waits for the foreground child to finish, then runs the EXIT trap before `LANDED=1` is ever set. By then the record has landed. The trap moves the card back and releases the stake, and then prints `… not started: left in Approved, lease none of this call's, no START posted by this call`, which is false. Reproduction on a throwaway board: start `start-card.sh` in the background, poll `ps` until a `post-comment.sh` child of that pid appears, then `kill -TERM <pid>` (and again with HUP). Each time the exit was 143 or 129, the card was in Approved with `claimed=0` and `comments=1` (the START). The header says "The same undo runs on a signal", and the lead's ruling is "no START left". A signal to the whole process group (measured, TERM and HUP) undoes cleanly, because the record is killed too. Fix: decide "landed" from the board, not a flag, as `claim-ticket.sh` does. For example, note the card's comment folders before the record, and in the trap treat a new comment with this body as landed: keep the card and the lease, and say so. Or have `post-comment.sh` write its new comment id to a file the trap reads. Add a smoke case for a parent-only TERM during the record.

**Notes**

1. `start-card.sh:78 @ cf6d49f0` "`"$HERE/move-card.sh" "$BOARD" "$CID" "$SRCT"`": the undo moves the card to the bottom of Approved, so a failed start changes the pick order (measured). Two Approved cards had `order` 1024 and 2048; the top card's start failed at the record (its `comments` folder read-only). Its order went to 3072, and `arm-pass.sh` then armed the other card as the top of Approved. Suggest restoring the original `order` on the way back.
2. A move back that fails strands the card in Active with no lease (measured). With the record failing, I made Approved read-only once the `post-comment.sh` child appeared. Exit 1, and stderr said `left in Active (the move back failed, exit 1), lease none of this call's`: honest, not silent. But the card now sits in Active unleased with no comment, so `lint-leases.sh` (`no lease: 0`) is silent and only `arm-pass.sh` arms it. Consider keeping this call's lease when the move back fails, so the card is at least held by the session that has to tidy it.
3. Source lane, `start-card.sh:7 @ cf6d49f0` "board with no Approved lane: any lane" (measured): it works as the header says. A board with both Approved and Ready refuses Ready and Shaping, naming the lane. A card in `.trash` gets `0 cards … need exactly one`, exit 1. On a board whose Approved is retitled Ready, nothing is checked: cards in Proposed, Done, Ideas and Ready all start. That is the documented no-Approved path, and it is acceptable as ruled. But a board that renames its queue loses the gate protection, which the header does not say; worth one clause.
4. `skills/work/references/writing.md:96 @ cf6d49f0` "the session that starts the card posts it (`scripts/start-card.sh`, …)": the bullet reads as if every START goes through `start-card.sh`. A shaping start (`**START: shaping: …**`, described two bullets above) cannot: `start-card.sh` refuses both a shaping body and a card in Shaping. Meanwhile `farmed-prompt.md` now tells every subagent "never a START". Who posts a shaping start, and how, is now unclear. Suggest scoping "One per start" to a build start, and saying which session posts a shaping one.

**Checked**

- **Correctness vs done-when**: the done-when "the lint reports the eight-card case" now holds (measured). I copied the app's pipeline board from its git history at `e146430ed` and `90f4173e8`. `lint-leases.sh` reports `worked without a lease` for all 7 and all 8 unleased Active cards, and `arm-pass.sh` prints `unstaked` for each. The one card with a lapsed lease keeps its `lapsed` line and gets no new line.
- **New noise on the 17 real-board copies** (measured, `23a53be3` against `cf6d49f0`): stdout was identical apart from the new lines, and exit codes were the same except one board. Per board, new lines (lint / arm):
  - 16 boards: 0 / 0.
  - The hub's pipeline: 1 / 1, exit 0 → 1. One card in Active since October with no `claimed` and no `waiting`. Its latest comment is from a watch session ("Four done-when items are left, and all need the owner or the lab repo"). By the rule this is a true finding: nobody holds a card sitting in Active. It is parked on the owner without an ask, which the owner may want flagged.
  - No false positive found.
- **Undo paths** (measured on throwaway boards):
  - A record that fails after the move puts the card back in Approved, with no `claimed` and no START.
  - A lease held before the call, on a card in Approved, when the move fails: the card is unmoved and the lease kept.
  - A re-start in Active whose record fails, with a lease held before: no move, lease kept. The same with no lease before: no move, nothing staked is left.
  - A process-group TERM or HUP before the record: card back, no lease, no START.
  - Every one of these states is reported on stderr. The two gaps are Blocking 1 and Note 2.
- **The move note**: with stderr closed (`2>&-`), the base and the branch both exit 0 with the path on stdout (measured). With stderr open, the branch prints its one note line. Round 1's Note 3 is fixed.
- **Guides**:
  - The one-START rule lives once, in `writing.md` § START. `fixer.md`, `companions.md`, `lead.md` and `farmed-prompt.md` link to it without restating it, and the text is telegraphic.
  - `lead.md` § Dispatch now shows `--session <label>`, and names the refusal of a card from the wrong lane.
  - Citations resolve (smoke `cite_as`, `static` green). Note 4 is the one wording gap.
- **Mutations** (scratch copies of the worktree, OWN RUN):
  - Source-lane check dropped: `start_card` red at case 9 ("a card in Proposed (rc 0)").
  - Move-back in the undo dropped: `start_card` red at case 11.
  - Lint finding reverted to START-only: `lint_leases` red at case 10.
  - `arm-pass.sh` reverted to START-only: `arm_pass` red ("arm-pass.sh unstaked lines").
- **Ruled, not findings**: `WORKING_LANES` as exact titles, and `START_ERE` matching STARTLING.
- **Gates** (measured, on the worktree, `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only …`):
  - (a) `braces`: `smoke: 19 passed (sections: braces)`, exit 0.
  - (b) `lease,start_card,lint_leases,arm_pass,watch`: `smoke: 121 passed (sections: lint_leases, watch, arm_pass, start_card, lease)`, exit 0.
  - (c) the 15 generic sections: `smoke: 177 passed (sections: static, plan, lint_symlinks, post_comment, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0.

**Not checked**: the full smoke run; a SIGKILL anywhere (it skips the trap, as the header says); the takeover path with a real two-minute wait; a re-run of the fixer's FAIL-BEFORE (the mutations stand in for it).
