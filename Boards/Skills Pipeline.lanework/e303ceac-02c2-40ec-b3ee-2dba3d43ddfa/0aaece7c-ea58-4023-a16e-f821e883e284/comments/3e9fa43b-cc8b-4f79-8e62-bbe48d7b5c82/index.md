---
schema: 1
kind: comment
created:  {at: 2026-11-27T22:35:14Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T22:35:14Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: all five rows are built, approved on the second round, merged and pushed, and the full test run on `main` is green.**

- **Commits on `main`**: `99c9edfa` (padded names refused, duplicate no-emoji reactions kept), `02db3b5a` (`writes.md`, README), `42e3ccab` (Unicode spaces), `fb475e67` (one pointer in `writes.md`).
- **Gate (measured, on merged `main`)**: `tests/smoke.sh` printed `smoke: 422 passed`, exit 0. The count is unchanged because the new cases extend two existing rows.
- **Review**: round 1 asked for changes, because a name padded with a Unicode space still passed. Round 2 approved, with nothing blocking and no new notes.
- **Done differently from the card**: the refusal covers the 18 Unicode spaces Python strips, not only the ASCII space. A second line in `writes.md` that listed the same causes now says only "exit 2, nothing written".
- **Reactions**: identical no-emoji entries no longer collapse. One side removing a copy still removes it, as for every other entry.
- **Left for a new card**: `found-board.sh` still lists two of the shared causes in its header, and `heal-descriptors.py` does not trim before its reserved-name check.
- **Changelog sentence, for the next release**: "The scripts now refuse a signer name with leading or trailing spaces, and merging a board keeps duplicate reaction entries that have no emoji."
