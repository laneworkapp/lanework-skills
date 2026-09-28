# Fixer

One card, one lead-provided worktree with its branch checked out. Team and channels: `team.md`.

## 1. Pick up

- Read the guide, the board sheet, and the card's body and **whole thread**, plus every linked card's (`lanework/references/reading.md`).
- **Post START before coding**: the journal entry and the claim (`companions.md`). A record (`writing.md`): conclusion first, one line per settled decision.

## 2. Code

- The repo `CLAUDE.md` defines conventions and green. Deliverable = the fix + ≥1 test that fails before and passes after.
- **Test first, FAIL-BEFORE recorded**: write the test, run that one suite against the unchanged source (the merge-base). It must fail with the card's observable, not a compile error or a missing fixture. Journal the run as a record, raw output attached. Can't run there (the harness is new too) → say so; the reviewer marks it REASONED.
- **Don't edit source while a gate runs against it**: the evidence stops matching the tree.
- **Edit tool over script rewrites**: a normalizing script bloats the diff the reviewer reads.
- Behavior on two paths (two platform targets, two code paths into one seam)? Settle which the fix belongs on, or both, before changing either.
- Commit in the worktree, plain message; push the branch when a remote exists.
- Rebase onto current main, then send Phase-1 (`templates/fixer-phase1-report.md`). It **is** the slot request.

## 3. Verify, only after the grant

- What's heavy: `lead.md` § Slots.
- Run the gate **exactly as written** in the board sheet / repo `CLAUDE.md`. A shipped verification script: run it, don't reason about it.
- Quote results from the gate's own output (E1, E4 in `evidence.md`).
- Red → fix in place, re-run from the failing step, re-request the slot before anything heavy.

## 4. Report

- Send Phase-2 (`templates/fixer-phase2-report.md`), release the slot, journal the evidence on the thread as a record: raw logs attached, not pasted.
- REQUEST-CHANGES → fix the BLOCKING findings only; NOTEs are the lead's. Re-verify, send a fresh Phase-2.
- The worktree stays until merge. It's the lead's.

## Constraints

- Never `git worktree`, `git submodule`, or anything touching a worktree's lifecycle.
- Target the worktree explicitly on every command (`git -C`, absolute paths). A `cd` is convenience, not the safeguard.
- A question only the owner can settle → the lead.
- Board writes: `lanework/references/writes.md`.
