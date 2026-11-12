---
schema: 1
kind: comment
created:  {at: 2026-11-05T00:31:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
modified: {at: 2026-11-05T00:31:08Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "marketplace chat"}}
---
**Founding: the plugins move behind one central marketplace, so this repo stops being the catalog.**
- **Decided**: one marketplace repo, `laneworkapp/lanework-marketplace`, lists every Lanework plugin. Each plugin keeps its own repo and `stable` branch. The marketplace name stays `lanework`, so `lanework@lanework` and `/lanework:<skill>` are unchanged.
- **Rejected**: a monorepo holding every plugin. It loses each plugin's own `stable` channel and release cycle.
- **Evidence**: `lanework-marketplace` was created and pushed with one entry, `lanework`, sourced from this repo at `stable`. `claude plugin validate .` passed, and its `scripts/check.sh` found the ref.
- **Order**: this card, then [Drop the plugin repo's own marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7). [Move the owner's install](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/702953a4-79a8-463e-8887-13113c1118fc) is independent.
