---
schema: 1
kind: card
title: "Open calls still reach the chat: at filing, and at the end of a reply"
order: 0
labels: [{text: pitlane, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-01T15:57:55Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "Palette Review"}}
modified: {at: 2026-10-01T15:57:56Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "Palette Review"}}
---
The open-call rule from [Pitlane](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/Pitlane) covers shaping, sweeps and triage reports, but not two moments where an agent still asks in chat: filing a fresh card whose body lists open calls, and ending a chat reply with questions about a card's next step.

## Reproduce

In a live chat the owner asks for cards to be filed. The agent files a card with an "Open calls" section and a founding record, posts no asks, then closes its reply with "I need from you: …". Seen 2026-10-01 on the Lanework Pipeline palette sittings card and a Website Pipeline blog card: six open calls sat unasked until the owner pointed it out.

## Change

- `skills/pitlane/references/writing.md` § When to ask: the live-chat bullet gains a pre-send scan (each question on a card's options, scope or next step becomes an ask on that card first; no card yet → file it, then ask). A new bullet: filing a card with an open call sends its asks in the same pass as the founding record.
- `skills/pitlane/SKILL.md`: the hub line says "at filing as at shaping and never as a question in chat".
- `README.md`: pitlane word counts recounted.

## Done when

Both triggers are named in § When to ask, the hub line points at them, and `tests/smoke.sh` passes.
