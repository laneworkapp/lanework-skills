---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:48:20Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:48:20Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Round 2 review of `pointer-audit` at 06e17f2: APPROVE. The smoke blocker is closed, and NOTES 1-3 are addressed.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none": regex heuristic, guide sections cited by name)
ROUND:   2

CARD:   Active/43456b82 "Skills point at the board's own guide and schema for specifics, starting with priority and component"
BRANCH: pointer-audit at 06e17f2 (rebased onto main da61093; range-diff: 264b6ca = 4352486, plus 06e17f2)

BLOCKING: 0
  Round-1 finding tests/smoke.sh:84 "\b(priority|component): *[^ `]|(priority|component)[^.]*root keys?": closed. The line now reads "\b(priority|component):|(priority|component)[^.]*(root|top-level)|(root|top-level)[^.]*(priority|component)". OWN RUN on mutants: "Write `priority:` as a top-level key", "Priority and component live at the card root", "Set the root key `priority`" and the original writes.md:10 claim are all CAUGHT. "A root `priority:` / `component:` key is reserved", "Group the lane by component", the lead.md:27 wording and "scope or priority" are all passed.

NOTES: 2
  tests/smoke.sh:84 @ 06e17f2 "(root|top-level)[^.]*(priority|component)": also false-positives on prose like "The root cause outranks priority." (the fixer accepted "Priority: rank…" knowingly). No such line today; the failure message says what to reword.
  tests/smoke.sh:84 @ 06e17f2 "grep -v -i 'reserved'": any line containing "reserved" is exempt, so a root-key prescription that happens to mention "reserved" on the same line passes. Narrow; acceptable for a heuristic.

CHECKED:
  correctness vs done-when: round-2 diff (4352486..06e17f2): writes.md:9 quotes the guide's two sentences ("Quote any `title` containing a colon", "Keep every scalar on one line"), and both exist in the v82 § Frontmatter. writes.md:21 cites § Editing and deleting, and writes.md:25 cites § Moving and reordering, both real v82 headings. founding.md:19 "The script writes the board's required keys". The skill text from round 1 is unchanged by the rebase.
  project conduct:          telegraphic; entries replaced, the Moving pointer is one line; authority.md stamp still v78 (step 20 ok); board writes (c105b22) separate from code commits.
  both paths:               n/a, wording plus one guard.
  fail-before:              OWN RUN agreed: the round-2 regex hits skills/lanework/references/writes.md:10 on the 3908fde tree.
  test adequacy:            same step, same place, same name; now catches the house-style forms.
  blast radius:             round 2 touched writes.md, founding.md and smoke.sh only, as the fixer's record says.
  population:               the regex has zero hits on the 06e17f2 skills tree. Audit rows for the delete and Moving bullets were added in 7f7e3117.
  adversarial only:         round-2 hypothesis: a widened regex false-positives on the current tree or misses the mutants. Neither held. Full smoke OWN RUN at 06e17f2 (scratch worktree, detached): rc=0 read directly, "smoke: 21 passed", including step 21 plugin validate.

UNRESOLVED: none
```
