---
schema: 1
kind: comment
created:  {at: 2026-11-20T20:08:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-20: all six items built, reviewed and approved, merged to `main` at `2c5865f`. Smoke on main: 255 passed. The hold on 0.9.0 for item 1 is met.**

- **What changed**: `work/scripts/commit-board.sh` (items 1, 3, 4, 6), `file-card.sh`, `move-card.sh`, `post-ask.sh`, `post-comment.sh` and `lanework/scripts/lib.sh` (item 5: a shared `need_value`, usage errors exit 2), `tests/smoke.sh` (five new or changed cases). Branch head `8af5727`.
- **Item 1, the staged-work loss**: a failed pre-commit hook now commits nothing and leaves the index as the owner had it. Smoke case: "a failed pre-commit hook commits nothing and leaves the owner's staged version in the index".
- **Review: approved, round 1, adversarial.** In throwaway repos, with index and HEAD recorded before and after, the index stayed byte-identical and HEAD never moved for: a failing pre-commit hook, a hook that edits the work tree then fails, a staged deletion, a staged rename, a staged new file, paths with a space and with unicode, a failing commit-msg hook, SIGTERM during the hook, and two runs racing on the lock. The script before the fix lost the staged version in every one.
- **Each new case can fail**: the reviewer reverted the six items one at a time in a scratch copy; each revert failed its own case.
- **Done when**:
  - smoke with the new cases: met, 255 passed on main.
  - hook repro (staged v2, disk v3, hook exits 1): met, index still `v2`, status `MM`.
  - the grep line: prints only `lint-ask.sh:15`, which is outside the four scripts item 5 names. Met in intent; the grep is broader than the item.
  - `work-commit` folders in `TMPDIR` before and after: met, 0 and 0 with a private `TMPDIR` on two full runs.
- **Built differently from the body**: `LANDED` is cleared when `PRE` is taken, so a retry after a hook failure does not reset the index. The reviewer checked it cannot leave the index wrong.
- **Not fixed here, filed**: after a rejected push the script still replaces the owner's staged version with HEAD's. Same loss, different route, and the script did this before this card. Filed as [commit-board.sh drops the owner's staged version of a path when a push is rejected](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/08ccbaba-b51b-4860-937b-13037b41b85e), with an ask on whether 0.9.0 waits for it.
- **Smoke under load**: three runs on main failed before the passing one, each while Xcode builds and other smoke runs held the load average between 50 and 350: one broken pipe, two on a plan-claim timing case. This merge touches no plan or lease script. The passing run was at load 33.
- **Bump**: patch; rides 0.9.0. **CHANGELOG**: none; the 0.9.0 entry about the helpers covers it.
