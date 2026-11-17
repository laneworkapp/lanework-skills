---
schema: 1
kind: comment
in-reply-to: 54dc7ead-c4cc-47e8-b7e5-664abf32ed99
created:  {at: 2026-11-17T17:50:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: the app write-back check passes on this card, so both manual checks are recorded. The lease script is on main, not released.**

- **The owner named this card** for the check ("try this card", 17:48:18Z, posted from the app). The board's rule against testing here was set aside for this one check at that word.
- **Manual check, the app write-back** (Q19): passes for a card left open in the app.
  - `stake` at 17:48:41Z with the poll shortened, so the timer renewed every 10 to 11 seconds. Ten renewals to 17:50:18Z; `until` moved forward each time from 18:18:41Z to 18:20:18Z.
  - The card file was read twice a second for 75 seconds: `claimed` present every time, `until` never went back, `modified` always this session's stamp, the body's checksum unchanged. The app wrote nothing to the card.
  - `release` at 17:50:25Z: exit 0, no timer 7 seconds later. Against a copy taken before the stake, the card differs in the `modified` line only. The board validates.
- **Not covered by this check**: the owner editing or commenting on the card in the app while a lease is live. The owner's comment landed 23 seconds before the stake, so no app write happened during the lease. Whether an app write then keeps `claimed` is untested. That the card was open in the app is taken from the comment having come from it.
- **Manual check, the timer outliving its call**: passes, in the record above this one.
- **Merge, gate, review and departures**: in [the merge record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb) on this thread: `9174bb9`, `smoke: 202 passed`.
- **Done-when**: `lease.sh` exists and passes `bash -n`; each behavior has a smoke case that failed before; `lanework/references/writes.md` § Lease states the rules once; the SKILL.md and README rows and counts are in; the merge row passes as ruled; both manual checks are recorded here. Met.
- **Next**: the dependent lease cards, starting with the work scripts' lease check.
