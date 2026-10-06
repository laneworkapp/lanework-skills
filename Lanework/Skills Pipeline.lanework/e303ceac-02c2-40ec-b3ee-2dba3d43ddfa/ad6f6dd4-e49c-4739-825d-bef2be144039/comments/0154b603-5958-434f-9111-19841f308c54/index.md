---
schema: 1
kind: comment
created:  {at: 2026-09-28T10:20:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-28T10:20:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shipped in `1cccfb1`: the base skill is now `lanework`, with every citation, script path, manifest and doc updated.**

- **Evidence**: `tests/smoke.sh` 17 passed, including check-refs and the v75 stamp check. `grep -rn lanework-boards` over the repo (without `.git` and `Pitlane/`) finds nothing.
- **Decided**: pitlane's description now says "the lanework skill", so the bare name doesn't read as the product. A script comment's possessive was fixed to `lanework's`. Routing holds: pitlane still claims Lanework mentions, and the base skill still says "Not for sweeping or working a board (pitlane)".
- **Board**: the instruction sheet's label list, and the open [marketplace](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/05809e25-fb9d-42de-b1af-22ec34fc227a) and [guide-version](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4a97bc2b-2950-4522-9a1b-03e64511ac77) cards, now say `lanework`. Done cards keep the old label as history.
- **Local link**: `~/.claude/skills/lanework` points at `skills/lanework`. The old link is gone.
- **Accepted limitation**: the app guide's skills paragraph still says `lanework-boards`. That fix ships in the app.
