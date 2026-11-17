---
schema: 1
kind: comment
created:  {at: 2026-11-17T15:26:24Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T15:26:24Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: a card whose body holds `}}}` cannot be renewed, checked or released, and the exit codes it returns break the contract the four dependent cards build on. 9 notes.

- **Stance**: adversarial (a write-wait-read-back race between sessions, a detached timer rewriting card files, four cards on its exit codes)
- **Round**: 1
- **Card**: [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb)
- **Branch**: `lease-script` at `112c236`

**Blocking**

1. `skills/lanework/scripts/lease.sh:71 @ 112c236` "`grep -q '}}}' "$stage/index.md"`": the triple-brace guard reads the whole staged file, body included, so any body with `}}}` (a JSON example in a code fence, a label-config example) fails every lease write. Measured: a card that gains `{"a": {"b": {"c": 1}}}` in its body mid-lease → the timer silently stops renewing (`write_card set || true`); `check` on the lapsed own lease prints nothing and exits 1 (outside its 0/3/4); `renew` exits 1; `release` exits 1 and leaves `claimed` with the timer already killed, so the card stays held until a two-minute takeover. A fresh stake on such a card exits 1, which callers read as "held by another". Population: 7 of 2,323 cards on the Lanework repo boards have `}}}` in the body. Fix: guard the front matter only, as `file-ticket.sh` and `file-record.sh` do, and add a smoke case with `}}}` in the body.

**Questions for the lead**

1. `skills/lanework/scripts/lease.sh:223 @ 112c236` "`if [ -d "$MEM.lost" ]`": a staked card whose `claimed` the owner deletes (PDR Q17's "frees a card") gives `check` → `lost`, exit 3, a loss record, no further write; but `stake` first → exit 0, the session re-stakes silently, and a later `check` says `held`. Measured both orders. The body makes claimed-gone a loss for `check` and a quiet release for the timer. Is `stake` over a remembered card with `claimed` gone a loss (exit 3), or a fresh stake?
2. Fixer decision 6, `lease.sh:252` "`no lease on ${CID:0:8} to renew`": `renew` with no lease and no memory exits 1, the code the body reserves for "held by another". Keep 1, or treat it as usage (2)?

**Notes**

1. `lease.sh:103 @ 112c236` "`[ -d "$c/comments" ] || mkdir "$c/comments"`": check-then-mkdir. Two takers at once on a lapsed card with no comments: the loser dies on `mkdir: File exists` (exit 1 by `set -e`, before its notice) and leaves a `lease-comment.*` stage dir in `TMPDIR`. Measured 10 of 10 two-taker runs with one notice, one holder; the outcome is right by accident. In `lose()` the same race would mark the session lost with no record posted, since `mkdir "$MEM.lost"` runs first. `mkdir -p` fixes it.
2. `tests/smoke.sh:1944 @ 112c236` "`# 6. a changed by`": no case races the timer against `check` on a loss. A mutant with the `mkdir "$MEM.lost"` once-guard removed passes all 15 lease cases; my race (timer plus five concurrent `check` calls, 20 reps) catches it with 2 to 5 records in 6 of 20 reps. The real script gave exactly 1 in 20 of 20. Worth a smoke case: the trial counts these records.
3. `lease.sh:245 @ 112c236` "`[ -z "$IGNORED" ] || post_record`": a `claimed` with no `until` is voided and staked over, but no **Lease ignored** record is posted (the record keys on a non-empty `until`). An unreadable `until` (`soon`) does post one.
4. `lease.sh:52 @ 112c236` "`date -j -u -f %Y-%m-%dT%H:%M:%SZ`": a valid RFC 3339 `until` with fractional seconds or `+00:00` reads as unreadable, so a live lease in that shape is staked over at once, without the takeover wait. `lease.sh` writes only the `Z` form, so this only bites a hand-written or re-serialized lease.
5. `lease.sh:148 @ 112c236` "`git -C "$M_DIR" status --porcelain`": `git status` refreshes `.git/index` in the holder's worktree (measured: the index mtime moved on a loss). `git --no-optional-locks status` reads without writing.
6. `lease.sh:131 @ 112c236` "`grep -q -F 'lease.sh _timer'`": `is_timer` matches any lease timer. A memory file whose stale pid now belongs to another card's timer makes `release` kill that timer (measured with a planted pid; an unrelated process is safe). Matching `_timer <board> <card-uuid>` closes it.
7. `lease.sh:63 @ 112c236` "`awk -v m=`": a body with no trailing newline gains one on the first lease write. Every other body byte and every other key, in value and order, held over a stake, 50 renewals and a release.
8. CRLF card: stake exits 1 ("no frontmatter"), the "held by another" code, on a card the validator passes. `move-card.sh` refuses the same card, so it is not new. The exit code is the part a lease caller would misread.
9. `lease.sh:187 @ 112c236` "`printf '%s\t%s\t%s (%s)\t%s\t%s\n'`": the title sits mid-row. A literal tab in a title shifts the minutes column. Only a title the validator already rejects carries one. Putting the title last would make the row safe anyway.

**Checked**

- **Correctness vs done-when**: every subcommand against the body and the rulings (ADR Q1, Q2, Q3, Q4, Q7, Q9, Q11, Q12, Q14, Q18, Q21; PDR Q17, Q20; Q6, Q8, Q16, Q19). Measured on throwaway boards (a path with spaces), fake session ids, stand-in `CLAUDE_PID`s, a private `TMPDIR`:
  - race: 2, 5 and 10 sessions on one free card, 20 reps each at the real 1 s wait, with the machine loaded: 60 of 60 runs had exactly one exit 0, the rest exit 1, `by` the winner's, the body byte-identical, no loss record, a memory file for the winner only. A late writer starting inside the wait sees the live lease and exits 1. Writes are staged in `TMPDIR` and `mv`ed in, the path re-resolved before the `mv`.
  - lost lease: timer plus five `check` calls racing, 20 reps: 1 record each time. Wording exact; it opens with `LEASE_LOST_PREFIX`, names branch, directory and files, and passes `lint-ask.sh` as a record. Afterwards `stake`, `renew`, `check`, `release` all exit 3 and change nothing.
  - clock guard: 34 min and 35 min minus 3 s hold (exit 1); 35 min plus 3 s, 36 min and an unreadable `until` are voided, staked over, **Lease ignored** posted; a past `until` goes through takeover. BSD `date -j -f` only.
  - takeover: notice wording exact; the holder's timer answers a notice naming it within one poll and ignores an older notice and one naming another session; `by` changed in the wait → exit 1 with the notice kept.
  - `check`: held, lost and never-held with exit 0, 3 and 4; never-held writes nothing to the card or to `TMPDIR`; another `by.name` under the same session is held. Fixer decision 7 (own lease, no memory → held, memory rebuilt) matches ADR Q21.
  - timer: one per session and card after stake, stake, check; survives the staking shell (reparented to pid 1); exits on release, loss, `CLAUDE_PID` gone, card deleted or trashed; follows the card to another lane by uuid and keeps renewing there; renews by counted polls.
  - exit codes: 21 usage cases (no model, no session id, empty id, no `CLAUDE_PID` on `stake` only, unknown uuid, uuid in two lanes, uppercase or short uuid, bad subcommand, `--force` off `release`, list arity) all exit 2, messages on stderr, stdout empty.
  - `list` on Skills Pipeline and Card Lease Discovery: exit 0, no output, checksums of every file identical before and after.
- **Project conduct**: no `git add`, `commit` or `stash` in the script (HEAD and stash list unchanged across a loss); bash 3.2.57 `-n` clean; no `declare -A`, `mapfile`, `${x,,}`, GNU `date -d`, bare `sed -i`, `setsid`, `timeout` or `flock`. `plugin.json` and `CHANGELOG.md` untouched. No "couldn't resolve X, so assume Y".
- **Both paths**: timer and `check` both find a loss, one record either way. Claimed-gone splits between `check` and `stake` (question 1).
- **Fail-before**: OWN RUN agreed with FIXER RUN: the 15 lease cases against the merge-base `5e7519f` stop at case 1 with `lease.sh: No such file or directory`.
- **Test adequacy**: 15 named cases beside their neighbours; 10 isolated runs, 15 of 15 each, while other load ran, so no timing flake seen. Eight mutants of a copy: the read-back skipped, the guard dropped, `by.name` compared, no notice answer and no notice wait each fail a case; renewing by wall clock fails case 8 (indirectly). The post-twice mutant survives (note 2). The no-stop-on-release mutant survives because the timer exits by itself once its memory file is gone: an equivalent mutant.
- **Blast radius**: 7 files, as the body's Files list (no CHANGELOG, by the lead's START). `writes.md` § Lease states each rule once, telegraphic, no test knobs, no guide version, no live `dispatch`; nothing else under `skills/` restates it. SKILL.md rows in. README row in; counts 382, 1,896 and 5,125 match `wc -w`. The merge row asserts the later side's `claimed` whole and no merge comment, per the lead's Q6 ruling.
- **Population**: race 60 runs over 3 sizes; loss race 20 reps; `}}}` 7 of 2,323 cards; usage 21 cases. Full gate in the fixer's worktree at `112c236`: `smoke: 198 passed`, exit 0, 225 s. `pgrep -fl lease.sh` afterwards: empty. Nothing under the real `TMPDIR` or `/tmp` `lanework-lease`.

**Hypotheses**, written after the card, the whole thread and the diff, before the fixer's attachments and logs (the thread includes the fixer's closing [record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb), read in the thread pass). 4 of 10 held in full, 3 in part.

1. N≥5 racers spread past the 1 s wait and two win: refuted, 60 of 60 single winners.
2. The `}}}` guard spans the body and blocks lease writes: held (blocking 1).
3. A CRLF card cannot be staked: held (note 8).
4. `stake` ignores memory when `claimed` is gone: held (question 1).
5. Two takers post two notices in one second: refuted; found the `mkdir` race instead (note 1).
6. Timer and `check` double-post a loss: refuted for the script; held for smoke's power to see it (note 2).
7. `git status` writes the index: held (note 5).
8. The timer loses a card moved to another lane: refuted.
9. A reused pid makes `release` kill the wrong process: in part, another timer only (note 6).
10. `list` rows break on a tab in a title: in part, invalid titles only (note 9).
