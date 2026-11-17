---
schema: 1
kind: comment
in-reply-to: ee06da21-757e-4dc8-bd38-ba09956a8b48
created:  {at: 2026-11-17T21:59:30Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Blocking 1 and notes 2 to 6 are closed as the lead ruled, the fixes introduce no regression, and 1 note remains.

- **Stance**: adversarial; the arming pass now decides from card leases which cards a session picks up unasked, and a START comment stops being a claim
- **Round**: 2
- **Card**: [watch: the session stakes a lease before working or handing off a card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233)
- **Branch**: `watch-lease` at `19bbaa1` (local branch, `origin/watch-lease` and the fixer's worktree all agree)

**Blocking**: none.

**Notes**

1. `skills/watch/references/responding.md:18 @ 19bbaa1` "Read the card whole; act per the lane body (`work/SKILL.md`)": "act" sits in step 1, before the stake in step 2. Step 2's "immediately before the first write or hand-off" decides the order, so no wrong outcome follows. "Read the card whole and its lane body" in step 1, with "act" moved after the stake, would read cleanly.

**Checked**

- **Blocking 1 (closed)**: `responding.md:18-22` now reads the card first, stakes only the card to work "immediately before the first write or hand-off", releases a staked-then-unworked card at once (step 3), and releases in the closing write (step 5). `events.md` item 5 reads "the move is the work order once the card is read and is the one to work: stake, then act". Each scenario walked through the three files:
  - A card dragged into Approved below the top: step 1 lists "Approved but not the top" → report, no stake.
  - A `waiting` card, or a lane body that puts it out of scope: step 1 → report, no stake. The `arm` row in `arming.md` filters both before routing.
  - The top Approved card: read → stake → move to Active (the first write) → work or hand off → release with `--release` at the gate.
  - A lapsed lease moved in by the owner: the stake takes it over, with the two-minute wait linked to `writes.md` § Lease. The `stale` row still never takes one over at arming.
  - Result: no stake without work, no worked card without a stake, no lease left behind.
  - No contradiction with `work/references/lead.md` § Dispatch ("Stake each card before the fixer gets its worktree") or with `lanework/references/writes.md` § Lease (release "done, at a gate, given up").
  - The read-to-stake window: two watches that both read the top card both stake, and `lease.sh` writes, waits and reads back, so one is refused (exit 1) and step 2's report line, "held by another session", covers it. The text names that outcome, and nothing further is owed.
- **Note 2 (closed)**: `arming.md:26`, `responding.md:16` and the `arm-pass.sh` header say "no lease (none, or voided by the clock guard)". `responding.md` says an owner's move of a lapsed card is the owner asking, linked to `writes.md` § Lease, not restated.
- **Note 3 (closed)**: `responding.md:22` cites `work/references/lead.md` and `lanework/scripts/lease.sh`, and no bare cross-skill cite is left under `skills/watch/references`. `check-refs.sh`: 241 references, 0 missing.
- **Note 4 (closed)**: the "Stop" bullet in `arming.md` says the session's leases outlive the watch and a card dropped at stop is released, linked to `writes.md` § Lease.
- **Note 5 (closed)**: the twin-title fixture (`AT1` leased, `AT2` not) is in the full-board line check and has its own case. My title-join copy of `arm-pass.sh` now fails the arm-pass block at the full-line check (0 of 13). With that check disabled, it fails the twin case ("the lease must join by uuid"); the unmutated block passes 13 of 13.
- **Note 6 (closed)**: `arm-pass.sh:35` no longer drops `list`'s stderr, and exit 1 is kept. The smoke case puts "boom: no lease today" beside the arm-pass note. No noise on a normal run:
  - On the three live boards: stderr 0 bytes, exit 0, checksums unchanged, lines byte-identical to round 1 at `478a726` (2, 23 and 3 lines).
  - On a fixture of malformed leases (`claimed: garbage`, an unparseable `until`, no `until`, an impossible date, a fractional `until`, and a card file with no front matter): stderr 0 bytes, exit 0, every card `arm`, as `lease.sh` classes them.
- **Notes 7 and 8**: no change, as ruled. **Note 1**: deferred by the lead to [the Active-lane sentence card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/84bb7548-cb2d-4c8f-a052-3d1f6a170598). **Question 1**: accepted as the body's named risk.
- **Blast radius**: `478a726..19bbaa1` touches 6 files: `skills/watch/references/arming.md`, `events.md` and `responding.md`, `skills/watch/scripts/arm-pass.sh`, `tests/smoke.sh` and `README.md`. Nothing outside `skills/watch`, `tests/smoke.sh` and `README.md` has changed since the merge-base. README § Sizes matches `wc -w` (182, 790, 532, 579; total 2,083), and `check-sizes.sh` reports 57 rows, 0 wrong.
- **Smoke**: one full run in the fixer's worktree at `19bbaa1`: `smoke: 240 passed`.
