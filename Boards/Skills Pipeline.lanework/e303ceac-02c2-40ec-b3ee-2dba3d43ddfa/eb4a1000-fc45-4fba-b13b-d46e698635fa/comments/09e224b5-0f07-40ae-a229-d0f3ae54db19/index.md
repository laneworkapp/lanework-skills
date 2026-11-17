---
schema: 1
kind: comment
created:  {at: 2026-11-17T18:31:31Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T18:31:31Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: the lease's memory is keyed by card uuid alone, so one write to another copy of the board kills the lease a session holds on the real card. Seven notes.

- **Stance**: adversarial. Trigger: every agent comment and card move now passes a lease check that can refuse the write (exit 3) and start a detached timer.
- **Round**: 1
- **Card**: [eb4a1000](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa)
- **Branch**: `work-lease` at `62ee7bf`

**Blocking**

1. `skills/work/scripts/post-comment.sh:65 @ 62ee7bf` "rc=0; \"$LEASE\" check", with the root cause at `skills/lanework/scripts/lease.sh:268 @ 62ee7bf` "if [ -f \"$MEM\" ]; then lose". The memory file is `<session>/<card-uuid>`, and `check` never compares the `board=` it saved with the board it was given. Measured: session S-a stakes card C on board A. A copy of A made before the stake (an agent worktree's checkout of the same `Boards/`, or a hand fixture copied from a live board) holds C with no `claimed`. One `post-comment.sh` on the copy, run by the same session (`--name fixer`, from the worktree), exits 3 and posts a **Lease lost** record on the copy, which can be committed on the branch. Then `post-comment.sh` on the real board exits 3 although `claimed` there is still S-a's and live, `move-card.sh` exits 3, and the timer exits within a poll, so the real lease lapses unrenewed. This is the "wrong refusal silences an agent" case, and it goes against the ruling's "the check only acts on a lease the writer holds or held" ([ADR](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)): the writer never held a lease on that board. Fix: `lease.sh` treats a remembered card whose `board=` differs from the resolved board as never-held, in `check`, `stake`, `renew` and `release`, or keys the memory by board too. That file is the lease card's, so the lead rules where the fix lands. This branch is what makes every card write reach it. Add a smoke case that writes to a copy under the same session, then writes to the original.

**Questions for the lead**

1. The fix for Blocking 1 is in `lanework/scripts/lease.sh`, which the body leaves out of scope. Should it land on this branch, or on a lease card that merges first?
2. `post-ask.sh` exits 1 on a lost lease (`skills/work/scripts/post-ask.sh:75 @ 62ee7bf` "refused the ask; nothing written"), the same code as a lint refusal. The farmed prompt names only `post-comment.sh` and `move-card.sh` exiting 3. Should post-ask pass a 3 through, so a loser stops instead of retrying? Nothing is written either way: measured, no ask, no `waiting`, one **Lease lost** record.

**Notes**

1. `lease.sh` `write_card` (the lease card's code) is a read, then a rewrite, then an `mv`, with no lock, so a renewal by the timer can overwrite a concurrent `move-card.sh` write. Measured with the timer renewing every poll: 20 `move-card.sh --clear-waiting --top` runs left the card never torn, never in two lanes, `claimed` always intact, but in 2 of 20 `waiting` came back. At real timing (a renewal every 15 min, a window of milliseconds) this is rare, and it applies to every writer of `index.md` (post-ask's `waiting` too). Worth a card on the lease script.
2. Smoke does not catch `--release` run before the comment lands: that mutation passed every case. Nor does it catch `--release` calling `lease.sh release` when the check found no held lease (that mutation passed too). Case 7 could assert the comment lands before the release (for example a comments folder made read-only: then no release), and could run `--release` on a free card and on another session's card.
3. `post-comment.sh:80 @ 62ee7bf` "release by hand": rerunning the same command after a failed release posts the closing record twice (measured: 2 comments). `lead.md` § Dispatch could say: on that exit, run `lease.sh release` and never repost.
4. Any check failure other than 0, 3 or 4 is exit 1 with nothing written. That fails closed even for a session that holds nothing. Measured: a session id with a space, and a `lanework/scripts/lease.sh` missing beside `work`, both silence every write while `CLAUDE_CODE_SESSION_ID` is set. Neither shape occurs with a real Claude Code id or the plugin install. Missing `CLAUDE_PID` and a board with no `.schema` write as today. Two cards with one uuid exit 2 before the check.
5. `templates/farmed-prompt.md:11 @ 62ee7bf` "none (no card write)" reads as "a subagent with no lease never writes the card". That contradicts the ruling that answers on cards nobody holds stay open. Suggest: "none: the session holds no lease; writes pass as today".
6. `lead.md` names `lease.sh stake` but not what to do when it exits 1 (another session's live lease, or a backed-off takeover) or blocks 2 min (a lapsed lease). Those are in `writes.md` § Lease, but lead.md is where a lead decides to dispatch.
7. Smoke's `unset CLAUDE_CODE_SESSION_ID CLAUDE_PID` weakens no case: the lease cases set the id per call, and the whole suite also passes with a never-held id exported in its place (below).

**Checked**

- **Correctness vs done-when**: post-comment state matrix measured on fixtures under `mktemp -d`:
  - No session id, a free card, another's live lease never held here, own live, a fixer under the lead's lease, and `--session S-other` on a never-held card: rc 0 and the comment lands, with the card byte for byte as it was.
  - Own lapsed lease: rc 0, `until` 30 min out, a new live timer that outlives the script.
  - Lost (another `by`, `claimed` deleted, the timer alive and racing): rc 3, only the one **Lease lost** record lands, the reason is on stderr, and a second call writes nothing.
  - No session id, a free card and another's lease never held here: comment, card and the rest of the board byte-identical to main's `post-comment.sh` once stamps are masked.
  - `--release`: held, `--ahead 20` and own lapsed give rc 0, `claimed` gone, the memory gone, the timer exited. Lost gives rc 3 with nothing posted or released. Free, never held and no session id post the comment with a note on stderr and release nothing.
- **move-card.sh**:
  - Held with `--clear-waiting --top --comment`: moves, `claimed` intact, `waiting` dropped, the timer alive. The timer then renews the card in its new lane.
  - Lost with `--comment`: rc 3, not moved, the comment not posted, one record.
  - Free, another's lease, no session id and own lapsed (renewed): moves as on main. The board validates.
- **post-ask.sh**: smoke's held and lost cases agree with my reading of the code.
- **Refusal order**: the check runs after every refusal (flags, `--ahead`, board, uuid, reply, body, two cards, same second, lint) and before the `mv`. Smoke case 8 pins it, and moving the check earlier fails smoke.
- **Project conduct**: commits keep the scripts apart from the prose and README. `plugin.json`, CHANGELOG, `watch/`, `plan/`, `heal/` and `lanework/` are untouched (diff from the merge-base). No guide version number. The README § Sizes departure is explained (`check-sizes.sh` needs it), and smoke passes it.
- **Both paths**: `move-card.sh` gains the check as the lead's START ruled. `post-ask.sh` inherits it (Question 2). `file-card.sh` makes a new card, which has no lease. Hand-rolled writes skip the check, an accepted limit.
- **Fail-before**: OWN RUN agrees with the fixer's. The new lease cases, run against `skills/work` at the merge-base `d246916`, fail at case 2 with "post-comment on a lapsed own lease: rc 0, until … timer 87912 (was 87912)".
- **Test adequacy**: mutations on copies, each run on the lease section of smoke:
  - Caught: skipping the check, 4 read as lost, 3 read as write, the check moved before the refusals, `--session` used as the id, no release, the move-card check skipped, 3 read as move, 4 read as lost in move-card.
  - Not caught: `--release` before the comment, and release without a held lease (Note 2).
  - The cases are named by what they prove and sit after the lease cases, like their neighbours.
- **Blast radius**: 11 files as the fixer reported. Smoke was unchanged in the worktree before and after (`git status` empty).
- **Prose**:
  - `writing.md` § START is the only definition: `START:` stays the first word, about 40 words, Scope/Verify/Where, matching the ADR. Companions, fixer and lead link to it.
  - Nothing under `skills/work/` calls a START a claim (grepped `claim`, `START`, `stale`, `30 min`; the remaining hits are evidence claims and the commit-board lock).
  - `lead.md` has the stake at dispatch and `--release` on close in the diagram and § Dispatch. `team.md`, `sweep.md` (Farm, Triage with `lease.sh list`) and the farmed prompt (`Lease:`, never stake) are accurate against `lease.sh` as built.
  - A subagent's `CLAUDE_CODE_SESSION_ID` is its parent's (measured in this session), so `--name fixer` posts pass under the lead's lease, and as today when the lead holds none.
- **Population**:
  - `tests/smoke.sh` in the fixer's worktree: "smoke: 214 passed" over 214 cases, 203 old plus 11 new.
  - The same suite on a copy with a fake never-held `CLAUDE_CODE_SESSION_ID` exported instead of unset: "smoke: 214 passed", no lease memory written.
  - Afterwards `pgrep -fl lease.sh` prints nothing, and the real `lanework-lease` folder matches its listing from before the review.

**Hypotheses**, written before reading the fixer's START (`fab7c236`), FAIL-BEFORE (`b4b29d3e`) and closing record (`ae0009b5`) on [eb4a1000](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa). 3 of 9 held.

1. A refused post renews or loses the lease. Refuted: the check runs after every refusal.
2. A check exit 2 silences an agent that holds nothing. Held only for shapes a real environment doesn't produce (Note 4).
3. The timer started from `$(post-comment.sh)` hangs the caller or dies with the script. Refuted.
4. post-ask on a lost lease sets `waiting`, or its exit code is ambiguous. Ambiguous held (Question 2), `waiting` refuted.
5. move-card tears or duplicates the card, or drops `claimed`, racing the timer. Refuted. A stale `waiting` came back in 2 of 20 (Note 1).
6. `--release` misbehaves, or a retry is unsafe. A retry duplicates the comment (Note 3).
7. Smoke's `unset` weakens the existing cases. Refuted by the never-held run.
8. The prose still calls START a claim, or is wrong when the lead holds none. Refuted, apart from Note 5's wording.
9. The new cases miss mutations. Held for two of eleven (Note 2).
10. Found while testing, not pre-registered: memory keyed by uuid alone poisons the lease from a board copy (Blocking 1).
