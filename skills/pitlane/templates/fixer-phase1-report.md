# Fixer Phase 1: code-complete report (= slot request)

Send this structure to the lead, not prose.

```
CARD:   <lane/<uuid> and title>
BRANCH: <branch, worktree absolute path>
FILES:  <changed source files>
TEST:   <new/modified suite + method>

FAIL-BEFORE:
  <the scoped command, the sha it ran at (the merge-base), and the test's own
  failure line: the card's observable, not a compile error. Where the raw run is
  attached on the thread. "CAN'T RUN AT MERGE-BASE: <why>" if the harness is new.>

LINKED CONTEXT:
  <what the card's and linked cards' threads say that bears on the fix: a duplicate,
  a one-fix-many sibling to bundle, a corrected root-cause guess, related work
  landed or in flight. "none found" only after reading them.>

EXPECTED BLAST RADIUS:
  <what should change and why, and what must come back byte- or behavior-identical.
  The identity half is load-bearing: it's how verification catches a mismatch.>

PRE-REGISTERED VERIFICATION:
  <REQUIRED, written BEFORE the gate runs: tests that fail before and pass after,
  suites that must stay untouched, counts that should move, with expected values.
  Allowed to be wrong: report the mismatch, never bend the measurement or narrow
  the fix to match it.>

TOUCHED SURFACE:
  <modules/suites/seams touched: the lead's cross-branch overlap signal.>

UNCERTAINTY:
  <an uncovered edge case, a second path that may need the fix, done-when ambiguity.
  "I only fixed the macOS path" is the signal the reviewer needs. Say if the new
  test is UNRUN.>

REQUESTING VERIFICATION SLOT
```
