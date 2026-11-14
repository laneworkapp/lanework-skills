---
schema: 1
kind: card
title: "watch and dispatch: the session stakes a lease before working or handing off a card"
order: 6144
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:48:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T15:01:33Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
Make `watch` and `dispatch` honor the card lease: the session stakes a lease before it works a card or hands it to a subagent, keeps it while the subagent runs, releases it when the card reaches a gate or is done, and the arming report lists held cards and lapsed leases.

## Files

`lease.sh` below is the script card [0f83a9dd](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb) adds to `skills/lanework/scripts/`. This card only calls it; it states no lease rule of its own and cites `lanework/references/writes.md` for them.

**watch**

- `skills/watch/references/arming.md`
  - § Arming pass: a work order is a card in an `agent` lane with no valid lease. The phrase "no START or plan comment: `work/references/companions.md`" cites the lease instead. A START comment no longer claims a card (ADR "Every skill takes a lease").
  - The same pass lists the cards it skipped: held (valid lease, minutes left) and lapsed (a lease past `until`). Neither is a work order, and the arming pass never takes over a lapsed one: the owner frees it, or asks an agent to take it.
  - § Tell the user: the held and lapsed lists join the report.
- `skills/watch/references/responding.md`
  - § A move into an agent lane: the work order is stake-first (`lease.sh stake`), and a refused stake is a report line ("held by another session"), not work. Release when the card is handed to a gate or done, before the closing commit, so the release rides in that commit (ADR "A lease write restamps modified and is never committed alone").
  - § Action-calling: the farmed prompt names the lease the session holds and tells the subagent not to stake (ADR "The session holds the lease; its subagents never stake"). The prompt wording itself is card [eb4a1000](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa)'s `work/templates/farmed-prompt.md`; this file only points at it.
  - § Ruling or discussion: one line saying a reply, a ruling fold and a lane exit stake nothing, since a write to a card the session does not hold is not blocked (ADR "Every card-writing script checks the lease first", Consequences).
- `skills/watch/references/events.md`: item 5 (a move into an agent lane is the work order) says "stake, then act"; item 6 names a lease write (stake, renewal or release, by any session) as another card `index.md` change that is context, not a reply.
- `skills/watch/SKILL.md`: no change.

**dispatch**

- `skills/dispatch/references/routing.md`
  - § Arm step 3: `arm` means no valid lease; `stale` means a lapsed lease; a new report-only `held` line. Step 5 reports held and lapsed cards to the user.
  - § Route step 4: after `state.sh claim` prints `spawn` for an `arm` or an owner `move` into an agent lane, the router runs `lease.sh stake` on the card before spawning. A refused stake drops the event with one line to the user and runs `state.sh finish`. A `comment` event stakes nothing.
  - § On completion: when `state.sh finish` prints nothing (the card leaves the in-flight set), the router runs `lease.sh release`. When it prints queued events the card stays in flight and the lease stays held for the follow-up handler. An `ACTION: escalate` re-spawn keeps the lease.
  - A `bulk` event: the router cannot name its cards before the diagnosis, so it cannot stake for them. The handler reports each card it finds moved into an agent lane as `ACTION: orders: <card uuid>[, <card uuid>...]` and acts on none. The router raises a `move` event per uuid and routes each normally (stake, spawn).
  - One sentence: `state.sh`'s `claim` means in flight (the router's own bookkeeping), not a lease.
