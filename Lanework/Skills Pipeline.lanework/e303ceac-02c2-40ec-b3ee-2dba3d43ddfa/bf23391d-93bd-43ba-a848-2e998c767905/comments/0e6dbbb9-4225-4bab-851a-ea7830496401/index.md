---
schema: 1
kind: comment
created:  {at: 2026-11-16T01:21:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-16T01:21:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Closed: CI installs PyYAML, and the `smoke` run on `main` is green with all 157 cases.**
- **Change**: `.github/workflows/smoke.yml` gains `actions/setup-python@v5` (Python 3.x) and `python3 -m pip install pyyaml` before the smoke step. Commit `d5daf16`'s branch `card/bf23391d-ci-pyyaml`, merged as `e0fb429`. No file under `skills/` changed.
- **Evidence**: pull-request run 43785226186 and `main` run 43785527469 both end `smoke: 157 passed`. Before: run 43719137499 died after case 13 with `ModuleNotFoundError: No module named 'yaml'`.
- **Not covered**: the runner has no `claude` CLI, so case 157's `claude plugin validate` step is skipped in CI and still runs only locally. `stable` stays red until the next release moves it.
