---
schema: 1
kind: comment
created:  {at: 2026-11-14T03:56:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T03:56:58Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Filed from a chat review of the guide-version stamp: the owner worried it causes more problems than it solves, and the history says the number is useful but the gate sits in the wrong place.**

- **Source**: the owner, in chat on 2026-11-13: "what may we be able to do to avoid having to track that version. i worry it causes more problems than it solves." Then asked for the finding on a card, to review the next day.
- **Evidence**: `git log -- CLAUDE.md` for the six stamp moves and `git show --stat` on each for their size. `tests/smoke.sh:1305` and `:1444` for the two checks. `head -1` of this board's `CLAUDE.md` reads v117 in the working tree and v114 at HEAD. `scripts/release.sh` has no stamp or guide check today (grep, zero matches in one file).
- **Corrected from the chat**: the chat said the stamp-reading regex in the v117 card's `lib.sh` change would likely trip smoke's no-version check. It would not: the check matches `v` followed by a digit, and a regex source reads `v[0-9]+`. What would trip it is the planned prose naming v114 in `work/references/writing.md`. The body carries the corrected version.
- **Softened from the chat**: the chat recommended feature detection over the version read for `@anyone`. The v117 guide itself prescribes the version read, so the body keeps that as a note for the v117 card and not as part of the recommendation.
- **Rejected**: dropping the stamp outright. Four of six trips found real drift, and most of the v114 catch-up was prose no validator would catch.
- **Also seen**: the v117 guide's "Ready-made skills" paragraph still lists four skills and the old names `pitlane` and `pitwall`. App-side, not this repo's to fix.
- **Not done**: no skill, test or script was changed. Smoke was not run in this session; "red now" rests on the two version lines and the gate's compare.
