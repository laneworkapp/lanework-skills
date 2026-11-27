---
schema: 1
kind: card
title: "heal-board.py lags the board healer, now at heal v6"
order: 1024
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "heal", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-25T04:51:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:51:40Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-27T13:21:40Z
---
The skills' `heal-board.py` lags the healer the app ships into each board, which moved to heal v6.

Found while reading the skills against guide v122, on [cf9fd707](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/cf9fd707-01a4-41e4-82f4-d8616f723f86).

## What moved

- **No thread, no drop**: a board or lane value the healer would drop is now left as written and reported as a `skip`, because a board or lane has no thread to keep the dropped value in.
- `.schema/HEAL.md` gained "Drops a fact: yes" rows for H03, H05, H07 to H11 and H13.

## To decide in shaping

- Port the v6 rules into `skills/lanework/scripts/heal-board.py`, or have it defer to the board's own `.schema/bin/lanework-heal.py` when the board has one. `lanework/references/writes.md` already says the board's copy wins.

## Done when

- On a throwaway board, `heal-board.py` and the board's v6 healer make the same call on a board or lane value that v6 skips.
