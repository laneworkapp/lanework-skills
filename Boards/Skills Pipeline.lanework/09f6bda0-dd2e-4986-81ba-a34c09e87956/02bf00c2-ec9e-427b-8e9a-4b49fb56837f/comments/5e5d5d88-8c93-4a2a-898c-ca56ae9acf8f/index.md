---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:50:55Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:50:55Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Shaped and moved to Proposed: an owner action is a legal ask, so no call is open.**
- **Decided**: the guide's ask is "a question, or an imperative" and `waiting` marks a card blocked on a human's reply, so "run these, then reply here" is an ask with `waiting`. No guide change is needed.
- **Decided**: the sweep change is a new row, not a split of "Active, stalled". The fresh case [702953a4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/702953a4-79a8-463e-8887-13113c1118fc) is in Approved, which that row does not cover.
- **Decided**: the Short form also changes, because it is what every farmed agent reads.
- **Rejected**: an option button "Done" on every owner-action ask, since the template allows options only when choosing and adds a Recap line to each.
- **Evidence**: `writing.md` and `sweep.md` read on `main` at `210b30f` and in `guide-v118-anyone` at `07143bc`. That branch changes the Short form line, adds an `@anyone` bullet to § The ask, and edits the `waiting` sentence and the sweep's first row. A draft imperative ask with `@anyone` passes the installed `lint-ask.sh` with exit 0.
