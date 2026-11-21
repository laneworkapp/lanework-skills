---
schema: 1
kind: card
title: "Lease: a renewal can undo another write to the card, and a renamed board forgets its leases"
order: 86016
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T19:08:42Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T01:36:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The lease timer rewrites a card from a copy it read earlier, so a renewal that lands just after another script's write puts the old front matter back, and can wipe a ticket's Resolution. The fix is to make the lease's own write check that the card is unchanged before it lands, retry if it changed, and never renew a card that is no longer this session's. Two small timer and wording fixes ride along. The renamed-board limit stays as ruled.

## Today

- **A renewal can undo a concurrent write.** Read. `write_card` (`skills/lanework/scripts/lease.sh:63-86`) reads the card, rewrites `claimed` and `modified`, finds the card again (line 84) and moves the staged copy over whatever is there. Nothing checks that the card is unchanged. If the card was moved meanwhile, the staged copy lands at the new path, with the old `order`, the old `waiting` and the old body. The timer calls `write_card set` at lines 187 and 189 without checking that `claimed` is still its own in the file it rewrites.
- Measured, on a throwaway pipeline board, with the timer renewing at every poll (`LEASE_TEST_POLL=0.02`, `LEASE_TEST_RENEW_EVERY=1`). 20 runs of stake, then `move-card.sh <card> Done --clear-waiting --top`. Out of 20, 8 came back with `waiting` and `order` restored. In other runs 9 of 20 and 10 of 20 did. The card was always in Done, never in two lanes, and `claimed` was always there.
- Measured: the same timer against `resolve-ticket.sh` on a throwaway plan board. Out of 40 runs over two batches, 16 lost the `## Resolution` on the Resolved card (7 of 20, then 9 of 20). In 1 run of 20, `claimed` was also left on the Resolved card. The old body called this case reasoned only; it happens.
- At the real timing (a renewal every 15 minutes, a window of milliseconds) it is rare. It applies to every script that writes a card's `index.md`. Not measured against the app's own writes.
- **The timer can exit at its first poll.** Read, and measured with a forced delay. `ensure_timer` starts the timer (`lease.sh:148`) and only then saves its process id (line 149). Until that save, the memory holds `pid=` empty, and the timer exits on any `pid` that is not its own (line 180). On a scratch copy with a 0.5 s pause added between the start and the save, at a 0.2 s poll, 5 of 5 timers were gone 0.3 s after the stake. On the unchanged script it did not reproduce: 0 of 30 at a 0.001 s poll, 0 of 30 at 0.2 s. At the real 60 s poll it needs a 60 s stall.
- **The header overstates the renamed-board limit.** Read. `lease.sh:17` says a renamed board "is a new key, never-held". Measured on a throwaway board renamed under a live lease: the old timer exits, `check` still reads `held` while `claimed` names the session, renews and starts a new timer. After a second rename with another session's lease on the card, `check` printed `never-held` (exit 4) and posted no **Lease lost** record. So the memory is forgotten, not the lease. `lanework/references/writes.md` § Lease already words it right.

## Change

