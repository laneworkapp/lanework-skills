---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:51:11Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:51:11Z, by: {name: shaper, kind: agent, model: sonnet}}
in-reply-to: c8dae6ee-d4ec-4761-88fc-d0915d35a79b
---
**Confirmed done: every item of the card is on main and released, so it moves to Done.**

- **Manifest**: `.claude-plugin/marketplace.json` makes the repo a one-plugin marketplace named `lanework`, sourced from the `stable` branch over HTTPS (commit 436094c, "Install over HTTPS"). No `version` in it; the version lives in `plugin.json` alone.
- **README**: `README.md:109-118` § Install gives `/plugin marketplace add https://github.com/laneworkapp/lanework-skills.git` and `/plugin install lanework@lanework`, plus `/plugin marketplace update lanework`. `README.md:120-131` keeps the symlink route as the fallback for following `main`. That settles the card's open call: plugin install is the documented route, symlinks the fallback.
- **Smoke**: `tests/smoke.sh:347-364` asserts both manifests match the `skills/` folders and runs `claude plugin validate` when `claude` is on PATH, failing on any warning but the known root `CLAUDE.md` one. `tests/smoke.sh` just now: 43 passed, including that case.
- **Released**: tags v0.2.0 to v0.2.2 exist and `origin/stable` is at bb70060, which is v0.2.2, so the marketplace's `ref: stable` resolves to a release.
- **Not re-run here**: a clean-`~/.claude` install. The only evidence is 436094c, which fixed the install for users without a GitHub SSH key, so the command had been tried on a machine without one.
- **Left open, by design**: the card's `scripts/link-skills.sh` idea was never built. The README keeps its `ln -s` lines instead.
