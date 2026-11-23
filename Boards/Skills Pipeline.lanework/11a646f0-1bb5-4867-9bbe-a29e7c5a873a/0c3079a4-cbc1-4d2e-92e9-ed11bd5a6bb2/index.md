---
schema: 1
kind: card
title: "The smoke suite shares variables and process patterns across sections, so new cases break it only in a full run"
order: 2048
created:  {at: 2026-11-23T12:33:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T12:33:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`tests/smoke.sh` is one long script whose sections share shell variables and process patterns. On 2026-11-22 that cost four failed full runs and two killed ones, none caused by a fault in a skill script.

## Evidence

- **Shared variable names.** The pick-order cases set `PL`, which a later case reads as the plan board: the run stopped at case 214. The settle-question cases left `RE` set to a card uuid, which the lease helper `L` passes as `LEASE_TEST_RENEW_EVERY`: every lease timer died at its first poll and the run stopped at case 355. Each showed only in a complete run of 30 to 60 minutes. Both are fixed where they bit; nothing stops the next one.
- **Pattern kills.** `lease_cleanup` runs `pkill -f "$LS _timer"`, and case 13 and the plan cases wait on `pgrep -f "$LS _timer"`. Two runs from the same checkout end or stall each other. Separately, a build agent ran `pkill -f "bash tests/smoke.sh"` and ended every suite run on the machine.
- **A new case edited a claim under a live timer** and the timer rightly declared the lease lost: the run stopped at case 373. Fixed in the case.
- **No way to run one section.** Fixers and reviewers extracted line ranges by hand into their own harnesses, so new cases were never run next to their neighbours before the full run.

## Done when

- A section cannot read a variable another section set by accident: sections scoped (subshell or function with locals) or a guard that fails on a name reused across sections. Which one is an open call for shaping.
- The suite stops and waits on its own timers by pid, never by pattern.
- One section can be run alone by name.
