---
schema: 1
kind: comment
created:  {at: 2026-09-27T21:16:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T21:16:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Done. Not yet committed**: the working tree also holds other uncommitted edits to these same `SKILL.md` files. The owner asked for this in chat, so triage and review happened there.

- `discovery` description: 974 → 167 characters, with `disable-model-invocation: true` set.
- Exclusion clauses removed from `lanework-boards` (755 → 706) and `pitlane` (the 1025-character description before the uncommitted edits, 693 now).
- `README.md` has a note under the skills table saying to run it as `/discovery <topic>`.

Verified: all four `SKILL.md` frontmatters parse under PyYAML. A grep of `skills/` found no instruction telling Claude to invoke discovery. Only the descriptive mentions in `lanework-boards` stay. Both card files passed `lanework-validate.py`.
