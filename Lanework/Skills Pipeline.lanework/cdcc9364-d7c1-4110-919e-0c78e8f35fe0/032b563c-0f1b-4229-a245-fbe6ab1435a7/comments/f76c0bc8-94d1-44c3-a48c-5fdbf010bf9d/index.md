---
schema: 1
kind: comment
in-reply-to: 5a9f2371-b687-4396-bc47-00385383cca0
created:  {at: 2026-10-25T16:20:15Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T16:20:15Z, by: {name: handler, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Three filing scripts skip the destination lane's `card-defaults`, so a lane that sets default labels gets cards without them.**

- **The rule**: the guide (§ Frontmatter, lanes) says a lane's `card-defaults.labels` apply to a card born into it. The app does this only for cards it makes, so agents must union them in (`lanework/references/writes.md` § Placing).
- **The gap**: `plan/scripts/file-ticket.sh` renders its frontmatter from `ticket-card.md` and `mv`s it into the lane. It never reads the lane's defaults. `discovery/scripts/file-question.sh` and `file-record.sh` have no `card-defaults` handling either (grep finds none in any script).
- **Why it surfaced now**: v101's Board Settings lets the owner set lane defaults in the app, so any board can have them, not only hand-edited ones.
- **Likely fix**: one helper in `lanework/scripts/lib.sh` reads the lane's `card-defaults.labels`, stamps kinded entries from `config.labels`, and merges case-insensitively with the script's own labels (own value wins for a `single` kind). The three scripts call it, plus a smoke case with a defaulted lane.
- **Not checked**: whether `found-*.sh` need it (they set lanes up, so likely not).

The card is still in Ideas, unshaped. Triage it out to Shaping when you want the fix scoped.
