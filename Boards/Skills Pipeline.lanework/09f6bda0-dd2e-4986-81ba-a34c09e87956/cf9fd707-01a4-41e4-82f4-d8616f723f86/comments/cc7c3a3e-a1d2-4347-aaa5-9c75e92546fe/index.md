---
schema: 1
kind: comment
in-reply-to: 9917eea5-f373-491c-bae8-edd87f6d48de
created:  {at: 2026-11-25T12:36:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-25T12:36:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**In plain terms: the app now lets anyone put an emoji on a comment, and the skills have no rule for it yet.**

- **What a reaction is**: a thumbs-up or other emoji you click onto a comment in the app. It is saved inside that comment's file. The guide now says an agent may add one of its own too.
- **Why a rule is needed**: the skills tell agents never to change a comment once it is posted, and adding an emoji changes the comment's file. The watch also has no instruction for what your emoji on a comment means.
- **A**: agents leave reactions alone. They never add one, and your emoji never counts as an answer to a question. You still answer by clicking an option or writing a comment. This is two lines of text in the skills.
- **B**: agents may add an emoji, for example an eyes emoji to show a comment was seen. This needs a new small script and its tests.
- **C**: as A for agents, and your thumbs-up on a question would count as picking an option. The skills would have to invent which emoji means which option, and the app would still show the card as waiting.
- **Fixed whatever you pick**: a merge will stop losing your reactions.
- **Recommended**: A. It is the smallest change and nothing is lost by it. B or C can be added later.
