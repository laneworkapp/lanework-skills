---
schema: 1
kind: comment
created:  {at: 2026-10-07T13:12:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-07T13:12:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in v0.2.1. Reported by the owner: the SSH URL fails for some users.**

**Evidence**: `bash tests/smoke.sh; echo $?` printed `smoke: 37 passed` and exit 0, including `claude plugin validate`. A clone of `stable` over HTTPS succeeded with no ssh-agent, no credential helper and no global git config. `scripts/release.sh 0.2.1` tagged `v0.2.1` and moved `stable` to `26b987d`.
**Commits**: `marketplace.json` and `README.md`, then the changelog and the release.
**Note for existing installs**: users who added the marketplace with the old shorthand keep its SSH clone. Removing the marketplace and adding it again with the HTTPS command switches it.
