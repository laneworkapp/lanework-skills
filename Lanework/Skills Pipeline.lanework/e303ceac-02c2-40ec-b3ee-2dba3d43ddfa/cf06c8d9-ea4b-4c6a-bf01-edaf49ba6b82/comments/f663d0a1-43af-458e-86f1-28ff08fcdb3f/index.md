---
schema: 1
kind: comment
created:  {at: 2026-09-28T09:59:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T09:59:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in da5a3bf. The skills now target guide v75.**

- **lanework-boards**: `writes.md` adds `tracker` to the names never signed, and a short § Tracker boards. It says the card `remote`, the `state` label, the comment `remote` and `.tracker.nosync/` are the engine's, and never to be written or copied. It says your writes push. It says each comment on a published card posts publicly as the token's user and emails the watchers. It points at the guide's § Frontmatter for shapes. `format.md` lists `.tracker.nosync/` as app-owned.
- **pitlane**: `writing.md` says comments and ask handles on a synced card are public, and links to `writes.md`.
- **pitwall**: `events.md` counted any `kind: human` comment as the owner's. On a tracker board a pulled comment is `kind: human` under the tracker login, so the watch would have answered strangers in public. It now surfaces those to the user instead.
- **discovery**: no drift. Discovery boards aren't tracker-bound, and its glossary template only uses "Tracker" as an example term.
- **Not drift**: the v75 skills-repo paragraph is app text and now matches the repo. The `assignees` reservation is unchanged. `settle-question.sh` keeps every frontmatter key except `waiting`, so it never drops `remote`.
- **Schema**: `BoardSchema.version` is still 1, so `lanework-schema v1` stays.
- **Evidence**: `tests/smoke.sh`: 17 of 17 passed, including "one version stamp (lanework-agent-guide v75), in authority.md only". README sizes were re-measured on 2026-09-28.
