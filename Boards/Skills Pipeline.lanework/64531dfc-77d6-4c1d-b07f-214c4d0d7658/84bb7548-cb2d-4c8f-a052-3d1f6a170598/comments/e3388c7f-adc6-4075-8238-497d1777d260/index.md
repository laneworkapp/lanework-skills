---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:25:33Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:25:33Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**The body is now a proposal; one open call remains, the exact Active sentence.**

- **Decided**: `heal-descriptors.py` line 92 stays. It is already a predecessor entry in `OLD_BODIES`, not the sentence the heal checks against (that is read from the template at run time). The card's first note had this wrong. What changes there is a new entry: the v0.8.0 body, which the file's own rule and `heal/references/descriptors.md` say to add in the same commit.
- **Decided**: no ruling is needed on whether the heal rewrites founded boards. Its existing design answers it: a body that is a predecessor word for word is replaced, a customised body only gets the actor sentence inserted, and nothing is applied without the user's confirmation.
- **Evidence**: a dry run of the heal on a scratch copy of this board (not this board) lists `lane Active: insert-actor customised`. This board's Active body differs from the stored predecessor by "that names", so the heal will not replace it. The owner edits that one lane body by hand.
- **Rejected**: leaving `OLD_BODIES` alone. A board founded from v0.8.0 would then get the new sentence inserted beside the old claim text.
- **Rejected**: making the heal replace customised Active bodies that contain "claiming it with a comment". It would rewrite owner prose, which the heal's rules rule out.
- **Accepted limitation**: this board's own lane body stays stale until the owner edits it.
