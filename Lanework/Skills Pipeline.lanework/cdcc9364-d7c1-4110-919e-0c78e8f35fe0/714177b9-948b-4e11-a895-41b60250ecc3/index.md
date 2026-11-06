---
schema: 1
kind: card
title: "Let an agent clear waiting when it records an owner ruling given off the board"
order: 6144
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-06T00:08:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-11-06T00:08:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
---
Agents disagree about clearing `waiting`. The guide says only the app clears it. But the owner sometimes answers in chat, and has asked agents to clear marks that no longer need a reply. The proposal, passed on by the Lanework Pitwall session on 2026-11-05: an agent may clear `waiting` when it records an owner ruling given outside the board, citing where the ruling came from.

## Conflict

`work/references/writing.md` § The ask says "Never remove it yourself", and the guide's Mentions section says "Only the app clears it". The guide wins over the skills, so a skill can allow this only if the guide does too. That makes this an app change first, or an owner ruling that the skills deliberately go further than the guide.
