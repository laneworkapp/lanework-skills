---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:04:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**The trial board and its steps are ready. The trial has not run.**

- **Folder**: `/private/tmp/claude-501/-Users-rzen-Indie-Shared-lanework-skills/9aee3c0f-725c-4271-b6c9-c924e53cd5a4/scratchpad/dispatch-trial/`: `Dispatch Trial.lanework`, `STEPS.md`, `expected-arm-pass.txt`. The board sits in its own local git repo with no remote.
- **Fixture**: five cards. An unanswered owner comment in Ideas; an answered one in Ideas; an unclaimed Shaping card; an Active card whose only comment is a START 45 minutes old; an unanswered owner comment in Done.
- **Measured**: `arm-pass.sh` from main on that board prints exactly one `comment` (the Ideas card), one `arm` (Shaping) and one `stale` (Active, 45m). The board validates, 0 failures over 19 documents.
- **Steps cover**: the hand install from main beside the 0.7.0 plugin (the trial uses `/dispatch`, not `/lanework:dispatch`), what the arming report and the handler should do, `/clear`, a restart, and cleanup.
- **Not specified by the references, so only observed**: a handler still running at `/clear`, how a cleared session finds its state, a handler mid-work at quit.
