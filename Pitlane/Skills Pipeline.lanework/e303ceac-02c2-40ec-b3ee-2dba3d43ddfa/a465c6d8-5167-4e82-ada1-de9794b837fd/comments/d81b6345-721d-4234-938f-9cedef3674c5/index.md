---
schema: 1
kind: comment
created:  {at: 2026-10-01T16:15:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T16:15:15Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Built in `c859202`. Every done-when is met, but plugin installs fail until the first release creates the `stable` branch.**

- **Decided**: `marketplace.json` sources the plugin from the `stable` branch, and the version lives only in `plugin.json`. Per the Claude Code docs, the manifest's version wins and users only update when it changes, so a second copy could only drift.
- **Decided**: `release.sh` requires a `Version X.Y.Z:` changelog entry, and the GitHub release notes are the changelog lines added since the previous tag.
- **Decided**: the first release is v0.1.0, because `plugin.json` already says 0.1.0 and nothing was ever installed at that version.
- **Accepted limitation**: CI has no `claude` CLI, so `claude plugin validate` runs only in local smoke. CI still runs the manifest checks.
- **Evidence**: `claude plugin validate . --strict` passed. Local smoke: 18 passed, and the new manifest check fails a `plugin.json` with one skill removed. CI run 36890454868 on `c859202`: success, 18 passed, the pitwall case included. `scripts/release.sh 0.1.0 --dry-run`: clean, ten notes lines, nothing changed.
