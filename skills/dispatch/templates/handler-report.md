# Handler report

The handler's whole reply: this shape, at most 10 lines, no prose around it. The router parses it, and every extra line is cost in the main context.

```
CARD:   <Board> · <card title> · [<short id>](lanework://<board-id>/<card-id>) | none
EVENT:  <kind> <author>[, <kind> <author>...]
ACTION: <reply | ruling folded | lane exit to <lane> | shaped | build led: <outcome> | no-op: <why> | escalate: <why>>
COMMIT: <short hash, pushed | none>
WROTE:  <absolute path of every board file written, separated by " ; " | none>
LANE:   <lane uuid> in-scope | out-of-scope
GATE:   <what now waits on the owner, one line | none>
ASKS:   <uuid of each ask posted | none>
TIER:   <your model>
ANSWER: <chat events only: the answer, at most 2 lines>
```
