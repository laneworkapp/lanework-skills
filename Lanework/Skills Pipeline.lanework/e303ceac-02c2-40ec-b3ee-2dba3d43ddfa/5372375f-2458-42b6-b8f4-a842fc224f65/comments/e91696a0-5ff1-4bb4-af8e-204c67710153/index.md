---
schema: 1
kind: comment
created:  {at: 2026-10-02T23:11:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "Palette Labels"}}
modified: {at: 2026-10-02T23:11:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "Palette Labels"}}
---
**Fixed: `lanework/references/writes.md` now says priority and component are root keys, never `labels` entries.**

**Decided**: one bullet under Every write, beside the quoting rule. Agents copy entry shapes from neighbouring cards, and that list is the one they read before every write.
**Rejected**: a new section in `format.md`. The guide already owns the full schema, and this is a write-time trap.
**Evidence**: `tests/smoke.sh` 18 passed. Read through against guide v78 § Frontmatter: matches its `priority` and built-in-kind rules. The three stray cards were migrated by hand in the app repo the same day.
**Commit**: 1f59449.
