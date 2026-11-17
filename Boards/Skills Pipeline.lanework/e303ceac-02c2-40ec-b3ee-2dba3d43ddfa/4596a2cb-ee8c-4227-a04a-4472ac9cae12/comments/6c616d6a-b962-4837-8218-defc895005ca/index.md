---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:56:09Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:56:09Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Built and green on branch `cite-as` at `2538f29`: `tests/smoke.sh` ends `smoke: 173 passed`.**

- **Population**: 168 on main plus five new cases (cite v117 mint, trash and legacy scan, v114 and unreadable stamp, links, resolve unblocked) = 173; no existing assertion changed.
- **Gate**: `cite_enabled` in `lib.sh`, beside `ask_handle`'s identical comparison; no guide number in any Markdown file under `skills/`.
- **Departures**: none from the body except the void dispatch row. Templates use one `{{cite}}` key in place of `Q{{n}}`; the scripts print `cite Q<n>` / `cite ADR<n>` on a gated board.
- **Checked**: `move-card.sh` rewrites only `order`, `modified` and `waiting`, so a move keeps `cite-as`. `file-card.sh` untouched.
- **Left alone**: the Decisions lane body text in `discovery/templates/lanes.md` and `plan/templates/lanes.md` still says cards are titled `ADR:` or `PDR:`; it is mirrored in the heal catalog, so it is a follow-up card.
