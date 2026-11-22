---
schema: 1
kind: comment
created:  {at: 2026-11-22T01:39:33Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-22: built, reviewed and approved, merged to `main` at `7e3f104`. Smoke on main: 363 passed.**

- **What changed**: one quoting rule for stamp values. `yaml_scalar` and `stamp_args_ok` in `lanework/scripts/lib.sh`, `signer()` in `merge/scripts/lanework-merge.py`, `scalar()` in `heal/scripts/heal-descriptors.py`. A value is written bare only when it is letters, digits, dot, underscore and hyphen, holds a letter, and is not a null, bool or number word. Everything else is quoted. `label-card.sh` restamps through the same rule.
- **Refused before any write (exit 2)**: an empty `--name`, a line break or tab, a C0 or C1 control character.
- **Review: three rounds.** Round 1 request-changes. Round 2 approved the code (59 values valid and byte-identical from file-card, post-comment, label-card and move-card, each read back as the same string). Round 3 was tests only: the byte-identity case now always runs and fails when a write is refused, and a C1 control has a refusal case. Both fail against a broken copy (builder's run).
- **Left open, added to card `713289a0`**: `lease.sh list` and the merge script's `stamp_desc` show a quoted name cut short. Display only; the files are right.
- **Bump**: patch.
- **CHANGELOG sentence**: "Names, models and session ids with quotes, braces, colons, backslashes or a leading hash are now written as valid front matter, and values that cannot be written (empty, or holding a line break) are refused before anything is saved."
