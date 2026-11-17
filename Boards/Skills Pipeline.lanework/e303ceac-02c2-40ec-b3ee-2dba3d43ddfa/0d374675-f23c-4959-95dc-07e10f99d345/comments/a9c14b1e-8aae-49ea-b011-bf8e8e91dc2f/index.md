---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:29:33Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T02:29:33Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review round 2: REQUEST-CHANGES at ac8f9d9. B1 and B2 closed. 2 new BLOCKING: the Done row makes shipped cards work orders, and the sheet heal leaves "Tasks passed both gates" beside the holding rule. 8 NOTES.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (the diff adds heal-descriptors.py, which rewrites lane bodies and board sheets on users' boards: persisted data)
ROUND:   2

CARD:   Active/0d374675-f23c-4959-95dc-07e10f99d345 "Agents stall on approved cards: lanes name no actor or trigger"
BRANCH: lane-actors at ac8f9d9 (rebased onto main 301ebbc, merge-base 47876da)

ROUND-1 BLOCKING, re-checked by quoted text:
  B1 heal-descriptors.py "new = para + ("" if re.search(...)": CLOSED. :233 NOT_PROSE.match puts the sentence above the body as its own paragraph. Measured: bodies opening with "## Policy", a list and "> Quote" each keep their markup byte for byte. The sentence lands as paragraph 1. Second run: 0 changes. The board validates.
  B2 heal-descriptors.py "new = lines[:at + 1] + [perm] + lines[at + 1:]": CLOSED. :407 skips "  " and tab continuation lines. Measured: a hard-wrapped Two human gates bullet stays whole, and Agent lanes lands after its last line.

BLOCKING: 2 (both new in this round's diff)
  skills/lanework/references/board-kinds.md:23 @ ac8f9d9 "| Done | agent | the agent that built a card moves it in when its done-when is met |": round 1 had Done "none", and the owner's ruling plus the sheet line give the agent lanes as Shaping, Approved and Active. Under this file's own key, "agent = acted on unasked", and under arming.md:19 ("agent lanes ... Every unclaimed card there (no START or plan comment) = work order"), every unclaimed Done card is now a work order. Measured on this board: 19 of 34 Done cards have no START, Claimed or Plan comment. A /watch armed now would act on 19 shipped cards, and the Done body ("moves it in, with a closing comment carrying the evidence") invites closing comments that duplicate existing ones. Fix: the Done row's who-acts goes back to "none" (or a "record" value excluded from the arming pass). The trigger text can stay.
  skills/heal/scripts/heal-descriptors.py:400 @ ac8f9d9 "elif any(l.startswith(PERMISSION_MARK) for l in lines):": the sheet heal only inserts. A sheet founded from the pre-ruling template keeps "A chore the owner files in Tasks has passed both." in the same pass that turns its Tasks body into a holding bucket. Measured on a $TMPDIR copy of Lanework Website Pipeline: Tasks gets replace-body "Each waits here until the owner moves it to Approved." The sheet gains the Agent lanes line but still says a Tasks chore has passed both gates. The dry run shows no skip line for it. The healed board contradicts itself, and the sheet, which wins over lane bodies, still says Tasks chores are pre-approved. Fix: treat that sentence as template text. Remove it (it is verbatim template text, the same footing as replace-body), or emit `skip board sheet: still says Tasks chores passed both gates (remove by hand)`. The Flow bullet's "Tasks as the owner's side entrance" can take the same treatment. Add a smoke case.

NOTES: 8
  skills/lanework/templates/pipeline-index.md:19 @ ac8f9d9 "but move a card out only when asked": the ruling is "never move a card out or start its work unless asked". The sheet line, the one place each board carries the rule, drops "start". An agent could fix an Issue in place without moving it. Add "or start its work".
  skills/lanework/references/board-kinds.md:5 @ ac8f9d9 "**owner** = holding: agents read, link, research, answer; move out or start only on request": the key makes every owner row a holding bucket, but Proposed says "Agents never move out" and Asked says "Only the agent moves a card out". Split the gates from the holding lanes in the key ("owner = gate or holding"), or keep "holding" on Ideas, Issues and Tasks only.
  skills/lanework/references/board-kinds.md:17 @ ac8f9d9 "| Issues | owner | holding: agents read, link, research, answer; move out / start only on request |": the intro's holding definition repeated word for word, and :12 says it a third time ("Ideas, Issues, Tasks = holding (owner rows below)"). The owner asked for the rule once and tersely. Make the row "holding: owner moves it on".
  skills/work/references/sweep.md:28 @ ac8f9d9 "| **Holding** | Ideas, Issues, Tasks | report only": this restates the holding lane list (Ideas also sits in the gate row at :26) and says less than the ruling, which lets agents link, research and answer there unasked. Cite board-kinds with "report; research or answer only".
  skills/watch/references/arming.md:19 @ ac8f9d9 "Other lanes: report, never act" and responding.md:19 "Any other lane: surface in the report, never act": "never act" contradicts the holding rule (agents may read, link, research and answer). The point is no work order. Write "no work order: report".
  skills/watch/references/arming.md:19 @ ac8f9d9 "agent lanes (`lanework/references/board-kinds.md`...)": pre-existing (round 1 code, so a NOTE): the other kinds' record lanes are rows marked "agent" (discovery Facts, Settled, Decisions and Parked, design-loop Dead ends, datapoint Filed). At arming, every card in them is a work order because none carries a START. Same fix as BLOCKING 1: "none" or "record" for lanes an agent only files into.
  skills/lanework/templates/datapoint-lanes.md @ ac8f9d9 "agents leave ideas here but never promote one" (also board-kinds.md:53): "never" contradicts the holding rule's "only on request". Write "promote one only when asked".
  skills/lanework/templates/pipeline-index.md:17 @ ac8f9d9 "Tasks as the owner's holding bucket for chores": a sheet bullet that renames a lane role the Agent lanes line two bullets down already gives. Cosmetic.

LEAD-RULED ROUND-1 NOTES, checked:
  Agent lanes composed from existing lanes: done. compose_permission keeps only the board's own lanes. No measured board lacks Shaping, Approved or Active.
  Depth-1 lanes without kind: done. Kind-less boards now list their lanes; none matches a set.
  --skip: done, case-insensitive. `--skip Ideas --skip "board sheet"` gives two skip lines. Applied with the matching digest, Ideas stays untouched.
  --expect digest: done. A wrong digest gives exit 3 with nothing written, and the shown digest applies. heal/SKILL.md step 3 uses it.
  Unclaimed cards only: done in arming.md:19 and responding.md, citing companions.md. See BLOCKING 1 for Done.
  Lane-meaning reverts: Chosen ("only when the owner asks") and datapoint Ideas are done. Drafting's "once the owner places the card" fits the ruling. Done kept; see BLOCKING 1.
  --name "": "needs a non-empty name", exit 64.

CHECKED:
  correctness vs done-when: every template's 2nd sentence names an actor and a trigger (read all 4 tables). The table header lives only in board-kinds.md. The watch acts on a bare move and on unclaimed waiting cards. "/heal on a pre-fix pipeline board" is met for lane bodies, not for the sheet (BLOCKING 2). On a $TMPDIR copy of this board at 301ebbc: 0 sheet changes, as the lead expected. Lanes: 6 changes (Proposed and Approved replace-body, insert-actor on Ideas, Shaping, Active and Done). Issues and Tasks: 0.
  project conduct:          the fixer left board writes for the lead (301ebbc). Skill changes are one commit per round. No "assume Y" shapes found.
  both paths:               insert-actor prose vs non-prose and anchor vs fallback are both handled now. Sheet heal, insert vs stale template sentence: unhandled (BLOCKING 2).
  fail-before:              round 1 OWN RUN stands. The new smoke cases 53-59 test B1, B2, --skip, --expect and an empty --name, and would fail on the 4637540 script (B1 and B2 measured failing there in round 1).
  test adequacy:            the new cases sit in the same block, in the same style. Missing: a pre-ruling sheet carrying "passed both", and an arming-pass or Done-row check (prose, hard to test; a grep that Done's who-acts is not "agent" would do).
  blast radius:             vs 47876da: 20 files, the same set as round 1. Main's own changes (found-board.sh --model, lib.sh, discovery scripts, smoke) are not in the branch diff. Full smoke at ac8f9d9 from the fixer worktree: "smoke: 64 passed".
  population:               47 non-fixture boards under ~/Indie copied to $TMPDIR. 23 match a set (8 pipeline, 5 design-loop, 1 datapoint, 9 discovery), the other 24 match none (kind-less lanes now counted). Apply changed 140 files. Every touched board has 0 validator failures. Second run: 0 changes on all 47. 1 of 4 healed sheets keeps "passed both" (Website Pipeline, the only one founded from the template text that has it). Done: 19 of 34 cards unclaimed on this board.
  adversarial only:         re-review is scoped, so no new hypothesis set. Attacked: the insert fixes on heading, list, quote and wrapped input (held up), the digest on a stale or wrong value (held up), the ruling's "stated once" (restated 3 times in board-kinds and contradicted by sweep, arming and responding wording), the Done row against the arming pass (BLOCKING 1), and sheet currency after the ruling (BLOCKING 2).

UNRESOLVED: this is round 2. Per team.md § Bounding review the lead rules on both BLOCKINGs; there is no third round. Both fixes are small: a table cell, and one verbatim-sentence check plus a smoke case.
```
