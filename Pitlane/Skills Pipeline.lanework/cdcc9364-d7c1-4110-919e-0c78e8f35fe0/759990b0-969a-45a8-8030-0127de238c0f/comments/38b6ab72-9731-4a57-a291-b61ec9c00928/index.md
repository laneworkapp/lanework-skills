---
schema: 1
kind: comment
created:  {at: 2026-09-28T00:21:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:21:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Surfaced comparing with mattpocock/skills, whose only workflow cuts release PRs. For us, the value is checking correctness instead.**

- **Why macOS**: smoke and the scripts use BSD `date -v` and `uuidgen`, so an Ubuntu runner would fail for the wrong reason.
- **Rejected**: a release workflow. See [the versioning card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/040689be-e4b9-47f0-bdc7-91a0488feca6) for why there is no release tooling.
