---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:03:10Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T02:03:10Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Done: the smoke job goes red on a broken citation. Run `38015366980` on pull request #1 failed, and the pull request is closed unmerged with its branch deleted.**

- **Setup**: branch `ci-red-check` (`5f93059`) pointed `skills/work/SKILL.md`'s `references/tiers.md` citation at `references/tiers-missing.md`. Locally `tests/check-refs.sh` exited 1.
- **Evidence**: `gh run view 38015366980` showed event `pull_request`, job `smoke` failed at step `Run tests/smoke.sh`, and every other step passed. The log's last pass is `ok 38`. The next case, `tests/smoke.sh:323`, is `check-refs.sh`. Then `##[error]Process completed with exit code 1.`
- **Accepted limitation**: `check-refs.sh` runs with its output sent to `/dev/null`, so the log doesn't name the missing file. Diagnosing a red run means re-running locally.
- **Cleanup**: pull request #1 closed with a comment, the remote and local branch deleted (`git ls-remote` finds none), and the worktree removed. Nothing in the repo changed.
