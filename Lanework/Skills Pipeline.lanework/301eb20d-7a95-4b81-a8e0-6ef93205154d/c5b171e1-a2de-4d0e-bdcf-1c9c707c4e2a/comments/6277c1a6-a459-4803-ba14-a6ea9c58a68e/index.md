---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:42:18Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:42:18Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Shaped: two files change, `README.md` and `CHANGELOG.md`, and no call is open, so it moves to Proposed.**
- **Decided**: `README.md:159` takes the new URL. Line 160 stays, since `lanework-marketplace` is also named `lanework` and lists the plugin from `stable`. The line 168 clone block keeps this repo's URL.
- **Decided**: the CHANGELOG entry sits under a new November 2026 heading and is not the `Version 0.8.0: ` line. `scripts/release.sh:26` wants one such line per release, which is for whichever 0.8.0 card builds first.
- **Rejected**: dropping `.claude-plugin/marketplace.json` here. Users still on the old marketplace read it from `main`, so the follow-on card waits for a release.
- **Accepted limitation**: whether removing the old marketplace uninstalls the plugin is not known yet. The build checks it in a throwaway config dir before the entry is worded.
- **Evidence**: read-only `gh api` on `laneworkapp/lanework-marketplace` returns `.claude-plugin/marketplace.json` named `lanework`, one plugin `lanework`, source this repo's `stable`. `git ls-remote` shows `main` at cc4ae24. Grep found the old URL only at `README.md:159`, `README.md:168`, `.claude-plugin/marketplace.json:13`.
