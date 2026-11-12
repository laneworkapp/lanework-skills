---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:42:28Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:42:28Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
Decision: one rule, not a shaping-only step. The write rule lives in `lanework/references/writes.md` § Placing beside the `card-defaults` bullet; the Shaping row of `work/references/sweep.md` (line 26) points at it. Two prose files plus the README size counts, no script, so no smoke case. Trivial in size, but it stays out of the 0.8.0 set until the owner answers the two open questions.

Question 1, scope. A: every lane an agent writes a card into (one rule covers shaping, filing and moves; lanes grouped by date are a no-op). B: Shaping only (the rule gains a lane condition, and Ideas/Issues/Proposed cards still land in the trailing section).

Question 2, `by: due`. A: never assign (a date is the owner's call; shaping leaves it). B: assign a date when the proposal implies one (agents would be inventing deadlines).

Body rewritten with the full proposal.
