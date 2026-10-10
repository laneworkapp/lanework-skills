---
schema: 1
kind: card
title: "Relay, don't engage left the owner's board question answered in chat"
order: 1024
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}, {text: "watch", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-10-10T00:04:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T00:04:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
A watch session read "else surface to the user" in `work/references/companions.md` as "deliver the answer in chat", so an owner's question on a companion's card got its answer in the terminal, plus a chat question about whether to post it.

**Reproduce**: the owner comments a question on a card another session shaped, and that session can't be reached. The watch answers in chat instead of on the card. It happened twice, on the Lanework Pipeline board.
**Cause**: the rule meant to stop two sessions building or moving one card was read as "don't answer". That contradicts the work skill's "answer questions on any card" and "never as a question in chat".
**Files**: `skills/work/references/companions.md` (the rule), `skills/watch/references/responding.md` (a pointer).
**Done when**: the bullet says not engaging means not taking over the work, the owner's comment gets its reply on the card, and chat gets one line only. Smoke passes.
