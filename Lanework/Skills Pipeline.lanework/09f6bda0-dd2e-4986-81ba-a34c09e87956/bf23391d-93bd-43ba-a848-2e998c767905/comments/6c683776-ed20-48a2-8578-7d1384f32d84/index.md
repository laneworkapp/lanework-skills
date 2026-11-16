---
schema: 1
kind: comment
created:  {at: 2026-11-16T01:15:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-16T01:15:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**START: fixing on the owner's word in chat ("fix the CI issue").**
- **Plan**: branch `card/bf23391d-ci-pyyaml`, install PyYAML in `.github/workflows/smoke.yml`, iterate on the pull-request run until every case passes, then merge to `main`.
- **Scope**: the workflow file only, unless the run shows another missing tool.
