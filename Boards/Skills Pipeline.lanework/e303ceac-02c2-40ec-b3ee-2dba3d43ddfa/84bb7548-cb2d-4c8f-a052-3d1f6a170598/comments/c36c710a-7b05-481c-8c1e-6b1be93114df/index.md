---
schema: 1
kind: comment
in-reply-to: d019f1fe-06f6-49d5-8f01-5e4225651eb8
created:  {at: 2026-11-17T22:28:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: merged to main at `ba59f35`, smoke green. Not released.**

- **Merge**: branch `active-lane-sentence` at `168bc45`, one commit, merged with `--no-ff` as `ba59f35` and pushed.
- **Gate**: `tests/smoke.sh` on main after the merge, with the session variables unset: `smoke: 241 passed`, exit 0. Main before was 240.
- **Review**: standard, one round, approved at `168bc45`, no blocking findings.
- **Done-when**:
  - `pipeline-lanes.md` has the ruled Active sentence, and a board founded from it carries that sentence. Met.
  - The heal's table lists the body 0.8.0 shipped, and a dry run on a board founded from 0.8.0 lists `replace-body` for Active. Met.
  - Smoke is green with the cases the body lists. Met.
  - A grep of `skills/` for "claiming it with a comment" finds only `heal-descriptors.py`. Met, as a smoke gate.
- **Departure from the body**: the gate's grep skips `__pycache__`. A `python3 -m py_compile` run, which the body's Verified list names, leaves bytecode carrying the old phrase beside the script. Smoke writes none itself, and a source file with the phrase is still caught.
- **For the owner**: this board's own Active lane body is customised, so the heal will not rewrite it. A dry run on a scratch copy proposes inserting the new sentence after "The build lane." and leaving the old claim text beside it. A hand edit of that lane body is the fix.
- **CHANGELOG**, for the release commit: "New pipeline boards now say an agent holds a card in Active with a lease, and heal brings boards founded with the old wording up to it."
- **Next**: the lease trial card.
