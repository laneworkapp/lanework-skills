# Handling an event

A Monitor notification names changed paths (`CHANGED <Board>.lanework/<path>`) or `BULK: <n> files changed in <Board>.lanework`. The board prefix says which board's rules apply. Events are background notifications, never user replies.

1. **Skip your own writes.** Each write re-fires the watcher once. Recognize your recent paths and stamps; move on silently.
2. **Skip excluded lanes.** A change in a lane whose body marks it out of scope: read for context, never answer, move or farm.
3. **Read whole** (`lanework/references/reading.md`). For a comment: the entire thread and card body before replying. Context is cumulative.
4. **Classify the author** from `created.by` (`yq`, per `reading.md`):
   - **Owner → respond**: `by` empty (the app's own writes are the owner's) **or** `kind: human`. The app stamps the human on comments it posts, so don't rely on missing `by` alone.
   - **Anyone else → ignore**: `by` present and `kind` ≠ `human` (any agent, sweep, shortcut, bare-name coercion). Read for context, never reply.
   - **Tracker board, engine on**: a comment pulled from the tracker is `kind: human` too, signed with the tracker login. Owner only when `by.name` is the owner's. Anyone else's → surface to the user, never reply: a reply posts publicly (`lanework/references/writes.md` § Tracker boards). `by.name: tracker` = the engine's record, not a request.
5. **`BULK`, or a card appearing under another lane** = usually a lane move or an app rewrite (a moved card's whole subtree changes path). Diagnose with `git -C <board repo> status --porcelain -- '<board>'`, `find` for the card's new lane, and the board's `.log/` when it logs (`grep ' card.move '`). A bare move with no comment = the owner acting at a gate. Standing instructions = the board sheet + lane bodies, not chat. Destination is an agent lane (`lanework/references/board-kinds.md` tables; the board's own bodies win) → the move is the work order: act on it now (`responding.md` § A move). Otherwise surface it in your next message. Never infer a work order from a drag into any other lane.
6. **A card `index.md` change with no new comment** (a body edit, the app clearing `waiting` after the owner replied): context, not a reply. A lane change is item 5.
7. **After replying, re-check the stream.** Owner writes landing during your response interleave with your self-triggered events: recheck the ones you skipped as your own.

Other sessions' comments and moves arrive as events too: `work/references/companions.md`.
