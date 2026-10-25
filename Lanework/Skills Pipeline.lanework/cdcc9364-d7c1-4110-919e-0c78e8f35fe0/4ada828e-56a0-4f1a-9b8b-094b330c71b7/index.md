---
schema: 1
kind: card
title: "Dispatch arming: answer waiting owner comments in every lane, flag stale claims"
order: 2048
labels: [{text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T16:00:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T16:00:59Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
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

## Out of scope

`watch`'s arming pass. It has the same first two gaps. Owner ruling 2026-10-25: dispatch only.
