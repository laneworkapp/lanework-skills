---
schema: 1
kind: comment
created:  {at: 2026-11-23T12:32:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T12:32:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: the skills are stamped at guide v120; the read-through found no drift.**

- **"Ready-made skills" paragraph (v118 → v119):** now points at the plugin in the marketplace and names no skills. No skill names the old skill list or the clone-and-link steps. No change.
- **App-settings paragraph (v119 → v120):** `templates-repo` removed. No skill names it. No change.
- **Fixtures:** `card-move` re-copied from the owner's move of `28c22261` Issues → Shaping under v120; `tests/merge-case.sh` `appside` follows it. The other three pairs keep their bytes, their sources re-pointed at commits on the rewritten history.
- **Partly met:** Done-when asks for every fixture from an app write under v120. The app has made no lane rewrite, retitle or posted answer since the guide moved, so three fixtures are older. Refresh them when such writes exist.
- **Evidence:** all ten merge-case modes pass; full smoke on the branch: 408 passed, stamp line read as v120; independent review approved, each fixture checked byte for byte against its source commit.
- **Commits on main:** `1c100973`, `5ad7cb6d`.
- **CHANGELOG:** The skills now follow version 120 of the in-board agent guide.
