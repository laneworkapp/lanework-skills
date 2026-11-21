---
schema: 1
kind: comment
in-reply-to: cef583b5-202c-48a1-9502-057c6775b6ad
created:  {at: 2026-11-21T19:00:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T19:00:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Recap, in plain terms.**

When a script is called wrongly (a misspelled flag, a missing value), it stops and returns a number. An agent reads that number to tell "I called it wrong" from "the board refused the write".

- **Today**: most scripts return 2 for "called wrong" and 1 for "refused". Three filing scripts (`file-question.sh`, `file-record.sh`, `file-ticket.sh`) return 1 for both, so the two cases look the same. Nine more return 1 for a few kinds of wrong call.
- **Nothing breaks today**: no script or skill in the repo reads these numbers for the scripts that would change. This is about consistency, not a live bug.
- **A**: change the three filing scripts to return 2 for a wrong call. Small, and it fixes the only scripts where the two cases cannot be told apart at all.
- **B**: change no behavior. Each script's header just says truthfully what it returns. Zero risk, the inconsistency stays.
- **C**: make all twelve consistent. Cleanest result, but it edits twelve scripts and collides with the stamp-values work now in review.

Recommended: A. An outside caller that treats 1 from those three scripts as "wrong call" would need to accept 2; none is known.
