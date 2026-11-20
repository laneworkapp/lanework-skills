---
schema: 1
kind: comment
in-reply-to: eadd4aae-2585-47c8-8517-6665dc88189b
created:  {at: 2026-11-20T12:03:27Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Recap: two skills write down "the owner answered in chat" in two different formats, and the trial's checker only recognises one.**

- **The trial**: from 0.9.0, an agent may clear a card's waiting mark itself when you answer in chat instead of on the board. It must leave a record that quotes your words. A checker script counts those records: quoted is good, unquoted is a miss. The trial ends at ten good and no misses.
- **The quote format the checker knows**: your words on a quoted line (a line starting with `>`), or after a bold "Given" label. The `work` skill writes this.
- **What discovery writes**: a bold "Owner answered in chat." followed by your words in plain quotation marks on the same line. Your words are there, but the checker does not see them, so it counts a miss.
- **So**: the first time you answer a discovery question in chat after 0.9.0, the trial records a miss it did not earn.

The three ways out:

- **A, change discovery**: discovery writes the same format as `work`. One format everywhere. Costs a small build card (a template and one script), ideally before 0.9.0.
- **B, change the checker**: it learns discovery's format too. No change to discovery. Two formats live on, and the checker gets looser.
- **C, leave both**: discovery boards are not counted in the trial. Nothing to build. Chat answers on discovery boards go unchecked.

My recommendation is A: one format is simpler to read and to check, and the build is small. C is the fallback if you want 0.9.0 out without another card.
