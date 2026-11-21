---
schema: 1
kind: comment
created:  {at: 2026-11-21T16:45:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; to Proposed.

**Reproduced**: item 1. A planted `.lease-write.<card>.1.lanework-tmp` was deleted by `lease.sh stake`, because `kill -0 1` fails with "operation not permitted".

**Reasoned, not run**: item 2 (the temp file carries the script's pid). It needs a second volume; the smoke case goes in the RAM disk case.

**Dropped**: item 3. The shaper ran `echo "11e: S\x"` under bash and it printed unchanged. The reviewer had seen `S ` in a failure message; that was not reproduced.

**Kept**: item 4, the sentence stated twice in `writes.md`.

**Order**: builds after `f6743778` and `ef4e28f3` merge. Both edit `lease.sh`.

**Open calls**: none.
