---
schema: 1
kind: comment
created:  {at: 2026-11-16T11:34:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed: the guide-version check is advisory in smoke and at release, merged to `main` as `aefff3a`.**

- **Built**: `007f71d` and `0d98c48` on `card/110192c0-advisory-guide-check`. Four files: `tests/smoke.sh`, `scripts/release.sh`, `CLAUDE.md`, `README.md`. Nothing under `skills/`.
- **Review**: round 1 asked for changes (the release block exited silently when a board file was missing), round 2 APPROVE at `0d98c48`. Both verdicts are above.
- **Smoke on merged main, in the main checkout** (board guide v118, stamp v114), where it failed before: `smoke: 158 passed`, exit 0, with `note: the board is ahead of the stamp (guide v118, schema v1; stamp guide v114, schema v1): read every skill against it, fix the drift, then bump the stamp in CLAUDE.md`.
- **Release, dry run on main**: `scripts/release.sh 0.8.1 --dry-run` printed `release.sh: warning: the board in the working tree is ahead of the stamp in CLAUDE.md (guide v118, schema v1; stamp guide v114, schema v1): the skills may be unread against it`, then went on to its next check and stopped there (no changelog entry for 0.8.1).
- **Still failing, as intended** (the reviewer's measurements): a second stamp in `CLAUDE.md`, and a guide version in a file under `skills/`.
- **Not checked**: the CI run for this push. A real release cut with the warning showing.
- **Follows**: nothing forces [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) any more. It still carries the catch-up to v118.
