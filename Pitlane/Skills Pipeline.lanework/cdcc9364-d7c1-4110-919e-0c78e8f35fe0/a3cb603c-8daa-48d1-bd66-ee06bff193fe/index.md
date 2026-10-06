---
schema: 1
kind: card
title: "README sizes drift: generate or check the word counts"
order: 6144
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-06T22:56:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:56:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The README's per-file word counts are a hand-kept snapshot, and they drift with every skill edit. `writes.md` was already 816 words against the table's 759 before the current campaign.

Either generate the table in smoke or the release script, or have smoke fail when a count is off by more than a margin.
