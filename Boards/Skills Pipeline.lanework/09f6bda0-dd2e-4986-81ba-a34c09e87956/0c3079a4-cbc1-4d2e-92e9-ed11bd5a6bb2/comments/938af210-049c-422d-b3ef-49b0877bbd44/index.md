---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:49:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:49:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Proposal finished: scoping ruled A, moved to Proposed for review.**

- **Decided**: each section runs as a function in its own subshell. Slice 3 in the body now says how: plain calls, the case count in a file, a trap per section, shared boards only through fixtures.
- **For review**: slice 1 adds one test-only knob to a shipped script, `LEASE_TEST_PIDLOG` in `lease.sh`, beside the five that exist. Nothing reads it outside tests.
- **Release**: none needed. Tests only, apart from that knob.
