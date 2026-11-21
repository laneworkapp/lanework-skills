---
schema: 1
kind: comment
created:  {at: 2026-11-21T01:36:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `ee11aca` and pushed. Not released.

**What changed** (`skills/lanework/scripts/lease.sh`, cases in `tests/smoke.sh`):

- A lease write lands only on the card as it was read. The compare and the rename happen in one perl process, so a card move or a ticket's Resolution that lands while the timer renews is kept, never overwritten.
- A stake writes only over the `claimed` it read. Two sessions claiming one card at once can no longer overwrite each other: one wins, the other backs off.
- A release writes only while `claimed` is still the expected session's. A release over another session's claim exits 1 and keeps the memory. Already released returns 6, and a forced release of a card released meanwhile posts no force record.
- When the stage folder is on another volume than the board, the write goes through `<board>/.lease-write.<card>.<pid>.lanework-tmp` (ignored by the board's `.gitignore`), compared again before its rename.

**Departures from the proposal:** the cross-volume path, the stake rule and the release rule were not in it. The reviewer found each as a way the original check could still lose a write.

**Evidence:**

- `tests/smoke.sh` on `main` at `ee11aca`: `smoke: 309 passed`, exit 0.
- Claim race measured under load: 0 failures in 40 runs on the branch. Before the stake rule the branch failed 32 to 34 of 40, against 3 of 40 on `main`; the fixer had called it a known flake.
- New cases 3b (two stakes race), 3c (release over another's claim), 11b (in-place write during the compare), 11c, 11d (RAM disk, other volume). The reviewer removed each rule in turn and confirmed a case fails.
- Review: six rounds, approved at `62bd4bc`.

**Left open**, filed as a follow-up card in Issues:

- A session id containing a backslash, comma or closing brace leaves a stranded `claimed` after a stake backs off (also true before this change).
- The "release by hand" wording points toward `--force` over a real holder.
- A SIGKILL of perl mid-write can leave the temp file on the board.
- A board the app never opened has no `.gitignore`, so the temp file is not ignored there.
- Design idea: swap-and-verify with `renameatx_np` would close the last window.

**CHANGELOG sentence:** The lease timer no longer undoes a card move or a ticket's Resolution that lands while it renews, two sessions claiming one card at once can no longer overwrite each other's claim, and lease writes work when the board is on another disk.
