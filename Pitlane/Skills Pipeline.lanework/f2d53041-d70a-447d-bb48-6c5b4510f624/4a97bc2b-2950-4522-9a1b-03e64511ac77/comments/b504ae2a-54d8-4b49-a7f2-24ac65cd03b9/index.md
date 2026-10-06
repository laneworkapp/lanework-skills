---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:32:05Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:32:05Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
in-reply-to: a9ce74b0-37f5-4a8a-bf0d-9d7e7b913a8e
---
**In short: A keeps a reminder to re-read the skills each time the app's guide changes. B drops the reminder and trusts the skills never to repeat the guide.**

**A, keep the stamp**: the repo notes which guide version the skills were last checked against. Smoke fails when this board's guide is newer, so a skills release waits for a re-read and a one-line bump. Cost: that re-read, once per guide change.
**B, drop it**: no number and no check. Cost: when a skill repeats a guide rule and the guide changes that rule, nothing notices until an agent follows the stale rule.
**Happening now**: this board's guide moved from v78 to v82 on 2026-10-06. v82 moves priority and component into `labels`. `skills/lanework/references/writes.md:10` still says the opposite, and smoke stays green. Under A, smoke would fail until someone fixed it.
**Changed recommendation**: A, for now. The earlier lean to B assumed the skills repeat nothing from the guide. They still do until [the pointer card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/43456b82-7956-4027-a435-e78fa9badbea) lands. The gate can go once that audit is done.
