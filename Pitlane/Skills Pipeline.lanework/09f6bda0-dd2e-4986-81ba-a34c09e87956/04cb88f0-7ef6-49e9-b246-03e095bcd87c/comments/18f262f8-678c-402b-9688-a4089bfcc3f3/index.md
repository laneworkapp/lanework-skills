---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:26:56Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:26:56Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review: REQUEST-CHANGES, one blocking finding. The new find misses a board folder that is a symlink; everything else holds, and the lead's plan works if the two steps ship in one push.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none"; moves a board folder = persisted data)
ROUND:   1

CARD:   Active/04cb88f0 "Boards folder: Lanework, then Boards, then legacy Pitlane"
BRANCH: boards-folder at 6e3c26c (reviewed as merging: 3bfc96b)

BLOCKING: 1
  skills/lanework/references/finding.md:15 @ 3bfc96b "find \"$r/$f\" -maxdepth 1 -name '*.lanework'":
  BSD find runs -P by default and does not follow a symlinked start path. If ~/Lanework (or a repo's
  Lanework/) is a symlink, for example into iCloud or Dropbox, it prints nothing. Reproduced: link
  home/Lanework -> real/ holding "Sym Board.lanework" gives no output. The old
  `ls -d ~/Pitlane/*.lanework` found it. Result: sweep skips those boards without saying so, and /watch
  by name says "no match". Fix: `find -H ...`, or a trailing slash `"$r/$f/"`. Both checked: found.

NOTES: 8
  finding.md:15 @ 3bfc96b "2>/dev/null; done; done": the loop's status is that of the last find, so it
  exits 1 whenever ~/Pitlane is missing, which is the normal case after a move. An agent may read that
  as a failure. Append `; true`. Also, without `-type d` it matches a file named x.lanework (seen in
  Boards/), and order inside one folder is directory order, not sorted (Z before a). Both are minor.
  finding.md:26 @ 3bfc96b "at one level (repo or `~/`)": the per-level reading fits the card ("move it",
  git mv for a repo, mv for ~/Pitlane/). The owner could read "only under Pitlane/" as covering the whole
  project, though. The divergent case is a repo with Lanework/ and Pitlane/ both holding boards: no
  offer, so the legacy folder stays. That state doesn't arise on its own, because new boards go into the
  first folder that exists. The lead should confirm it with the owner.
  finding.md:28 @ 3bfc96b "`git mv` the folder, commit the move on its own": this gives no caution
  about open worktrees or other sessions writing under Pitlane/, which is the same collision the lead is
  avoiding here. Consider "after open worktrees merge".
  skills/watch/references/arming.md:15 @ 3bfc96b "(`lanework/references/finding.md`)": sweep.md's pointer
  names "legacy offer", but arming's doesn't. The card's Verify expects the offer to fire on /watch with no
  argument, and the offer should come before arming, since a move forces a re-arm. Adding "legacy offer
  first" to the pointer would cover it.
  tests/smoke.sh:33 @ 3bfc96b "grep -n 'Lanework/' \"$F\" | head -1": this order check reads only the table.
  Swapping the find loop to `Boards Lanework Pitlane` still passes (tested). The legacy check is sound:
  a "legacy" line in sweep.md fails, and a non-legacy Pitlane line in finding.md fails. Any finding.md
  line with "legacy" on it passes, but that is bounded to one file.
  finding.md:15 @ 3bfc96b "\"<repo root>\"": from a subdirectory this is still a placeholder, and the
  same was true before the change. From a git worktree, the worktree root holds a stale copy of the board.
  Not from this diff.
  skills/lanework/references/founding.md:9 @ 3bfc96b "Path: `<repo root>/<folder>/<Name>.lanework`": it
  omits ~/ boards, which finding.md covers. A nit.
  ORDER, for the lead's plan: once commit 1 is on main with the board still under Pitlane/, smoke fails
  at VAL (rc 2, can't open Lanework/.../lanework-validate.py). CI runs on every push to main, release.sh
  runs smoke, and sessions branched in that window go red. Also, main's CLAUDE.md would name
  Lanework/Skills Pipeline.lanework while the board is still under Pitlane/, so another session could
  fire the legacy offer itself. Do the merge and the hand `git mv` back to back, and push them together,
  so origin/main is never red.

CHECKED:
  correctness vs done-when: the grep of skills for Pitlane hits only finding.md:9 and :15, both
    "legacy" lines. The release check uses scratch-repo pathspecs. A pending change under Lanework/ or
    Pitlane/ is exempt. LaneworkX/, PitlaneNotes/, Lanework.txt and src/ are all reported:
    a pathspec matches whole path parts only, so no real non-board path is wrongly exempted.
    release.sh cds to ROOT first.
  project conduct: telegraphic where agent-facing. README is user prose, accurate, and names Pitlane
    only as the old name. CLAUDE.md has both paths updated. Board writes and skill changes are in
    separate commits, and the repo's .gitignore is untouched.
  both paths: repo and ~/ levels, bash and zsh (both -c and -i): same output, spaces in names fine.
    The symlink path is the BLOCKING finding.
  fail-before: OWN RUN agreed. The branch's tests/smoke.sh run over a bf8e2e0 tree exits 1 with "Pitlane
    named outside finding.md's legacy entry" (sweep.md:8, arming.md:14-15, finding.md:5,6,9,10,14).
  test adequacy: inline in smoke.sh after the matching rename check, in the same style.
  blast radius: commit 1 changes the 8 files the plan named, and commit 2 is renames only.
  population: smoke at 6e3c26c (archive copy) gives "smoke: 31 passed", rc 0. 3bfc96b alone fails only
    at VAL (rc 2). For the lead's plan, a scratch clone with current main 759b1fe merged with 3bfc96b
    (clean), then a hand `git mv Pitlane Lanework`, gives 31 passed, rc 0. The untracked files under the
    board (a comment dir, .tracker.nosync/) moved with it. Nothing in CLAUDE.md, README, release.sh
    or smoke depends on commit 2 itself.
  adversarial only: hypotheses written first. Held: symlink miss (BLOCKING), file match, non-zero exit,
    weak order check, red interval. Didn't hold: the zsh comment breaking (it works in zsh -i
    here), the pathspec over-matching, a stale Pitlane in another skill (discovery/board.md points at
    finding.md).

UNRESOLVED: is the offer per level (the fixer's reading) or project-wide (repo plus ~/)? Owner's call.
```
