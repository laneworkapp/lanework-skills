---
schema: 1
kind: card
title: "Review leftovers 3: Recap-click edges, lease memory file, commit-board setsid, smoke guard"
order: 5120
labels:
  - {text: "discovery", kind: {type: "skill", text: "Skill"}}
  - {text: "lanework", kind: {type: "skill", text: "Skill"}}
  - {text: "work", kind: {type: "skill", text: "Skill"}}
  - {text: "repo", kind: {type: "skill", text: "Skill"}}
created:  {at: 2026-11-21T19:23:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T03:47:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-23T04:17:25Z
---
Reviewer notes left open when several cards closed on 2026-11-21 and 2026-11-22 (Recap click, smoke under load, commit-board leftovers, label-card, lease write path, script headers, lint output, lease trial). They were never re-checked. This card re-checked every one against `main` at 6e04933: 21 are still true, none is already fixed, 2 could not be settled by reading, and 3 are reviewer-confirmed non-defects to close with a reason. No item blocks a release. The fixes are small and spread over four scripts, `tests/smoke.sh` and the headers of a dozen scripts, so the proposal splits them into three build cards.

## Items

Status key: T = still true on main, ND = not determined, R = rule out (no change). "Run" means a throwaway board or function under `mktemp -d`.

**`discovery/scripts/settle-question.sh`**

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| BOM before `Recap:` | T. Run: `is_recap_click` (`:47-55`) returns 1 for a BOM before the frontmatter and for a BOM before the body line; only `\r` is stripped (`:48`) | strip a leading `\xEF\xBB\xBF` in the awk first line and body line | `Recap:` click saved with a BOM: settle refuses without `--record`. Fails before |
| No case for an agent record starting `Recap:` | T. `tests/smoke.sh:460-478` uses owner comments only. Run: an agent-authored one returns 1 (correct), but nothing pins it | none to the script | an agent comment `Recap: x` plus a real owner answer: counts as the record's own, so settle must not treat it as a click. A mutant that skips it by body alone fails |
| Broken pipe over about 64 KB | T. Run: a real click with a 200 KB body returns 141 (`tr` dies under pipefail after awk exits early), so it is read as not a click and settles | read the first body line without the early exit: `awk` reads all, or `head -c` bounded before it, or `\|\| true` on `tr` | click with a 200 KB second line: refused. Fails before |
| Settle after click with `waiting` cleared | T. `:95` runs the lint only when `WAITING=1`; no other guard | with `waiting` absent, run the lint anyway when the card has an ask and only a click after it, or refuse and name `--record` | card, ask, click, `waiting` removed: settle without `--record` exits 1. Fails before |

**`lanework/scripts/lease.sh`**

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| `mem_save` in the notice branch resurrects the file after release | T. `:240` checks `$MEM` once, `:248` saves later; `release` does `rm -f "$MEM"` (`:355`) after only a `kill` of the timer | re-check `[ -f "$MEM" ]` and `M_PID` just before the save, and save only under that check | R as a deterministic case: the window is microseconds. Rule out unless a `LEASE_TEST_*` pause hook is added (the script already has `LEASE_TEST_WRITE_PAUSE`); recommend the code fix without a case |
| `mem_load`, `mem_save` end the timer under `set -e` | T. `:31` `set -euo`, `:170-184` unguarded, called at `:240`, `:248` | `mem_load \|\| exit 0`; `mem_save \|\| true` in the timer only | `LEASE_TEST_POLL=1`: stake, `chmod 500` the memory dir, wait two polls, restore, assert the timer pid still lives. Fails before |

**`work/scripts/commit-board.sh`** (`push_bounded`, `:159-167`)

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| `POSIX::setsid()` unchecked | T. `:161` | `POSIX::setsid() or POSIX::_exit(126)` | R: setsid cannot be made to fail in a fresh forked child; say so in the thread |
| Fallback that signals the child alone has no case | T. `grep` of smoke finds none | none | R: the window is before `setsid`, a few microseconds. Same hook-free reasoning as above |
| TERM or HUP before handlers are installed | T. handlers set at `:162`, after the fork at `:160` | block INT, TERM, HUP with `POSIX::sigprocmask` before the fork, install handlers, unblock; the child unblocks before `exec` (a mask survives `exec`) | R: not reproducible deterministically. Keep the existing `:2688`-`:2736` cases green |

**`work/scripts/label-card.sh`**

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| Test hook gives up after about 20 s | T. `:84` runs 400 x 0.05 s. Effect is a flake, not a false pass: past 20 s the script compares an unchanged card, lands, and `tests/smoke.sh:2418-2423` fails on `rc` | on expiry print "hold expired" and exit 1 so a slow run fails loudly and names the cause | none new; the existing case covers it |

**`tests/smoke.sh`**

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| Early-reader guard misses `sed q`, `awk exit`, `\| read`, a variable call | T. `EC` at `:59` matches `head` and `grep -[a-zA-Z]*[qm]` only | add `sed [0-9]*q`, `awk .* exit`, `read -r` to the pattern; extend the two samples at `:60-62` | the guard's own self-check samples (a failing sample fails the run). The variable-call form cannot be matched by a pattern: R for that one |
| `bq()` discards the exit code | T. `:802` `o=$(...)` with no `\|\| return` | reuse `bfirst` (`:56`), which returns the script's code | a `bfirst`-style self-check: `! bq` over a failing stub, as `:57` does for `bfirst` |

**`lanework/scripts/lib.sh` `board_index_files`** (`:413-447`)

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| The fallback `cd` redirect has no case | T. Redirect is present at `:440`. Run: with it removed, a `CDPATH=.:`, relative path, newline-named card and sibling-symlinked lane lists `zz/card\ntwo` and `zz/plain` a second time. Smoke `:1427-1430` uses no newline name, so it takes the fast path | none to the script | that board under `CDPATH`: the list holds each card once. Fails on the mutant |
| Fallback runs only when counts differ | ND. Reasoned in the review, never reproduced; `:436` confirms the condition | fall back when any listed path holds a newline | would need a folder that vanishes between `find` and `realpath`; settle by trying a deletion in a loop on a throwaway board, else R |

**Comment notes**

| item | status, evidence | fix | smoke case |
|---|---|---|---|
| `lint-leases.sh` reports a shaping handoff as `two STARTs` | T. Run: `START (shaping)` then `START` 878 s apart, different sessions: `two STARTs a1 a2 878s apart`, exit 1. Code at S2 `:134-140` | skip a START whose first line begins `START (shaping)` (S1 `:79`) | that board: no finding, exit 0. Fails before |
| Mixed exit codes for an unreadable file | T. `file-card.sh` and `found-board.sh` exit 1 (`found-board.sh:40-41`), the other five exit 2 | align to 2, update the two headers | `file-card.sh --body /nope`: exit 2. Fails before. See Open calls |
| Seven scripts omit the usage line on an unknown flag | T. `file-ticket.sh:35`, `claim-ticket.sh:31`, `resolve-ticket.sh:35`, `file-record.sh:35`, `file-question.sh:34`, `settle-question.sh:33`, `merge-board.sh:20` print one line | add `echo "usage: $USAGE" >&2` as `commit-board.sh:67` does | one loop over the seven: stderr holds `usage:`. Fails before |
| Header omissions | `claim-ticket.sh` T (`:7-12` omits not a board, not a uuid, no lane); `heal-descriptors.py` T (`:14-16` omits "reserved and empty `--name` only with `--apply`"); `move-card.sh` T (`:15-18` omits an existing destination and a bad prefix); `heal-board.py` ND (docstring exit list not matched to the code) | edit the headers | none; `tests/smoke.sh` already checks headers state exit codes, so no new case |
| `found-board.sh` `rm -rf "$BOARD"` on a lane-stamp brace | T, unreachable today (`:97`) | `rm -rf` only what this run created: track `CREATED=1` after `mkdir` | R: unreachable; the guard is the fix |
| `lease.sh list` and `stamp_desc` cut a quoted name short | T. `lease.sh:61` `rn` stops at `,`, `}` or `"`; `lanework-merge.py:377` the same | read the quoted value whole in both | a claim named `a, b "c"`: `list` and a merge note print it whole. Display only |
| Pid 0 swept, zombie temp kept, newline board path fails stake | R: reviewer says none is a defect today; the third predates the branch | none | close with this reason |

## Proposal

One card, built as three branches merged in this order, each with its own review.

1. **settle-question**: `skills/discovery/scripts/settle-question.sh` (four items), `tests/smoke.sh` Recap block `:460-478`. One file, one reviewer.
2. **Process hardening**: `skills/lanework/scripts/lease.sh`, `skills/work/scripts/commit-board.sh`, `skills/work/scripts/label-card.sh`, `skills/lanework/scripts/found-board.sh`. Four unrelated scripts that share the review lens (a race or a signal); each change is a few lines with a case only where one is deterministic.
3. **Consistency and tests**: the seven usage lines, exit-code alignment, the header omissions, `lint-leases.sh` shaping skip, the stamp display in `lease.sh` and `lanework-merge.py`, the `lib.sh` case, the early-reader guard and `bq()`. All are text or tests; the smoke guard and `bq()` touch only `tests/smoke.sh`.

Why three branches and not one: slices 1 and 2 change the behavior of scripts others call, and slice 3 is mostly wording and tests. The slices share no file except `tests/smoke.sh`, so they can be built in parallel and merged in order. Why one card and not three: no slice needs a ruling the others do not, and splitting would send two of them back through triage.

Decision in this proposal: an unreadable `--body`, `--ask`, `--index` or `--lanes` exits 2 in every script, as five of the seven already do and as `lanework/references/writes.md` has it for a bad argument value. `file-card.sh` and `found-board.sh` move from 1 to 2.

## Risks

- Aligning exit codes changes documented behavior: a minor bump, a CHANGELOG line.
- The `sigprocmask` change in `push_bounded` could weaken the timeout path if the child keeps the mask; the existing `:2724-2736` cases must stay green and a mask inherited across `exec` is the failure to look for.
- The BOM strip must not turn a human click with a leading BOM into an agent one; check `created.by` still decides.
- The lint-leases skip would hide a real double START when one of them is labeled "(shaping)". Accepted: a shaper and a lead are two stages, not two builders.

## Verification

- `bash -n` on each edited script; `tests/smoke.sh` once at the end of each slice.
- Each new case demonstrated failing against `main` first (stash the fix, run the case).
- `tests/check-refs.sh`, `tests/check-sizes.sh` after the header edits.
- Never run a script against `Boards/`; throwaway boards only.

## Done when

- [ ] BOM, large-comment and cleared-`waiting` cases in `settle-question.sh` pass and fail on the pre-fix script.
- [ ] Timer survives an unwritable memory dir; `mem_save` in the notice branch re-checks `$MEM`.
- [ ] `commit-board.sh` checks `setsid` and installs its handlers under a signal mask; existing push-bound cases pass.
- [ ] `label-card.sh` hold expiry exits 1.
- [ ] The seven scripts print the usage line on an unknown flag, with one case.
- [ ] `lint-leases.sh` skips a `START (shaping)`; one case.
- [ ] `EC` and `bq()` fixed, each with a self-check.
- [ ] `lib.sh` CDPATH plus newline plus sibling case present.
- [ ] Each item the table rules out is named in a closing comment with its reason.
- [ ] `tests/smoke.sh` passes; CHANGELOG entry if exit codes changed.

## Release

Minor: the exit-code change is new behavior in two scripts. One CHANGELOG entry.

## Open calls

None.
