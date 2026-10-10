---
schema: 1
kind: comment
created:  {at: 2026-10-10T03:08:55Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T03:08:55Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**A third sighting: the Skills Pipeline watch, armed before `lane-actors` landed, ran on the old rules until it re-read them at 03:08Z.**

- **Missed**: the arming pass over agent lanes, which didn't exist when it armed. A re-read found nothing unclaimed, so no work was lost.
- **Signal it had**: the v83 guide rewrite and the 0.3.0 release both arrived as events. Either one could trigger a re-read. A release commit touching `skills/`, or a skills stamp move, is a cheap thing to check on each event.
- **Also seen**: Monitor expires every 30 minutes and is re-armed here. The re-arm is a natural point to re-read the skill files.
