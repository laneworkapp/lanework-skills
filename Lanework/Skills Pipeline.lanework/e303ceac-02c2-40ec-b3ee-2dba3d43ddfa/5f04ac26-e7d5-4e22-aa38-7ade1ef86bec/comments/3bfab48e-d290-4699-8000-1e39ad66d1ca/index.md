---
schema: 1
kind: comment
created:  {at: 2026-10-10T11:59:03Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T11:59:03Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review, round 1: REQUEST-CHANGES on `found-board-fixes` at 26e763c, for both cards. One finding blocks: the discovery wrapper still renders the raw board title into the body through `{{topic}}`. Everything else holds. Smoke passes 83 of 83, check-sizes finds 0 wrong of 48 rows, and all 39 hostile-input boards validate.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (found-board.sh writes every founded board; lib.sh is sourced by every script and title_str was rewritten)
ROUND:   1

CARD:   Active/5f04ac26 "Templates: a line break in a board title splits its body heading"
        Active/d97756aa "found-discovery-board.sh: --labels edge cases match found-board.sh"
BRANCH: found-board-fixes at 26e763c (read off the branch), merge-base bca7ced

BLOCKING: 1
  skills/discovery/scripts/found-discovery-board.sh:27 @ 26e763c "--var topic="${TITLE% Discovery}"": the raw title still
    reaches the board body, in "Discovery on {{topic}}:" (discovery/templates/board.md:13). Measured at 26e763c:
    title $'x\n## Evil Discovery' -> body line "## Evil: its problem and domain space, ..." becomes the board's FIRST ##
    heading, so the board description moves into the agent instruction sheet (guide: "everything below its first ##").
    That is a template heading built from a raw title, which the done-when rules out. $'one\r\ntwo' leaves a raw CR in
    the body ("Discovery on one^M"), and $'x\n\ny' splits the paragraph. The new smoke case passes anyway: it checks only
    the "# " line and "title:". Unflagged second path of the same defect (checklist item 5, E12).
    Fix: --var topic="$(flat_str "${TITLE% Discovery}")" (lib.sh is already sourced there), plus a grep -qxF on
    "Discovery on uno dos: ..." (or its prefix) in the Brk loop of tests/smoke.sh.

NOTES: 2
  skills/discovery/scripts/found-discovery-board.sh:23 @ 26e763c "[ "$k" = round ] || LABELS="$LABELS,$k"": --labels round,round
    exits 0 through the wrapper but 2 through found-board.sh. The wrapper drops every round before found-board.sh checks for
    duplicates, so the lead's within-one-list rule has one exception. This predates the branch and nothing is lost.
  skills/lanework/scripts/lib.sh:8 @ 26e763c "flat_str()": a title made only of line breaks ($'\n', $'\n\n') still founds,
    with heading "#  " and title " ". It no longer splits, but nothing rejects a title that is blank once flattened.
    A trailing LF becomes a trailing space (the fixer flagged this).

CHECKED:
  correctness vs done-when: 5f04ac26: LF, CR and CRLF titles through both founding scripts give one "# one two" line and
    title "one two". d97756aa: through both scripts, --labels type --labels size -> type,size (round first in discovery),
    type --labels type -> type once, and an empty list -> exit 2 with no board. Discovery round stays first in all 26
    matrix cases. Not met: the {{topic}} path (BLOCKING).
  project conduct:          one commit, only skills/ and tests/, no board writes, no .DS_Store. Scripts use bash 3.2 and BSD
    tools. The usage comments in both scripts were updated, and SKILL.md and founding.md don't contradict the new rules.
    The lead ruled on the "SEEN dedupes" spec error in the thread. No "assume Y" shapes.
  both paths:               --labels: both scripts covered, and both share merge_kinds. Title: heading (fixed) and
    frontmatter (title_str) are covered. The body {{topic}} path is unhandled and unflagged (BLOCKING). {{project}} and
    {{verified}} in pipeline-index are caller --var values, not the title, so they are out of scope.
  fail-before:              OWN RUN agreed with the fixer. The branch's tests/smoke.sh on bca7ced source fails at the new
    heading case, printing "# one" then "two" under title "one two". Running the bca7ced scripts directly:
    --labels type --labels size -> [size] rc=0, and found-discovery-board.sh --labels "" -> rc=0 with a board written.
  test adequacy:            3 new cases sit beside the hostile-title and label-kinds blocks, named and asserted like their
    neighbours. Gap: no assertion on the {{topic}} line (BLOCKING). A merge_kinds mutation that matches against $out
    instead of $1 would turn the existing "type,type" exit-2 case red (reasoned), so that rule is covered.
  blast radius:             4 files: lib.sh +19/-2, found-board.sh +4/-3, found-discovery-board.sh +5/-4, smoke.sh +33,
    which matches the cards' Touches. Sourcing lib.sh in the wrapper adds one top-level assignment (LIB_DIR) and no
    name clashes. Everything else is function definitions.
  population:               title_str old vs new, /bin/bash 3.2.57 (the only bash on this host): 24 hostile inputs,
    20 byte-identical. The 4 that differ are exactly the ones containing CRLF (two spaces -> one, as documented).
    End to end: 12 hostile titles (LF, CR, CRLF, trailing LF, only LFs, tab, {{id}} {{stamp}}, backslash+quote,
    "\n## Evil", "\n\n", "\\\r\n\"") x found-board, found-discovery-board, file-question, file-record = 48 runs per side,
    all rc=0. 24/24 boards validate with 0 failures (Skills Pipeline .schema copied into each throwaway board).
    The old/new diff is only the flattened headings and CRLF -> one space in titles. {{...}} in a title is not
    re-expanded (render is one pass), and is identical on both sides. --labels: 26 cases x 2 scripts. The 15 boards
    written validate with 0 failures. Every refusal leaves no board folder and 0 lanework-found.* entries in a private
    TMPDIR per case (positive control: the accepting cases wrote boards in the same run). Gate at 26e763c in the scratch
    worktree: "smoke: 83 passed" rc=0, "check-sizes: 48 rows, 0 wrong".
  adversarial only:         hypotheses written before the reports. (1) $(...) strips a trailing newline: no, it is
    flattened first. (2) CRLF output changes: HELD, documented. (3) bash 3.2 $'...' pattern substitution: works.
    (4) merge_kinds checks against $1, not $out: correct, it keeps the within-list refusal. (5) and (6) empty names lost
    across flags ("" then type, type then ","): no, all exit 2. (10) ${2?} inside $(...) changes the exit code: no, a
    missing value is rc=1 before and after. (11) lib.sh sourced after the argument loop: no, line 13 / line 15.
    (12) {{...}} in a title: safe. (19) {{topic}} is a second raw path: HELD (BLOCKING).

UNRESOLVED: none
```
