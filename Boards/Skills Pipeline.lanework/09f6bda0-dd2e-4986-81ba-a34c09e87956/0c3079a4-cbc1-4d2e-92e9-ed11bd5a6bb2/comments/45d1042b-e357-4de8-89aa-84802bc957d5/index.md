---
schema: 1
kind: comment
in-reply-to: 963ac99a-cc94-4534-9508-f16959be2b68
created:  {at: 2026-11-23T16:45:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:45:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**In plain terms: the test suite is one long script where every part shares the same notepad, and the question is how to give each part its own.**

- **What is decided**: how to stop one group of tests from tripping over a leftover from an earlier group. Twice this week an earlier group left a value behind under a short name, a later group picked it up by accident, and a 30 to 60 minute run failed for no real reason.
- **Why now**: the other two parts of the proposal (stopping timers precisely, and running one group of tests alone) do not depend on this. This part does, and the card moves to Proposed once it is chosen.
- **A, a separate room for each group**: each group runs sealed off, so nothing it sets can reach the next one, and a group that reaches for a leftover fails at once with a clear error. Each group also cleans up after itself, which fixes a cleanup step that is skipped today. The cost: the boards that several groups share on purpose have to be built fresh for each group that needs them.
- **B, each group lists the names it keeps to itself**: works only for the names someone remembers to list. There are about 740 names, so the lists are long, and one forgotten name leaks as before. The most rewriting of the three.
- **C, a checker that complains when two groups use the same name**: the least rewriting. About 114 names are shared today, mostly harmless scratch names, so it needs about 100 renames or a list of exceptions, and a list of exceptions would have let one of this week's two faults through. It would also have missed the other one.
- **My pick is A**: it is the only one that makes the mistake impossible instead of relying on someone to notice it.
