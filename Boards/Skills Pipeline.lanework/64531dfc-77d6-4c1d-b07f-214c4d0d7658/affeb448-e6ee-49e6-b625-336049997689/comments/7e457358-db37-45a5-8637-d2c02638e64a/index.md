---
schema: 1
kind: comment
in-reply-to: cdcebadc-5675-4338-9d66-139902de959e
created:  {at: 2026-11-27T12:58:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:58:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**In plain terms: there are two healers, they have drifted apart, and the question is how to make them one.**

- **Two healers**: the app writes its own repair script into every board it opens. The plugin also carries one, written by hand a while ago, for boards the app has not opened yet.
- **The drift**: the app's script has moved on to version 6. The plugin's has not. Where the app's script now keeps a value and writes a note about it, the plugin's quietly throws the value away. Example: a board with its own priority list loses its ranks and colours.
- **When it happens**: only on a board the app has never opened, such as one an agent just created. On every other board the plugin's script already steps aside.
- **A**: the plugin stops having its own repair logic and carries an exact copy of the app's script. When the app's script changes, the copy is replaced in one step and a test warns when it is out of date. Cost: a large file from the app sits in the public plugin repository.
- **B**: keep the plugin's own script and rewrite the parts that differ, by hand. About 700 lines, and the same work again each time the app's script changes.
- **C**: remove the plugin's script. Boards the app has opened lose nothing. A board the app has never opened then has no repair script at all.
- **Recommended**: A. It is the only one where the two cannot drift again.