1. **The lease write lands only on the card it read.** In `skills/lanework/scripts/lease.sh`, `write_card` takes `set`, `renew` or `clear`. Each try copies the card as read into the stage, rewrites from that copy, finds the card again, and moves the result in only when the path is the same and `cmp` shows the file unchanged. If the card changed, it starts over, up to 5 tries, then writes nothing and says so on stderr (exit 1). `renew` also requires `claimed` in the copy to be this session's. If it is not, it writes nothing and returns 5. The timer's two renewals (lines 187 and 189) and `own_held`'s renewal use `renew`. The timer goes on to its next poll, which already posts the loss or stops on a release. `stake`, `renew` and `check` read the card again and decide once more. `stake` keeps `set`, and release keeps `clear`. A test knob, `LEASE_TEST_WRITE_PAUSE` (seconds, default 0, the first try only), holds the write between the read and the compare so smoke can make the race happen every time. A prototype on a scratch copy, without the knob, measured 0 of 40 against `move-card.sh` and 0 of 20 against `resolve-ticket.sh`. Add one clause to the **Writes** line of `lanework/references/writes.md` § Lease: a lease write lands only on the card as it read it, and otherwise reads again. Update README § Sizes for the new word count.
2. **The timer waits for its id.** At `lease.sh:180` the timer exits only on a saved `pid` that is not its own, so an empty one means "not saved yet": `[ -z "$M_PID" ] || [ "$M_PID" = "$$" ] || exit 0`. Release still stops it, because release removes the memory (line 179 exits). Measured on the scratch copy with the 0.5 s pause: 0 of 5 timers gone. This item could be dropped: it is harmless at the real poll. It is kept because it is one line and may be one cause of the load-only smoke failure below.
3. **The header says what happens.** `lease.sh:17` reads: a board folder renamed or moved under a live lease is a new key, so the memory is forgotten and the old timer exits. `claimed` still reads as held, and the next write renews it and starts a new timer. Lapsed and taken over meanwhile, the next write lands with no loss record. This is wording only. It could be dropped, but it costs nothing.
4. **Smoke**, in the lease section of `tests/smoke.sh`:
   - With `LEASE_TEST_WRITE_PAUSE=1` and `RE=1`, a held card in Active, and `move-card.sh --clear-waiting --top` run during the pause: the card ends in the target lane with no `waiting`, the new `order`, and `claimed` still this session's.
   - The same pause, with `claimed` changed to another session during the pause: the renewal writes nothing (the file is byte-identical after it), and the next poll posts one **Lease lost** record.
   - A held card whose memory file is rewritten with `pid=` empty: the timer is still alive two polls later.

## Not in scope

- **The renamed or moved board.** It is a stated limit, by [the lead's ruling on the work scripts' lease check](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa). Adopting a memory whose board path is gone was refused there, because it gives a false loss record after a throwaway copy is deleted. The open question from that review is now answered, by reading: the app does not rename the folder when the owner renames a board. `renameBoard` in `lanework-app` `Lanework/LiveStore/BoardStore.swift:7796` rewrites only the `title`, at the same root folder. So only a Finder rename, a `git mv` or a moved checkout reaches the limit.
- **A timer from the older memory layout** that doubles the loss record. That ruling noted it with no change: `lease.sh` has never been released (it is not on `stable`), so only development sessions on main can hold one.
- **Foreground writers stay unguarded against a renewal.** A script that reads before a renewal and writes after it drops the renewal's newer `until`. The older `until` is still about 15 minutes ahead, and the takeover notice ([ADR12](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)) covers a lease that only looks lapsed. Guarding every writer would mean a lock that every card-writing script takes. [ADR3](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74) keeps that lock as the fallback for staking collisions, not for this.
- **The `claim-ticket.sh` items** from the second comment: the restamped `order` after a claim ends before its move (measured by that review, and the same before the lease), the one-fork window (reasoned), and a stake stranded by an uncatchable signal (recovered by the next claim). They are in plan's claim flow, not in the lease write. File them as their own Issues card if they are wanted.
- **The first plan claim smoke case failing under parallel load.** Its cause is not isolated. Item 2 removes one candidate. Run it again after the build, five runs in parallel, and file an issue if it still fails.

## Risks

- `compact_fm` and the retry make each lease write a little slower. A card that keeps changing gives up after 5 tries and writes nothing. For the timer, that means one skipped renewal, and the next poll tries again.
- There is still a window between the `cmp` and the `mv`, but it is microseconds now, not a whole rewrite. The app's writes are not measured, before or after.
- A `renew` that finds `claimed` gone now writes nothing where it used to restore `claimed`. That is the intended change: release and loss are then found by the paths that already handle them.

## Done when

- `tests/smoke.sh` passes, with the three new cases in item 4.
- `grep -n 'never-held; lapsed' skills/lanework/scripts/lease.sh` prints nothing, and `grep -n 'memory is forgotten' skills/lanework/scripts/lease.sh` prints the header line.
- `grep -n 'write_card set' skills/lanework/scripts/lease.sh` shows only the stake's write. No `write_card set` is left in `timer()` or `own_held()`.
- `pgrep -fl 'lease.sh _timer'` prints no smoke timer after the run.

Bump: patch.
