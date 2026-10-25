---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:21:10Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-25T11:21:10Z, by: {name: reviewer, kind: agent, model: opus}}
---
**REQUEST-CHANGES, round 1: the compact form holds, but the skill heal's new compact-collection pass unquotes YAML words in a stamp, which the board heal v2 keeps quoted.**

- **Evidence**: smoke in the fixer worktree at `e58deea`, `smoke: 121 passed`, no `__pycache__`. Own FAIL-BEFORE at `7c8a801` agrees with the fixer's on all three observables. The skill and board heals give byte-identical trees over the 25 H17 rewrites on a copy of this board, and over 11 of 12 on an adversarial board. The 12th is the blocking finding. Runs: [review-runs.log](attachments/b6a3a848-a825-4b2f-ad88-27222508efd5/blob.log).

```text
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer at opus; the diff changes writers of board files and the git merge driver)
ROUND:   1

CARD:   Active/3d4b9109 "Smoke is red: the board's guide moved to v101, the skills are stamped v93"
BRANCH: guide-v101 at e58deea

BLOCKING: 1
  skills/lanework/scripts/heal-board.py:339 @ e58deea "PLAIN_OK.fullmatch(s) and not isinstance(scalar(s), (bool, type(None)))":
  a stamp over several lines, e.g. created: / at: ... / by: {name: claude, kind: agent, model: "on"}, is now
  rewritten by compact-collection to one line with model: on (and name: yes stays plain). PyYAML reads both
  as True, and the board heal v2 writes "on" and "yes" quoted (its YAML_WORDS, the app's plainFlow). Before
  this branch the skill heal left that stamp alone, so this is a new value-changing rewrite, and it breaks
  the "byte-identical apart from stamp spacing" claim. Fix: port v2's YAML_WORDS check
  ({true,false,yes,no,on,off,null,y,n,~}, lowercased) into the plain_ok branch, and add a YAML word to
  ok 22's "Stamp over lines" seed card so the parity diff covers it.

NOTES: 3
  skills/merge/scripts/lanework-merge.py:267 @ e58deea "return repr(v)": a whole-number float stays "2.0"
  where the heal writes "2". Near 120 characters that changes the line count, so H17 fires after a merge:
  12 of 5663 random values with floats, 0 of 3705 without. Already in the fixer's UNCERTAINTY.
  skills/lanework/references/writes.md:34 @ e58deea "Your own value of a `single` kind wins": the guide
  also says that when a lane's defaults hold several values of a single kind, one is kept (the lowest rank,
  else the first). The bullet doesn't say that.
  file-ticket.sh, file-question.sh and file-record.sh don't union a lane's card-defaults. Reachable since
  v101's Board Settings writes the key. This is the fixer's follow-up, not drift.

CHECKED:
  correctness vs done-when: smoke green with ok 120 reading v101; check-sizes 62 rows, 0 wrong. Guide
                            v93->v101, HEAL.md v1->v2 and lanework-heal.py v1->v2 walked line by line:
                            compact form, nested levels and multi-line stamps (H17), card-defaults kinded
                            entries, the Board Settings keys, the text-kind wording, --global removed,
                            emit_kept dropped (the skill heal had none), the key-line comment, the plain
                            app timestamp, the H11 skip change (skill already matches: 6 cases identical),
                            stamp plainFlow (the blocking finding), .gitignore v5. No skill restates the
                            retired "no control in the app" wording.
  project conduct:          the stamp is only in CLAUDE.md; no board writes in the branch; plain messages;
                            python3 -B is in compact_fm, and smoke gates __pycache__
  both paths:               writers (found-board, file-ticket, file-record) + heal + merge: all three
                            changed. file-question.sh is uncompacted on purpose: its waiting and labels max
                            out around 95 characters quoted
  fail-before:              FIXER RUN checked; OWN RUN agreed: the new smoke on old skills stops at
                            "compact-collection dry run lacks: index.md: ... 2 lines to 1"; the new
                            merge-case on the old driver fails "5 lines to 8" (merge and rebase); old
                            writers give H17 on PL2 1, Plan 4, Discovery 3, D Discovery 1
  test adequacy:            ok 21/22/119 sit beside the heal and stamp cases. ok 119 has a positive control.
                            Fixture checks moved to value comparisons (same_doc, flowed), and ok 119 now
                            covers the layout they used to pin. ok 22 can't see the blocking case: its seed
                            has no YAML word
  blast radius:             12 files, exactly the card's Touches list; no unexplained churn
  population:               H17 scan over 53 of 53 smoke boards: 1 hit, a hand-written smoke card
                            excluded by design; fuzz 9368 values in all
  adversarial only:         hypotheses written before the reports: (1) the skill emitter diverges from the
                            board heal v2 on quoting: held (stamp YAML words); (2) the merge emitter
                            produces invalid YAML or loses a key: refuted (round trip exact); (3) the
                            merge's line count differs from the heal's: held for floats only; (4) the
                            skill parser misreads a block and compaction drops data: refuted beyond YAML
                            1.1-only forms (0x10, 1_000, 12:30), which the board heal reads identically;
                            (5) other heal-v2 rule changes missed (H11 skip, emit_kept): refuted; (6)
                            the writers still emit H17 somewhere: refuted on all 53 boards

UNRESOLVED: none
```
