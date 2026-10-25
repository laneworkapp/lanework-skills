# Handler

One fresh subagent per event, or per batch of queued events, on one card. Spawned by the router (`routing.md`). It does what the `watch` session did for that event and returns a fixed report. Its context is the card's thread, never the router's memory.

## Read, every time

1. `work/SKILL.md`, then the chain in `lanework/references/authority.md`: the guide, the board body, the card's lane body.
2. **Lane out of scope** (its body says so) → stop. Report `LANE: <uuid> out-of-scope`, write nothing.
3. **The card whole** (`lanework/references/reading.md`): body, whole thread, every linked card. Resolve its path fresh (`lanework/references/writes.md` § Paths). Bulk: diagnose first (§ Act).
4. `work/references/writing.md` before any comment.

## Act

Through `watch/references/events.md` items 3–7 and `watch/references/responding.md`, read with these swaps:

| watch says | a handler does |
|---|---|
| the main session, the watch session | this handler |
| stamp `session: "board watch"` | `by: {name: handler, kind: agent, model: <tier>, session: "board dispatch"}` |
| the watch session leads the build | this handler leads it (`work/references/lead.md`): worktree, fixer, reviewer, merge, close |
| § Report to the user | the report (`templates/handler-report.md`) |

Per event kind:

| kind | action |
|---|---|
| `comment` | answer each owner comment with no agent reply `in-reply-to` it yet. Queued events → one pass, each answered once. All answered → no-op |
| `move`, `arm` | a work order only when the card is unclaimed (`work/references/companions.md`) and its lane is an agent lane by the board and lane bodies. Lane order rules hold: Approved takes only its top card. Else no-op, reason in `ACTION` |
| `bulk` | the diagnosis in `watch/references/events.md` item 5. Each card it finds moved into an agent lane → act on it here as a move. Into any other lane → `GATE` |
| `chat` | answer the owner's question from the board in `ANSWER`. Write nothing |

## Escalate

On sonnet, and the work needs opus (a spec that still leaves hard calls: `work/references/tiers.md`) → before any write, report `ACTION: escalate: <why>`. The router re-spawns at opus.

## Commit

Board writes → one commit in that board's repo, then push (`lanework/references/writes.md` § Git). Handlers share the repo: `git commit --only -- <paths>`. On an `index.lock` error, wait 2s and retry, up to 5 times. Never delete the lock.

## Report

`templates/handler-report.md`, filled, nothing else. `WROTE` names every board file written, so the router registers each as a self-write.
