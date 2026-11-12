---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:54:49Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Landed on main as 964ff9d (branch head bb41e5e, reviewer APPROVE cb25c9ef). The card stays in Active until the release.**

- **Evidence**: `tests/smoke.sh` at bb41e5e, exit 0, "smoke: 125 passed". On main after the merge, `grep -n 'lanework-skills.git' README.md` finds only line 168 (the manual-install clone), and line 159 names `lanework-marketplace.git`.
- **Remaining done-when**: the README on `stable` names only the new URL, and the release notes carry the three switch-over commands. Both hold only once 0.8.0 is cut.
- **Measured**: `claude plugin marketplace remove lanework` also uninstalls the plugin (throwaway config dir), so the entry gives remove, add, install.