- `skills/dispatch/references/handler.md`: the `move`/`arm` row's "only when the card is unclaimed (`companions.md`)" becomes "only when the prompt's `Lease:` line says this session holds it". A handler never runs `lease.sh stake`, `renew` or `release`. The `bulk` row becomes diagnose and report orders, as above. § Commit: a handler's commit may carry the live `claimed` key to other machines, where it is a hint that lapses by its `until` (ADR "A lease write restamps modified and is never committed alone", Consequences).
- `skills/dispatch/templates/handler-prompt.md`: one line, `Lease: held by this session on this card until <time> | none (comment, bulk, chat). Never stake, renew or release it.`
- `skills/dispatch/templates/handler-report.md`: the `ACTION` list gains `orders: <card uuid>...` (bulk only). No new line, so the report stays at ten.
- `skills/dispatch/scripts/arm-pass.sh`
  - Reads leases once per run with the read-only `lease.sh list <board>` and joins them to cards by uuid. It reimplements no lease rule (clock guard, lapsed) and writes nothing.
  - `arm`: an agent-lane card with no valid lease (Approved: top card only, as now). A START comment alone is not a claim.
  - `held` (new, report-only): a valid lease. Same seven fields; author `-`, paths `<n>m` left. Never routed.
  - `stale`: a lapsed lease, in place of a START with 30 minutes of silence. Author `-`, paths `<n>m` since `until`. Report-only, as now.
  - Header comments rewritten; the START/closing-comment claim logic and `STALE_MINUTES` go. `comment` lines are unchanged. Done is still never swept.
  - Stays bash 3.2 and BSD tools, like the rest of the script.
- `skills/dispatch/scripts/state.sh`: no change. Its `claim` is the router's in-flight set (dedupe, queue, relay to a build lead) for one session's own events, and the lease is the cross-session claim, so both are still needed. Following the lease would lose the queue.
- `skills/dispatch/SKILL.md`: the `arm-pass.sh` row reads "owner comments to answer, cards to arm, held cards, lapsed leases". No other change.

**repo**

- `tests/smoke.sh`: the `arm-pass.sh` block (the cases around START claims and `STALE_MINUTES`) is rewritten, and prose checks are added. Cases are named under Verified.
- `README.md`: § Sizes word counts for each changed file (`tests/check-sizes.sh` fails otherwise).
- `CHANGELOG.md`: not touched here. The release entry for the lease is written once, at release.

## Verified

`tests/smoke.sh` passes. New cases on throwaway boards, with lease fixtures hand-written into card frontmatter (`claimed: {by: {..., session: "..."}, until: <clock +20m>}`), each failing on the current script:

1. `arm-pass.sh: a card with a valid lease in an agent lane is no arm and prints one held line with the minutes left`
2. `arm-pass.sh: a lapsed lease prints a stale line with the minutes since until, and no arm`
3. `arm-pass.sh: a START comment with no lease is an arm` (replaces the old dead-claim and fresh-claim cases)
4. `arm-pass.sh: an until more than 35 minutes ahead is no lease, so the card is an arm`
5. `arm-pass.sh: a leased card in Done prints nothing`
6. `arm-pass.sh: an unanswered owner comment on a held card prints comment, then held`
7. `arm-pass.sh: leaves every card file byte-identical` (checksums before and after)
8. `classify-event.sh: a lease write (a card index.md with a claimed key, no lane change) is body, not move or comment`
9. `watch and dispatch prose`: grep checks in the style of the existing watch ones. `arming.md` no longer defines unclaimed by a START; `routing.md` runs `lease.sh stake` before a spawn and `lease.sh release` when finish prints nothing; `handler.md` says a handler never stakes; `handler-prompt.md` carries a `Lease:` line.

Dropped: the `STALE_MINUTES` case. The "agent lane titles on the command line" and "non-board exits non-zero" cases stay.

`tests/check-refs.sh` and `tests/check-sizes.sh` run inside smoke. Every changed script passes `bash -n`.

The router's and watch's flow is prose and cannot be run in smoke. It is read through against the board guide and the rulings. Cards worked through `watch` and `dispatch` after release count toward the 50-card live trial the owner ruled (PDR "The lease works when smoke passes and 50 leased cards run clean"); nothing extra is built for that here.

## Done when

