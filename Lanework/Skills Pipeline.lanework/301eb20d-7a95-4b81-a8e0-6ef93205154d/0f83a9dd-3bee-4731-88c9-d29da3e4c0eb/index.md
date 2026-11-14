---
schema: 1
kind: card
title: "lanework: a lease script to stake, renew, check and release a card lease"
order: 4096
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T15:02:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Add one script, `skills/lanework/scripts/lease.sh`, that holds the whole card lease (stake, renew, check, release and list, with the background timer, the clock guard and the takeover notice) exactly as the owner ruled it on Card Lease Discovery, so the four skills that follow only call it.

Open calls: none. Every behavior below is a ruling, linked under Source; the choices this card makes itself are listed under Decided here.

## Files

- `skills/lanework/scripts/lease.sh`: new, macOS bash 3.2 and BSD tools, sourcing `lib.sh` like its siblings. Subcommands:
  - `stake <board> <card-uuid> --model m [--name n]`: refuses (exit 1) over a valid lease held by another session; staking a card whose lease is the caller's own renews it and makes sure the timer runs. A lapsed lease held by another session goes through the takeover below. Starts the timer.
  - `renew <board> <card-uuid> --model m`: reads `by` first. Another session's `by` is a lost lease (exit 3). Lapsed and still its own, or live, renews.
  - `check <board> <card-uuid> --model m`: the call every card-writing script makes before it writes (ADR13). It tells three states apart and prints one word on stdout: `held` (exit 0), `lost` (exit 3), `never-held` (exit 4). `held`: this session's id is in `by` and the lease is valid; a lapsed lease still its own is renewed and a dead timer restarted first. `lost`: this session staked the card (its memory says so) and now another session's `by` is there, or `claimed` is gone: posts the loss record once, then exit 3 on every later call without writing. `never-held`: this session never staked it, whether the card is free or another session holds it: writes nothing, so a session answering on someone else's card is never blocked.
  - `release <board> <card-uuid> --model m [--force]`: deletes `claimed`, restamps `modified`, stops the timer, clears its state. Another session's lease is refused (exit 1) unless `--force`, which releases it and posts the forced-release record. No lease is a quiet exit 0.
  - `list <board>`: read-only, one line per held card: full card uuid, title, holder (name and session), whole minutes left (or minutes since it lapsed), and `live`, `lapsed` or `voided` (a lease the clock guard rejects). The uuid and the minutes are what the watch and dispatch arming pass reads.
  - an internal `_timer` subcommand, which `stake` starts detached.
- **For the plan card** ([b808e18c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)): every subcommand but `list` takes the card by uuid, as `<board> <card-uuid>`; each outcome has its own exit code (below); one session may hold any number of leases at once (one memory file and one timer per card, nothing global per session); and the two-minute takeover wait is shortened for tests by `LEASE_TEST_NOTICE_WAIT`, read only by smoke. None conflicts with a ruling.
- Exit codes are the interface the downstream cards rely on: 0 ok (`check`: held); 1 refused (held by another); 2 usage, no model, no `CLAUDE_CODE_SESSION_ID`, no `CLAUDE_PID`, or no single card with that uuid; 3 lost; 4 `check` only: never held.
- **Which cards this session staked** is remembered in a per-session directory outside the board: `${TMPDIR:-/tmp}/lanework-lease/<session id>/<card-uuid>`, one small file per card (the card path's board, the timer's pid, the working directory and branch at stake). `stake` writes it, a loss marks it `lost`, `release` removes it. It is the only thing that separates `lost` from `never-held`, and it outlives a dead timer. The holder match compares the session id alone, never `by.name`, so a fixer or other subagent running under its lead's session passes. If the directory is cleaned (a reboot), a card that was lost reads `never-held`: the cost is a missed stop, bounded by the lease's own lapse.
- `skills/lanework/scripts/lib.sh`: one new constant, `LEASE_LOST_PREFIX='**Lease lost**:'`, the fixed opening of the loss record. `lease.sh` writes the record with it, and [the lease trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b)'s `lint-leases.sh` greps for it, so the two cannot drift; whichever card builds first adds it and the other reuses it. Nothing else changes: `lease.sh` otherwise uses `by_of`, `now_utc`, `uuid`, `fm_value`, `comment_file` and `compact_fm`, which exist. A shared comment-posting helper is not extracted here (see Decided).
- `skills/lanework/references/writes.md`: one new section, `## Lease`, the only place the rules are stated: the key's shape, who holds (the session; subagents never stake; one machine, a hint across machines), the 30-minute length and 15-minute renewal, the clock guard, takeover, release, what a lease write restamps and never commits, the exit codes, and the fixed wording of the three records. It is the place every other skill links to.
- `skills/lanework/SKILL.md`: one row in the Scripts table for `lease.sh`, and the write-rules row of the Topics table gains "the lease".
- `README.md`: the `lanework` row of the skills table gains the lease; the `lanework` word counts in § Sizes (`SKILL.md`, `references/writes.md`, the total and the summary row) are updated, because `tests/check-sizes.sh` compares them with `wc -w`.
- `tests/smoke.sh`: the cases below. `tests/merge-case.sh`: one row, two differing leases on one card.
- `CHANGELOG.md`: at release, one user-facing entry (not part of the build).

