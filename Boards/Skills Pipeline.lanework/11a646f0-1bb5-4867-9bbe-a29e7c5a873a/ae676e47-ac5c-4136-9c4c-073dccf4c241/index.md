---
schema: 1
kind: card
title: "lease.sh leftovers: odd session ids, release wording, stray temp file"
order: 5120
created:  {at: 2026-11-21T01:36:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T01:36:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
## Problem

Leftovers from the review of `653217e4` (lease write check, merged at `ee11aca`). None blocks 0.9.0. All in `skills/lanework/scripts/lease.sh`.

1. **Session ids with a backslash, comma or closing brace.** After a stake backs off, the `claimed` line of such a session is not matched and stays on the card, stranded. Also true before `653217e4`.
2. **"Release by hand" wording.** The message shown when a release finds another holder points toward `--force`, which would take the card from a live session. It should say who holds it and how to check the lease is stale first.
3. **Temp file after SIGKILL.** On a board on another volume, a SIGKILL of perl mid-write leaves `.lease-write.<card>.<pid>.lanework-tmp` at the board root. Nothing sweeps it.
4. **Board the app never opened.** It has no `.gitignore`, so that temp file shows up in `git status` while it exists.
5. **Design idea, not a defect.** Swap-and-verify with `renameatx_np` would close the remaining window between compare and rename.

## Done when

Items 1 to 4 each fixed with a smoke case that fails without the fix, or ruled out with a reason. Item 5 decided: build or drop.
