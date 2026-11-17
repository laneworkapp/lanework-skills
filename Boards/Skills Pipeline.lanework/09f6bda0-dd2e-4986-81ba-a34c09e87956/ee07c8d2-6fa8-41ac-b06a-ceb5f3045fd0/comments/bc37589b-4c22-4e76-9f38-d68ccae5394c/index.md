---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:34:38Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Round 2 fixed on `retire-dispatch`; `tests/smoke.sh` green: `smoke: 152 passed`.**

- **Blocking 1**: the `comment` row now reads "... Else answer it as a new owner comment. Either way, then carry on as `arm` when the card sits unclaimed in an agent lane (Approved: its top card)", so an already-answered card is armed too. The false-alarm sentence stays.
- **FAIL-BEFORE** at `fb56a57`: the smoke case now greps `Either way, then carry on as `arm``; it failed with `watch arming lacks the arm-pass section, its script, the compaction rule, the answer-then-arm clause, the full lane-title list or the stale report place`.
- **Sizes**: arming.md 649 words, watch total 1,602; the README cell is no longer space-padded; `check-sizes` 0 wrong.
