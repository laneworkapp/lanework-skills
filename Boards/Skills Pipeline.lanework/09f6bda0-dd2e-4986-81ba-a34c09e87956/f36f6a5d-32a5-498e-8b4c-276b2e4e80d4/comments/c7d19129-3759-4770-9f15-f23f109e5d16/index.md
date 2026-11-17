---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:36:51Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T01:36:51Z, by: {name: fixer, kind: agent, model: opus}}
---
**Verified: `tests/smoke.sh` is green at `84bdef4` on `dispatch-skill`, rebased on `origin/main` `f0bb998` and pushed. It printed `smoke: 114 passed`, 11 of them the new dispatch cases.**

- **Evidence**: 2 `state.sh` cases (claim and queue round-trip, a lead's card relayed, the registry's TTL and prune). 8 `classify-event.sh` cases: an owner comment, an agent comment, a `session: "board dispatch"` comment classed as self, a lane move including a bare `mv` and an agent's move, a BULK burst, a registered self-write next to an owner comment, an out-of-scope lane, and a mixed burst. 1 fixture board validation. `check-sizes: 62 rows, 0 wrong`.
- **Decided**: the router hand-builds two more event lines, `arm` for the arming pass and `chat` for an owner question that needs a card read. `classify-event.sh` never emits either.
- **Decided**: a sonnet handler that hits hard calls reports `ACTION: escalate` before writing anything. The router re-spawns it at opus, per the tiers ruling.
- **Decided**: `WROTE` paths in the report are separated by ` ; `, because board paths contain spaces.
- **Outside the card**: commit `f4c8385` changes smoke's plugin-validate filter. Claude Code 2.1.310 appends "Plugin directory checks" (ICON_MISSING), which smoke counted as an unexpected warning. That made smoke red on an unchanged tree: the merge-base archive shows the same warnings. Only warnings above that section count now. A synthetic warning placed above it is still caught.
- **Observed**: the existing `claim-ticket.sh` case failed once in five runs ("claim did not move to Working with a Claimed comment"). It passed on the rerun, and dispatch doesn't touch that code.
- **Not done**: the measured trial, which is the lead's after merge. The board's `Skill` label value isn't touched either.
- **Attached**: [the gate run](attachments/9000a5b4-3d33-4ed8-b59a-64d6353574fe/blob.log).
