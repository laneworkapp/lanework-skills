---
schema: 1
kind: card
title: "Dispatch arming: answer waiting owner comments in every lane, flag stale claims"
order: 1024
labels: [{text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T16:00:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T16:21:19Z, by: {name: shaper, kind: agent, model: sonnet, session: "board dispatch"}}
waiting: {for: rzen, since: 2026-10-25T16:21:19Z, comment: 3bb86d7d-6249-4a16-9dce-491ae72f1c7b}
---
At arming, `/dispatch` sweeps only the agent lanes, and an `arm` event only checks for a work order. Owner comments left unanswered while no watch ran are never picked up.

## Gaps (`dispatch/references/routing.md` § Arm step 3, `dispatch/references/handler.md` § Act)

- **Unanswered owner comments**: `arm` doesn't apply the `comment` rule, which answers each owner comment with no agent reply `in-reply-to` it. A claimed agent-lane card with a waiting owner reply is a no-op.
- **Non-agent lanes**: Ideas, Issues, Tasks and Proposed aren't swept. An owner question left there waits until the owner posts again.
- **Stale claims**: a card claimed by a handler that died with its session (a quit, a resume) is skipped as claimed and stays stuck in Active, along with any leftover worktree.
- **Cost**: one handler per agent-lane card, most of them no-ops on a busy Approved lane.

## Direction

- The arming pass classes each card by script, never by the router reading it. A card with an owner comment that has no agent reply `in-reply-to` it, in any lane not out of scope, gets a `comment` event. An unclaimed agent-lane card gets an `arm` event. Approved gets its top card only.
- A claim whose session isn't the current dispatch and has no live session behind it → flagged to the owner in the arming report, never auto-released.

## Proposal

- **New script** `skills/dispatch/scripts/arm-pass.sh <board>`: one tab line per card to route, classed from the files (`in-reply-to` on comments, `created.by`, START comments), never by a model. `comment` for a card whose newest owner comment has no agent reply `in-reply-to` it, in any lane. `arm` for an unclaimed card in an `agent` lane (Approved: its top card only). A card with both gets the `comment` line only. Lane scope stays the handler's call: it reports `out-of-scope` and the router excludes the lane.
- **Stale claims**: the same script prints a `stale` line for each claim it finds (a START comment with no later closing comment) that fits the rule in the open call below. The router adds the lines to its arming report and never routes them.
- **`routing.md` § Arm step 3** swaps the `read-board.sh` loop for the script's lines and says what the report carries. **`handler.md` § Act** `arm` row: an `arm` on a card with an unanswered owner comment answers it first.

## Files

`skills/dispatch/scripts/arm-pass.sh` (new), `skills/dispatch/references/routing.md`, `skills/dispatch/references/handler.md`, `tests/smoke.sh` (a case), and the README word counts if `tests/check-sizes.sh` says so.

## Verification

`bash -n` on the script. A smoke case on a throwaway board with: an owner comment unanswered in Ideas, Proposed and Done; one answered by an agent reply; a claimed Shaping card; an unclaimed Approved pair; a START old enough to be stale and one fresh. Assert each line the script prints. `tests/smoke.sh` passes. Output quoted in the closing comment.

## Done when

On that fixture board the script prints exactly the expected `comment`, `arm` and `stale` lines, `routing.md` and `handler.md` describe the new arming pass, and a dispatch arm in a trial run on a scratch board answers the unanswered owner comment in a non-agent lane. `/clear` and restart behaviour is tested in the same trial.

## Risks

- A long board has old unanswered owner comments in Done, and the first arm spawns a handler for each.
- A START with a closing comment in a different shape reads as still claimed.

## Recommendation

Build the script as above, skip the sweep in Done, and flag stale claims by age.

## Open calls

- **Stale-claim rule**: when is a claim stale? See the ask on the thread. Recommended: A.
- **Sweep scope**: does every lane include Done? See the ask on the thread. Recommended: A.

## Out of scope

`watch`'s arming pass. It has the same first two gaps. Owner ruling 2026-10-25: dispatch only.
