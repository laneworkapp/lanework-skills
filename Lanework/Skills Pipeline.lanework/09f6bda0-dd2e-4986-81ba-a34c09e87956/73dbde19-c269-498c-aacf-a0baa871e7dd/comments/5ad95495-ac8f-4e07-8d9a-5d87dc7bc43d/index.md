---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:35:52Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:35:52Z, by: {name: reviewer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Review: APPROVE at `9a8568c`, 0 blocking, 3 notes.**

```
VERDICT: APPROVE
STANCE:  STANDARD (fixer ran at sonnet; blast radius matched Phase-1; prose only)
ROUND:   1

CARD:   Active/73dbde19 Write reviewer verdicts as Markdown, not a code fence
BRANCH: verdict-markdown-73dbde19 at 9a8568c (origin/verdict-markdown-73dbde19, read off the branch)

BLOCKING: 0
  none.

NOTES: 3
  1. skills/work/templates/review-verdict.md @ 9a8568c "**Notes**": the template says what a note is but not how to write an empty one; Blocking has "**Blocking**: none." and Questions says leave it out. A clean review will invent a form (Notes: none / omit / "0 new"). Add one clause.
  2. scratchpad/vm/c1.md, c2.md @ 9a8568c "**Lead-ruled re-check: APPROVE" / "**Review of `pointer-audit`": both open with a bold conclusion line above "**Verdict: ...**", so the result is stated twice, which the card's Problem counted as a defect (427 of 647). The template has no such line. All three rewrites also end "**Unresolved**: none." while the template says leave Questions for the lead out when none, and c1 and c2 use "Unresolved", not the new heading. The body's own sample does the same, so either the template or the samples need to agree before the owner views one.
  3. skills/work/templates/review-verdict.md @ 9a8568c "<one sentence: why, and the note count>": the fenced template's BLOCKING and NOTES counts are now only a sentence (the note count; the blocking count only on REQUEST-CHANGES). Harmless, since the numbered lists carry them; mentioned because the count was a field before.

CHECKED:
  correctness vs done-when:
    1. no fence around the verdict, order result, blocking, questions, notes, checked, hypotheses: met (template diff).
    2. three rewrites keep every line, no fence, no hard breaks: no fence in any (grep: 0 backtick fences), lines are paragraph or list-item long. c3 is the body's sample with its preface dropped. I did not re-read the c1 and c2 source verdicts, so "every line kept" for those two is the fixer's claim, not mine. The extra opening line in c1 and c2 is an addition, not a drop (note 2).
    3. smoke passes or fails only on the guide gate: NOT RUN on this head (lead runs it). Scoped here: check-sizes 62 rows 0 wrong, check-refs 249 references 0 missing, both my own run in the worktree.
    4. owner views a rewrite in the app, thread records it: OWNER ONLY, open. The fixer's comment says so too.
  guide rules for comments (v114): the template uses paragraphs, bullets, one nested bullet level, numbered lists, bold, inline code, links and a blank line after every list. No table, no fence, no hard break, no HTML. The guide's only comment-specific rule is the blank line after a list; the template and all three samples keep it.
  nothing lost vs the released template: STANCE/ROUND/CARD/BRANCH have bullets; BLOCKING and NOTES keep anchor, failure scenario, fix direction and "never blocks, lead may file"; CHECKED keeps all seven rows plus the adversarial row, now Hypotheses; UNRESOLVED became Questions for the lead (moved up); the lane/uuid prefix became the link. Only the counts (note 3).
  reviewer.md vs template vs team.md: agree. "Questions for the lead above Notes and Checked", "Notes = something a person could act on...", "A check that came up clean goes under Checked" appear in both; the template's "never blocks" matches § Bounding review; the failure scenario stays in the Blocking line; the anchor format is unchanged. No stale UNRESOLVED, VERDICT: or CHECKED left under skills/ or tests/*.sh.
  repo conventions: telegraphic bullets, one topic one file (rules in reviewer.md, shape in the template, one restated clause in the template is the permitted owner-facing exception), no guide version under skills/ (grep clean), README § Sizes rows agree with wc -w (check-sizes).
  fail-before: not applicable, prose only, the body asks for no smoke case.
  blast radius: README.md, reviewer.md, review-verdict.md, as Phase-1 said. No script, no plugin.json.
  population: the 3 rewrites are the whole sample the body asks for (one clean APPROVE was requested; the fixer made three adversarial ones, none a plain standard APPROVE: the body asked for "one clean APPROVE, one REQUEST-CHANGES and one adversarial". That is a gap against Verification, not against Done when).
  adversarial only: n/a (standard).

UNRESOLVED: none for the owner beyond done-when 4. For the lead: the gate on 9a8568c before merge.
```
