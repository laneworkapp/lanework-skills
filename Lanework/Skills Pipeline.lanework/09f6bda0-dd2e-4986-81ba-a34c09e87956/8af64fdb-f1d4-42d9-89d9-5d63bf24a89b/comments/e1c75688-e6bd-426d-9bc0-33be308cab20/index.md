---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:50:56Z, by: {name: reviewer, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T10:50:56Z, by: {name: reviewer, kind: agent, model: opus, session: "board dispatch"}}
---
**Review round 1, adversarial: APPROVE at `58ae5a3`, with 0 blocking and 5 notes. My own runs agree with the fixer's, and appside also passes against the v101 board files.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none": the done-when mutation was substituted)
ROUND:   1

CARD:   Active/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b "merge: a skill that resolves git merge conflicts on a board without a human"
BRANCH: merge-appside at 58ae5a3 (merge-base 292d879)

BLOCKING: 0
  none

NOTES: 5
  N1 tests/merge-case.sh @ 58ae5a3 "AE=2026-01-02T00:00:00Z": A's title stamp is earlier than the app card's
     created (2026-10-10T01:09:29Z), so the README's own app marker (modified with no by) is never discriminated.
     Measured: a stamp_at that returns None for a modified with no by falls back to created, the app still wins,
     and appside exits 0. Fix: set AE between created and the app's modified (e.g. 2026-10-10T01:30:00Z).
  N2 tests/fixtures/app-writes/comment-posted.md @ 58ae5a3 "{name: \"Rouslan Z\", kind: \"human\"}": added on one
     side only, so no merge code parses the quoted stamp. Only rehome and cmp touch it. The lead already ruled
     that the unquote mutation stands in for the done-when one. Recorded so the done-when wording isn't read
     as literally met.
  N3 tests/fixtures/app-writes/lane-rewrite.after.md, card-move.after.md @ 58ae5a3: both app writes change
     frontmatter only, so no body merge is two-sided. Measured: merge_text returning ours unchanged stays green.
     This comes from the real app writes. No fix needed.
  N4 tests/fixtures/app-writes/README.md @ 58ae5a3 "the version at the parent of the commit shown in its column":
     for card-move the before column names 4e94081, which is the fixture itself; its parent fe9520b lacks the file.
     It should read "the parent of the after commit". The lane-rewrite before cell also gives no path.
  N5 tests/merge-case.sh @ 58ae5a3 "else G \"$M\" add -A -- \"$BN\"": this branch would stage anything the pass
     left untracked, which hides it from clean_status. It's dead in the measured run (the merge stopped, so
     MERGE_HEAD was present). Fix: assert MERGE_HEAD, or drop the add -A.

CHECKED:
  correctness vs done-when: appside passes in smoke (fixer's raw run, step 78 of 119, 0 not ok) and runs in CI
                            (smoke.yml runs tests/smoke.sh on macos-latest). The unquote mutation turns it red.
                            The repo CLAUDE.md guide-bump sentence names re-copying the fixtures.
  project conduct:          nothing under skills/; tests are bash with BSD sed -i ''; no board writes in the
                            code commit; no "assume Y" shapes
  both paths:               merge path exercised. Rebase is not run for appside, and the done-when doesn't
                            ask for it (NOTE-level at most)
  fail-before:              OWN RUN agreed. Merge-base script, appside -> exit 0 (generic case ran). Branch
                            tests at the merge-base -> exit 0, 1 unmerged path resolved, the merge stopped.
                            Unknown mode -> exit 2. Mutations: unquote -> exit 1 "the merge comment doesn't
                            name the kept title"; later() inverted -> exit 1 "the later (app) title must win";
                            rehome off -> exit 1 (merge-board.sh non-zero); foreign() always true -> exit 0
                            (the pass rebuilds by uuid, still correct); merge_text ours -> exit 0 (N3);
                            no-by modified unparsed -> exit 0 (N1)
  test adequacy:            a new mode beside its siblings in tests/merge-case.sh; one smoke line next to
                            the other merge-case lines; fixtures under tests/fixtures/ with a sourcing README
  blast radius:             11 files: CLAUDE.md, tests/merge-case.sh, tests/smoke.sh, 8 under
                            tests/fixtures/app-writes/. Matches Phase-1; no churn
  population:               all 7 fixtures byte-compared with git show <cited sha>:<path>: 7 of 7 identical.
                            Mutations: 6 run, 3 red, 3 green (each explained above). Smoke 119 ok, 0 not ok
  adversarial only:         hypotheses written before the reports: H1 fixtures not byte-true (refuted, 7/7);
                            H2 green without the driver logic (partly held: N1, N3); H3 the add -A branch
                            masks leftovers (held as a latent risk, N5); H4 the quoted stamp is never parsed
                            (held, N2, already ruled); H5 breaks on v101 board files (refuted, below);
                            H6 asserts not sensitive to which side wins (refuted by the later() mutation)

v101 check (lead's ask, measured): scratch worktree detached at origin/main 3a91177 (board guide v101, schema v1)
with the branch's tests/ checked out. merge-case.sh in all 7 modes (appside, merge, rebase, nodriver, clean,
rebasemove, dirty): every one exits 0. The scratch worktree was reset to 292d879 afterwards.

UNRESOLVED: none
```
