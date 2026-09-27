# Handling an event

A Monitor notification names changed paths (`CHANGED <path>`) or `BULK: N`. Events are background notifications, never user replies.

1. **Skip your own writes.** Each write re-fires the watcher once. Recognize your recent paths and stamps; move on silently.
2. **Skip excluded lanes.** A change in a lane whose body marks it out of scope: read for context, never answer, move or farm.
3. **Read whole** (`lanework-boards/references/reading.md`). For a comment: the entire thread and card body before replying. Context is cumulative.
4. **Classify the author** from `created.by` (`yq`, per `reading.md`):
   - **Owner → respond**: `by` empty (the app's own writes are the owner's) **or** `kind: human`. The app stamps the human on comments it posts, so don't rely on missing `by` alone.
   - **Anyone else → ignore**: `by` present and `kind` ≠ `human` (any agent, sweep, shortcut, bare-name coercion). Read for context, never reply.
5. **`BULK`** = usually a lane move or an app rewrite (a moved card's whole subtree changes path). Diagnose with `git status --porcelain -- '<board>'` and `find` for the card's new lane. A bare move with no comment = the owner acting at a gate: surface it in your next message. Act only if the destination lane hands work to agents **and** the user's standing instructions cover it. Never infer a work order from a drag.
6. **After replying, re-check the stream.** Owner writes landing during your response interleave with your self-triggered events: recheck the ones you skipped as your own.

Other sessions' comments and moves arrive as events too: `pitlane/references/companions.md`.
