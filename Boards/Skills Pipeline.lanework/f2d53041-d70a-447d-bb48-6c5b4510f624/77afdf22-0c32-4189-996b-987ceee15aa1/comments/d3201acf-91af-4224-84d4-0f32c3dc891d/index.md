---
schema: 1
kind: comment
in-reply-to: 63461aa2-ee4c-458f-851d-8778363c0ed7
created:  {at: 2026-11-21T19:02:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T19:02:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Agreed: C. The body now carries it.**

> C seems better, since lanework hasnt yet been released, i think its an easy argument to choose the more consistent option.

- **Why I agree**: the cost of C is callers that depend on the old codes, and there are none in the repo and few outside it yet. That cost only grows after wider release.
- **My earlier lean to A** rested on the overlap with the stamp-values branch. Build order removes that: this card builds after that branch is on `main`.
- **What C means in the body**: a wrong call exits 2 in all twelve scripts, a refusal stays 1, a lost lease stays 3. One smoke case per changed script.
- **Left as is**: the two heal scripts keep 64 for a wrong call, since their reference file documents it. Say so if you want those at 2 as well.
- **Guard**: the no-argument smoke case now requires exit 2, so a new script cannot drift.

The card stays in Proposed for your review.
