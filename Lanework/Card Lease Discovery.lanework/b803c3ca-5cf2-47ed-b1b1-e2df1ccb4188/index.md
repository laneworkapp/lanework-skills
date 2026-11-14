---
schema: 1
kind: lane
title: "Decisions"
order: 4608
icon: {glyph: signpost.right}
created:  {at: 2026-11-14T04:24:54Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T04:24:54Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
One card per ADR or PDR, titled `ADR:` or `PDR:`, with `Record` and `Status` labels and line 1 linking its question. The agent files it from a question's ruling, before the question settles. Cards never leave; an overturned decision gets the `superseded` status and a dated comment linking its replacement.
