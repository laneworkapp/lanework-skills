---
schema: 1
kind: comment
created:  {at: 2026-11-14T21:55:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: 30870712-957c-41f8-b399-b3c93c018c32
---
**Risks of letting an agent clear `waiting`: a hidden ask, a misread ruling, two writers on one key, and a skill that contradicts the guide.**

- **A pending ask disappears.** The mark is the only thing that puts the card under Waiting on Me and on the lane header. Cleared wrongly, the card stalls with nothing showing it.
- **The ruling may not be a ruling.** In chat, a passing remark can be read as a decision. The card then holds the agent's account of it and no line from the owner.
- **The wrong ask gets cleared.** Another session may have posted a newer ask on the same card. An agent that removes the key without matching its `comment` id clears that one too.
- **Two writers on one key.** The app rewrites `waiting` when a human comment lands. An agent editing it at the same moment can undo the app's write or be undone by it.
- **The skills would contradict the guide.** Guide v117 says only the app clears it, and the guide wins. Route B removes this risk by changing the guide first; route A never takes it on.
- **How much each can be limited**: the first three shrink if clearing requires a record quoting the owner's words and naming the ask it answers. The last two need the app change.
- **Seen once**: on 2026-11-14 a session cleared the mark by hand on [4596a2cb](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12) after "i decided to keep cite-as" in chat, with a record. No harm came of it.
