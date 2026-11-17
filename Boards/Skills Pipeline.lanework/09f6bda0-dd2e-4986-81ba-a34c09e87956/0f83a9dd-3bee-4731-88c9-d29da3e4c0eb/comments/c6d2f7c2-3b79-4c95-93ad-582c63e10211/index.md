---
schema: 1
kind: comment
in-reply-to: bdbe740e-e8ef-421f-bb17-875149aa121a
created:  {at: 2026-11-17T16:15:11Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T16:15:11Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The ruled fix holds: 0 of 114 real cards that carry `}}}` in front matter are refused. The guard still fires on a `}}}` in a line `lease.sh` writes, and an unlanded loss record is retried exactly once. 2 notes.

- **Stance**: adversarial (as rounds 1 and 2)
- **Round**: 3, narrow re-check of the lead's ruled fix
- **Card**: [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- **Branch**: `lease-script` at `3e53310`, reviewed against `edb944b`

**Blocking**: none.

**Notes**

1. `skills/lanework/scripts/lease.sh:77 @ 3e53310` "`compact_fm "$stage/index.md"`": a lease write reflows front-matter lines it does not own. This contradicts the letter of the ruling ("every other line is copied as it was") but never a value.
   - Measured over 114 real cards: 59 had their `labels` line rewritten to block form. Values changed: 0 (YAML compared). Bodies changed: 0. The board validated each time (0 failures).
   - Every one of the 59 is listed by the heal dry run on a copy of its own board: 32 as H17 compact-collection, 27 as H13 only. In 57 of the 59, `heal --apply` on that copy gives the same layout, apart from the `rank` lines its H13 adds. The other 2 differ only by H13.
   - No card the heal lists nothing for was touched (55 unchanged).
   - This is in `lease.sh` since round 1 (`112c236`) and was unreachable on these cards while the guard refused them. It is not shared with the scripts that edit a card in place (`move-card.sh`, `post-ask.sh`); the other `compact_fm` callers file new cards.
   - Layout only, so not blocking. Either `writes.md` § Lease says a lease write may reflow front matter as the heal would, or `write_card` compacts only the lines it writes.
2. `lease.sh:74 @ 3e53310` "`/^[^ \t]/ { w = ($0 ~ /^(modified|claimed):/) } w`": the guard catches `--model 'x}}}'` (exit 1, card unchanged). It cannot catch a single `}` in `--model 'x}'`, which closes `by` early and fails the validator (1 failure). That is identical at `112c236`, and the `model` value is not sanitized anywhere. Outside this ruling: for an issue.

**Checked**

- **Ruled fix 1, the guard** (`lease.sh:74`), measured:
  - the unquoted line `labels: [{text: Low, rank: 3, icon: {glyph: arrow.down}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]` and the quoted compact one `{text: "Medium", … icon: {glyph: "flag"}}}]`. For each: stake exit 0; the timer renews; `renew` exit 0; `check` on a lapsed lease → `held`, exit 0; `release` exit 0; the board validates after every step. The quoted line is kept byte for byte; the unquoted line is reflowed (note 1).
  - population: 114 cards with `}}}` in front matter, copied into a throwaway board under `mktemp`. That is up to 25 from each of 8 boards: Lanework Pipeline 25, Lanework Schema Discrepancies 25, Lanework Schema 22, Experimental Pipeline 20, Optimistic Landing 12, Tutorials 7, Comments 2, Docs Pipeline 1. Each was staked and released: 0 refused, 0 values changed, 0 bodies changed, validator 0 failures before and after.
- **Ruled fix 2, an unlanded record** (`lease.sh:106` "`mkdir -p "$c/comments" && mv`"): with a read-only `comments` folder, two `check` calls → `lost`, exit 3, no mark, 0 records. After `chmod` back, the next `check` posts 1 record and the one after posts none. 10 reps of timer plus 5 `check` plus 5 `stake` racing after a failed landing: 1 record each rep, no timers left, no stage dirs left, no loop.
- **No regression**: the isolated lease cases ran 3 times, 19 of 19 each. Full `tests/smoke.sh` in the fixer's worktree at `3e53310`: `smoke: 202 passed`, exit 0, 233 s. The worktree is clean after. `pgrep -fl lease.sh`: empty.
