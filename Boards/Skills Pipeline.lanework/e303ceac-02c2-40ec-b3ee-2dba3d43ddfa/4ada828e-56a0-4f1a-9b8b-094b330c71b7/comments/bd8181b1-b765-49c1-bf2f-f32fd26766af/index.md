---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:55:05Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:55:05Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**FAIL-BEFORE: the new smoke case fails at the merge-base, where `arm-pass.sh` does not exist. Code is complete and pushed on `dispatch-arming-4ada828e` at `305934d`.**

- **Run**: the new case alone (extracted into a scratch harness, since the full gate waits for the lead's slot), against `964ff9d` with the script absent: `.../skills/dispatch/scripts/arm-pass.sh: No such file or directory`, exit 1. The harness is new, so this is the card's observable (no arming pass exists) and not a broken fixture.
- **After**: the same case prints `ok 1`, `ok 2`, `ok 3` with the script in place (eight expected lines asserted exactly).
- **Decisions**: the script parses frontmatter with awk (no yq); agent lanes come from the `board-kinds.md` agent rows unless titles are passed; a claim is the last comment opening `START`, closed by a later comment opening Merged, Closed, Shipped, Done, Confirmed done, Released, Landed or Abandoned; the card's newest owner comment decides `comment`; `stale` prints for every unclosed claim, in any lane but Done.
- **Not used**: `waiting.for`. The rules key on comment files only (`in-reply-to`, `created.by`), so a string or a list there changes nothing.
- **Next**: the full gate, once the lead grants the slot.
