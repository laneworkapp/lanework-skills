---
schema: 1
kind: comment
created:  {at: 2026-09-27T21:18:24Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T21:18:24Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in f5a32b7.** The owner requested it in chat ("lets do same on the other skills"), so triage and review happened there.

- **Words** (SKILL.md, then SKILL.md plus references): lanework-boards 1682 → 320 and 5936 → 2065; pitlane 1388 → 329 and 7502 → 3944; pitwall 1646 → 200 and 1646 → 884.
- **Decided**: the rule that farmed prompts carry the record/ask rule (7cd6091) is kept. It now lives once, as `writing.md` § Short form, and `templates/farmed-prompt.md` says to paste it.
- **Decided**: the lanework-boards guide version stays at v67. Its content was not re-checked against v70.
- **Added**: two shell traps hit in this session: an `&&` chain as the last line of a loop under `set -e`, and `xargs` on paths with spaces.
- **Evidence**: `tests/smoke.sh`, 14 of 14 passed. It founds pipeline, design-loop, datapoint and discovery boards and validates each with the schema validator. A control confirms the validator rejects a bare-colon title with "unparseable-yaml". It also runs file, settle and park, and both a passing and a failing lint-ask. `tests/check-refs.sh` resolved all 103 cited paths.
- **Attribution**: f5a32b7 also contains another session's uncommitted "discovery: human-invoked only" edits ([f2671d01](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f2671d01-332b-4d10-a9ff-b02fe2b43d6b)), swept in by `git add skills`. That session was told. Its card is left for it to commit.
