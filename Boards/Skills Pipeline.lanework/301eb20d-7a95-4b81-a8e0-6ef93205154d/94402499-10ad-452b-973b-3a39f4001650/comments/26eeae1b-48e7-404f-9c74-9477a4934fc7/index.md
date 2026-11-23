---
schema: 1
kind: comment
created:  {at: 2026-11-23T17:35:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T17:35:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Test plan drafted in the body; moved to Proposed for review.**

- **Picks changed from the ask**: the plan tests `setup-matt-pocock-skills`, `to-tickets`, `research`, `grill-with-docs` and `diagnosing-bugs`. `prototype` is dropped, since it outputs only code and chat. `setup` and `to-tickets` are added, since they file work items. The body says why.
- **Main finding from reading the set**: nothing in it looks for a `.lanework` folder. Its tracker skills stop until its setup skill has run, and setup accepts a tracker described in prose. That is the likeliest bridge to a board.
- **Method**: each skill runs under three conditions (no mention of the board, a one-line root pointer, the prompt names it) in a scratch repo under `/tmp` with no remote and failing `gh` and `glab` stubs.
- **Cost**: about 16 to 20 fresh sessions at the sonnet tier on your account.
- **Nothing was run.** The plan comes from reading the installed skill files.
