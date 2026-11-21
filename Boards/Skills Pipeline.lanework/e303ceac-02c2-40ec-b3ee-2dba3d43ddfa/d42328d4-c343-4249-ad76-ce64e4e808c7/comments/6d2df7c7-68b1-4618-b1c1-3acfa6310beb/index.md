---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:44:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Merged to main 2026-11-17; the card stays in Active, because its done-when needs `stable` to lack the file and only a release moves `stable`.**

- **Merge**: `e203ecb` on main, from branch `drop-marketplace-json` at `225a835` (one commit, three files).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 168 passed`, exit 0. Count unchanged: the two dropped asserts sat inside one case.
- **Review**: standard stance, approve at `225a835`, nothing blocking.
- **Done-when**:
  - `tests/smoke.sh` and the `CLAUDE.md` layout table no longer mention `marketplace.json`. Met on main.
  - `stable` has no `.claude-plugin/marketplace.json`. Not met: `stable` is at 0.8.0.
  - The central marketplace check passes against the new `stable`. Not met: run `scripts/check.sh` in `lanework-marketplace` after the release. Against today's `stable` it printed `ok: lanework -> https://github.com/laneworkapp/lanework-skills.git@stable`.
- **Before 0.9.0 is cut**: [the owner's install moves](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/702953a4-79a8-463e-8887-13113c1118fc), or it loses its catalog.
- **Closes when**: 0.9.0 is released and the check above passes.
