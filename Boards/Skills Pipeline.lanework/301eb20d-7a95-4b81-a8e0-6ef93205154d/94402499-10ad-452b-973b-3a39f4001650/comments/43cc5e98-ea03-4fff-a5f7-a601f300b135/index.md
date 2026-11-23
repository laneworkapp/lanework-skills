---
schema: 1
kind: comment
created:  {at: 2026-11-23T17:28:09Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T17:28:09Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaping: the title can be read two ways, so one question before the plan is drafted.**

- **My reading**: run third-party skills unchanged in a repo that has a Lanework board, and see whether each one finds the board on its own and puts its output there as cards and comments, instead of loose files such as a research note, a glossary or an ADR.
- **What the spike would record**: per skill, whether it found the board, where its output went, whether the board still validates, and what small change (to our skills, the in-board guide, or a wrapper) would make it land on the board.
- **Candidates already installed on this machine**: the mattpocock set (`research`, `domain-modeling`, `grilling`, `diagnosing-bugs`, `prototype`), which write files or run long question-and-answer sessions.
- **Where it would run**: a throwaway board in a scratch repo, never this board.