## Behavior

- **Shape**: `claimed` in the card's frontmatter, written in the compact block form because the holder's `by` alone passes 120 characters:

  ```
  claimed:
    by: {name: claude, kind: agent, model: <model>, session: "<CLAUDE_CODE_SESSION_ID>"}
    until: 2026-11-14T15:30:00Z
  ```

  The holder is the session id, read from `CLAUDE_CODE_SESSION_ID` and never from a flag. No session id, no lease (exit 2). The id is the only thing compared when asking "is this lease mine?". The guide has no `claimed` key: it is custom metadata, which the app preserves and does not draw (guide, Frontmatter: unknown keys). The board validator accepts it.
- **Stake**: resolve the card's path fresh; read `claimed`; write `claimed` and the restamped `modified` (staged outside the board, then `mv` in); wait one second; read back. A different session in `by` means back off, exit 1, no record (the caller never held it).
- **Timer** (`_timer`, started by `stake`, one per session and card): counts its own waiting with `sleep`, never the clock. Each minute: re-resolve the card, read it. If `by` is no longer this session's, find the loss (below) and exit. If a takeover notice naming this session is newer than the last one seen, renew at once. Every 15 minutes of elapsed time, renew. It exits when the card or `claimed` is gone (released), when the lease is lost, or when `CLAUDE_PID`, the session's own process, is gone. Its pid and the work-in-flight facts (the working directory and branch at stake time) live in the per-session file above. Started with `nohup`, detached, output discarded (macOS has no `setsid`).
- **Renew**: reads `by` first. Another session's `by`: the lost-lease path. Lapsed and still its own: renew, so a session that slept comes back to its card (Q16). Each renewal rewrites `until` from the clock as it is then and restamps `modified`.
- **Lost lease**: the loser stops and posts one record in the fixed wording, then never writes the card again: a later `renew` or `check` by that session finds its per-session file marked lost and writes nothing, exit 3. The record names the work in flight, which the script reads itself: the branch and working directory saved at stake, and `git status --porcelain` there for the files touched. It is the one card write made without holding the lease. The timer posts it when it finds the loss; `check` posts it when the timer is dead and the card-writing script finds it first. Whichever comes first, only one is posted.
- **Clock guard**: a reader treats a `claimed` whose `until` is over 35 minutes ahead of now, or unreadable, as no lease. `stake` over one succeeds and posts the "lease ignored" record. A past `until` gets no guard.
- **Takeover**: for a lapsed lease held by another session, `stake` posts the takeover notice (the takeover record) in the fixed wording, waits two minutes, reads again. The holder's `until` moved, or `by` changed: back off, exit 1; the notice stays in the thread. Unchanged: stake as on a free card. Before it starts, the taker reads the thread for a START or a "Lease lost" record, which may point at work to keep: the script prints the latest one's first line. So `stake` over a lapsed lease blocks for two minutes by design.
- **Release**: in the holder's closing write (Q8): the card's `claimed` removed, timer stopped. `--force` is for the owner's word, never the holder's own: it posts the forced-release record naming the holder it released.
- **Writes**: every lease write (stake, renewal, release) restamps `modified` whole with the writer's `by`, and none is committed (ADR9). The script never runs `git`. Comments are posted by the script itself with `comment_file`, never by `work/scripts/post-comment.sh`.
- **Records, fixed wording** (records, never an ask, no handle; the first words are the match key for the timer and for the trial's lint):
  - `**Lease lost**: session <session> no longer holds this card; session <other> does. Work left in place: branch <b>, directory <d>, files touched: <list>. This session writes this card no more.`
  - `**Takeover notice**: session <taker> takes this card from session <holder> at <time> unless the lease is renewed first. It lapsed at <until>.`
  - `**Lease ignored**: until <x> was over 35 minutes ahead of <now>, so the card was staked as free.`
  - `**Lease released by force** on the owner's word: session <s> held it until <until>.`
- **Lint timings checked**: [the trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b)'s `--window 1800` is this card's lease length and `--grace 900` is one renewal interval, so a live holder, which renews every 15 minutes and so is never more than 15 minutes from lapsing, cannot be flagged; a dead timer is flagged once 15 minutes past `until`. Its lapsed check reads `claimed.until` in the block form this script writes, which that card says it handles.
- **Test-only knobs**: environment variables `LEASE_TEST_STAKE_WAIT` (1), `LEASE_TEST_NOTICE_WAIT` (120), `LEASE_TEST_POLL` (60) and `LEASE_TEST_RENEW_EVERY` (15 polls) let smoke run in seconds. Documented in the script header, never in `writes.md`.

## Decided here

These are not on Card Lease Discovery. Each is a build detail the rulings leave open, so none is an ask.

- **Name**: `lease.sh`, as the card proposed.
- **`lease.sh` posts its own comments**, as `comment_file` writes them, with a distinct-second check (it waits for the next second if the second is taken), and does not call `post-comment.sh`. The work card makes `post-comment.sh` call `lease.sh check`; calling back would loop. Folding the shared part into `lib.sh` waits until a third caller exists.
- **`lib.sh` gains only `LEASE_LOST_PREFIX`**, because a second script (the trial's lint) needs it. The wording is not ruled; `**Lease lost**:` is proposed here and shared with the trial card.
- **Work in flight is read by the script**, not supplied by the session: the timer has no session to ask when it finds a loss.
- **`CLAUDE_PID` is required** for `stake`, since the timer exits with that process. It is set in this session's environment; whether a headless `claude -p` job sets it is not checked (the discovery fact names the same gap). The manual check below tests it.

## Verified

New cases in `tests/smoke.sh`, all on throwaway boards outside the repo (never the Skills Pipeline board), each run with the test-only knobs and a stand-in `CLAUDE_PID`, each failing before the script exists:

1. `lease: stake writes claimed with by.session and until 30 minutes ahead; the board validates and the heal dry run lists nothing`
2. `lease: no session id or no CLAUDE_PID is exit 2 and writes nothing`
3. `lease: two racing stakes leave one holder` (two session ids started together: one exit 0, one exit 1, `by` is the winner's)
4. `lease: stake over another session's live lease is refused`
5. `lease: renew moves until forward and restamps modified, and leaves the body byte for byte`
6. `lease: a changed by yields one Lease lost record naming branch, directory and files, and no further write`
7. `lease: an until over 35 minutes ahead is no lease; stake posts Lease ignored`
8. `lease: takeover posts the notice and waits; the holder renewing makes the taker back off; no change makes it stake`
9. `lease: check prints held, lost or never-held; renews a lapsed lease of its own and restarts a dead timer; compares the session id, not by.name; and writes nothing for a card this session never staked, free or held by another`
9b. `lease: the loss record opens with LEASE_LOST_PREFIX`
9c. `lease: one session holds three leases at once: three files, three timers, and releasing one leaves the other two held`
10. `lease: release removes claimed and stops the timer; another session's release is refused; --force releases and records it`
11. `lease: the timer renews by elapsed time, answers a notice within one poll, and exits when its CLAUDE_PID is gone or the lease is lost`
12. `lease: list prints held cards with holder, time left, lapsed and voided`
13. `lease: no timer process is left after the run` (a final check that smoke leaks nothing)
14. `tests/merge-case.sh`: two differing leases on one card resolve to the side with the later `modified`, with the loser's text in the merge comment (Q6).

Also: `bash -n`, `check-refs.sh` (the new citations resolve) and `check-sizes.sh` (README counts) pass as part of smoke. Smoke is red at the guide-version stamp gate until [the v117 card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) lands: run it on the throwaway cases first, and read the stamp failure as that card's.

Two manual checks, quoted in the closing comment:

- **The app write-back** (Q19): a card open in the Lanework app while a lease is staked and renewed, to see whether the app writes back an older copy. A failure becomes a request to the app.
- **The timer outliving its call**: stake from a Claude Code Bash call and from a headless `claude -p` job, wait past one poll, and confirm the timer is still running after the call returned and that `CLAUDE_PID` was set. A failure is reported here as a finding before the downstream cards build on it.

## Done when

`lease.sh` exists and passes `bash -n`; every behavior above has a named smoke case that failed before and passes after; `writes.md` states the rules once under `## Lease` and nothing else in `skills/` restates them; the SKILL.md row and the README row and word counts are in; the merge row passes; and both manual checks are recorded in the closing comment.

## Risks

- **A stall over a second** between two sessions' read and write lets both think they hold the card until one's next renewal (ADR3, provisional). The lost record counts it; a lock is the ruled fallback.
- **The timer outliving its start** is untested: a harness may kill background children when a tool call ends. The manual check above settles it before downstream cards depend on it.
- **A whole-file rewrite** every 15 minutes can race an edit the owner or another script makes to the same card (the app too: Q19). Lease writes re-read the file just before landing, as the other scripts do.
- **No `setsid` on macOS**, so the timer relies on `nohup` and the pid file. A killed session without a trace leaves a timer until its next poll finds `CLAUDE_PID` gone, at most a minute.
- **A mis-compact layout**: `compact_fm` and the heal must agree on the block form. Case 1 checks a heal dry run lists nothing; if it does, the layout changes to the heal's.
- **`stake` over a lapsed lease blocks two minutes.** A caller with a short tool timeout must know it. `writes.md` says so.
- **A hand-rolled write skips the lease** and its check (ADR13's consequence). Not fixable here.
- **Across machines** the lease is a hint (ADR2): a pulled lease lapses by its `until`.

## Depends on

- [Skills target agent guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8): smoke is red at the stamp gate until it lands.

Built on this (each calls the script):

- [work: card-writing scripts check the lease, and START shrinks to a short plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa)
- [plan: claim-ticket stakes a lease and still moves the ticket to Working](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)
- [watch and dispatch: the session stakes a lease before working or handing off a card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233)
- [Lease trial: a collision lint and a clean run over the first 50 leased cards](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b)

## Recommendation

Build it as written, after the v117 card. It is the one script every other lease card calls, and it carries two checks the discovery could not make without a real script: the app write-back and the timer outliving its call. Build and run both checks before the four dependent cards start.

## Source

- [ADR: A lease's holder is the stamp's by, with the harness session id required](lanework://33527992-d72c-417b-85a2-1b62bea96794/31f5a0e4-1c31-43be-a36f-5fedd78a3bc9)
- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: A lease holds on one machine; across machines it is a hint](lanework://33527992-d72c-417b-85a2-1b62bea96794/94e3d45e-37cf-4c39-a633-87610ab297b4)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930)
- [ADR: A lost lease leaves the work in place, and the loser stops](lanework://33527992-d72c-417b-85a2-1b62bea96794/3b8d6e0b-1668-4e67-80ab-4a88fda8ad96)
- [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)
- [ADR: The clock guard is a range check against now, with an elapsed-time timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/674f3c98-33a5-41f5-acb3-7f59abafdfcf)
- [ADR: One lanework script holds the lease mechanism and its timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/0e5b4553-6ac0-47b9-862b-91951dc35948)
- [ADR: A lease write restamps modified and is never committed alone](lanework://33527992-d72c-417b-85a2-1b62bea96794/aec193e9-55d2-4f60-9cd6-17a05258e307)
- [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
- [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
- [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
- [Q8: Releasing a lease](lanework://33527992-d72c-417b-85a2-1b62bea96794/0f36b65c-b027-461a-b9af-5c8db6e5fc5a), [Q6: Merging two differing leases](lanework://33527992-d72c-417b-85a2-1b62bea96794/3182fff4-99d4-4d9f-8a8c-12926e6153c5), [Q16: A holder back late](lanework://33527992-d72c-417b-85a2-1b62bea96794/c8e5934d-298c-4444-88b2-b44dd8c7ce95), [Q19: The untested app rewrite](lanework://33527992-d72c-417b-85a2-1b62bea96794/066be348-6145-4667-b4bc-8dc5bcae9eb6)
