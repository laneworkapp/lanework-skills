---
schema: 1
kind: comment
created:  {at: 2026-11-21T19:23:32Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-21: built, reviewed and approved, merged to `main` at `21b5284`. Smoke on main at `a8c5b73`: 354 passed.**

- **What changed**: `work/scripts/commit-board.sh` (staged entries are saved once even when the first try only pushes; `LANEWORK_PUSH_TIMEOUT` above 86400 is refused; the push runs in its own session with no terminal, so a password or passphrase prompt fails at once); six smoke cases. Branch head `b548f80`.
- **Review: approved, round 1**, no blocking findings. Nine of ten mutants fail a case; all six notes from the earlier review are closed.
- **Behavior change to know**: a push that needs a typed username, password, passphrase or host-key answer now fails fast and counts as a rejected push. Agent, keychain and GUI askpass pushes are unaffected (reasoned by the reviewer, not measured).
- **Left open, filed as a follow-up card**: the `setsid` return value is unchecked; the fallback that signals the child alone has no case; a signal in the few microseconds before the wrapper installs its handlers is not forwarded.
- **Bump**: patch.
- **CHANGELOG sentence**: "Board commits with --push no longer wait out the push timeout when git asks for a password or passphrase; they fail fast, reject timeouts above one day, and keep your staged changes after a failed push."
