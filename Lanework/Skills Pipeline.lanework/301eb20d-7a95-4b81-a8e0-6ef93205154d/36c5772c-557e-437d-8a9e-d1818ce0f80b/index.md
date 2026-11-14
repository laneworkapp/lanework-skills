---
schema: 1
kind: card
title: "Lease trial: a collision lint and a clean run over the first 50 leased cards"
order: 8192
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:58:33Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
Add a read-only lint, `lint-leases.sh`, that finds lease collisions in a board's threads, then run it over the first 50 leased cards and record whether the run was clean.

## Files

- `skills/work/scripts/lint-leases.sh`: new, modelled on `lint-stamps.sh` (sources `../../lanework/scripts/lib.sh`, skips `.trash`, `.log`, `.schema` and `attachments`, handles flow and block frontmatter, CRLF). `lint-leases.sh <board dir>... [--since <ts>] [--first <n>] [--window <s>] [--grace <s>]`. One line per finding on stdout, exit 1 if any, silent exit 0 when clean, exit 2 on a bad path or flag. The tally `leased cards: N, lease lost: a, two STARTs: b, lapsed: c` goes to stderr, so stdout keeps the lint-stamps contract. It writes nothing anywhere.
- `skills/lanework/scripts/lib.sh`: one constant, `LEASE_LOST_PREFIX`, the fixed opening of the "lease lost" record. PDR2 and ADR3 require one wording and no ruling states it; the lint and `lease.sh` (the first card under Depends on) both read this constant, so neither can drift. If that card lands first, it adds the constant and this card reuses it.
- `skills/work/SKILL.md`: one sentence beside the `lint-stamps.sh` line: `scripts/lint-leases.sh <board>... [--since <ts>] [--first <n>]` finds lease collisions (read-only).
- `README.md`: the § Sizes row for `work/SKILL.md`, the skill total and the summary words, so `tests/check-sizes.sh` stays green. Nothing else in the README changes: the lint is a checking tool, not a key feature.
- `tests/smoke.sh`: the cases under Verified, placed after the `lint-stamps` block.

## What the lint reports

All three come from files alone. A comment's session is its `created.by.session`; a comment is a START when its first line, after an optional `**`, begins `START` (the test `dispatch/scripts/arm-pass.sh` already uses).

- **lease lost**: a comment whose first line begins `LEASE_LOST_PREFIX`. Line: `<card>: lease lost <comment id> <time>`.
- **two STARTs**: two START comments on one card from different sessions, at most `--window` seconds apart (default 1800, the lease length of ADR4). Line: `<card>: two STARTs <id> <id> <n>s apart`, ending `first session wrote again` when the earlier session posts any comment after the later START. A START with no `session` is skipped. Same-session STARTs are never a finding (a session may re-post its plan after compaction).
- **lapsed**: a card whose frontmatter still has `claimed` with an `until` more than `--grace` seconds in the past (default 900, one renewal interval; a live holder renews well inside it). Line: `<card>: claimed until <ts> is <n>s lapsed`. This one reads the whole board, not only the counted cards.

## Where the 50 are counted from

- A card counts as leased when it has a START comment created at or after `--since`, or a lease-lost record. The lease leaves no trace after release (`claimed` is deleted), and ADR5 keeps START as the plan every leasing skill posts, so START is the only mark a script can count afterwards.
- `--since` is the UTC time the first card was staked on a live board. The first trial comment on this card records it.
- `--first <n>` keeps the `n` cards with the earliest qualifying START, so "the first 50" is a rerunnable result. The trial passes `--first 50`.
- The boards counted are those under this repo's `Lanework/`, passed explicitly: `lint-leases.sh Lanework/*.lanework --since <ts> --first 50`. That includes Skills Pipeline, the board where this work happens. The lint only reads, so the run is the trial and does not break "Never test on this board", which bars scripts that write. Smoke runs only on throwaway copies, never on a live board.
- Boards in other repos are not counted unless the owner names them; the lint takes any number of boards.

