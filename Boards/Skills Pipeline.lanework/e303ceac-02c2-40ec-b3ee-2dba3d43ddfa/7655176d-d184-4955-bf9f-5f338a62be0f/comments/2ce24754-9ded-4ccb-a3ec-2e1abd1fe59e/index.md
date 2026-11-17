---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:16:46Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:16:46Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** Two blocking findings: a killed `commit-board.sh` leaves the owner's index staging a reversal of the board commit, and the same-second smoke case misses its mutant about half the time. Plus 6 notes.

- **Stance**: adversarial. Trigger: the branch ships four scripts that write boards for every plugin user, and one of them commits, un-commits and pushes under a lock.
- **Round**: 1
- **Card**: [Work skill: ship move-card, post-ask and commit-board helpers](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f)
- **Branch**: `work-helpers` at `f8ce9f7` (`f8ce9f71b615267a08c2b8dee7193278b71009ba`), merge-base `2023143`

**Blocking**

1. `skills/work/scripts/commit-board.sh:143 @ f8ce9f7` "`if git push -q origin "$BRANCH" 2>"$STAGE/push.err"`", together with `:150` "`git reset -q -- "${ADD[@]}"`". The real index is synced only after the whole push loop. A kill after the commit and before line 150 leaves HEAD at the new commit while the real index still holds the old content of the named paths. Measured in a temp repo with a bare origin and a `pre-push` hook that sleeps 5 s, then SIGTERM, and separately SIGKILL, 2 s in. Both runs left HEAD at the new commit, `git status` showed `MM` on the card's `index.md`, and `git diff --cached` showed the reversal staged. The owner's next plain `git commit` then silently reverts the board write. A push waiting on the network or a credential prompt, killed by an agent harness timeout, is exactly this state. Fix: run `git reset -q -- <paths>` right after `git commit`, and again after each un-commit, so the index matches HEAD at every point a kill can land. The line-150 reset then only confirms it.
2. `tests/smoke.sh:1554 @ f8ce9f7` "`R1=$("$SK/work/scripts/post-comment.sh" "$WB" "$C1F" --body "$T/pc.md" --model smoke)`". Done-when 4 is not met for D6 (the ask lands in the record's second). Case 157 posts the record at the clock second and the ask straight after. With the wait removed (`post-ask.sh:72` replaced by `:`), the record and ask still fall in different seconds about half the time, and the case passes. Measured: the mutant failed 3 of 6 runs of record then ask. Fix: post the record with `--ahead 1`. The no-wait mutant then lands the ask before the record every time, and `[[ "$AA" > "$RA" ]]` fails deterministically.

**Questions for the lead**

1. Spec gap on file-card. The body's verification bullet "the caller's own value of a `single` kind wins" is unreachable under the body's own design ("Takes only the flags above"), because the caller cannot pass a label. The fixer's substitute (two lane values of one `single` kind keep the lowest rank) is a different rule, so it is not a faithful stand-in. Record the gap on the card, or drop the bullet. The rule is still cited in `lanework/references/writes.md` § Placing for hand-written cards.

**Notes**

1. `skills/work/scripts/commit-board.sh:43 @ f8ce9f7` "`os.path.realpath(sys.argv[1])`": a symlink inside the work tree is resolved to its target, so the target is committed and the link is not. Measured: naming `B/link.md` (pointing to `lane a/card1/index.md`) committed the card file, and the link stayed untracked. Rare on boards. Use `abspath` plus a realpath check on the parent only.
2. `commit-board.sh:49 @ f8ce9f7` "`*[\*\?\[]*`": a real path containing `[` or `?` is refused as a glob, even though `GIT_LITERAL_PATHSPECS=1` already makes it literal. Measured on `lane [x]/i.md`, exit 1. Refuse only when the path does not exist and was not in HEAD.
3. `commit-board.sh:30 @ f8ce9f7` "`TRAILER="$2"; shift 2`": `--trailer` given twice keeps the last one silently (measured: `B: 2` only). Either refuse a second one or keep both.
4. `commit-board.sh:115-116 @ f8ce9f7` "`changed on both sides:`": on a diverged branch with no overlapping file, the message ends in an empty list (measured). Print "none" so the reader knows the files were checked.
5. All three new parsers, like `post-comment.sh`, exit 1, not the documented 2, on a flag with no value (`${2:?…}`). Measured: `move-card.sh … --model` gives rc 1, `post-ask.sh … --for` gives rc 1. This is inherited, so fix it in all four together if at all.
6. `skills/work/templates/ask.md:3 @ f8ce9f7` "`Post with scripts/post-comment.sh --ahead 1`": this now contradicts `writing.md` § The ask, which says to post with `post-ask.sh`. The template is what agents fill in. Cite `post-ask.sh` there, leaving `post-comment.sh --ahead 1` only for the multi-handle case writing.md already names.

**Checked**

- **Correctness vs done-when**: all four scripts exist, are executable and are `bash -n` clean under `/bin/bash` 3.2.57. No `mapfile`, `readarray`, `${x,,}`, `sed -i`, `date -d` or `realpath` binary (only Python's `os.path.realpath`). Each sources `lib.sh` through a symlinked `work` folder (measured, with and without `lanework` symlinked beside it).
  - commit-board: staged-but-unrelated `notes.txt` stayed staged and uncommitted, untracked files were left alone, and the stash count did not change. Run from a subdirectory with a space-named board, it committed the right path. A multi-line message with quotes went through `-F` intact. No trailer is added unless `--trailer` is given. It never stashes and never runs `add -A` without paths.
  - commit-board paths: `..` was normalised, a moved card was committed as `R100`, a deleted card as `D`, and a symlink pointing outside the tree was refused. Detached HEAD gave exit 1. With no origin it committed locally, and `--push` with no origin gave exit 1.
  - commit-board locking: six concurrent `--push` runs gave six commits, origin equal to HEAD, all serialised on one lock. A lock with a dead pid was reclaimed. A pid-less empty dir was taken at once (rename onto an empty dir). An empty pid file was reclaimed after the 10 s mtime grace. A linked worktree waits on the common-dir lock, then pushes its own branch. SIGTERM runs the EXIT trap and removes the lock. SIGKILL leaves a dead-pid lock, reclaimed on the next run, plus a stage dir under `TMPDIR`, not in the repo.
  - move-card: block-form `modified` and `waiting` were rewritten and dropped whole. Body lines `---`, `order: 5`, `waiting: x` and `modified: y` came through byte-identical. `--top` over a lowest of 1 gives 0.5. Two prefix matches exit 2. A `--comment` failing lint, and a same-second `--comment`, both exit 1 with the card unmoved and no comment written.
  - post-ask: `waiting: {for, since, comment}` matches the guide's § Mentions shape, with `since` equal to the ask's `created.at`. An earlier `waiting` is replaced, which is documented. The template's own filled example passes for `--for kim` and for `--for anyone`, so the double lint refuses nothing the guide allows. The no-board lint is what checks an ask to a person other than the owner.
  - file-card: a title with quotes, a colon and backslashes parses back exactly through YAML.
- **Project conduct**: `plugin.json` is untouched, and there is no Version line in CHANGELOG. The one CHANGELOG sentence is user-facing. Prose cites the scripts rather than restating them (`SKILL.md` one line, `writes.md` § Moving and § Git one line each, `traps.md` two Shell rows). The `writes.md` § Placing addition is right, because `file-card.sh` does union lane defaults. README § Sizes matches `wc -w` (434, 445, 1,317, 1,184; `check-sizes.sh` is in smoke). Board writes and skill changes are in separate commits.
- **Both paths**: push on and off, push with and without unpushed earlier commits, main checkout and linked worktree all exercised. The one unhandled path is the kill window (Blocking 1).
- **Fail-before**: FIXER RUN checked (merge-base smoke stops after `ok 149`, harness wiring only). OWN RUN by mutation instead of a scratch merge-base: the no-wait mutant of `post-ask.sh` escaped 3 of 6 runs (Blocking 2). Trailer, push default, `.DS_Store`, lock reclaim and prefix were REASONED from the case text: each asserts the exact observable a mutant would change (message body equals the subject, origin sha unchanged, rc 1 with no global excludes, 20 s alarm against a 300 s wait, rc 2).
- **Test adequacy**: 15 cases (150–164) sit beside the existing script cases in `tests/smoke.sh`, all on throwaway copies. git runs with `GIT_CONFIG_GLOBAL=/dev/null`, `GIT_CONFIG_NOSYSTEM=1` and a local identity. Nothing touches the repo or the real board beyond reading `.schema`. The D1–D14 to case map in the fixer's report reads true case by case.
- **Blast radius**: 11 files, matching the body's Files touched, with no `lib.sh` change. The extras (glob and `comments/.draft` refusal, skipping a never-committed path, § Placing) are recorded in the fixer's report.
- **Population**: smoke run in the fixer's worktree printed `smoke: 167 passed` (152 before, plus 15). The mutant result is 3 failures over 6 runs.
- **Accepted limitations**: `--push` carrying earlier unpushed commits is accepted. Measured: a rejected push with one unpushed commit un-committed only its own commit (compare-and-swap `update-ref`), then stopped on divergence, with the earlier commit and the work-tree content intact. The `kill -0` misread of a reused pid is accepted: the run waits 300 s and exits 1 with nothing committed.

**Hypotheses**, written before reading [the fail-before record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/09f6bda0-dd2e-4986-81ba-a34c09e87956/7655176d-d184-4955-bf9f-5f338a62be0f/2c192613-124b-4f29-baf6-7cc8d3dc9669) and [the build record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/09f6bda0-dd2e-4986-81ba-a34c09e87956/7655176d-d184-4955-bf9f-5f338a62be0f/65c3cda2-f07d-4866-a4b2-d2de68f45d87). 4 of 12 held, one more by design.

1. A kill between commit and the closing reset leaves the index staging a reversal: held (Blocking 1).
2. A rejected push with earlier unpushed commits drops a foreign commit: refuted.
3. A push the remote accepted but reported as failed leaves the local branch behind: not run.
4. The reclaim race lets a third waiter in while a live lock is moved aside: reasoned only. The window is microseconds, and the loser stops on `mine`.
5. A symlink is committed as its target: held (Note 1).
6. `--trailer` twice silently keeps the last: held (Note 3).
7. `--comment` is posted and the move then refused: refuted.
8. A flag with no value exits 1, not 2: held (Note 5).
9. The second lint refuses asks the guide allows: refuted.
10. post-ask clobbers an existing `waiting`: by design and documented.
11. A file-card title breaks YAML: refuted.
12. SIGTERM skips the EXIT trap: refuted.
