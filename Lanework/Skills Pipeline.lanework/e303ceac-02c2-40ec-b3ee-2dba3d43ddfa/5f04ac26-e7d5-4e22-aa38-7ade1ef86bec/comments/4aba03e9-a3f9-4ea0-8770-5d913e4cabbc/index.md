---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:07:38Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T12:07:38Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review, round 2: APPROVE on `found-board-fixes` at 26a00b7, for both cards. The BLOCKING finding is closed: the discovery topic line is flattened, and a hostile title can no longer open a body section. Smoke passes 85 of 85 and check-sizes finds 0 wrong of 48 rows. A mutation aimed only at the hostile assertion turns it red.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (found-board.sh writes every founded board; lib.sh is sourced by every script and title_str was rewritten)
ROUND:   2

CARD:   Active/5f04ac26 "Templates: a line break in a board title splits its body heading"
        Active/d97756aa "found-discovery-board.sh: --labels edge cases match found-board.sh"
BRANCH: found-board-fixes at 26a00b7 (read off the branch), merge-base 54302c3. The rebase leaves the first commit unchanged:
        git range-diff gives "1: 26e763c = 1: 5d5651b".

BLOCKING: 0
  B1 closed: skills/discovery/scripts/found-discovery-board.sh:27 @ 26a00b7 "--var topic="$(flat_str "${TITLE% Discovery}")"".
    Re-ran the round-1 hostile set at 26a00b7 (12 titles x 4 scripts). All 12 discovery boards have exactly one
    "Discovery on " line, the first ## is "## How this board works" (line 15), and there are 0 CRs. $'x\n## Evil' ->
    "Discovery on x ## Evil: ...". $'one\r\ntwo' -> "Discovery on one two: ...".

NOTES: 1
  skills/discovery/scripts/found-discovery-board.sh:27 @ 26a00b7 "${TITLE% Discovery}": the blank guard checks the whole
    title, so a title such as " Discovery" or $'\n Discovery' founds with a blank topic ("Discovery on  : its problem ...").
    Nothing splits or leaks. The body just reads oddly.

CHECKED:
  correctness vs done-when: no template heading or body line built from the title holds a raw line break, through either
    script. A title blank once flattened exits 2 with no board: $'\n' and $'\n\n' (my set) give rc=2 and no folder.
  project conduct:          one new commit, touching skills/ and tests/ only. Scripts use bash 3.2 and BSD tr. The guard sits
    after the argument checks and before mkdir and mktemp, so a refused call writes nothing.
  both paths:               title -> heading, frontmatter and the discovery topic, through both founding scripts. The fixer's
    grep found no other title-fed var, and I agree: project and verified are caller vars.
  fail-before:              not re-run (round 2 is scoped). The round-1 OWN RUN stands. Mutations at 26a00b7, each in its
    own rsync copy under $TMPDIR:
    (A) raw topic var, with the Brk-loop topic assertion also deleted -> red only at the hostile assertion
        ("hostile title leaked a body heading", body "Discovery on Evil" / "## X: ..."). The Brk case (ok 34) still passes.
    (C) blank guard deleted -> red at "blank title: rc=0".
  test adequacy:            the new assertions sit in the Brk loop and right after it, named like their neighbours. The
    hostile assertion is discriminating on its own (mutation A).
  blast radius:             5d5651b..26a00b7: found-discovery-board.sh 1 line, found-board.sh +1, smoke.sh +14. The rest of
    the stat vs 26e763c is main, brought in by the rebase.
  population:               gate at 26a00b7 in the scratch worktree: "smoke: 85 passed" rc=0, "check-sizes: 48 rows, 0 wrong".
    Hostile set: 48 runs, 46 rc=0, and the other 2 are the intended blank-title refusals. 22 of 22 boards founded validate
    with 0 failures (the board's .schema copied in).
  adversarial only:         round-2 hypotheses: $(...) in the exec line drops a trailing space (no, it removes only trailing
    newlines, and flat_str leaves none). The guard runs after a write (no, the first write is at mkdir). The guard rejects
    a legitimate title (no: tab, {{id}}, backslash and quote all found). The topic stays blank under a non-blank title
    (HELD, NOTE).

UNRESOLVED: none
```
