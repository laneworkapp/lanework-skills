---
schema: 1
kind: card
title: "Lease: a renewal can undo another write to the card, and a renamed board forgets its leases"
order: 6144
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T19:08:42Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T13:39:57Z}
---
Three things found in the review of [the work scripts' lease check](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa), none fixed there. All are in `skills/lanework/scripts/lease.sh`, on main and not released.

## A renewal can undo a concurrent write

- `write_card` reads the card, rewrites it and moves it into place with no lock. A renewal by the timer that reads before another script writes, and lands after, puts the old front matter back.
- Measured by the reviewer on a throwaway board with the timer renewing at every poll: 20 runs of `move-card.sh --clear-waiting --top`. The card was never torn, never in two lanes, and `claimed` was never lost. In 2 of 20 runs `waiting` came back after being cleared.
- At real timing a renewal happens every 15 minutes and the window is milliseconds, so it is rare. It applies to every writer of a card's `index.md`, the `waiting` that `post-ask.sh` sets included.
- Not measured: the same race against the app's own writes.

## A renamed or moved board forgets its leases

- The lease's memory is keyed by the board folder's path, so that a copy of a board is another board. A board folder renamed or moved while a lease is live gets a new key.
- If `claimed` still names the session, the next write reads the lease as held and renews it. But the old timer exits at the rename, so without a write the lease lapses in 30 minutes. If another session then takes the card, the first session's next write lands with no **Lease lost** record. Measured by the reviewer; before the memory was keyed by board that write was refused.
- Stated as a limit in `lanework/references/writes.md` § Lease by [the lead's ruling](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa). The fix the reviewer proposed, adopting a memory whose board path no longer exists, was refused there: it reads a card as lost after a throwaway copy is deleted without a release.
- Not checked: whether the app renames a board's folder when the owner renames the board. If it does, the owner can reach this from the app.

## The header comment overstates the limit

- `lease.sh` line 17 says a renamed board "is a new key, never-held". The memory is forgotten, not the lease. Suggested: "is a new key: memory forgotten", and a word that the old timer exits at the rename.

## Also seen

- A timer started before the memory was keyed by board, still running after the change, renews beside the new one and doubles the loss record. Only development sessions on main can hold one.
