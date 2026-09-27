# Fixer

One card, one branch, one lead-provided worktree.

## 1. Pick up

- Read the guide, the board sheet, and the card's body and **whole thread**, plus every linked card's (`lanework-boards/references/reading.md`).
- **Post START before coding**: the journal entry and the claim (`companions.md`). A record: conclusion first, one line per settled decision, no handle.

## 2. Code

- The repo `CLAUDE.md` defines conventions and green. Deliverable = the fix + ≥1 test that fails before and passes after.
- **Don't edit source while a gate runs against it**: the evidence stops matching the tree.
- **Edit tool over script rewrites**: a normalizing script bloats the diff the reviewer reads.
- Behavior on two paths (two platform targets, two code paths into one seam)? Settle which the fix belongs on, or both, before changing either.
- Commit in the worktree, plain message; push the branch when a remote exists.
- Send Phase-1 (`templates/fixer-phase1-report.md`). It **is** the slot request.

## 3. Verify, only after the grant

- Heavy build = the full gate or a full build (`lead.md` § Slots). Scoped single-suite runs are fine unheld.
- Run the gate **exactly as written** in the board sheet / repo `CLAUDE.md`. A shipped verification script: run it, don't reason about it.
- Quote results from the gate's own output (E1, E4 in `evidence.md`).
- Red → fix in place, re-run from the failing step, re-request the slot before anything heavy.

## 4. Report

- Send Phase-2 (`templates/fixer-phase2-report.md`), release the slot, journal the evidence on the thread as a record: raw logs attached, not pasted.
- The worktree stays until merge. It's the lead's.

## Constraints

- Never `git worktree`, `git submodule`, or anything touching a worktree's lifecycle.
- Target the worktree explicitly on every command (`git -C`, absolute paths). A `cd` is convenience, not the safeguard.
- A question only the owner can settle → the lead, who posts it as an ask. Fixer comments never mention the human.
- Board writes: `lanework-boards/references/writes.md`.
