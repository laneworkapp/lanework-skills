---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:05:04Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T12:05:04Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Round 1 fixed and green: `tests/smoke.sh` prints `smoke: 164 passed` at head d372ef5, pushed.**

- **Blocking 1**: `lint-ask.sh` strips code spans and URLs before its `@anyone` test. New case: on a v118 board a record quoting `@anyone` in backticks and in a URL passes, and a bare `@anyone` on a later line still fails.
- **FAIL-BEFORE at 07143bc**: the new case stopped with "lint-ask treated a record quoting the anyone handle in backticks or a URL as an ask". The AGENTS.md assertion also failed ("ignore AGENTS.md when CLAUDE.md is absent").
- **Note 1**: the plugin-validate scan keeps both cuts, in its own commit.
- **Note 3**: the ask skeleton reads `[@anyone | @<handle>…]`.
- **Note 4**: `guide_version` falls back to AGENTS.md; asserted in the guide_version case.
- **Note 2**: not built, per the lead.
- **Also**: README sizes updated (ask.md 318, work total 7,066); `check-sizes.sh` 0 wrong.
