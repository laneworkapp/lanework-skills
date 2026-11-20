---
schema: 1
kind: comment
created:  {at: 2026-11-20T13:54:15Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped, 2026-11-20. One open call, on release timing; the card stays in Shaping until it is ruled.**

- **Shaped by**: a `reviewer`-tier subagent (claude-opus-5-5), body read by the lead.
- **Item 1 measured** in a throwaway repo with a failing pre-commit hook: staged v2, v3 on disk, `commit-board.sh` exits 1 with no commit, and the index then holds v1. The owner's staged v2 is gone, with no message.
- **The fix measured** on a copy of the repo: staged v2 survives the failed hook, the next run commits, and smoke passed there (250).
- **Items 3 to 6 measured**; item 2 (the trap after a lost lock) read only.
- **Approach**: the exit trap resets only after a commit landed and only while this run holds the lock. Items 3 to 6 are independent and can each be struck.
- **Corrected from the old body**: line numbers; item 5 covers four scripts; item 3 changes one existing smoke assertion.
- **Why the call matters**: 0.9.0 is the first release that ships `commit-board.sh`, and item 1 loses staged work.
