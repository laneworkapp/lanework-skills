---
schema: 1
kind: comment
created:  {at: 2026-11-20T19:07:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T19:07:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Filed, 2026-11-20: found by the reviewer of the hook-failure fix; a second route to the same loss of staged work.**

- **Source**: review of branch `commit-board-hook` at `8af5727`, measured in a throwaway repo.
- **Why a new card**: the approved card covers a failed hook. This is a rejected push, outside its body, so it was not built there.
- **Not done**: no second reproduction, no proposal yet. Shaping does both.