## Verified

New cases in `tests/smoke.sh`, on a copy of the discovery board with seeded comments, each with a stated session:

1. `lint-leases` is silent, exit 0, and tallies the cards on a board with only one-session STARTs.
2. `lint-leases` finds a lease-lost record, naming the card and comment.
3. `lint-leases` finds two STARTs from different sessions inside the window, tags `first session wrote again` when it did, and passes two STARTs from one session and two from different sessions further apart than the window.
4. `lint-leases` finds a `claimed` lapsed past the grace in flow and block form, and passes a live lease and one lapsed inside the grace.
5. `--since` leaves out earlier STARTs and `--first` keeps only the earliest `n` cards, for the tally and the findings.
6. `lint-leases` leaves every file of the board unchanged (checksum before and after) and exits 2 on a missing path, no board and an unknown flag.
7. Once `lease.sh` exists: its "lease lost" record opens with `LEASE_LOST_PREFIX`, and the lint finds it.

`bash -n` on the new script runs from the existing loop over `skills/*/scripts/*.sh`. `check-sizes.sh` covers the README rows.

The trial: after 50 cards are leased, run the lint on this repo's boards and quote the output, including the stderr tally, in the closing comment.

## Done when

- `tests/smoke.sh` passes with cases 1 to 6 (and 7 once `lease.sh` exists), and `tests/check-sizes.sh` passes.
- The closing comment on this card quotes the lint run with `--first 50`: the exact command, the `--since` value, the count of leased cards and the count of each finding.
- A clean run (all three counts 0) closes the card. One lease-lost record or one two-START card reopens the staking ruling of ADR3, with the lock as the fallback, as a new card. A lapsed claim makes the run not clean (PDR2 counts a card left held by a dead session as a failure) but does not reopen ADR3: the card stays open, each hit is traced to a missed release or a dead timer and freed, and the trial is rerun from the same `--since`.

## Risks

- The trial cannot start until the four cards under Depends on ship and sessions stake leases. The lint itself can be built and smoked before then; only case 7 and the trial wait.
- A START is a proxy for a lease. A session that stakes and works with no START, or a START posted without staking, miscounts by one.
- A legitimate handoff (the first holder releases, a second session starts within 30 minutes) matches the two-START rule. The line says whether the first session wrote again, and the closing comment judges each hit by reading the thread. The PDR counts any such card, so none is dropped silently.
- The lint cannot see a lease that was never staked (a session with no id, a hand-rolled write) and cannot see a collision between two machines (ADR2: across machines a lease is a hint).
- `lib.sh` is shared with the lease script card: a clash over the constant is a one-line rebase.
- The smoke stamp gate is red until the guide v117 card lands (see the lease script card), so smoke cannot go green here before it.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb): writes the "lease lost" record and shares `LEASE_LOST_PREFIX`
- [work: card-writing scripts check the lease, and START shrinks to a short plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa): the START shape the lint reads
- [watch and dispatch: the session stakes a lease before working or handing off a card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233)
- [plan: claim-ticket stakes a lease and still moves the ticket to Working](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5)

## Recommendation

Approve. Build the lint and its smoke cases now, behind the lease script card, and hold the trial until the four cards ship. No open call: the three points the rulings leave open (wording, "inside one lease", "lapsed long ago") are set above as lint parameters that a flag can change, not as rulings.

## Source

- [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
- [ADR: Staking writes, waits and reads back, provisionally](lanework://33527992-d72c-417b-85a2-1b62bea96794/1e666a0e-4a8c-4c03-8f67-2c930097db74)
- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153): START stays as the mark the count reads
- [ADR: A lease runs 30 minutes, renewed by a timer](lanework://33527992-d72c-417b-85a2-1b62bea96794/ce03dec0-06e0-4fa8-ac29-671c59ba6930): the window and the grace
