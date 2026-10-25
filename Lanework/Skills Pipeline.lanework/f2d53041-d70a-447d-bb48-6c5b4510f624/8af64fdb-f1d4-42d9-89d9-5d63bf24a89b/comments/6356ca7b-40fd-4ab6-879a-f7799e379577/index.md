---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:23:23Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:23:23Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review round 1: REQUEST-CHANGES on `merge-skill` at `068c6b4`. 4 blocking findings: the pass destroys uncommitted local edits, and three cases where the driver resolves cleanly but leaves the earlier text only in `.git` or breaks the board.**

```text
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer ran at opus; the diff rewrites board files during git merges and edits .gitattributes and .git/config)
ROUND:   1

CARD:   Active/8af64fdb-f1d4-42d9-89d9-5d63bf24a89b "merge: a skill that resolves git merge conflicts on a board without a human"
BRANCH: merge-skill at 068c6b4

BLOCKING: 4
  1. skills/merge/scripts/lanework-merge.py:942 @ 068c6b4 "remove_paths(repo, sorted(tracked - {''}))":
     the pass deletes every tracked file in a conflicted card and rewrites it from HEAD's tree, so uncommitted
     work-tree edits are destroyed. Repro: a clone with an uncommitted edit to a comment ("DIRTY_LOCAL_TOKEN",
     status " M"), and both sides edited the card body. git merge stops on index.md only and leaves the dirty
     comment alone. merge-board.sh then exits 0 and reports "Nothing was lost", but the dirty text is gone from
     the disk, the index and the history. The rename/rename variant does the same. The app writes continuously,
     so uncommitted board edits at pull time are normal.
     Fix: before removing, detect tracked paths whose work-tree bytes match none of base/ours/theirs. Keep them,
     either as the ours side or carried like a stray, and name them in the report. Or refuse that card, the
     way git refuses to overwrite local changes. Add a smoke case for it.
  2. lanework-merge.py:747 @ 068c6b4 "if c['cls'] == 'card' and rc == 0:" (the ledger path, 745-748):
     a clean pull where the other side moved the card and edited its body, and we edited the body too. git
     finishes the merge by itself, ours is earlier, and our body is in neither the board nor any merge comment.
     It exists only in .git/lanework-merge/ledger.jsonl, plus one stderr line in the pull output. Repro: s3
     mover=B, with TOKEN_A "ONLY in ledger.jsonl". Shaping record 767d3ca3 rejected exactly this: "a clone with
     the driver and no agent would then lose the earlier body silently". The same path catches any comment or
     attachment loss on a card whose path changes.
     Fix: when the driver records a loss it can't place in place, write the merged file with no markers and
     exit 1, as the trash row already does, so git stops and the pass places and stages it.
  3. lanework-merge.py:747 @ 068c6b4, same branch, lane and board files: both sides edit a lane body (or the
     board body) and git finishes by itself. The earlier text goes only to ledger.jsonl, with no stderr line,
     because the message is printed only for cls == 'card'. No pass ever runs, so no lost-*.md is written
     either. Repro: s5, with LANE_TOKEN_A "ONLY in ledger.jsonl". Worse, edits in different paragraphs, which
     git alone would have merged cleanly, now lose one side.
     Fix: exit 1 on any lane or board loss, or keep both inline (see UNRESOLVED 1).
  4. lanework-merge.py:739-743 @ 068c6b4 "if c['cls'] == 'card' and here and rc == 0: ... post_losses(...)",
     in a rebase: pick 1 is a body edit that loses to upstream, so the driver writes an untracked merge comment
     in Ideas/<card>/comments/. Pick 2 moves the card to Approved. git moves the tracked files, and the comment
     is left behind in a folder with no index.md. The validator then fails with "duplicate-identity ... 2
     folders on this board claim the identity". merge-board.sh stages the orphan and exits 1, after a git pull
     --rebase that itself finished with exit 0. Repro: s4.
     Fix: in a rebase or cherry-pick (and any operation git may finish by itself), don't write in place:
     exit 1 so the pass posts the comment at the final path. Or the pass re-homes orphaned merge comments to
     their card's current folder.
  Shared cause and test gap: tests/merge-case.sh:125 @ 068c6b4 "expected the merge to stop on a rename/rename".
  Every mode forces git to stop, so the no-agent path, where git finishes the merge itself, is never run. Add
  a driver-only case (no conflicts left by git) asserting every token is on the board and staged or committed,
  and a rebase case with a later move.

NOTES: 9
  - lanework-merge.py:1156 @ 068c6b4 "py = shlex.quote(sys.executable or 'python3')": the driver pins a versioned
    interpreter (/opt/homebrew/opt/python@3.14/bin/python3.14) and an absolute .git path. A Python upgrade, or a
    moved repo, breaks the driver. Measured: a missing interpreter gives a conflict with ours and no markers,
    contradicting rules.md's "a clone without it sees plain git markers". Prefer `python3` from PATH and a
    path relative to the git dir.
  - lanework-merge.py:862 @ 068c6b4 "et = split_doc(it.decode('utf-8', 'replace'))[0]": no CRLF normalization
    in the pass, so on a CRLF board win is always ours and placement ignores stamps. Content merges are fine
    (measured).
  - git merge --abort, or a reset and redo, leaves the driver's untracked merge comment and its ledger entries.
    The next pass posts a loss from a merge that never happened. A redo appends a duplicate ledger entry
    (measured: 2 entries).
  - Criss-cross: each clone that merges posts its own merge comment for the same loss, giving two copies of
    A1's text after the cross merge (s8). Correct otherwise; the inner quiet driver works.
  - lanework-merge.py:499 @ 068c6b4 "'Title: kept ...'": on an attachment index, the line reads as the card's
    title and doesn't name the attachment.
  - lanework-merge.py:587 @ 068c6b4 "File `%s`: changed on both sides, ours kept.": theirs' bytes for an
    unclassified board file aren't kept anywhere outside git history.
  - tests/merge-case.sh: TR1 "carrying the edit" is checked only as a token anywhere on the board, not inside
    the trashed card. M1's order isn't asserted.
  - Fixer evidence: fail-before attachment 39fa7bf1 shows a smoke run dying at heal-board.py, exit 127. It
    doesn't support the record's "merge-case.sh exits 2". My own run agrees with the claim.
  - README: the lanework word count for writes.md is stale, as the fixer flagged.

CHECKED:
  correctness vs done-when: every row of both tables, against my own scratch two-clone repos under $TMPDIR,
    beyond the fixture. Correct: same comment edited on both sides (later wins, earlier in a merge comment);
    different comments added to one card (both kept); 3-way label removals (x,y,z -> z,p,q); attachments on
    both sides (ours plus blob.theirs.png, attachment title loss recorded); a CRLF card (CRLF kept, earlier
    body in a comment); cherry-pick of a later trash against an edit (trashed, carrying the edit);
    criss-cross. Wrong: blocking 1 to 4. Done-when's "every body ... exists somewhere on the board" fails
    in 2 and 3, and "the board validates" fails in 4.
  project conduct:          stage-exact-paths and BSD/macOS bars hold. lib.sh is sourced by relative path.
    Cites resolve, and check-refs passes. One topic per file: rules.md is the single source, writes.md got
    one pointer line. Telegraphic text.
  both paths:               merge and rebase are tested, but only with git stopping. The driver-only path
    git finishes by itself isn't tested and isn't flagged in UNCERTAINTY (that's where 2 to 4 live).
    Cherry-pick and CRLF aren't in the fixture; I ran them by hand.
  fail-before:              OWN RUN agreed. In the scratch worktree at fdcf794, with the branch's tests:
    smoke exit 2 at the merge case (lanework-merge.py missing). Scratch restored clean. The fixer's
    attachment doesn't match its claim (NOTE).
  test adequacy:            tests/merge-case.sh beside smoke.sh, run as steps 25-27, like its neighbours.
    Assertions are per-row and specific. See the gap under blocking.
  blast radius:             9 files, as planned in the START record. No churn.
  population:               smoke 32 passed of 32 (own run on a git-archive export of 068c6b4, exit 0).
    14 of 14 fixture tokens. My scenarios: 10 runs, 4 losses or breakages.
  adversarial only:         hypotheses written before the reports: uncommitted edits clobbered (held, B1);
    driver-only merges leave text untracked or in the ledger (held, B2 and B3); untracked comments orphaned
    by a later move (held, B4); CRLF frontmatter parse (held for placement only, NOTE); binary attachment
    crash (didn't hold); criss-cross inner merge (didn't hold); install clobbering attributes or matching
    non-board paths (didn't hold: idempotent, CRLF .gitattributes fine, scope limited to *.lanework/ dirs);
    a broken interpreter path (held, NOTE).
  install:                  appends one line, '**/*.lanework/** merge=lanework', idempotent (ran twice).
    Writes merge.lanework.{name,driver,recursive} and merge.lanework-inner.{name,driver}, and silently
    overwrites an existing merge.lanework.driver. check-attr: a board file matches; a file named X.lanework,
    docs/y.lanework.md and Foo.lanework don't.
  merge comment:            line 1 is the header, one line per loss, the losing body in a markdown fence.
    Stamp {name: merge, kind: agent, session: "merge"}, validator clean.

UNRESOLVED:
  1. (d) Lane and board bodies: later wins, and the earlier text goes to .git/lanework-merge/lost-*.md,
     which is per clone and never committed. Should the owner get both inline instead (no thread to hold the
     loser), or a stop? The driver also turns non-overlapping lane edits that git would have merged into a
     loss.
  2. (e) On a clean driver-only pull, merge comments and blob.theirs.* stay untracked and out of the merge
     commit, so the other clone never sees them until someone commits. Accept this, or have the driver stop
     the merge (exit 1) whenever it records any loss, trading "no agent needed" for nothing left behind?
  3. (b) A card purged with rm on one side and edited on the other comes back, instead of the card's
     "leftover -> ours". I agree with keeping the edit, per "when in doubt, keep both edits"; the owner may
     want to know.
  (a) single-valued kinds as state and (c) refusing pairs whose created stamps differ: both agree with the
  spec and the guide. No ask.
```
