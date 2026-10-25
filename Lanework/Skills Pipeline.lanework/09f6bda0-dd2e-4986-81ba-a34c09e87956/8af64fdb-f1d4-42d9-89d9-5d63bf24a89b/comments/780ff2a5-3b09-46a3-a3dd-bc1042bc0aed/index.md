---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:47:45Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:47:45Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review round 2: REQUEST-CHANGES on `merge-skill` at `76e47dc`. B2 and B3 are fixed, and so are all 5 notes. B1 and B4 are narrower but still reproduce, and the new rehome pass crashes on an uncommitted app move. All three fixes are small.**

```text
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer ran at opus; the diff rewrites board files during git merges and edits .gitattributes and .git/config)
ROUND:   2

CARD:   Active/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b "merge: a skill that resolves git merge conflicts on a board without a human"
BRANCH: merge-skill at 76e47dc (rebased on main 7248f42; content diff read against 068c6b4)

BLOCKING: 3
  B1 (narrowed, still open). skills/merge/scripts/lanework-merge.py:921 @ 76e47dc "if b'\n=======' in wt:":
     a dirty file that is itself an unmerged path is skipped when it contains any line starting with
     "=======", on the guess that it is git's marker output. remove_paths then erases it. Repro: my round-1
     rename/rename case (A moves the card to Approved, B to Done), with the uncommitted comment holding a setext
     H1 ("Heading" over a line of "=======") and DIRTY_LOCAL_TOKEN. merge-board.sh exits 0 and says "Nothing
     was lost"; the comment is staged as a plain rename with HEAD's text, and DIRTY_LOCAL_TOKEN is gone. The
     plain s10 and s9 repros now carry the edit (measured).
     Fix: recognise git's output exactly. Rebuild it from the stages with git merge-file, or require
     "<<<<<<< " and ">>>>>>> " lines as well. Or, when in doubt, carry the bytes anyway: stop-on-doubt has
     to fail safe.
  B4 (narrowed, still open). skills/merge/SKILL.md:17 @ 76e47dc "4. **Stop.** The merge commit, `git rebase
     --continue`, or committing a re-home is the user's.": the driver no longer writes in place, and the
     losing pick stops (fixed). But the pass's own merge comment, committed with pick 1, is still left in
     Ideas/<card>/comments/ when pick 2 moves the card. Repro: my s4 at 76e47dc, with the pass at the stop,
     then GIT_EDITOR=true git rebase --continue. The rebase finishes with exit 0, commit a2 is in history
     with "duplicate-identity ... 2 folders on this board claim the identity", and the board fails
     validation on disk. A second merge-board.sh re-homes it (measured), but by step 4 nothing runs it: the
     agent has stopped, and the user ran --continue. tests/merge-case.sh rebasemove passes only because the
     test itself runs the pass again after the loop.
     Fix: make the second run part of the flow. Options: the rebase-mode report and SKILL step 4 say "after
     the rebase finishes, run merge-board.sh once more and commit the re-home"; or install adds post-rewrite
     and post-merge hooks that run the re-home, never clobbering an existing hook.
  N1 (new code). lanework-merge.py:1009 @ 76e47dc "moved, title = [], title_of(open(os.path.join(repo, home,
     'index.md')...": rehome picks the home from the index (ls-files), not from the work tree. State: a tracked
     orphan comment (the comment-vs-move case, before anyone ran the pass), then the owner moves that card in
     the app, which is uncommitted. merge-board.sh crashes with a FileNotFoundError traceback, exit 1, and
     prints no report. Repro: r2-rh.sh case (j). When run inside a merge, this happens after the cards were
     already resolved and staged, so the report and validation are lost. Had it not crashed, git mv would
     have rebuilt the stale home folder, a ghost with no index.md.
     Fix: take homes from the work tree (index.md present on disk), and skip any card whose index and work
     tree disagree. Add a case for it.

NOTES: 4
  - lanework-merge.py:1075 @ 76e47dc "notes['beside'] += [l['line'] for l in ls]": a lane or board title changed
    on both sides loses the earlier title to the one-paragraph report only. Owner rulings cover bodies, not
    titles; the earlier title could go inline under the merged-from heading like the body does.
  - rehome: untracked files in an orphan folder (the app's .draft, a temp file) aren't moved, so prune leaves
    the folder, still with no index.md. A git mv -k skip where the destination exists leaves the same.
  - rehome runs on every pass, with no operation in progress, and stages with git mv into whatever the user
    already has staged. Fine per SKILL, but worth a line in the report saying the staging is mixed in.
  - rules.md Limits: GUI git clients often run with a minimal PATH, so python3 may resolve to the
    /usr/bin/python3 CLT stub. The fallback is safe (ours, no markers, stopped; the pass resolves it).

CHECKED:
  round-1 blocking, re-checked by quoted text:
    B1 "remove_paths(repo, sorted(tracked - {''}))": still at the same call. The carry block in front of it
       saves s10 (staged as ours, named in the report) and the plain rename/rename. The setext case still
       loses the edit (above).
    B2 "if c['cls'] == 'card' and rc == 0:": gone. s3 now stops with mover=A and with mover=B; the pass posts
       one merge comment at the final path, committed, and the board validates. FIXED.
    B3 lane ledger path: gone. s5 merges by itself with nothing untracked; the overlapping lane edits sit
       inline under "## Merged from the earlier edit (2026-01-02T00:00:00Z, alice)", both tokens committed.
       FIXED, per the owner's ruling A.
    B4: see above.
  new behaviour:
    stop on loss: the driver writes only %A. No ledger, blobs or lost-*.md remain, and an abort leaves
      nothing behind (code read; the fixture asserts nothing untracked after the stop).
    driver command: python3 "$(git rev-parse --git-common-dir)/..." ran correctly in a linked worktree
      whose path has spaces ("r2 wt space/linked wt"). It stopped on loss there, and the pass resolved it.
    rehome: a no-op on a clean board; ignores an untracked half-written card folder and the app's
      comments/.draft; skips two tracked homes (duplicate identity). Crashes in case (j), above.
    carry: s10 (no move) and s9 (rename/rename) carried and staged; fails on "=======" (above).
  round-1 notes: CRLF placement normalised (process_card text()); abort and reset leftovers gone with the
    ledger; the attachment title line names the attachment; an unclassified file keeps theirs beside it as
    notes.theirs.txt (asserted); TR1 asserted inside .trash, M1 asserted at order 4000; criss-cross duplicates
    listed under Limits; interpreter pinning replaced. All fixed.
  fail-before:              OWN RUN agreed. The round-2 tests/merge-case.sh against a git-archive export of
    068c6b4: clean "not committed: LANE_A_TOP", rebasemove "the losing pick should stop", dirty "the
    uncommitted edit was erased", merge "unclassified file: ours kept, theirs beside it". Each exit 1, and each
    matches the fixer's d72f2555.
  gate:                     smoke 36 passed of 36, exit 0 (own run on a git-archive export of 76e47dc).
  blast radius:             skills/merge, tests and README, as expected. smoke.sh's other changes come from
    main's rename (7248f42), not this branch.
  project conduct:          stage-exact-paths and BSD bars hold; rules.md stays the single source, and the
    new rows are telegraphic.
  population:               my round-2 runs: 4 round-1 repros (2 fixed, 2 narrowed), worktree-with-spaces 1
    of 1 ok, rehome 4 attacks (3 ok, 1 crash), carry 3 (2 ok, 1 loss).

UNRESOLVED: none. The owner's two rulings are applied as written.
```
