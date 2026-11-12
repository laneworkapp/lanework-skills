---
schema: 1
kind: card
title: "Let an agent clear waiting when it records an owner ruling given off the board"
order: 6144
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-06T00:08:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-11-12T18:56:23Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
waiting: {for: anyone, since: 2026-11-12T18:56:22Z, comment: b124ec22-59e3-47ee-a468-0bf9a88ae93b}
---
Decide whether the skills may tell an agent to clear a card's `waiting` mark itself after recording an owner ruling given outside the board.

## Problem

The guide (v117, Mentions) says "Only the app clears it", and `work/references/writing.md` § The ask says "Never remove it yourself". The owner sometimes rules in chat and wants stale marks gone. Passed on by the Lanework Pitwall session on 2026-11-05: an agent may clear `waiting` when it records the ruling, citing where it came from.

## Constraint

The guide wins over the skills (`lanework/references/authority.md`; repo `CLAUDE.md`: "The in-board agent guide wins"). The app clears `waiting` itself once a human comment lands on the card after `since`, or replies to the ask by `in-reply-to`. A skill telling agents to clear it would contradict the guide, and an agent that clears it hides a pending ask from the lane header.

## Open call

**Open call: which route?** Recommended: A.

- **A (recommended): keep the rule, document the chat case.** No new power. Add to `work/references/writing.md` § The ask: when the owner rules in chat, the agent records the ruling on the card (cites the chat), leaves `waiting`, and links the ask in the chat reply so one click or one line from the owner on the card clears it. Smallest change, stays inside the guide.
- **B: app change first.** Request the guide/app allow agent clearing (e.g. a cited ruling record), wait for a guide bump, then update the skills and stamp. Right if the owner wants the behaviour; blocked on the app.
- **C: skills go further than the guide.** Rejected in advance: breaks the authority chain and the guide-wins rule. Listed only so the owner can overrule it.
- **D: drop the card.** The current rule already covers it.

## Plan if A

- Files: `skills/work/references/writing.md` (one sentence in § The ask, "Owner in a live chat" bullet in § When to ask extended). No other skill file restates the rule (grep of `skills/` for clear/remove waiting finds only this file, `watch/references/events.md` and `discovery/references/rounds.md`, both describing the app's clearing).
- No script changes, so no new smoke case. `tests/check-sizes.sh` runs only if README word counts move (they should not).

## Verified by

- `tests/smoke.sh` passes (covers `check-refs.sh`, `check-sizes.sh`, guide-version gate).
- The edited page read through against guide v117 § Mentions: nothing instructs an agent to remove `waiting`.

## Done when

- `grep -n "clear" skills/work/references/writing.md` shows the waiting rule unchanged ("Only the app clears it") and the chat-ruling procedure present in exactly one place.
- `tests/smoke.sh` exits 0.
- The closing comment quotes the diff.

## Risks

- Adding a procedure for the chat case could read as permission to clear; word it as "leave the mark".
- Owner may prefer B: then A's wording is a stopgap and must not be stamped as the final rule.
