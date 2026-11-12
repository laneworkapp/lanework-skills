---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:43:36Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:43:36Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Shaped and moved to Proposed: the body now holds scope, files, interfaces, risks, verification, done-when and a recommendation; no open call for the owner.**

**Evidence**: read on `main` `skills/lanework/references/writes.md:7,12`, `skills/work/templates/farmed-prompt.md:9`, `skills/work/SKILL.md:30`, `skills/work/references/writing.md:9,18,48`, `skills/lanework/scripts/lib.sh` (`now_utc`, `comment_file`), `skills/plan/scripts/claim-ticket.sh`, `tests/smoke.sh` (lint-ask block at 590-607, `refused` at 440), `tests/check-sizes.sh`, README § Sizes. Nothing outside the board was changed.
**Decided**: minimum for 0.8.0 is the rule plus `lint-stamps.sh` plus smoke; `post-comment.sh` is recommended in but can follow.
