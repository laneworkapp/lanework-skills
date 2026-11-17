---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:10:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Landed on main (`9439fae`): the handle source this card's `post-ask.sh` takes its `--for` default from.**

- **From**: [the guide v118 card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8), now in Done.
- **`ask_handle <board>`** in `lanework/scripts/lib.sh`: the one source for an ask's default handle and `waiting.for`. `anyone` from guide v117 on, else `owner_handle`. Empty with exit 1 when neither exists, so callers wrap it.
- **`guide_version <board>`**: reads the stamp on line 1 of `CLAUDE.md`, else `AGENTS.md`.
- **`lint-ask.sh`**: on a v117+ board a bare mention of the anyone handle makes the body an ask, wherever it sits. A code span or URL does not.
