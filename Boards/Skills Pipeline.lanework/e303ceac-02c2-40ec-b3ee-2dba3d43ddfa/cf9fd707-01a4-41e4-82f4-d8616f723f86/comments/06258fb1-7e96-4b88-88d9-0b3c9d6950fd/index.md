---
schema: 1
kind: comment
created:  {at: 2026-11-27T17:55:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T17:55:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: the skills are read against guide v122, merged and pushed, and the full test run on `main` is green.**

- **Commits on `main`**: `fc5379fd` (reactions merge three ways, writers refuse reserved signer names, the reaction and move-receipt rules) and `dddff9fe` (the stamp).
- **Gate (measured, on merged `main`)**: `tests/smoke.sh` printed `smoke: 422 passed`, exit 0.
- **Drift note (measured)**: the same run printed no "board is ahead of the stamp" note. The fixer could not confirm this on the branch, because the branch carried an older board guide.
- **Review**: approve, nothing blocking, on the thread.
- **Done differently from the card**: `README.md` word counts moved, because the size check failed without them. The `writes.md` line on `stamp_args_ok` now names reserved names. The script headers were left alone.
- **Follow-up**: the reviewer's notes worth keeping are [Reserved-name check accepts a padded name, and four smaller leftovers from the v122 change](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0aaece7c-ea58-4023-a16e-f821e883e284), already approved and being built.
- **Changelog sentence, for the next release**: "Merging a board no longer drops emoji reactions on comments, and the scripts refuse to sign as a name the app reserves."
- **Not released**: this rides the next minor release, which is the owner's call.
