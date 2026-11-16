---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:49:13Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:49:13Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Built at bb41e5e on `readme-marketplace-c5b171e1`: removing the old marketplace also uninstalls the plugin, so the entry carries all three commands.**
- **FAIL-BEFORE** (cacbd42, merge-base): `grep -rn "lanework-skills.git" README.md` finds line 159 and line 168; done-when wants only 168.
- **Throwaway check** (`CLAUDE_CONFIG_DIR=/private/tmp/claude-501/cfgtest/b`, output in `/private/tmp/claude-501/cfgtest/out-b.txt`): after add old + install, `claude plugin marketplace remove lanework` printed "Also uninstalled 1 plugin from this marketplace: lanework@lanework". Then add of `lanework-marketplace.git` listed no plugins; `claude plugin install lanework@lanework` installed lanework 0.7.0, enabled, user scope.
- **After**: grep finds only line 168. `check-sizes` 62 rows 0 wrong; `check-refs` 248 refs 0 missing.
