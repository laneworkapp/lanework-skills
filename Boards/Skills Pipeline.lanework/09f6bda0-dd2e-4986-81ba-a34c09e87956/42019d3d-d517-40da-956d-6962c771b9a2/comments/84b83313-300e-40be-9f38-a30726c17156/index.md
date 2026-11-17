---
schema: 1
kind: comment
in-reply-to: 6b53ed0c-f245-4976-9188-1e612bc39030
created:  {at: 2026-11-17T16:43:14Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T16:43:14Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Blocking 1 is fixed, and so are notes 1 and 2. One note remains: a narrow leftover case that the fallback rule can't close.

- **Stance**: standard (prose in one reference file and one grep smoke case, no script change)
- **Round**: 2
- **Card**: [42019d3d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/42019d3d-d517-40da-956d-6962c771b9a2)
- **Branch**: `move-receipts` at `ee59b51`, re-checked over `33036c7..ee59b51`

**Blocking**: none.

**Notes**

1. `skills/watch/references/events.md:12 @ ee59b51` "The receipt counts only if it is the newest with `moved.to.lane` = the card's current lane": one case is still read wrong. An agent's older receipt brings a card into lane L, the card leaves L, and later the owner returns it to L with a bare `mv`, which writes no receipt. The newest receipt into L is then the agent's, so the owner's return reads as an agent's move and its work order is missed. A bare `mv` changes no stamp, so no text rule can tell the two moves apart. Closing it would need a log or time check, which is more than this card covers.
   - It needs three things together: an agent identity in a receipt (rare, because Shortcuts counts as the owner), an agent lane, and the owner moving the card by hand on a board where receipts are on.
   - I'd accept it rather than name it in `events.md`. The body's Risks section already says prose can misread a receipt. If the lead wants a record, it belongs in the closing comment.

**Checked**

- **Blocking 1, re-read by its quoted text**: item 5 now says which receipt counts. I walked each case:
  - **The round-1 case**: an agent's receipt R1 into Shaping, then the owner's bare `mv` into Approved. No receipt names Approved, so the no-receipt rule applies, the owner is the mover, and the move is a work order. Right.
  - **The reverse**: an old owner receipt into X, then an agent's bare `mv` into Y. No receipt names Y, so the move is read as the owner's. That is the same result as the fallback before this change, so nothing got worse.
  - **Left the lane and came back, both moves in the app**: the newest receipt is this move's. Right.
  - **The owner's receipt for this move has not landed yet, and an older agent receipt names the same lane**: the move is misread at first. Item 4's "Item 5 reads it" re-reads the move once the new receipt arrives, and then it is read as the owner's. The bare-`mv` version of this case has no later receipt to correct it (Note 1).
  - **This move's receipt with `moved.by` absent**: the owner. Right.
  - **An agent's receipt for this move into an agent lane**: "an agent's move: context, never a work order". Right.
- **Note 2**: the wording is in place and reads cleanly before "Destination is an agent lane → … work order".
- **Note 1**: `responding.md:15 @ ee59b51` now reads "An owner's move (`events.md` item 5), or a card waiting at arming … = work order, if unclaimed … No comment to answer". Only that phrase changed, and it reads right with the rest of the line: a receipt is never answered. `lanework/references/writes.md:28` ("A bare `mv` reads as the owner's move") agrees with the no-receipt rule.
  - I grepped `skills/` for `bare move`, `no comment`, `receipt`, `to.lane` and `owner's move` at `ee59b51`. Beyond `events.md`, `responding.md` and `writes.md`, the only hits are `arm-pass.sh:20,84`, which agree, and `discovery/scripts/file-record.sh:10`, which is unrelated. Nothing contradicts the change.
- **Fail-before**: OWN RUN. The extended case fails at `33036c7` and passes at `ee59b51`. Removing `` `moved.to.lane` `` from item 5 alone also makes it fail. The `to.lane` grep checks item 5 only.
- **Project conduct**: the new wording is short and telegraphic like its neighbours, each topic stays in one file, and no guide version is added. Item 6 is byte-identical to the merge-base. Four files changed: README, events.md, responding.md and smoke.sh. CHANGELOG, `plugin.json` and the scripts are untouched.
- **Blast radius**: 7 insertions and 7 deletions, all in the files the lead's ruling named.
- **Population**: README § Sizes matches `wc -w` at `ee59b51`: `events.md` 511, `responding.md` 376, `SKILL.md` 180, `arming.md` 649, watch total 1,716 in both the summary row and the detail table. The full `tests/smoke.sh` run in the fixer's worktree at `ee59b51` ended with `smoke: 203 passed` (exit 0), with ok 108 (the item-6 check) and ok 109 (the new case).
