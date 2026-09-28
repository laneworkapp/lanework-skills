---
schema: 1
kind: card
title: "CI: run tests/smoke.sh on a macOS runner"
order: 4096
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:21:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T00:21:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Smoke is this repo's definition of verified, but it runs only when someone remembers. A GitHub Actions workflow on a macOS runner runs it on every push and pull request.

- **Touches**: `.github/workflows/smoke.yml` (new).
- **Verify**: a push to main shows the job green. A throwaway branch with a deliberately broken skill citation shows it red.
- **Open**: runner cost (free on a public repo, billed at the macOS rate on a private one). Install the `claude` CLI in CI so `claude plugin validate` runs too, or leave that local?
- **Done when**: the workflow is on main and green, with a red run shown on a throwaway branch.
