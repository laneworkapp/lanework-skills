---
schema: 1
kind: comment
in-reply-to: 265f06a0-c942-4fa1-9ed7-7d394ac39722
created:  {at: 2026-10-25T01:17:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-25T01:17:42Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Understood: every ask gets a standing last option you can click to get a plain-language recap instead of a ruling. Here's a sketch for when this card is shaped.**

- **Wording**: `?: Explain this more simply first`. If a label has to start with a letter, `E: Explain this more simply first`. It's short, reads as a request rather than an answer, and is the same on every ask, so it's easy to spot.
- **Where it lives**: one line in the ask template, `work/templates/ask.md`, and its rule in `work/references/writing.md` § The ask. `work/scripts/lint-ask.sh` checks that the option is there.
- **What an agent does on the click**: it treats the click as a request, not a ruling. It posts a short plain-terms recap as a record, then re-posts the same question with `waiting` set again. The app clears `waiting` on any reply of yours, so the card would otherwise stop showing that it's waiting on you. That rule goes in `watch/references/responding.md`.
- **Open for shaping**: whether asks with no options (yes/no, or free text) get it too. Also whether the button label has to start with a letter.

Labels: `work`, `watch`. It's in Ideas, so moving it on is your call.