- `arm-pass.sh` reads leases through `lease.sh list` and prints `arm`, `held` and `stale` as above, and no line of it reads a START comment.
- `watch` and `dispatch` stake before working or handing off a work order, release at a gate or when done, and never let a subagent stake: nothing in `skills/watch` or `skills/dispatch` still treats a START comment as the claim.
- The arming report lists held and lapsed cards.
- The nine smoke cases above exist and `tests/smoke.sh` is green.

## Risks

- **The interface of `lease.sh list`.** This card needs `list` to print the card uuid and a minutes-left or minutes-lapsed figure per held card, and to apply the 35-minute clock guard itself. Card 0f83a9dd's body says only "one line per held card: title, holder, time left, lapsed or not". It must add the uuid, or `arm-pass.sh` falls back to matching titles, which can repeat.
- **Ordering.** Smoke on `main` stays red at the stamp gate until the guide-v117 card lands (card 0f83a9dd depends on it too), and the lease script must exist before these prose calls to it do.
- **A START-only card is now free.** A card an older session claimed with START and no lease will read as an `arm` after this ships. A minor release, with the lease entry in the changelog, is the cover; there is no migration.
- **Restamps and move authorship.** `classify-event.sh` reads a move's author from a `modified.by` under 120 seconds old. A lease renewal by another session restamps `modified`, so an owner move onto a card within two minutes of a renewal reads as an agent move and is dropped. That needs a card held by another session and moved by the owner mid-work, so it is rare and costs the owner one repeat move. Case 8 pins the part this card can fix (a lease write is `body`); the rest is the cost of the ruling that every lease write restamps `modified`.
- **A handler's commit can carry a live lease**, and the release after its report leaves the card file modified until the next board commit. Both are the ruled consequences of "never committed alone" and "the session releases after".
- **A router stake waits a second** (write, wait, read back). One per work order, so a spawn is delayed by about a second.

## Depends on

- [lanework: a lease script to stake, renew, check and release a card lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb): `lease.sh`, its `list` output, and `lanework/references/writes.md`, where the lease rules are stated once.
- [work: card-writing scripts check the lease, and START shrinks to a short plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa): the farmed-prompt wording, and `companions.md` no longer reading a START as a claim.
- [Skills target agent guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8): through card 0f83a9dd, for the smoke stamp gate.

## Recommendation

Build it after the two cards above, in one pass: the `arm-pass.sh` script and its smoke cases first, then the prose. Taking over a lapsed lease stays out of the arming pass: it needs the two-minute notice, which a router must not block on, and today's `stale` is already report-only. A session asked to work that card takes it over through `work`. No call is left for the owner.

## Source

- [ADR: The session holds the lease; its subagents never stake](lanework://33527992-d72c-417b-85a2-1b62bea96794/064a8796-daab-46ad-9f90-f3c5551d5118)
- [ADR: Every skill takes a lease; START shrinks to a short plan](lanework://33527992-d72c-417b-85a2-1b62bea96794/a812e504-fe1e-4368-a9a8-7d825730f153)
- [ADR: A takeover posts a notice and waits two minutes](lanework://33527992-d72c-417b-85a2-1b62bea96794/6a9abc5d-1f60-4eec-9350-b2e61a40bc9b)
- [ADR: A lease write restamps modified and is never committed alone](lanework://33527992-d72c-417b-85a2-1b62bea96794/aec193e9-55d2-4f60-9cd6-17a05258e307)
- [ADR: Every card-writing script checks the lease first](lanework://33527992-d72c-417b-85a2-1b62bea96794/887ab369-329c-46db-805c-381d29581843)
- [PDR: Leases are seen through agents and reports, not on the board](lanework://33527992-d72c-417b-85a2-1b62bea96794/514933de-5ec5-45bb-9831-1f6ed3ce8f0d)
- [PDR: The lease works when smoke passes and 50 leased cards run clean](lanework://33527992-d72c-417b-85a2-1b62bea96794/67912ed8-4595-4514-8a6f-a5a629b473c8)
