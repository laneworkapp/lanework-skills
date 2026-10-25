---
schema: 1
kind: card
title: "Dispatch skill: a flat-context watch session"
order: 3072
labels: [{text: dispatch, kind: {type: skill, text: Skill}}, {text: watch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T01:06:26Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "skills chat"}}
waiting: {for: rzen, since: 2026-10-25T01:09:53Z, comment: 1ebe6a1b-12e1-4cf0-b28a-44a7ea04976e}
modified: {at: 2026-10-25T01:09:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
A new skill, `dispatch`, turns a long-running watch session into a pure router that hands each board event to a fresh subagent, so the main context stays flat however many events arrive.

## Problem

A `/watch` session grows its context per event, not per hour, and recycling it is disruptive. The growth is structural in the `watch` skill, not incidental:

- `watch/references/events.md` step 3 ("read whole") pulls every card thread and body the owner touches into the main context.
- Step 5 (BULK diagnosis: `git status`, `find`, `.log` greps) runs in the main context.
- `watch/references/responding.md` makes the watch session the lead of every build cycle, so fixer and reviewer reports, evidence review and synthesis accumulate there too.
- Monitor notifications, self-write skips and `yq` output are small individually and relentless over hours.

The watch session is a dispatcher, a reader and a lead at once. Only the dispatcher needs to be long-lived.

## Goal

An interactive, long-running session that follows one or more boards, where the main context pays a bounded cost per event (target: median ≤ 2k tokens, independent of card or thread size), and nothing the owner writes goes unanswered. The session remains a normal chat the owner can talk to.

## Design

`dispatch` is the routing layer between the Monitor stream and the handling. The main session becomes a pure router; a fresh subagent handles each event.

### The router (main session) does, per event, and nothing else

1. Runs `dispatch/scripts/classify-event.sh <board> <changed paths...>`, which emits one line: event kind (`comment`, `body`, `move`, `bulk`, `self`, `excluded`), card UUID, card title, lane, author kind (from `created.by` via `yq`), and whether the paths match the self-writes registry. The model never opens a card, thread or lane body to classify.
2. Drops `self` and `excluded` silently.
3. Checks the in-flight set (`dispatch/scripts/state.sh`): a handler already running on that card → the event is queued for that card and nothing is spawned.
4. Spawns one handler `Agent` (fresh, never `fork`), tier per `work/references/tiers.md`: the brief is `dispatch/templates/handler-prompt.md` filled with board path, card path, event kind, changed paths, and the by-path instruction to read the authority chain itself. Nothing else goes in. Runs in the background.
5. On the handler's completion notification: records the handler's reported write paths into the self-writes registry, drains that card's queue into one follow-up handler if any events arrived meanwhile, and gives the user one line: board · card title · action · commit short hash · what now sits at a human gate.

The router never reads a thread, never runs the BULK diagnosis, never folds a ruling, never leads a build. Everything in `watch/references/events.md` steps 3–6 and all of `watch/references/responding.md` move into the handler.

### The handler (one fresh subagent per event)

- Reads `work/SKILL.md`, `lanework/references/authority.md`, the board guide, board body and the card's lane body by path, then the card whole (`lanework/references/reading.md`). The thread is its cumulative context; it does not need the main session's memory of earlier events.
- Acts per `watch/references/responding.md` as it stands today: reply to an owner comment, fold a ruling, apply the lane exit, act on a move into an agent lane, post an ask. Stamp `session: "board dispatch"`.
- A substantial coding card: the handler itself is the lead (`work/references/lead.md`) and spawns fixer and reviewer. The main session sees only the lead's final report.
- Commits its writes in the board's repo per `lanework/references/writes.md` § Git, then pushes.
- Returns `dispatch/templates/handler-report.md`, fixed shape, ≤ 10 lines: card, event kind, action taken, commit hash, paths written (for the self-writes registry), what waits at a human gate, open asks posted. No prose beyond the template.

### State lives in files, not in context

`<scratchpad>/dispatch/` holds: boards watched, the in-flight set, per-card event queues, and the self-writes registry (path + timestamp, pruned after a few minutes). `dispatch/scripts/state.sh` is the only writer. Consequences:

- Arming (`/dispatch <board>...`) reads the board guide once for the watcher's sake and the `agent` lanes' names from `lanework/scripts/read-board.sh`; it does **not** read every lane body into the main context (handlers read the lane they act in). The arming pass over unclaimed cards in agent lanes stays, each spawned as a `move` event to a handler.
- After `/clear` the Monitor survives (`watch/references/arming.md`); `/dispatch` re-arms from the state file in one short read, no board re-read.

### Shared with `watch`

`watch/scripts/watch-boards.sh` and `watch/references/arming.md` § Monitor are reused unchanged (the fswatch-is-only-a-trigger header stays load-bearing). `work/references/companions.md` claims (START/plan comments) remain the cross-session protocol; the in-flight set is only the intra-session one.

## Files

New skill `skills/dispatch/`:

- `SKILL.md`: hub; run as `/dispatch <board> [<board>...]`, `disable-model-invocation: true` like `watch`.
- `references/routing.md`: the router loop above, what the main session may and may not do.
- `references/handler.md`: what a handler reads, does, and returns.
- `templates/handler-prompt.md`, `templates/handler-report.md`.
- `scripts/classify-event.sh`, `scripts/state.sh` (both source `../../lanework/scripts/lib.sh`).

Touched elsewhere:

- `skills/watch/SKILL.md`: one line pointing at `dispatch` as the flat-context mode. `watch` itself is unchanged in this card; folding its events and responding into `dispatch` is a follow-up card once the trial numbers hold.
- `.claude-plugin/plugin.json` `skills` list, `README.md` skills table and install commands, the board's `Skill` label value `dispatch`.
- `tests/smoke.sh`: `classify-event.sh` on a throwaway board for an owner comment, an agent comment, a lane move, a BULK burst, a registered self-write and a change in an out-of-scope lane; `state.sh` round-trips (in-flight add/remove, queue drain, registry prune).

## Verification

- `tests/smoke.sh` green with the new cases.
- A measured trial on `~/.pitcrew-ledger-rig/Pitlane/Scratch Pipeline.lanework` (never this board): one `/dispatch` session handling ≥ 20 owner events of mixed kinds (comments, rulings, a move into Approved, a BULK move), recording the main-context token count from `/context` before and after each event, and the same 20 events replayed under `/watch` for comparison. Numbers quoted in the closing comment.

## Done when

- `/dispatch <board>` arms, and handles a comment, a ruling, a move into an agent lane and a BULK move end to end, with every card and thread read happening in a handler (no `Read`/`cat` of a card path appears in the main session's transcript).
- Median main-context growth per handled event ≤ 2k tokens over the trial, and no owner comment in the trial is left unanswered or answered twice.
- Smoke covers the six classify cases and the state round-trips.
- README, `plugin.json` and the board's `Skill` label carry `dispatch`.

## Risks

- **Double handling** when the owner posts twice on one card while a handler runs: covered by the in-flight set and per-card queue; the follow-up handler sees both comments in the thread.
- **Self-write detection misses** (a handler's write re-fires the watcher before its report lands): the registry is written from the handler's report on completion, so a race window exists. Mitigation: `classify-event.sh` also treats a comment stamped `session: "board dispatch"` as `self`, independent of the registry.
- **Lost continuity**: the main session no longer remembers what happened on a card earlier in the day. By design: the thread is the record, and the handler reads it whole. The user-facing one-liners keep a skim-able log in chat.
- **Handler cost**: each handler re-reads the authority chain and the card. That cost moves to disposable contexts, which is the point; tiers keep it cheap for comments and rulings.

## Decided

- **Entry point** (owner, 2026-10-25): a separate `/dispatch` beside `/watch` for the trial. `watch`'s events and responding fold into `dispatch` once the numbers hold.

## Open calls

- **Handler tiers**: per `work/references/tiers.md` as-is, or every handler on opus for the trial. **Recommended: tiers as-is (comments and ruling-folding on sonnet, build leads on opus, inherit only when the handler must make architectural calls).**
