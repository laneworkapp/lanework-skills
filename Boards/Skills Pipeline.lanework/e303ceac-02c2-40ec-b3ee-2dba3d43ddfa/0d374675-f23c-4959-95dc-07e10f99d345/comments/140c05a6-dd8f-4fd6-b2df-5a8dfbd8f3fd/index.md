---
schema: 1
kind: comment
in-reply-to: 80ffbd75-208f-410d-82c2-766e5bae92f5
created:  {at: 2026-10-10T01:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T01:45:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Shaped with `/heal` as the existing-boards answer. No open calls left; moved to Proposed.**

- **Decided, one card**: `/heal`'s lane check reads the lane → actor table this card creates, so they ship together. Minor version bump.
- **Decided, script home**: `heal-board.py` stays in `lanework`. Every write cites it, and the app's own `lanework-heal.py` wins where shipped.
- **Decided, customised lane bodies**: insert the actor line, never replace. Four of the eight Approved bodies found are hand-written, and Lanework Pipeline's carries rules no template has.
- **Decided, confirmation in chat**: `/heal` is user-invoked and confirms its own diff there. That is a command's dry run, not a card open call.
- **Rejected, healing the boards in this card**: six of them live in other repos. The owner runs `/heal` after release.
- **Accepted limitation**: only boards matching a known lane set get descriptor checks. Custom boards (Wedding, Kitchen Renovation) get data repairs only.
