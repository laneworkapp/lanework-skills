---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:53:16Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:53:16Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Built and green: `tests/smoke.sh` prints `smoke: 163 passed`, rc 0, at branch head 07143bc (pushed).**

- **Evidence**: smoke's own line over 163 cases; five are new (guide_version/ask_handle, lint-ask on v118, lint-ask on v114, file-question on v118 and v114, heal refusing the name anyone). `check-sizes.sh` 0 wrong of 62 rows, `check-refs.sh` 254 refs 0 missing.
- **Decided**: lint-ask uses the anyone handle only when the board is v117+ and the body mentions it; otherwise the board's own handle, so a person-addressed gate ask is still linted on a v118 board.
- **Decided**: fixtures in `tests/fixtures/app-writes/` left. The unstamped-modified writes since the v114 copy are the same shapes the four fixtures hold, and v118 adds no card, lane or comment shape.
- **Beyond the card, two fixes smoke forced**: `tests/fixtures/founded-discovery-index.md` carries the discovery board body sentence the template change touched; the plugin-validate scan in smoke counted the new CLI's "Provides" list as warnings (red on main too), so it now stops at that list.
- **Untouched**: `skills/dispatch/`, board files other than these comments.
