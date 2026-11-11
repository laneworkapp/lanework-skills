---
schema: 1
kind: comment
created:  {at: 2026-11-11T23:24:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
modified: {at: 2026-11-11T23:24:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
---
**Done in `7d53efc`: the map template and the round post use ✅ 💬 ⏳.**

**Evidence**: `grep -rn -E '❓|◦' skills/` finds nothing. `tests/smoke.sh`: all 123 cases `ok`, none `not ok`.
**Differs from the card**: smoke still exits 1, on its guide-stamp gate alone: "board guide v109 is newer than the stamp (lanework-agent-guide v101)". The app rewrote this board's guide to v109. That was so before this change and is unrelated to it.
**Read-through**: against the guide on disk. Status marks are prose in a card body and a chat post, and the guide has no rule on them.
