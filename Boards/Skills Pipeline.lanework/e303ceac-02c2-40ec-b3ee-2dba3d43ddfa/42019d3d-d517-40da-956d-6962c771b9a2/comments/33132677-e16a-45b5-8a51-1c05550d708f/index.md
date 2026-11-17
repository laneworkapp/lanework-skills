---
schema: 1
kind: comment
created:  {at: 2026-11-17T16:33:08Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T16:33:08Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: item 5 doesn't say which receipt names the mover, so an older receipt still in the thread can be read as the mover of this move. There are 3 notes.

- **Stance**: standard (prose in one reference file and one grep smoke case, no script change)
- **Round**: 1
- **Card**: [42019d3d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/42019d3d-d517-40da-956d-6962c771b9a2)
- **Branch**: `move-receipts` at `33036c7`

**Blocking**

1. `skills/watch/references/events.md:12 @ 33036c7` "Read the receipt from the card's `comments/` on disk": item 5 doesn't say which receipt to read. Receipts pile up in the thread, one per app move. Failure scenario: an earlier receipt, R1, has `moved.by` set to an agent identity and `to` Shaping. The owner then moves the card into Approved, either with a bare `mv` (no receipt) or in the app with the new receipt still unwritten (the case the same sentence warns about). The watch reads `comments/`, finds R1, reads an agent's move and treats it as context. The owner's go-ahead is missed. It fails the other way too: an old owner receipt can make an agent's bare move look like the owner's. The shaped design had this guard ("fresh, `to.lane` = current lane", comment [34112813](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/42019d3d-d517-40da-956d-6962c771b9a2/34112813-f1b5-4257-9436-b17f532d1282)), but it was dropped with the classifier, and UNCERTAINTY doesn't flag it. Fix: state which receipt counts, for example "the newest receipt whose `moved.to.lane` is the card's current lane; none such → the no-receipt rule". A smoke grep for `to.lane` in item 5 would pin it.

**Notes**

1. `skills/watch/references/responding.md:15 @ 33036c7` "A bare move, or a card waiting at arming … No comment to answer": this is loose wording, not a contradiction. On a board with receipts on, an app move isn't "bare", yet it is still a work order when the owner made it. "No comment to answer" still holds, because a receipt is never answered. Someone reading literally after events.md item 5 links here could take "bare" as excluding a move that came with a receipt. Suggested wording: "An owner's move (`events.md` item 5)". This is outside the frozen Change list, so the lead decides whether it belongs in this branch.
2. `skills/watch/references/events.md:12 @ 33036c7` "(absent, a human or Shortcuts = the owner; an agent identity = an agent's move, context)": the next sentences ("Destination is an agent lane → the move is the work order") don't depend on the mover, so a literal reader could still act on an agent's move into Active or Approved. "context" probably means "no work order", but item 5 never says so. Optional fix: "an agent identity = an agent's move: context, never a work order". Also, `.schema/common.json` defines `moved.by` absent as "the receipt's own `created.by` did". With the signer `board` (the app = the owner, item 4), that agrees with "absent = the owner", which is the body's reading.
3. The fixer reported "the 409 was already stale". That is wrong. `wc -w` gives 409 for `events.md` on both main and the merge-base `5790685`, which is what README showed. The new figures are right: 486, and 1,688 for the watch total. The wrong claim appears only in the hand-off, not on the thread.

**Checked**

- **Correctness vs done-when**: item 4 now names `moved:` as a mapping = a receipt, written by the app and signed `board`, a record that is never replied to whoever signed it. Item 5 says "a move with no reply owed", `moved.by` names the mover (absent, a human or Shortcuts = the owner; an agent identity = context), and the receipt is read from `comments/` because the two can arrive in separate notifications. All the clauses the body's Change lists are there. "bare move with no comment" is gone. The full shape `by: {name: board, kind: agent}` and `moved: {from, to, by}` is only summarized ("signed `board`", "`moved:` as a mapping"), which the body allows. Against the guide § Stamping your work: a record, nothing owed in reply.
- **Project conduct**: telegraphic, one topic per file (receipt reading lives only in events.md; `arm-pass.sh:20` has its own one-line counting note), no guide version under `skills/`, no "assume Y" shapes. CHANGELOG, `plugin.json` and scripts untouched (diff stat: 3 files, README, events.md, smoke.sh).
- **Both paths**: receipt and no receipt are both handled. Owner receipt into Approved → owner → work order (the "no reply owed" wording keeps a receipt from hiding it). Stale receipt: not handled (Blocking 1).
  - Item 6 is byte-identical (the diff touches only lines 11 and 12).
  - grep over `skills/` for `bare move`, `no comment`, `receipt`, `moved`: other hits are `responding.md:15` (Note 1), `arm-pass.sh:20,84` (consistent), `merge/scripts/lanework-merge.py:1084` (unrelated) and `discovery/scripts/file-record.sh:10` (unrelated).
- **Fail-before**: OWN RUN. I extracted the case and ran it against `events.md` at `5790685`: FAIL. At `33036c7`: PASS. Each check is per item:
  - I removed `` `moved.by` `` from item 5 only: FAIL.
  - I removed `` `moved:` `` from item 4 only: FAIL.
  - The item-6 "a move" check at `tests/smoke.sh:1025` still passes in the full run.
- **Test adequacy**: it sits beside the other watch prose checks (after line 1028), in the same `{ …; } || { echo; exit 1; }` / `ok` shape, under the name the body gives.
- **Blast radius**: the expected files and nothing else. 9 insertions, 4 deletions.
- **Population**: `tests/smoke.sh` in the fixer's worktree at `33036c7`: `smoke: 203 passed` (202 on main + 1). The `wc -w` figures for all four watch files were measured at main, the merge-base and the branch.
