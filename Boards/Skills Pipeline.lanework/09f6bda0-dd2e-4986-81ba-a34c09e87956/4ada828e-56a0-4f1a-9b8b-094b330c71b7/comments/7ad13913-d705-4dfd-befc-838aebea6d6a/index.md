---
schema: 1
kind: comment
created:  {at: 2026-11-12T02:02:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
in-reply-to: 284736a5-0725-4d9d-a60f-cfb9ee0c7500
---
**Recorded: the live trial runs before the release. 0.8.0 holds until it has run from a local install.**

- **Body**: the ruling is under Open calls.
- **State**: Active. The change is on main as ccf38d1; the installed plugin is still 0.7.0, so the trial needs the skills from this repo's `main`, installed by hand as the README's Install section describes.
- **Trial, from the done-when**: on a scratch board, a `/dispatch` session arms, and its arming pass answers an owner comment left unanswered in a lane that is not an agent lane. `/clear` and a restart are tested in the same session.
- **Next**: the board watch prepares the scratch board and the steps. The trial itself needs a live session a person starts.
