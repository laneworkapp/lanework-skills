---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:55:30Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T11:55:30Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review: APPROVE at 716c7e7. Done-when met; 26 hostile sheets show the per-line step right on every case the card names, with five edge NOTEs.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (heal-descriptors.py rewrites board sheets on users' boards: persisted data)
ROUND:   1

CARD:   Active/9be75bc1-79e3-4f17-81f8-6aec3b69a331 "heal and board-kinds: follow-ups from the lane-actors review"
BRANCH: lane-review-followups at 716c7e7 (rev-parse), merge-base bca7ced

BLOCKING: 0
  none

NOTES: 5
  heal-descriptors.py:463 @ 716c7e7 "fenced = not fenced": a plain toggle. Input "````\n```\nS\n```\n````" or "```\n~~~\nS\n```"
    -> the inner line closes the fence and S inside the outer fence is removed (measured). Fix: remember the opener's char
    and length, and close only on the same char at >= that length. Flagged by the fixer; the released sentence inside a
    nested fence is near-impossible on a real sheet.
  heal-descriptors.py:465 @ 716c7e7 "not head.startswith(\">\")": a quote inside a list item, "- > S", is not seen as a quote
    -> removed, leaving a bare "- >" (measured). Fix: strip a leading list marker before the ">" test.
  heal-descriptors.py:468 @ 716c7e7 "(\"\", \"-\", \"*\", \"+\")": "1. S" leaves "1.", "- [ ] S" leaves "- [ ]" (measured). The
    card named only -, *, +, so this is to spec. Fix: match ^\s*([-*+]|\d+[.)])(\s+\[[ xX]\])?$.
  heal-descriptors.py:465 @ 716c7e7 "sentence in line": an indented code block ("    S" after a blank line) is not
    protected -> removed (measured). Edge only; protection is fence-only by the card's spec.
  board-kinds.md:5 @ 716c7e7 "agents move cards in, and out only once the ruling is in the body (discovery Asked)": read
    generally, this lets an agent move a pipeline Proposed card out once a ruling is in its body, against board-kinds.md:12
    "Agents surface a card at a gate and stop" and the Proposed lane body. sweep.md:27 now defers to this key instead of
    "never move". It is the card's own approved wording, and a board's bodies win, so it is a NOTE. Fix direction: "out only
    in discovery Asked, once the ruling is in the body".

CHECKED:
  correctness vs done-when: all four met. grep finds the key naming Asked; sweep names Ideas once (row 28 only); smoke 62
    covers own/inline/fence/quote/mixed; branch smoke "smoke: 81 passed" rc 0 (OWN RUN, T under $TMPDIR). Hostile set: 26
    sheets built from the healed "Heal Pre" board, each run as dry run, apply, second run, validate, with the whole body
    compared to the expected bytes. 21 OK; the 5 NOTEs above account for the rest (glued "Keep.S" -> "Keep." and a missing
    final newline kept are correct, expectation errors on my side). OK cases: CRLF own/inline (CRLF kept, no stray LF),
    sentence at body start (own line and inline), at end with and without trailing newline, twice on one line (bullet and
    inline), trailing spaces, * and + bullets, tab after marker, nested "  - S", own paragraph, followed by text
    ("- S Keep this." -> "- Keep this."), unclosed fence (untouched, no drop-stale line), info-string fence plus a real hit,
    a closed fence then a real hit. Every case: second run "0 changes", board validates, drop-stale reported only on removal.
  project conduct:          one commit with skill changes only, no board writes; plain message; README Sizes re-measured
    (check-sizes 48 rows, 0 wrong); check-refs 157 references, 0 missing; py_compile clean. No "assume Y" shapes.
  both paths:               dry run and --apply share one change list; the CRLF path goes through Document (normalised on
    read, restored on write), measured on both own and inline.
  fail-before:              OWN RUN agreed: branch tests/smoke.sh in the scratch worktree at bca7ced, cases 1-61 pass, then
    "drop-stale left a bare bullet or touched a neighbour: .../Heal Stale own.lanework", diff "14d13 < -". Same observable
    as the FIXER RUN. Positive control: the old script on my 26 sheets is wrong on 22 (E3).
  test adequacy:            case 62 sits beside the pre-ruling sheet case (61), same helpers (sum, validate, $HD), named
    in the same "heal-descriptors ..." form. Would fail on a wrong fix: own/inline compare the whole body to the seed.
  blast radius:             expected 4 files + README Sizes; actual the same 5. No churn.
  population:               smoke 81 cases; hostile 26 sheets, 21 OK + 5 NOTEs; old-script control 22 of 26 wrong.
  adversarial only:         written before the reports: H1 CRLF defeats the bare-bullet test (did not hold); H2 numbered
    or task markers left bare (held, NOTE); H3 "- > S" not seen as a quote (held, NOTE); H4 indented code not protected
    (held, NOTE); H5 ``` vs ~~~ or a longer fence closes early (held, NOTE); H6 tab adjacency (did not hold); H7 twice or
    trailing text (did not hold); H8 second run not 0 (did not hold); H9 drop-stale reported with nothing removed (did not hold).

UNRESOLVED: whether to tighten the board-kinds gate key so the Asked exception cannot be read as covering pipeline
  Proposed (NOTE 5). This is the owner's approved wording, so it is the lead's call whether to file it.
```
