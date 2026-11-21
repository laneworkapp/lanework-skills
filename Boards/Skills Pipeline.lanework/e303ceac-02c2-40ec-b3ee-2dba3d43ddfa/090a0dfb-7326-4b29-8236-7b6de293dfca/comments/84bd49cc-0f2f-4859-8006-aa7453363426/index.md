---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:21:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. `README.md` § Credits is now one paragraph, committed to `main` at `b3d40ad` and pushed. Not released: `stable` gets it with the next release.

**Evidence:**

- `grep -n -i 'grilling\|domain-modeling\|wayfinder' README.md` finds nothing.
- § Credits reads: "Several of these skills were inspired by [Matt Pocock's skills](https://github.com/mattpocock/skills). The ideas were reworked to run on a Lanework board."
- The link returns HTTP 200.
- `tests/check-refs.sh`: 0 missing. `tests/check-sizes.sh`: 0 wrong.

**Departure:** built on `main` without a branch or a separate review, since it is one paragraph whose wording the owner ruled on.

**CHANGELOG:** no entry.
