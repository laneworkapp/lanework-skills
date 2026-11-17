---
schema: 1
kind: comment
in-reply-to: 5a44ec05-8c97-425f-8dbf-2bc1f53e213e
created:  {at: 2026-11-17T15:54:41Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T15:54:41Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: the front-matter guard that fixed round 1 also refuses valid front matter, and 497 of 2,323 cards on the Lanework repo boards carry it. Everything else in the fix round holds. 1 note.

- **Stance**: adversarial (as round 1)
- **Round**: 2
- **Card**: [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- **Branch**: `lease-script` at `edb944b`, reviewed against `112c236`

**Blocking**

1. `skills/lanework/scripts/lease.sh:72 @ edb944b` "`frontmatter_of "$stage/index.md" | grep -q '}}}'`": a label whose kind carries an icon ends in `}}}` and is valid front matter: `labels: [{text: Low, rank: 3, icon: {glyph: arrow.down}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]`. Measured: the board validates that card (0 failures), and `stake` refuses it with exit 1, "no frontmatter, or a broken stamp", the code callers read as "held by another". Population: 497 of 2,323 cards on the Lanework repo boards have `}}}` in the front matter, all from iconed label kinds, 358 of them among the 947 cards on Lanework Pipeline. Round 1 had the same refusal, and so does `move-card.sh`. I counted only bodies then, so I missed it. It is the round 1 finding's failure on the line this round rewrote. The body case is fixed: a `}}}` body is staked, renewed by the timer and by `renew`, checked lapsed (`held`, timer restarted) and released, the body byte for byte. Fix: guard only the lines `lease.sh` writes (`modified:` and the `claimed` block), since every other line is copied as read, and add a smoke case staking a card with an iconed label from `templates/label-kinds.md`.

**Notes**

1. `lease.sh:154 @ edb944b` "`if ! post_record`", with `lease.sh:145` "`never lost without the record`": inside `if !` errexit is off, so a failed `mv` at `lease.sh:105` "`mv "$stage/$coid" "$c/comments/$coid"; rm -rf "$stage"`" falls through, and `rm` returns 0. Measured with a read-only `comments` folder: `check` → `lost`, exit 3, the mark kept, no record. After the folder is writable again, every later call still exits 3, with no record ever posted. Only a vanished card (`find_card`) takes the mark back. It never loops or double-posts. Fix: `mv … || { rm -rf "$stage"; return 1; }`, and the same for `mkdir -p`.

**Checked**

- **Correctness vs the rulings** ([3f2417d7](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb), [7d2eb5ef](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)), measured on throwaway boards:
  - remembered card, `claimed` gone, or another session's live, lapsed or voided lease: `stake` exits 3, and again 3; the card is byte for byte; 1 **Lease lost** record; 0 notices; 0 **Lease ignored**.
  - card never staked here: live → exit 1; lapsed → notice and takeover, exit 0.
  - legitimate paths unbroken: re-stake after the session's own `release` (exit 0, no loss); re-stake after a wiped memory dir (exit 0); a holder back late with its lapsed, untouched lease renews through `stake`, `check` (`held`) and `renew` (Q16).
  - race: timer plus 3 `stake` plus 3 `check` on one loss, `by` changed or `claimed` gone, 20 reps: 1 record every rep, every caller exit 3.
  - `renew` with nothing to renew: exit 1, as ruled. `writes.md` § Lease says "nothing to renew".
- **Notes as ruled**:
  - `mkdir -p`: the comments folder is now created with `mkdir -p`, the only place it was created.
  - case 6b: on a copy without the once-guard it fails 3 of 3 runs, "6 loss records, want 1".
  - a missing `until` posts **Lease ignored** with `until none`.
  - `--no-optional-locks` is in place.
  - `is_timer` with `ps -ww`: `release` kills the timer at once on a board path with spaces and on a 758-character path. A stale pid naming the same card uuid's timer on a copied board, `<board> copy`, is left alive.
  - `list`: the title is last. A literal tab now splits only the title, so the state stays field 4.
- **Docs**: the Takeover line and the exit-1 wording are in. No knobs, no guide version, no live `dispatch`. Nothing else under `skills/` restates the lease. README counts 1,916 and 5,145 match `wc -w`; `check-sizes: 57 rows, 0 wrong`.
- **Regression**: stake race, 10 sessions, 20 reps: 20 of 20 single winners, 0 loss records, the board validates, the heal lists 0 repairs. The isolated lease cases ran 5 times, 17 of 17 each.
- **Gate**: full `tests/smoke.sh` in the fixer's worktree at `edb944b`: `smoke: 200 passed`, exit 0, 216 s. The worktree is clean after. `pgrep -fl lease.sh`: empty.
