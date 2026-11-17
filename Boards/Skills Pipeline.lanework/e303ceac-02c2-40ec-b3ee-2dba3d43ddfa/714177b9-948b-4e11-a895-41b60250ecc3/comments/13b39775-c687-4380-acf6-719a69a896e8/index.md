---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:43:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: the rule and its lint are on main. Not released: the trial starts when 0.9.0 is cut, the owner's call.**

- **Merge**: `42b5a98` on main, from branch `waiting-clears` at `0d6d5a6` (one commit, six files).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 183 passed`, exit 0. Before: 174. Added 9 checks.
- **Review**: adversarial, approve at `0d6d5a6` in one round, nothing blocking.
- **Done-when**:
  1. The rule appears once in `work/references/writing.md` § The ask, naming the owner's exception, the record shape and the matching-ask condition; no guide version number added under `skills/`. Met.
  2. `work/scripts/lint-waiting-clears.sh` exists and its smoke case passes. Met.
  3. `watch/references/events.md` item 6 and `work/SKILL.md` carry one clause each; nothing else restates the rule. Met.
  4. This record names the ending line and where the lint is read. Below.
- **The trial's ending line**: ten `QUOTED` lines, no `NO-QUOTE`, and the owner names no clear as wrong. It ends badly on any `NO-QUOTE` left unfixed or any clear the owner calls wrong: the rule is struck and this card reopened.
- **Where it is read**: `skills/work/scripts/lint-waiting-clears.sh <board>`, run on each of the owner's boards.
- **Baseline before any agent used the rule**: this board `QUOTED 0, NO-QUOTE 3`, exit 1; Board Runner Discovery and Card Lease Discovery silent.
- **Two calls on how the trial is counted** are open on [the trial's counting card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/818c5b26-a6c4-4d52-9463-52354af89bc3): the three older clears, and the discovery skill's chat record reading as `NO-QUOTE`.
- **For the release commit**, as the body asks, the changelog entry: "Agents can now clear a card's waiting mark themselves when they record a ruling you gave outside the board, quoting your words on the card, and a new check lists every such clear."
- **Body's forecast that was wrong**: README word counts moved (`writing.md` 1,346 to 1,541); the rows were updated.
