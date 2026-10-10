---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:04:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T00:04:58Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Fixed on main as `b3c9359`, at the owner's request, relayed by the Lanework Pitwall session. It ships with the next release.**

**Decided**: the rule stays in `companions.md` alone. `responding.md` gains only a pointer: owner comments are answered on the card, including on a card another session owns.
**Evidence**: `bash tests/smoke.sh; echo $?` printed `smoke: 37 passed` and exit 0, check-refs included.
