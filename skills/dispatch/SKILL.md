---
name: dispatch
description: "Live watch on one or more Lanework boards with a flat main context: this session only routes, and a fresh subagent handles each owner comment, ruling and move. Run as /dispatch <board>..."
disable-model-invocation: true
---

# Dispatch

`watch` with the main session as a pure router. A script classes each board event from its paths and stamps. A fresh handler subagent then reads the card, acts, commits, and returns a fixed-shape report. The main context grows by one classify line and one report per event, however long the session runs. Runs only as `/dispatch <board> [<board>...]`: names or paths, resolved as `/watch` does (`watch/references/arming.md` § Boards).

Builds on `watch` (the watcher, the responding policy), `work` (tiers, the build cycle) and `lanework` (reading, writes). The router reads none of their board rules. Handlers read them, fresh, every time.

| step | file |
|---|---|
| arm, route each event, report, after `/clear` | `references/routing.md` |
| what a handler reads, does and returns | `references/handler.md` |
| the handler's brief, filled by the router | `templates/handler-prompt.md` |
| the handler's report | `templates/handler-report.md` |
| class a burst from paths and stamps | `scripts/classify-event.sh` |
| in-flight set, per-card queues, self-writes registry, excluded lanes | `scripts/state.sh` |
