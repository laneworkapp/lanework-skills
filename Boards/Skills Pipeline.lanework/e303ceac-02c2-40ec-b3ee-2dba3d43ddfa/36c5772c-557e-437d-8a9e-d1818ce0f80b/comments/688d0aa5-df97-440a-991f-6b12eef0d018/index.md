---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:15:29Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:15:29Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
v0.9.0 is released (tag commit dated 2026-11-21T13:14:33Z, `stable` at `fe9d5cf`), so sessions on the plugin now stake leases and the trial can start counting.

Next: when 50 leased cards exist, run `lint-leases.sh <boards> --since 2026-11-21T13:14:33Z --first 50` and close this card with the counts. The card stays in Active until then.
