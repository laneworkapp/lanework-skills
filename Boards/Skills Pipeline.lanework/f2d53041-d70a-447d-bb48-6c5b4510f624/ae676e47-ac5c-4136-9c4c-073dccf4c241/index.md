---
schema: 1
kind: card
title: "lease.sh leftovers: odd session ids, release wording, stray temp file"
order: 11264
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T01:36:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:20:11Z}
---
`lease.sh` stops accepting session ids it cannot store faithfully, tells a refused release how to check whether the holder's lease lapsed, and sweeps the temp file a killed cross-volume write leaves behind.

## Problem

Leftovers from the review of `653217e4` (lease write check). All in `skills/lanework/scripts/lease.sh`.

1. **Session ids with a backslash, comma or closing brace.** Reproduced on throwaway boards with made-up ids. For `S,x2` and `S}x3`, `stake` prints `session S staked bbbbbbbb first; backing off`, exits 1, and the card keeps `claimed: {... session: "S,x2" ...}`: `read_claim` ends the id at the first comma or brace, so the holder never matches itself. A later `release` by the same session exits 1 (`held by session S`) and the claim stays on the card. For `S\x1` the same happens because `write_card` passes the stamp through `awk -v`, which eats the backslash: the card holds `Sx1`, not `S\x1`. For `S\\n5` the card holds `S\n5`. Ids with `{` or a single quote round-trip fine. A claim stranded this way blocks every other session until its 30 minutes lapse.
2. **Release wording.** The text `release` prints when another session holds the card is `is held by session X; --force on the owner's word only`. It names the holder but not how to tell a live holder from a lapsed one, so an agent in a hurry has only `--force` in front of it. Reproduced by releasing a card staked by another session (exit 1, that line). There is no "by hand" wording left in the script or in `references/writes.md`.
3. **Temp file after SIGKILL.** Reproduced with a RAM disk as `TMPDIR` and `LEASE_TEST_WRITE_PAUSE=8`: a `kill -9` of the perl process during the pause left `.lease-write.<card>.<pid>.lanework-tmp` at the board root, still there 9 seconds later. Nothing in the script removes it; the perl cleanup runs only on TERM, INT, HUP and on its own failure paths.
4. **Board the app never opened.** Not reproduced as its own defect: reasoned from `lease.sh` header and item 3. Without a `.gitignore` the temp file shows in `git status`, but it exists only for the few milliseconds of a cross-volume write, plus until the next lease write once item 3 sweeps it. No separate fix beyond item 3.
5. **Design idea: `renameatx_np` swap-and-verify.** Not reproduced: reasoned from the perl block in `write_card`. Compare and rename already happen in one perl process with no fork between them, so the window is microseconds. Closing it would need `syscall()` from perl with a macOS syscall number (deprecated, fragile), works on one volume only, and on a detected loss could only swap back, which loses the other writer's change a second time.

## Change

1. `skills/lanework/scripts/lease.sh`: extend the session id check to refuse `\`, `,` and `}` as it does slash, quote and space (exit 2, usage message naming the character class). Real session ids are UUIDs; refusing at the door means no claim can be written that the script cannot read back. Update the exit-2 text in the header and in `skills/lanework/references/writes.md` § Lease (the Holder bullet and the Exit codes bullet say what a bad id is).
2. `skills/lanework/scripts/lease.sh`: reword the release refusal to `<card> is held by session X; lease.sh list <board> shows whether it lapsed (take a lapsed one with stake); --force on the owner's word only`. Add the same pointer, in few words, to the Release bullet in `references/writes.md` § Lease.
3. `skills/lanework/scripts/lease.sh`: at the start of `write_card`, remove every `$BOARD/.lease-write.*.<pid>.lanework-tmp` whose pid is not alive (`kill -0`). A live pid keeps its file. Update the comment above the perl block and the sentence in `references/writes.md` § Lease (Writes bullet) from "removed on every failure path and on TERM, INT or HUP" to also say a killed write's file is swept by the next lease write on the board.
4. Ruled out; only the header comment sentence about the missing `.gitignore` gains "and a killed write's file is swept by the next lease write".
5. Dropped, reasons in Problem.

## Verified

New cases in `tests/smoke.sh` next to the existing lease cases, on throwaway boards, none needing a RAM disk.

1. Stake under each of `S,x`, `S}x`, `S\x`: exit 2, stderr names the id, the card has no `claimed`. Without the fix: exit 1 and a stranded `claimed`.
2. Another session's release on a live claim: exit 1 and stderr contains `lease.sh list`. Without the fix the line is absent.
3. Plant `.lease-write.<card>.<dead pid>.lanework-tmp` (a pid of a finished subshell) and `.lease-write.<card>.<live pid>.lanework-tmp` (a running `sleep`) at the board root; run `renew` on a held card. The dead one is gone, the live one stays. Without the fix both stay.

## Done when

- `lease.sh stake <board> <card> --model m` with `CLAUDE_CODE_SESSION_ID='a,b'`, `'a}b'` and `'a\b'` each exits 2 and leaves the card without `claimed`.
- A release over another session's live claim prints a line containing `lease.sh list`.
- A leftover `.lease-write.*.<dead pid>.lanework-tmp` at a board root is gone after the next `stake`, `renew`, `check` that writes, or `release`; one with a live pid is untouched.
- The three new smoke cases pass and fail on `main` as it stands; `tests/smoke.sh` passes whole; the header, `references/writes.md` and the script agree on the id rule and on the sweep.

## Risks

- Refusing three more characters could reject an id some host sets. Claude Code session ids are UUIDs and the script already refuses slash, quote and space; the risk is small and the failure is loud (exit 2).
- The sweep trusts the pid in the file name. A reused pid keeps a stale file until that pid ends; the cost is a leftover, never a lost write. The glob runs on every write, which is negligible.
- A leftover file of a card on a board the sweeper never writes again stays; no worse than today.

## Recommendation

Build items 1 to 3 together; they are small and touch one script plus one reference. Item 4 needs nothing beyond a comment edit. Drop item 5: the window is already microseconds, and the syscall route is fragile and cannot actually recover the lost write.
