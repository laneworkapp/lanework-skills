---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:52:20Z, by: {name: shaper, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:52:20Z, by: {name: shaper, kind: agent, model: sonnet}}
---
**Mostly done: the workflow is on main and green, and the one missing piece is a red run on a throwaway branch. Body reshaped to that remainder; the card stays in Shaping.**

- **Workflow**: `.github/workflows/smoke.yml` (commit c859202) runs `tests/smoke.sh` on `runs-on: macos-latest`, on pushes to `main` and `stable` and on every pull request. It installs `fswatch` for the watch case first.
- **Green**: `gh run list --limit 100` returns only `main` and `stable` push runs, all `success`; the latest (38014574386) took 50s.
- **No red run exists**: none of those 100 runs failed, and none came from a branch or pull request, so the "red on a throwaway branch" half of the done-when has never been shown.
- **Settled by the shipped state**: runner cost (the repo is public) and the `claude` CLI. CI does not install it, so `tests/smoke.sh:359` skips `claude plugin validate` there and manifest validation stays local. Accepted limitation.
- **Next step**: open a throwaway pull request with a deliberately broken skill citation, quote the red run, then close it unmerged. Publishing a branch is the lead's or the owner's call, so it is not done here.
