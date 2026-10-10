---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:37:52Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T02:37:52Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Lead-ruled re-check: APPROVE at 74904dd. Both round-2 BLOCKING findings are closed and every ruled note is applied. 4 NOTES, none blocking.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (the diff adds heal-descriptors.py, which rewrites lane bodies and board sheets on users' boards: persisted data)
ROUND:   lead-ruled re-check

CARD:   Active/0d374675-f23c-4959-95dc-07e10f99d345 "Agents stall on approved cards: lanes name no actor or trigger"
BRANCH: lane-actors at 74904dd (merge-base with origin/main c609135; diff reviewed from 167e08a, the rebased round-2 head)

ROUND-2 BLOCKING, re-checked by quoted text:
  B1 board-kinds.md "| Done | agent | the agent that built a card moves it in ...": CLOSED. The row is now "| Done | none |". So are design-loop Dead ends, datapoint Filed and discovery Facts, Settled, Decisions and Parked. The key reads "**none** = never a work order". arming.md says "`agent` rows of the tables", and responding.md says "in an `agent` row of `lanework/references/board-kinds.md` = work order". Smoke greps that none of those 7 rows is `agent`. The 19 unclaimed Done cards on this board are no longer work orders.
  B2 heal-descriptors.py "elif any(l.startswith(PERMISSION_MARK) for l in lines):": CLOSED. drop-stale removes "A chore the owner files in Tasks has passed both.", and replace-flow swaps the released Flow bullet (a customised Flow only gets its released Tasks clause rewritten). Both appear in the dry run and in the digest, and both are written once per file. Measured on a $TMPDIR copy of Lanework Website Pipeline: 11 changes in 9 files (8 lanes, plus drop-stale, replace-flow and insert-permission on the sheet). The sheet ends with the current Flow, no "passed both", and the Agent lanes line. It validates, and a second run gives 0 changes. A new smoke case covers both the released and the customised Flow.

RULED NOTES, checked:
  sheet line "or start its work": done (pipeline-index.md:19, and smoke asserts it). This board's sheet line matches.
  key split: done. agent / gate / holding / none, stated once in board-kinds.md:5.
  holding rows: Issues "owner moves it on", Tasks "owner moves a chore to Approved", Ideas "owner triages to Shaping or out". The Moves bullet no longer restates the rule.
  sweep.md: "report; research or answer only (`lanework/references/board-kinds.md`)".
  "no work order": arming.md:19 "Any other lane: no work order, report"; responding.md "Any other lane: no work order, report". No "never act" is left under skills/.
  datapoint Ideas "only when asked": done in the template and the table.
  Flow: the template now reads "with Issues and Tasks as side entrances". No "holding bucket" is left under skills/.

BLOCKING: 0

NOTES: 4 (each on unchanged code or edge input, never blocks)
  skills/lanework/references/board-kinds.md:66 @ 74904dd "| Asked | gate | ... Only the agent moves a card out |": the new key says "gate = the owner rules; agents move cards in only", which this row contradicts. Asked is the one gate an agent moves cards out of, after the ruling is in the body. Add "or out once ruled" to the gate key, or reword the row.
  skills/heal/scripts/heal-descriptors.py @ 74904dd "stale = re.compile(r\"\s?\" + re.escape(OLD_SHEET[\"sentence\"]))": the match ignores context. If the sentence is a bullet of its own ("- A chore the owner files ..."), removing it leaves a bare "-" bullet. It would also hit the sentence inside a quote or a fence. Edge input: 0 of the 4 healed owner sheets have it anywhere but inline in the Two human gates bullet. Anchor the match to the bullet, or drop the whole line when nothing else is on it.
  skills/work/references/sweep.md:27-28 @ 74904dd "| **At a human gate** | Ideas (triage), Proposed (review) |" next to "| **Holding** | Ideas, Issues, Tasks |": Ideas sits in two workload rows. The key calls Ideas holding while the sheet's Two human gates bullet still names triage out of Ideas as a gate. The meaning holds together (the owner moves it out either way), but a sweep classifying by row can count Ideas twice. Cosmetic.
  Lanework/Skills Pipeline.lanework/index.md:43 (board text, not the branch): the Flow bullet still says "Tasks as the owner's holding bucket". heal leaves it alone because it is customised and carries no released clause. That is fine for an owner-facing sheet; the lead may want it to match the template's terseness.

CHECKED:
  correctness vs done-when: unchanged from round 2 except the two closures above. This board's $TMPDIR copy at the current sheet: 0 sheet changes. Lanes: 6 changes (Proposed and Approved replace-body, insert-actor on Ideas, Shaping, Active and Done). Issues and Tasks: 0.
  project conduct:          one skill commit for the round. Board writes left to the lead. No `git add -A` shapes.
  both paths:               sheet heal: released Flow vs customised Flow, both handled and smoke-tested. The sentence present vs absent alongside Agent lanes present vs absent works because the steps are independent. Measured: Website (all three steps), this board (none).
  fail-before:              round 1 OWN RUN stands. The new smoke case's fixture asserts "passed both" is present before the heal, and the heal must remove it.
  test adequacy:            the new case sits in the heal block and follows the neighbours' style. The `none`-row grep is next to the table-home case.
  blast radius:             167e08a..74904dd: 10 files (board-kinds, 2 templates, arming, responding, sweep, descriptors.md, the script, smoke, README sizes), all within the ruling. Full smoke at 74904dd from the fixer worktree: "smoke: 65 passed".
  population:               47 non-fixture boards under ~/Indie copied to $TMPDIR. Apply changed 140 files, and every touched board has 0 validator failures. Second run: 0 changes on all 47. Boards still saying "passed both" after the heal: 0 (Website Pipeline, the only one that had it, is clean).
  adversarial only:         scoped re-check. Attacked: drop-stale placement (NOTE 2), several steps writing one file (the first write carries them all, the digest covers each), --skip "board sheet" skipping every sheet step (it shares the `board sheet` key), the gate key vs Asked (NOTE 1).

UNRESOLVED: none
```
