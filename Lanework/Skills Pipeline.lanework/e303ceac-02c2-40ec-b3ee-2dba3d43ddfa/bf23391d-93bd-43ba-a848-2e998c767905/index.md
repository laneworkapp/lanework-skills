---
schema: 1
kind: card
title: "CI smoke fails on every push: the runner has no PyYAML"
order: 60416
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-16T00:38:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-16T01:21:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
The `smoke` workflow has no green run on `main` in its last 200 runs, because the GitHub runner's `python3` has no `yaml` module and `tests/smoke.sh` imports it.

**Evidence** (run 43719137499, 2026-11-15, commit `6215155`):

```
ok 13 - heal dry run lists every kind of damage and writes nothing
ModuleNotFoundError: No module named 'yaml'
heal check failed: root-key-mapping
```

The same commit passes locally in a clean checkout: `smoke: 157 passed`, with PyYAML 6.0.3 installed.

**Where**: `tests/smoke.sh` imports `yaml` in its helpers (lines 21, 36, 66) and several cases. `.github/workflows/smoke.yml` installs only `fswatch`.

**Effect**: CI checks 13 of 157 cases. `scripts/release.sh` runs smoke locally and never reads CI, so releases still go out, each with a red run on `stable`.

**Fix direction**: install PyYAML in the workflow before the smoke step. Not checked: whether a plain `pip3 install pyyaml` is allowed on `macos-latest`, whose Python may be marked externally managed. No file under `skills/` changes; check first that no shipped script imports `yaml` (a grep over `skills/` for `import yaml` found none).

**Done when**: a push to `main` shows a green `smoke` run with all cases.
