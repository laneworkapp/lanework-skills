---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:58:42Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T00:58:42Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review: REQUEST-CHANGES. Two blocking findings: the docs give two conflicting orders for filing a record, and a backslash in a title writes a card that won't parse.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (new script writes board files: persisted data)
ROUND:   1

CARD:   Active/e2fa8412 "discovery: record ADRs and PDRs on the board, not in docs/"
BRANCH: adr-lane at e38f8f5 (read off the branch; merge-base b4fc98b)

BLOCKING: 2
  skills/discovery/references/records.md:36 @ e38f8f5 "Order: file the record → put its link in the ruling → `settle-question.sh`":
    contradicts records.md:3 "Written at each round's close" and rounds.md:41 (Close step 2, runs after
    "every Asked card of the round is Settled / Parked"), both unchanged. An agent following rounds.md has
    every question Settled before it files a record. Then either it re-runs settle-question.sh, which appends
    a second "## Ruling" (measured: the script never checks the lane, it just appends), or it skips the link
    and the question never links its record. That breaks done-when "linked both ways". The smoke case itself
    takes the rounds.md path: tests/smoke.sh:261 files records on C1 after case 21 has already settled it.
    Fix: one order in one file. Either file records as each answer is taken, before settle (then rewrite
    records.md:3 and rounds.md Close step 2), or keep them at round close and say how the link reaches a
    Settled ruling (e.g. a link comment on the question).
  skills/discovery/scripts/file-record.sh:45 @ e38f8f5 'title "${TITLE//\"/\\\"}"': escapes " but not \.
    --title 'C:\path\to\thing' -> title: "ADR: C:\path\to\thing" -> validator FAIL "unparseable-yaml
    ... unknown escape character `\p`", and that card is now on the board (measured, throwaway board).
    Fix: escape backslash first, as lib.sh yaml_str does (render the bare value into the already-quoted
    template). Add one smoke title that carries a backslash.

NOTES: 6
  tests/smoke.sh:261 @ e38f8f5: E2 gap. With file-record.sh:50 'cat "$BODY_FILE"' replaced by a no-op,
    smoke still prints "smoke: 42 passed" (measured, mutated copy under $TMPDIR). Assert one --body line lands.
  file-record.sh:35 @ e38f8f5 'QCARD=$(ls -d "$BOARD"/*/"$QID"': no uuid shape check. QID ".." resolves to the
    board itself: rc 0, link lanework://<id>/.., link text = board title (measured). A record card's uuid is
    also accepted as the "question". The fixer flagged that Settled isn't required. Suggest a uuid regex plus
    the card being in Asked/Settled.
  file-record.sh:45 @ e38f8f5: a newline in --title writes a two-physical-line title scalar. It still parses,
    but it breaks the guide's "keep every scalar on one line". Flatten \n to a space.
  file-record.sh:47-49: the question title goes into the link text raw. A "]" in it (e.g. "Pricing [beta]")
    breaks the Markdown link. Low impact.
  file-record.sh:17 'MODEL="${CLAUDE_MODEL:-unknown}"': stamps model: unknown unless --model is passed. This is
    the same as file-question.sh and was flagged by the fixer. Same backslash class lives in file-question.sh
    (unchanged): worth its own Issues card.
  Thread: the fixer's FAIL-BEFORE names merge-base c152c5b. The real one is b4fc98b, but c152c5b..b4fc98b
    touches only board files, so the run is equivalent.

CHECKED:
  correctness vs done-when: fresh board has Decisions at 4608 between Settled 4096 and Parked 5120. Labels
    flattened per guide § labels (text, rank, kind order). Line 1 links the question. No docs/ write.
    "Linked both ways" is the unmet half (BLOCKING 1).
  project conduct:          stage/commit hygiene fine. Scripts are BSD/macOS-safe. lib.sh is sourced by
    relative path. README word counts re-derived with wc -w: 2,752 total and every row matches.
    check-refs: 127 references, 0 missing.
  both paths:               the older-board path (no Decisions lane) is prose only, flagged by the fixer.
    The script refuses one cleanly ("no Decisions lane", rc 1, nothing written: measured on a pipeline
    board). The record-timing path is unreconciled (BLOCKING 1).
  fail-before:              OWN RUN agreed. The branch's tests/smoke.sh at b4fc98b printed "Decisions lane
    missing or out of order", exit 1, after ok 22. This matches FIXER RUN.
  test adequacy:            cases 23-27 sit with the discovery block and are named like their neighbours.
    Body content is unasserted (NOTE 1).
  blast radius:             11 files, matching Phase-1. file-question.sh, settle-question.sh and
    found-discovery-board.sh are untouched. rounds.md is untouched, and it should have changed (BLOCKING 1).
  population:               smoke 42 passed of 42 at e38f8f5. Hostile run: 7 titles plus 6 bad uuids/boards,
    1 parse failure over 19 documents. That failure is the backslash card.
  adversarial only:         written before the reports: H1 title escaping (held: backslash, newline;
    {{stamp}} and "}}}" are safe because render is single-pass), H2 qid traversal (held: ".."), H3 non-question
    accepted (held), H4 "]" in link text (held), H5 yaml_str unused (held), H6 board without the lane (refused
    cleanly), H7 spaces in paths (fine), H8 smoke passes when the code is wrong (held: body).

UNRESOLVED: BLOCKING 1 is a design choice for the lead: file records per answer, before settle, or at round
  close with a different link mechanism.
```
