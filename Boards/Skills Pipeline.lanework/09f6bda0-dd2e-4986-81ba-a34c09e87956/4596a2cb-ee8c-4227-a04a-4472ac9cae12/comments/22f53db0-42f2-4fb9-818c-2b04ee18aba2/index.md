---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:59:15Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:59:15Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**All five points settled from the guide and the Card Lease Discovery board; no open call remains.**

- **Decided, which cards**: Q, T, F, ADR, PDR get `<prefix><n>` with a counter per prefix; the discovery map and topic cards get the fixed `Map` and `Topic`, as the example does. Scripts mint Q, T, ADR and PDR; facts by a template line, because no script files them.
- **Decided, pipeline boards**: out of scope. No skill files a pipeline card, and a board's prefix is its own sheet's choice. The link rule reads any `cite-as`, so a board that numbers by hand is picked up.
- **Decided, older boards**: titles are never rewritten, `heal` gets no rule (a title prefix is not damage). Minting counts both `cite-as` and a legacy `<prefix><n>: ` title prefix.
- **Decided, older apps**: scripts write `cite-as` and a bare title only when the guide line reads v117 or later, else as today. `found-board.sh` writes no guide, so unopened boards read as old.
- **Accepted limitation**: two sessions minting at once. Scan late, print the citation, validator warns `duplicate-cite-as`. No lock.
- **Rejected**: a `find_cite` lookup script. `read-board.sh` and `frontier.sh` showing the citation is the lookup, and every script already takes a uuid.
- **Found**: `resolve-ticket.sh` derives `unblocked T<n>` from the title prefix (`${t%%:*}`); dropping prefixes would break it, so it is in scope.
- **Found**: this board's `.schema/card.json` still describes `cite-as` as "Proposed, unruled — not read by this build", against the v117 guide. App-written, left alone.
- **Evidence**: the example's older link text (`[Q2: One machine…]`) was not rewritten and still resolves, so stale link text is harmless.
