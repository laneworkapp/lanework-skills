---
schema: 1
kind: lane
title: "Decisions"
order: 4608
icon: {glyph: signpost.right}
created:  {at: 2026-10-30T13:40:23Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-30T13:40:23Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
One card per ADR or PDR, titled `ADR:` or `PDR:`, with `Record` and `Status` labels and line 1 linking its question. The agent files it from a question's ruling, before the question settles. Cards never leave; an overturned decision gets the `superseded` status and a dated comment linking its replacement.
