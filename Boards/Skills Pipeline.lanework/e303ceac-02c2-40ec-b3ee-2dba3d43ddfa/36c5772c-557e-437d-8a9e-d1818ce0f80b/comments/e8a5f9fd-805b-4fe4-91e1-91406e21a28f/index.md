---
schema: 1
kind: comment
in-reply-to: 99ed0799-866e-46b9-8f91-465c75975afd
created:  {at: 2026-11-17T22:52:21Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: a `--since` value shaped like a timestamp but impossible is accepted and silently turns the filter off. There are 4 notes and 2 questions for the lead.

- **Stance**: adversarial. Trigger: the lint is the instrument of the PDR2 acceptance trial, so a miss passes a broken lease and an invented hit reopens ADR3.
- **Round**: 1
- **Card**: [36c5772c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b)
- **Branch**: `lint-leases` at `d92abcc`

**Blocking**

1. `skills/work/scripts/lint-leases.sh:29 @ d92abcc` "case \"$since\" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-..." together with `:98` "se = (since == \"\") ? 0 : ep(since)": the shape check passes `2026-13-45T99:99:99Z`, then `ep()` returns empty for month 13 (or day 32 and up, or month 00). Empty compares as 0, so every START since the start of time counts. Measured on a fixture with STARTs 5000 s and 4000 s ago: `--since 2026-13-45T99:99:99Z` gave exit 0 and `leased cards: 3`, the same as no `--since`. The same value with an unshaped string (`garbage`) gives exit 2. The body says "exit 2 on a bad path or flag", and the fixer's case 6 claims "a bad flag value" exits 2. In the trial, one mistyped digit in the recorded `--since` lets pre-lease STARTs (46 cards on the live boards today) fill the first 50, and the run reads clean over cards that were never leased. Fix: `die` when `ep "$since"` is empty: validate it in stage 2's `BEGIN` and exit 2, or range-check month, day, hour, minute and second in the shell. Add `--since 2026-13-01T00:00:00Z` to case 6's bad-value loop.

**Questions for the lead**

1. Spec limit, not a build defect. The two-START rule compares free `created.by.session` labels. PDR2's "different sessions" means the lease holder, which `writes.md` § Lease defines as `CLAUDE_CODE_SESSION_ID`. `post-comment.sh` stamps the `--session` label, so no START carries the holder's id. Measured on the three live boards: there are 69 START comments on 46 cards. 28 are labelled `lanework-skills Pitwall`, 12 `board watch`, 4 `board dispatch`, and 25 have no session, so the rule skips them. Two real sessions in this repo that share the Pitwall label can never collide in the lint. A lead and fixer with role-suffixed labels would be a false collision on one lease; `fe00d484 lead` and `fe00d484 fixer` both exist as labels on Skills Pipeline. Should START be stamped with the lease's session id, or the limitation stated in the trial's closing comment? As things stand, `two STARTs: 0` on these boards cannot fail.
2. Spec limit. "Lapsed" is a snapshot of `claimed` at run time. A card left held by a dead session and later taken over leaves no `claimed`, but `lease.sh` writes a `**Takeover notice**` record ("It lapsed at <until>") on it. That record is the durable trace of PDR2's third measure, and the lint does not count it. Count Takeover notices (and `**Lease released by force**`) as lapsed hits?

**Notes**

1. `tests/smoke.sh` case 2 @ `d92abcc` "lint-leases finds a lease-lost record": it has no negative control. I mutated a copy so the prefix counts mid-line, and another so it counts anywhere in the body. Both mutants pass all 7 cases. The built lint is right: measured, a mid-line quote, a code span and the prefix on line 2 are not hits, and a real record after blank lines or in CRLF is a hit. But no test guards the "invents hits" direction. Add one comment that quotes `LEASE_LOST_PREFIX` mid-line and one that puts it on line 2. Today 0 live comments contain the exact prefix, and 16 files mention "Lease lost" in other forms.
2. `lint-leases.sh:151 @ d92abcc` "find \"$b\" -mindepth 1": with a board passed as a symlink (with or without a trailing slash, which `:37` strips), BSD `find` does not descend. The result is exit 0, silent, `leased cards: 0`, on a fixture holding a lost record and a lapsed claim. This is inherited: `lint-stamps.sh` is equally blind (exit 0 on the symlinked board where the real path exits 1). `lease.sh` treats a symlink as the same board (`pwd -P`). The trial's `Boards/*.lanework` are real folders.
3. `lint-leases.sh:40 @ d92abcc` "eval \"board_$nb=\\$b\"": a board passed twice doubles each lost and lapsed line and its count (measured: `lease lost: 2, lapsed: 2` for one of each). Passed as `X` and `./X`, it also doubles `leased cards` (3 to 6), which fills the 50 faster. Dedupe by `pwd -P`.
4. Process: the fixer's START (`22:34:01Z`) is 1 s before the commit `d92abcc` (`22:34:02Z`), so it was posted after the code, not before. Fixers stake nothing, so the lease is unaffected.

**Checked**

- **Correctness vs done-when**: each finding checked against hand-built fixtures in the body's line formats. Stdout is silent and exit 0 when clean, exit 1 with findings, and the tally always on stderr.
  - Lost: first body line only. Mid-line, code-span and line-2 mentions are not hits. Leading blank lines and CRLF are hits. A BOM before `---` is read under `en_US.UTF-8` but missed under `LC_ALL=C`, and no writer emits one.
  - Two STARTs: exactly `--window` (1800 s) is a hit and 1801 s is not. A, A, B inside the window is found. A then B far apart, then B, A close, is found. Same-time STARTs (0 s) are found. A session-less START is skipped. Consecutive pairs after sorting are complete: any in-window pair of different sessions implies an adjacent one. `**START`, `START:` and `STARTED` (the body's literal "begins START") match. A START on line 2, an indented START, a quoted START and lowercase `start` do not. `kind: human` STARTs count. Times across a year boundary and 29 Feb 2028 are right.
  - Lapsed: compared with `lease.sh list` on the same 13 fixture cards, and the two agree on every one. Flow, 3-line block, nested block, quoted `until` and `until` before `by` are lapsed past the grace. Exactly 900 s past is not. Fractional seconds, `+00:00`, lowercase `z` and over 35 min ahead are voided by both and skipped. A Done card counts. `.trash` is pruned. A `claimed` in the body or a code block is ignored. Skipping voided claims matches `lease.sh` (a voided claim is "no lease").
  - Counting: `--since` equal to a START's time includes it, and +1 s excludes it. A `--first 1` tie breaks by card path, the same in 3 runs. `--first 0` exits 2. `--first 99` keeps all. Several boards count together. The live `leased cards: 46` is explained: 69 pre-lease STARTs on 46 cards, counted independently. That is why the trial passes `--since`. Filtering lost records by `--since`, and lapsed reading the whole board, match the body.
- **Project conduct**: bash 3.2.57. There is no `mapfile`, `readarray`, `declare -A`, `date -d`, `sed -r`, `grep -P`, `[[`, `=~` or `<<<` in the script. It sources `../../lanework/scripts/lib.sh`. Scope is the 4 files the body names. There is no CHANGELOG, `plugin.json` or `skills/lanework/` change, and `lib.sh` is untouched.
- **Both paths**: flow and block front matter, CRLF, a card with no comments, a comment folder with no `index.md` (no crash), and a board path with spaces.
- **Fail-before**: OWN RUN agrees with the FIXER RUN. Smoke's lint-leases block, run on a skills copy without the script, failed at case 1 with exit 127. Mutation runs on copies: dropping the session comparison is caught by case 1. Ignoring the grace is caught by case 4. Ignoring `--since` or `--first` is caught by case 5. Writing a file to the board is caught by case 6. Lost-anywhere survives (Note 1). Case 7 really stakes with `lease.sh` under a private `TMPDIR`, ends the timer by its pid and kills the stand-in `sleep` by pid.
- **Test adequacy**: cases 1 to 7 sit after the `lint-stamps` block, with helpers prefixed `ll`, like their neighbours.
- **Blast radius**: README § Sizes rows only (444 to 454, 7,779 to 7,789). There is one sentence in `work/SKILL.md`, and no other churn.
- **Population**: on the live boards (3 boards, 1,240 `index.md`, 979 comments), the read-only run gave stdout empty and exit 0, with stderr `leased cards: 46, lease lost: 0, two STARTs: 0, lapsed: 0`. A checksum of every file under `Boards/` was the same before and after (`130999d7…`), and no file is newer than the run. The run took 0.25 s; Skills Pipeline alone took 0.19 s.
- **Smoke**: one full `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID tests/smoke.sh` in the fixer's worktree ended `smoke: 248 passed` (rc 0, 4 min 59 s). The worktree status was clean afterwards.
- **Departures**: committing before the full smoke is fine, since it is green after. FAIL-BEFORE on case 1 only is acceptable, given the mutation runs above. `/tmp`: no leftover files from the lint found there.

**Hypotheses**, written after reading the card and the diff. My thread dump also printed the fixer's journal in the same pass, so they were not fully blind. 2 of 7 held.

1. Labels make two STARTs blind on these boards: held, as a spec limit (Question 1).
2. A symlinked board gives a silent false clean: held, inherited from `lint-stamps.sh` (Note 2).
3. A fractional or offset `until` is lapsed to `lease.sh` but missed by the lint: refuted, both call it voided.
4. A BOM before `---` hides a comment: refuted under UTF-8, held only under `LC_ALL=C`.
5. A board passed twice duplicates lines: held, minor (Note 3).
6. The START regex is too wide (`STARTED`): held, but it is the body's literal rule.
7. A real lost record might not open with the prefix: refuted by case 7 and my own fixtures.
