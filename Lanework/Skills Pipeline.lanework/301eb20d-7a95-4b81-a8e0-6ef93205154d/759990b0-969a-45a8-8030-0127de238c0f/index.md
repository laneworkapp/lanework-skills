---
schema: 1
kind: card
title: "CI: run tests/smoke.sh on a macOS runner"
order: 2048
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:21:44Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T01:53:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
`.github/workflows/smoke.yml` is on main and green (macOS runner, every push to main and stable and every pull request). What is left is proving the job goes red when smoke should fail.

- **Touches**: nothing in the repo. A throwaway branch and pull request only, closed unmerged.
- **Verify**: on a throwaway branch, break one skill citation so `tests/check-refs.sh` fails (for example point a `work/references/...` citation at a missing file), open a pull request, and read the run with `gh run list`.
- **Done when**: a closing comment quotes the run id of a red `smoke` run on that pull request, with the failing step, and the branch is deleted.
- **Not in scope**: installing the `claude` CLI in CI. `claude plugin validate` stays a local step; smoke skips it when `claude` is absent.
