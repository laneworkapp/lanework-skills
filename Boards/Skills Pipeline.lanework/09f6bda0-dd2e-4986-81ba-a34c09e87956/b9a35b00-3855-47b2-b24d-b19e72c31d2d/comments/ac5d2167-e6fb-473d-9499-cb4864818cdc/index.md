---
schema: 1
kind: comment
created:  {at: 2026-11-28T11:12:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T11:12:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Built on branch `start-card`: one script starts a card with its lease, and a started card with no lease is now reported by the lint, the arming pass and the move.**

- **Commits** (on `23a53be3`, head `9110ea26`): `3448049f` scripts; `bd524ee7` guides, README sizes; `608f60dd` smoke; `eeb14043` header line (the one-definition check); `38bbf046`, `4285633c` smoke timers kept out of snapshots; `94104ef0` start-card signs; `9110ea26` signature count 14.

**What each item does, and the case that proves it** (all measured, smoke on `9110ea26`):

1. **`work/scripts/start-card.sh <board> <card-uuid> --comment F --model m`**: `lease.sh stake`, then `move-card.sh` into the working lane with `--comment F` (or `post-comment.sh` for a card already there, a re-start). The body must open with START, not a shaping one. Refuses a plan board (points at `claim-ticket.sh`), no session id, no `CLAUDE_PID`. A stake it made is released if the move or record fails; a lease held before the call is kept. Exit 3 = lost. Cases `start_card` 2 to 7 (ok 109 to 114): free card leased, moved and START posted in one call; another session's card refused with the board byte for byte; a blocked move after a fresh stake leaves no `claimed`, memory or timer; the same failure on a held card keeps it; re-start in Active; lost = exit 3, unmoved, one **Lease lost** record.
2. **Missing-lease finding**: `lint-leases.sh` prints `<card>: started without a lease <comment id> <time>` and the tally gains `, no lease: N`; `arm-pass.sh` prints an `unstaked` line after the card's `arm` line (path = that START). Cases: `lint_leases` ok 55 (3 of 7 cards reported; silent on staked, Proposed, `waiting`, a sessionless latest START, and the same board staked); `arm_pass` ok 106 (same shape); `start_card` ok 115 (real writes: two unstaked reported, held and lost silent, lost ones are the lint's lease-lost lines).
3. **The note**: `move-card.sh` into a working lane, session id set, `check` = never-held: one stderr line once the card is in; exit and stdout as before. Case `start_card` ok 108: note for a free card and for another session's; none when held, with no session id, into Shaping, or lost.

**FAIL-BEFORE** (the new cases from `608f60dd` run against `23a53be3`'s scripts in a scratch copy, the old cases' tally strings put back to the old form; the old cases passed first, 11 and 24): lint case 10 printed nothing and exited 0 (`leased cards: 7, lease lost: 0, two STARTs: 0, lapsed: 0`); arm-pass printed no `unstaked` line; move-card case 1 printed an empty stderr. `start-card.sh` is new: REASONED.

**How it is recognised, and where it can be wrong**

- **Working lane** = `lib.sh` `WORKING_LANES`: titles `Active` and `Working`, exact. The narrowest choice: no existing script had one notion. `start-card.sh` uses Active and refuses a board with a Frontier lane.
- **START record** = `lib.sh` `START_ERE` / `SHAPE_ERE`, the rule `lint-leases.sh` already used, now shared with `arm-pass.sh`. "From a session" = the latest non-shaping START's `created.by.session` is non-empty.
- **False positives**: a card the owner moves back into Active after its closing release; a card given up in Active without a move; a session that stamps `--session` but has no session id, so it cannot lease.
- **False negatives**: a start record that doesn't open with START; one stamped with no session; work in other agent lanes (Shaping, Mockups); a card with `waiting` (skipped on purpose, as at a gate); a voided `claimed` (it counts as a lease here).

**Gates** (measured, `608f60dd`)

- `bash -n`: ok on all six changed `.sh` (lib, arm-pass, lint-leases, move-card, start-card, smoke).
- `check-refs: 266 references, 0 missing`; `check-sizes: 59 rows, 0 wrong`.
- `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only static,headers,usage_guard,plugin,versions,cite_as,release_gate,braces,lint_leases,lint_symlinks,lease,arm_pass,start_card,watch,post_comment,board_writes,commit_board,label_kinds,lane_actors,signature,plan` → `smoke: 313 passed (sections: static, plan, braces, lint_leases, lint_symlinks, post_comment, watch, arm_pass, start_card, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, lease, usage_guard, plugin, signature)`, exit 0. Added to the asked list: `start_card` (new), `lint_symlinks`, `commit_board`, `label_kinds` (they run move-card or lint-leases).
- Earlier red runs, fixed before this one: `lease` (a header line opened with START), `braces` (a start-card timer renewed under a snapshot on the loaded machine), `signature` (start-card had no `sign_board` of its own; writer count 13 → 14).

**Done differently from the card**

- Lead and fixer guides: the lead's `start-card.sh` posts the START, so the fixer's plan is now a record, not a second START. Two STARTs from two session labels within 30 min would trip the lint's two-STARTs finding. `fixer.md` § Pick up changed to match.
- `arm-pass.sh` keeps the `arm` line for an unstaked card and adds `unstaked` after it: "a START is no claim" stays as ruled.
- A re-start on a card already in Active stakes and posts START with no move, so the lint's fix is to run the same script.
- The finding reads every card and ignores `--since` / `--first`, as lapsed does.
- A new smoke section, `start_card`, holds the start-card and move-note cases.

**Not checked**

- `start-card.sh` has no source-lane check: starting a card at a gate (Proposed) is the caller's call, as with `move-card.sh`.
- The full smoke run passing at this head (only the sections above).
- A signal during the stake or the move (claim-ticket's TERM cases were not copied).
- A start record posted on a datapoint board's optional Active lane counts too; not exercised.

**Changelog draft**: Starting a card now stakes its lease, moves it to Active and posts the start note in one step, and unleased work gets flagged.
