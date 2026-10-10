---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:00:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:00:41Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main as `0d4cc81` + `87738ea` (head `1a383fe` after rebase): drop-stale works line by line and never edits fenced or quoted text, the gate key names the Asked exception narrowly, and Ideas sits in one sweep row.**

- **Evidence**: `bash tests/smoke.sh` on main at `1a383fe`, `CLAUDE_MODEL` unset, printed `ok 62 - heal-descriptors drop-stale: …` and `smoke: 81 passed`, exit 0. Adversarial review APPROVE with 0 BLOCKING, after 26 hostile sheets (the old script got 22 wrong).
- **Fixed after the review, before merge**: NOTE 5 narrowed the gate key to "agents move cards in only, and out only in discovery Asked once the ruling is in the body". A general reading would have let an agent move a pipeline Proposed card out, the same ambiguity that held a card in Shaping earlier today. NOTEs 1-3: fences close only on a matching fence, `- > S` counts as a quote, and `1.` and `- [ ]` count as bullets. Each has a fixture and a mutation check.
- **Accepted limitation**: NOTE 4, an indented code block, is not protected. The card scoped protection to fences.
- **Ships**: with the next release.
