---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:53:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:53:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Filed straight into Active because the owner asked for the work in chat, which is the go-ahead the two gates exist to collect.**

- **The owner, 2026-11-14, in chat**: "for discovery skill when an superceding ADR lands create relation records"
- **Decided**: a flag on `file-record.sh`, since that script is the one place a record card is made. PDRs are covered by the same flag.
- **Decided**: the relation sits on the new card only. The guide stores no inverse.
- **Rejected**: having the script also set the old card's status and post its comment. The owner asked for the relation; the rest stays as `records.md` has it.
- **Not checked**: how the app draws a `supersedes` relation.
