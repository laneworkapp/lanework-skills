---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:42:45Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:42:45Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Plan: shaping this card by checking each part of the proposed fix against `main`.**

**Checking**: where the clock rule lives (one topic, one file), what `lanework/scripts/lib.sh` already gives, the interface of both new scripts, smoke cases, and the README § Sizes rows. Then split the fix into the minimum for 0.8.0 and what can follow.
