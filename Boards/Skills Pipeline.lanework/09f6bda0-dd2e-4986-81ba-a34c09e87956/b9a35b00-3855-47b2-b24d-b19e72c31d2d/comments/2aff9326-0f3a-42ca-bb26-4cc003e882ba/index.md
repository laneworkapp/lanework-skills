---
schema: 1
kind: comment
in-reply-to: ae9f5350-10f5-4746-8264-e67d179a0449
created:  {at: 2026-11-28T17:26:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-28T17:26:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: APPROVE.** Round 2's Blocking 1 is fixed, and so are Notes 1 to 4. Three notes, none blocking. The one worth taking before merge is Note 1, a one-line fix.

- **Stance**: adversarial (signal and undo paths)
- **Round**: 3, scoped to `git diff cf6d49f0 start-card`
- **Card**: [Starting a card stakes its lease in one step; a missing lease is reported](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b9a35b00-3855-47b2-b24d-b19e72c31d2d)
- **Branch**: `start-card` at `4fed8904`

**Blocking**: none.

**Notes**

1. `skills/work/scripts/start-card.sh @ 4fed8904` "`cleanup() {`": a second signal during the undo leaves a lease with no START, and nothing is said (measured, 3 of 3). Reproduction on a throwaway board:
   - Send TERM to the start-card pid while its `move-card.sh` child runs.
   - Then send TERM again once the trap's move back (`move-card.sh … Approved --order …`) appears.
   - Each time: exit 143, no stderr line, the card back in Approved with `claimed` this session's and its timer renewing, and no START. The release never ran.

   The header's exception covers SIGKILL only. Fix: make `trap '' INT TERM HUP` the first line of `cleanup`, so the undo, once begun, finishes.
2. A landed start that a signal interrupted exits 143 or 129 with nothing on stdout, though the start is kept (measured). There is no `started …` line and no link, while stderr says `started, interrupted after the record …`. That is reasonable, but the header's exit list doesn't name it. Suggest one clause: "a signal: the signal's code; stdout empty; the stderr line says whether it started".
3. `skills/work/scripts/move-card.sh @ 4fed8904` "`--order N`": two small rough edges (measured).
   - `--order` takes a value equal to another card's order in the lane: the two cards then tie at 2048. This is harmless for the undo, because the card's own old slot was vacated.
   - `--order 5 --order 6` is refused as "one of --top, --bottom, --order", while `--top --top` passes.

   Also pre-dating this round: a `--comment` file whose first line is a bare CRLF is refused as "no START record", because awk counts the lone `\r` as non-blank. A plain blank first line is accepted.

**Checked**

- **Round 2's Blocking 1** (measured, my round-2 reproduction: signal to the start-card pid alone, polling `ps` for the child):
  - TERM or HUP during `post-comment.sh`: the start is kept (Active, this session's lease, one START). The line names the START's id and "nothing undone"; exit 143 or 129.
  - TERM or HUP during `move-card.sh`, or during `lease.sh stake`: not started (Approved, `lease none`, no START), and the line is true.
  - INT, to the pid alone and to its process group, during the move and during the record: same outcomes. The backgrounded steps ignore INT, so they finish and the board decides.
  - Process-group TERM or HUP during the record: card back, no lease, no START.
  - I could not reach a START on an unleased card. Every state line matched the board.
- **`my_start`** (measured, TERM during the record): it finds its own START for a first line with trailing spaces and a tab, glob and regex characters (`*?[glob] \\back "q" \`tick\``), braces and `$HOME`, and leading blank lines. Its comparison is exact-string (`=`), so no pattern is applied to the body. A BOM can't reach it, because `START_ERE` refuses the body first. Another writer's comment counts only if it is new since `PRE` and its first line is identical: reasoned negligible.
- **Children run in the background**: their stdin is `/dev/null`, which no step reads. Stake stdout goes to a temp file that the trap removes. The `prior:` line and the final stdout are unchanged on success.
- **`move-card.sh --order`** (measured):
  - Bad values (`abc`, `1e3`, empty, missing) exit 2, and so does `--order` with `--top` or `--bottom` in either order.
  - A plain `--top` move matches `23a53be3`'s stdout, exit and stderr.
  - The flag is in the header and USAGE once, and the undo is its only caller. It stamps `modified` on the move back: right, since the card changed container twice.
- **Notes 1 to 4 from round 2**:
  - Pick order is kept: case 15, and my own measure from round 2 now holds.
  - The lease is kept when the move back fails: case 16.
  - The header clause is there.
  - `writing.md` § START and `farmed-prompt.md` now cover build and shaping starts without restating each other.
- **Smoke stand-ins**: cases 13 to 16 run the real `start-card.sh`, from a copy of the skills tree in which only `move-card.sh` and `post-comment.sh` are wrapped. The wrappers `exec` the real scripts. Mutations (OWN RUN, `start_card`):
  - `wait "$CHILD"` dropped from the trap: red at case 13.
  - The `my_start` check dropped: red at case 13.
  - The round-2 `start-card.sh` restored: red at case 10, whose state-line text changed. With 10 and 11 restored, the fixer measured 13 red.
- **Gates** (measured, on the worktree, `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only …`):
  - (a) `braces`: `smoke: 19 passed (sections: braces)`, exit 0.
  - (b) `lease,start_card,lint_leases,arm_pass,watch`: `smoke: 125 passed (sections: lint_leases, watch, arm_pass, start_card, lease)`, exit 0.
  - (c) the 15 generic sections: `smoke: 177 passed (sections: static, plan, lint_symlinks, post_comment, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0.

**Not checked**: anything outside this round's diff; the full smoke run; a SIGKILL; the takeover path with a real two-minute wait.
