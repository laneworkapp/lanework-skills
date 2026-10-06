# Reviewer

One card's branch, read-only. Verdict: **APPROVE** or **REQUEST-CHANGES**. Stance (standard or adversarial), what may block, round cap: `team.md` § Review stance, § Bounding review.

**Read the head off the branch** (`git -C <repo> rev-parse <branch>`), never the hand-off. Branches move during review; an old sha re-files fixed findings.

**Adversarial**: read the card and the diff (items 1–3) and write down how you'd expect it to break **before** opening the phase reports.

## Checklist

1. **Context**: the card and whole thread, plus linked threads. Was the fixer's LINKED CONTEXT real? No duplication of a sibling's work; a one-fix-many sibling belongs in this branch. Sanity-check CROSS-POST.
2. **Diff from the pinned merge-base**: `git -C <repo> diff $(git -C <repo> merge-base main <branch>) <branch>`. Never `main..<branch>` (`traps.md`).
3. **Correctness vs done-when**: does the diff produce the card's stated observation, checked against its example, not just "it builds"?
4. **Project conduct**: the repo `CLAUDE.md` bars. Flag any "couldn't resolve X, so assume Y".
5. **Both paths**: behavior on >1 path → each handled, or the gap flagged in UNCERTAINTY. An unflagged gap = BLOCKING.
6. **Fail-before**: the fixer's FAIL-BEFORE run is at the merge-base and fails with the card's observable, not a compile error. Would the assertion still fail if the fix were wrong? Adversarial: also check out the branch's test files into the scratch worktree (`git -C <scratch> checkout <branch> -- <test paths>`) and run that one suite. Mark FIXER RUN, OWN RUN, or REASONED (only when the fixer said it can't run there).
7. **Test adequacy**: named and located like its neighbours?
8. **Blast radius**: Phase-2 actual vs Phase-1 expected. Unexplained churn = red flag, even when verification passed.
9. **Population**: every reported zero has its denominator (E1).

## Verdict

- Fill `templates/review-verdict.md`. **Post it on the card thread** (stamp `reviewer`), then send the same text to the lead. The thread is the durable copy; a message-only verdict dies at teardown.
- A record (`writing.md`). Owner-only questions go under UNRESOLVED, for the lead to ask.
- **Anchor findings** `file:line @ <short sha> "<quoted fragment>"`. Line numbers drift; sha + fragment stay checkable (E9).
- Re-review: read the **new** head, re-check each open BLOCKING finding by its quoted text, review only the diff since your last sha.
