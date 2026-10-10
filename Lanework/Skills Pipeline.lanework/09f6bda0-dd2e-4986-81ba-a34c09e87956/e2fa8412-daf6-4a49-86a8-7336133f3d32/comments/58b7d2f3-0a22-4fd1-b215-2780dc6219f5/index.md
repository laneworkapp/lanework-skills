---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:05:47Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T01:05:47Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Re-review: APPROVE. Both blocking findings are fixed and checked at b1f0cf3; NOTEs 1-4 are fixed too. Three wording notes remain, none blocking.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (new script writes board files: persisted data)
ROUND:   2

CARD:   Active/e2fa8412 "discovery: record ADRs and PDRs on the board, not in docs/"
BRANCH: adr-lane at b1f0cf3 (read off the branch). Rebase checked: range-diff "e38f8f5 = cfc937c".
        Reviewed diff: cfc937c..b1f0cf3.

BLOCKING: 0
  Round-1 #1 (record order) FIXED. One order, stated once:
    records.md:36 @ b1f0cf3 "answer taken → file the record (question still in Asked)".
    records.md:3 and rounds.md:32 point to it. rounds.md:41 Close step 2 now only checks.
    The script enforces it: a settled question is refused with "not a question in Asked", rc 1 (measured).
    Smoke now files on an Asked question, settles, and asserts the Settled ruling carries the link.
  Round-1 #2 (backslash title) FIXED. file-record.sh @ b1f0cf3 'CTITLE="${CTITLE//\\/\\\\}"' runs before
    the quote escape. All 9 hostile titles validate, 0 failures over 20 documents (measured). The titles:
    colons, quotes, leading "#", "[", "{", a backslash path, "end\", '\"mixed\\', "{{stamp}}", and \n plus \r\n.
    Mutation check: dropping the backslash escape turns smoke red ("cards not filed ... escaped, one-line titles").

NOTES: 3
  templates/lanes.md:11 @ b1f0cf3 "filed by the agent straight into this lane from a ruling in Settled":
    wrong under the new order. This is owner-facing text stamped onto every new board.
    Suggest "from a question's ruling, before it settles".
  records.md:35 @ b1f0cf3 "line 1 links the Settled question", and file-record.sh:2 "from a settled ruling":
    the same drift. At filing time the question is still in Asked.
  rounds.md:41 @ b1f0cf3 "Check every ruling that cleared the bar has its record card": no remedy named if
    one is missing. The question is Settled by then, and file-record.sh refuses it. Suggest saying what to do,
    e.g. a new question card, or a link comment on the Settled card.

CHECKED:
  correctness vs done-when: the record is linked both ways, measured in smoke case 25 and in my own run.
  project conduct:          README discovery total re-derived with wc -w: 2,812, matches.
    check-refs: 127 references, 0 missing. Board and skill changes are in separate commits.
  both paths:               the per-answer order is now the only documented path. The older-board path is
    unchanged and refuses cleanly.
  fail-before:              unchanged since round 1 (OWN RUN agreed). Both new assertions were mutation-checked:
    dropping the body -> "--body did not land in the card"; dropping the backslash escape -> red.
  test adequacy:            cases sit in the discovery block, named like their neighbours. Minor: the
    refused-write check's first clause '[ -z "$(ls "$DEC")" ]' can never be true (the lane's index.md is
    always there). The count clause carries the check.
  blast radius:             records.md, rounds.md, file-record.sh, smoke.sh, README. This matches the lead's
    ruling plus NOTEs 1-4. settle-question.sh and file-question.sh are untouched.
  population:               smoke: 43 passed of 43 at b1f0cf3, exit 0 (my own run).
    Hostile question ids refused, 8 of 8, rc 1: "..", "*", a record uuid, a short id, an uppercase uuid,
    an all-zero uuid, a "uuid/../uuid" path, and a uuid with a trailing newline.
    Decisions held 10 cards before those runs and 10 after. A settled question is also refused.
    No staging dirs left behind in $TMPDIR.
  adversarial only:         round-1 hypotheses re-tried. H1, H2, H3, H4 and H8 no longer hold.
    The "]" in link text is now escaped: "Pricing \[beta\]".
    A backslash in a *question* title gets lost, but that is file-question.sh writing "\ " (deferred NOTE 5),
    not file-record.sh.

UNRESOLVED: none
```
