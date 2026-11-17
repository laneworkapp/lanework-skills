---
schema: 1
kind: comment
in-reply-to: f74d2f21-4821-4603-9105-794d323ed8ab
created:  {at: 2026-11-17T18:57:31Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T18:57:31Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding, new in this round's fix. Keying the memory by the board's path loses a lost lease when the board folder is renamed or moved: a write that `62ee7bf` refused with exit 3 now lands. Every round-1 item is closed. Two notes.

- **Stance**: adversarial, as in round 1.
- **Round**: 2, scoped to the round-1 items and the diff `62ee7bf..911eea6`.
- **Card**: [eb4a1000](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa)
- **Branch**: `work-lease` at `911eea6`

**Blocking**

1. `skills/lanework/scripts/lease.sh:232 @ 911eea6` "MEMD=\"${R%/}/lanework-lease/$SESSION/$(board_key \"$BOARD\")\"". The key is the board's `pwd -P` path, so a renamed or moved board folder gets a new key, and the memory of the stake is no longer found.
   - Measured, same fixture on both versions: S-e stakes a card on `B one.lanework`. The folder is renamed `B two.lanework`. The old timer exits within a poll, as it did before this round, because its board path is gone. The lease then passes to S-taker. S-e posts.
   - On `62ee7bf`: exit 3 and one **Lease lost** record.
   - On `911eea6`: exit 0, the comment lands, and no loss record is written.
   - This is a wrong pass. It breaks the ruling "a holder learns of a lost lease at its next card write at the latest" ([ADR](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)).
   - It needs a rename or move while the lease is live, then a lapse (no write by the holder for 30 minutes, with the timer already dead), then a takeover. A rename with `claimed` still the session's reads correctly as held: measured, with a new timer started.
   - Fix direction: when this key holds no memory for the card, look for `<session>/*/<card-uuid>` memories whose saved `board=` path no longer exists, and adopt such a memory under the new key. A copy and its original both exist, so Blocking 1 of round 1 stays fixed. Or the lead may accept this as a stated limit in `writes.md` § Lease. This is the second REQUEST-CHANGES round, so the lead rules either way (`lead.md` § Disagreements).

**Questions for the lead**

1. Does the Lanework app rename a board's folder when the owner renames the board? If it does, Blocking 1 can be reached from the app, not only from a moved checkout.

**Notes**

1. A timer started by `62ee7bf`'s `lease.sh` (memory in the old `<session>/<card-uuid>` layout) and still running after the upgrade: the new `check` reads held and starts a second timer. Both renew. Measured: on a loss, the card gets **two** Lease lost records, where the ruling says one. On release, the old timer exits at its next poll and leaves nothing behind (measured). `lease.sh` has never been on `stable`, so only development sessions on main can hit this.
2. A `lease.sh` that exists but is not executable fails closed: exit 1, nothing written, "Permission denied". A dangling symlink skips the check with the note. The skip tests `-f`, so it cannot be triggered by a script that is present.

**Checked**

- **Round-1 Blocking 1, closed**. My round-1 reproduction re-run on `911eea6`, with a board path containing a space:
  - Writing to a copy made before the stake, with `--name fixer`, exits 0 and posts no loss record.
  - The original then reads `held`, its post exits 0, its move exits 0, the timer stays alive and `claimed` is intact.
  - A symlink, a symlink with a trailing slash, a trailing slash and a relative path all reach the same key: one memory folder, one timer.
- **Timer and memory paths**:
  - A timer started by `check` from inside `post-comment.sh` runs `_timer` with the resolved board, reads the same key, renews, and keeps renewing after `move-card.sh` moves the card.
  - A loss found by that timer marks `<card>.lost` under the key, and the next post exits 3.
  - `--release` leaves no card file in the key folder; the empty key folder remains.
  - `shasum` is `/usr/bin/shasum` on stock macOS.
- **Question 2, closed**. `post-ask.sh` on a lost lease: exit 3, card byte for byte, `waiting` untouched, only the loss record. With no handle: still exit 1.
- **Notes 2 to 6, closed**:
  - Case 208 now fails both round-1 mutations that survived: release before the `mv` ("whose comment did not land released the lease: rc 1") and release without a held lease ("on a card never held here: rc 0").
  - Further mutations are caught: memory without the board key, the timer without the key, and post-ask's 3 turned into 1.
  - `lead.md` covers the failed release and links § Lease for a refused or blocking stake.
  - The farmed prompt reads "none: the session holds no lease; writes pass as today" and names `post-ask.sh` exit 3.
  - The missing-`lease.sh` skip matches the ruling.
- **Blast radius**: 8 files, all inside the ruling. README § Sizes passes `check-sizes.sh` inside smoke. `writes.md` is untouched and states no memory path.
- **Existing lease cases**: they are still meaningful with the helper change. `mem()` derives the key the same way, the negative checks test the session folder, and a key-less `lease.sh` fails the first case.
- **Population**:
  - `tests/smoke.sh` in the fixer's worktree at `911eea6`: "smoke: 216 passed", over 216 cases.
  - Afterwards `pgrep -fl lease.sh` prints nothing.
  - The real `lanework-lease` folder matches its listing from before this round.
