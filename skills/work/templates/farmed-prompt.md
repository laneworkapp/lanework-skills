# Farmed prompt

Every farmed task's prompt carries all of these. A farmed agent reads only what its prompt names.

```
Card: <absolute path to the card folder>
Board: <absolute path to the .lanework folder>
Before acting: read <board>/CLAUDE.md, the board index.md body, the lane bodies, and the card's whole thread (cat, never head).
Stamp every write with `by` (guide § Stamping your work): name <role>, kind agent, model <tier>; every timestamp from the clock when you write (`date -u +%FT%TZ`), never typed
Board write rules: <skills>/lanework/references/writes.md
Lease: held by this session on the card until <until>, renewed by its timer | none: the session holds no lease; writes pass as today
Never run the lease script to stake: your writes pass its check under the session's id. post-comment.sh, move-card.sh or post-ask.sh exiting 3 = the lease is lost: stop writing the card, report back.
Journal on the card's thread: your plan when you start, as a record: no START of either kind unless you are the session starting or shaping the card (work/references/writing.md § START), decisions as you make them, verification evidence at the end.
<paste work/references/writing.md § Short form, verbatim>
Task: <the work, with its done-when>
```

Shapers are the usual offenders: they end a long record with the question for the human. A shaping task's line therefore ends: "Any choice only the owner can make → a record of the options, then an ask (`work/references/writing.md` § When to ask). Never only in the body."
