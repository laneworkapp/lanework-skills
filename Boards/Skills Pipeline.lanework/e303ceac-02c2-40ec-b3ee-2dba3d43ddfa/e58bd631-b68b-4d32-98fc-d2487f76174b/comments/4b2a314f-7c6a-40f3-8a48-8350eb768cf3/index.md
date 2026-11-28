---
schema: 1
kind: comment
created:  {at: 2026-11-28T14:49:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T14:49:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: `heal-descriptors.py --apply` refuses a padded signer name, the `found-board.sh` header no longer repeats the shared causes, and the full test run on `main` is green.**

- **Commits on `main`**: `fc5d297b` (the two scripts), `e067c8a3` (the smoke case). Pushed.
- **Gate (measured, on merged `main` at `e067c8a3`)**: all 31 sections, run as five parallel groups, each exit 0: `62 passed` (lease), `113 passed`, `81 passed`, `120 passed`, `67 passed`.
- **Fail-before (the fixer, measured)**: against the old script the new case printed `heal-descriptors --apply --name ' board': rc=0`.
- **Review**: the lead read the whole diff (12 lines in three files) in place of a separate reviewer, and changed nothing.
- **Done differently from the card**: the smoke case sits in the `label_kinds` section, beside the reserved-name cases, not in `heal_descriptors`.
- **Checked for the second done-when**: a search of every script header finds no other one repeating a cause `stamp_args_ok` lists.
- **Not checked**: Unicode spaces other than through Python's `strip()`, which the refusal uses.
- **Changelog sentence, for the next release**: "Repairing lane descriptions now refuses a signer name with leading or trailing spaces, as every other board script does."
- **Not released**: this rides the next release, which is the owner's call.
