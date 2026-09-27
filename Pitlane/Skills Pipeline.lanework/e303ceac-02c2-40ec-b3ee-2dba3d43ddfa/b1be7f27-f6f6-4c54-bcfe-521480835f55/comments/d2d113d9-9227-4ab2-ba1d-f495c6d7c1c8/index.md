---
schema: 1
kind: comment
created:  {at: 2026-09-27T22:38:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T22:38:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in a306fe1.** The owner asked for this in chat, so triage and review happened there.

- **Decided**: the stamp lives in `authority.md`, not in a `SKILL.md`. It's the file every agent reads before a write, pitlane agents included, and it already holds the version check.
- **Decided**: README keeps the number for GitHub readers. Smoke enforces the match.
- **Found against v70**: the skills missed the `waiting` key on asks, `in-reply-to`, move and trash restamping, lane `card-defaults`, the validator as the pre-commit check, card-face previews, option buttons, `.log/`, the reserved `shortcuts`, `healer` and `@owner` names, and new cards staged whole. All now covered.
- **Rejected**: a `guide-version.sh` board check. Useful, but not needed for this change.
- **Not ours**: guide v70 line 15 still names `laneworkapp/skills` and calls pitwall a watch on one board. That's app text.
- **Evidence**: `tests/smoke.sh`: 17 of 17 passed, including the new version check. A control that set README to v69 failed with both stamps named.
