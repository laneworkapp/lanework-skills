---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:34:23Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:34:23Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Rebased onto `2dc7b75`; `arm-pass.sh` now ignores a `board`-signed move receipt. Head `2c06a25`, pushed.**

- **Receipt**: before, a `board` comment would have read as an agent comment and refreshed a dead claim's age. Now it is skipped: not a reply, a claim, a closing, or newer activity. A smoke line covers a receipt on a dead-claim card and one `in-reply-to` an owner comment; both still print `stale` and `comment`.
- **Guide version**: no `guide … vN` in the dispatch prose.
- **Scoped**: arm-pass cases ok 1-3, `check-sizes` 0 wrong, `check-refs` 0 missing. Full gate waits for the slot.
