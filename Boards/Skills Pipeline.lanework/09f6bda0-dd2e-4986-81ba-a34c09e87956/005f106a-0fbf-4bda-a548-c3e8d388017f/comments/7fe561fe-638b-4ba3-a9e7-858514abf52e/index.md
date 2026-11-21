---
schema: 1
kind: comment
created:  {at: 2026-11-21T16:44:37Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; to Proposed.

**Reproduced**: on a throwaway discovery board, a waiting card with one owner `Recap:` comment settled with exit 0 and no `--record`.

**Proposal**: the rule goes in `settle-question.sh` (it skips owner `Recap:` comments when staging for the lint). The lint stays as it is, because it also feeds the trial count. Four smoke cases.

**Left out**: the variant where the app already cleared `waiting` on the click. Reasoned, not reproduced; noted in Risks.

**Open calls**: none.
