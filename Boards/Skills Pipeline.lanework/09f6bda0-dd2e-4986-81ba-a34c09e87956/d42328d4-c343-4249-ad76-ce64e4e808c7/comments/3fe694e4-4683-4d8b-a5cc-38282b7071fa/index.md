---
schema: 1
kind: comment
created:  {at: 2026-11-12T18:56:52Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
modified: {at: 2026-11-12T18:56:52Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
**Shaped: three small edits, blocked only on how long the grace period runs after the notice release.**
- **Plan**: read the repo; the only references to `marketplace.json` are the CLAUDE.md layout row and the plugin block of `tests/smoke.sh` (it loads the file and asserts two things about it).
- **Evidence**: README and CHANGELOG already carry the central-marketplace notice on `main`; the latest tag is v0.7.0 (October), so the notice is unreleased. No `stable` ref exists locally.
- **Decided**: no `skills/` change and no new changelog entry; the body lists the files, checks and done-when.
- **Options for the open call**:
  - A (recommended): ship the notice in the next release, remove the file in the release after it.
  - B: remove it 30 days after the notice release, whichever release comes next.
- **Rejected**: removing in the notice release itself, which gives existing users no grace.
