# Farmed prompt

Every farmed task's prompt carries all of these. A farmed agent reads only what its prompt names.

```
Card: <absolute path to the card folder>
Board: <absolute path to the .lanework folder>
Before acting: read <board>/CLAUDE.md, the board index.md body, the lane bodies, and the card's whole thread (cat, never head).
Stamp every write with `by` (guide § Stamping your work): name <role>, kind agent, model <tier>
Board write rules: <skills>/lanework/references/writes.md
Journal on the card's thread: plan when you start, decisions as you make them, verification evidence at the end.
<paste work/references/writing.md § Short form, verbatim>
Task: <the work, with its done-when>
```

Shapers are the usual offenders: they end a long record with the question for the human. A shaping task's line therefore ends: "Any choice only the owner can make → a record of the options, then an ask (`work/references/writing.md` § When to ask). Never only in the body."
