---
schema: 1
kind: card
title: "pitlane: adversarial review of shaped proposals before Proposed"
order: 1024
labels: [{text: pitlane, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-27T22:10:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-09-27T22:10:53Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
A second agent checks a shaped proposal before it reaches the owner's review gate: does it meet the board's bar, is the done-when observable, are the rejected routes real, is it a duplicate. In adversarial mode it argues the strongest alternative. `team.md` already has an empty "proposal reviewer" row for it.

First, measure: how often do Proposed cards bounce back to Shaping? Rarely → not worth an agent per shaping job.
