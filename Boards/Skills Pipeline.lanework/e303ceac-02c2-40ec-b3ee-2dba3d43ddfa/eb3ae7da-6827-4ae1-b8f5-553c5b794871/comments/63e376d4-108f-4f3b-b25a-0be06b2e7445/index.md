---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:17:33Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:17:33Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review of `rename-skills` at 481eefa: APPROVE, 0 blocking, 8 notes. Smoke 30 passed at the head; own fail-before agrees.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not none: trigger phrases untested, README sizes re-measured wholesale, racing section replaced)
ROUND:   1

CARD:   Active/eb3ae7da "Rename pitwall to watch and pitlane to work"
BRANCH: rename-skills at 481eefa (read off the branch; merge-base b75b35a)

BLOCKING: 0
  none

NOTES: 8
  1. README.md:55 @ 481eefa "`references/lead.md` | 976": measured 977 with `wc -w` at the head, so `work`'s total is 6,201, not 6,200 (README.md:26, :67). The other 3 skills re-measure exactly (lanework 2,774, watch 1,044, discovery 2,388, file by file). The "README sizes drift" Ideas card covers it, or fix it in the rebase below.
  2. tests/smoke.sh:231 @ 481eefa "grep -q 'lint-ask warning'": a broken LINT_SCRIPT path prints "warning: no lint-ask.sh at …" (file-question.sh:91), which this grep never matches, so smoke stays green when the path this card rewrote is wrong. It was the same before the branch, but a rename is exactly how that path breaks (E12). I checked the path by hand (fail-before line, below). Fix: grep for `warning` too.
  3. skills/work/SKILL.md:3 @ 481eefa "Use whenever the user mentions Lanework or a pipeline board": the "Pitlane" trigger is gone, but the `Pitlane/` folder still shows the word every day. So a user who says "check my Pitlane boards" now relies on "boards"/"Lanework" to load the skill. A temporary alias ("Lanework, Pitlane, or a pipeline board") until the folder card 04cb88f0 lands is the owner's call. The card doesn't ask for one.
  4. README.md:144 @ 481eefa "The skills are named for what they do.": this is accurate today. It goes stale twice: it doesn't name `merge` once merge-skill lands, and its line "the Pitlane/ folder … is unchanged" changes when Approved 04cb88f0 lands. "a separate convention with its own name" is close to a tautology.
  5. tests/smoke.sh:22 @ 481eefa "for n in pitlane pitwall; do": the card's Verify grep literally hits the guard (lines 22, 26) as well as the folder convention. That is expected and the fixer flagged it. Only the card's wording is off.
  6. skills/work/SKILL.md:6 @ 481eefa "# work" (and skills/watch/SKILL.md:7 "# watch"): lowercase headings, where the siblings use "# Lanework boards" and "# Discovery". Cosmetic.
  7. Board: Ideas card b9693bcb now has the `work` label, but its title still reads "pitlane: adversarial review of shaped proposals before Proposed". That's a title, not a label, so it's optional.
  8. Merge order: main + rename-skills merges clean (merge-tree exit 0, tree fe71e93). rename-skills + merge-skill (068c6b4) conflicts in .claude-plugin/plugin.json and README.md only. writes.md and smoke.sh auto-merge, and merge-skill adds no pitlane/pitwall citation. The second branch to land must: (a) keep the plugin list as lanework, work, watch, discovery, merge; (b) in README, add the `merge` row to the skills table, the sizes summary and its own section, add the merge install line and say "five"; (c) re-measure lanework writes.md after merge's added line; (d) put `merge` in the Names paragraph.

CHECKED:
  correctness vs done-when: I compared against each card bullet. The folders were git mv'd (100% similarity on unchanged files). name/description/heading are updated. Every pitlane/… and pitwall/… citation is swept, and `/pitwall` is gone from watch, discovery and README. My own grep at the head (pitlane|pitwall, excluding Pitlane/ and CHANGELOG) finds 18 hits: 16 are the Pitlane/ folder convention (CLAUDE.md, README, release.sh, finding.md, arming.md, sweep.md, smoke.sh:7), and 2 are the guard itself (smoke.sh:22, :26). There is no "Pitlane:" prefix, no "/pitwall" and no live racing metaphor in any SKILL.md (I grepped race/racing/pit lane/pit wall/crew/driver: no metaphor hits). The `name:` field matches the folder in all 4 skills. The work description still has "Lanework", "pipeline board", "sweep the pipeline board", "file a card on X" and "triage Ideas". The lanework description reads "Not for sweeping or working a board (the `work` skill)". The ~/.claude/skills relink is the lead's part at merge (thread 6c3be543), not the fixer's.
  project conduct:          Board writes (bfce8f0, 16681ba on main) are kept apart from the code commit (481eefa). Paths are staged explicitly. The plugin.json skills list matches the folders, and smoke ok 30 checks that independently. Keywords: "pitlane" is swapped for "work" and "watch". These are generic but harmless next to "lanework" and "kanban". No "assume Y" shapes.
  both paths:               The lint path is right both ways: a repo checkout resolves through LIB_DIR to skills/work/scripts/lint-ask.sh, and a symlink install resolves to ~/.claude/skills/work, which needs the relink at merge (already the lead's part). watch-boards.sh changed only in its header comment (diff line 2). Smoke ok 24 and ok 25 (fswatch present) pass at the head.
  fail-before:              FIXER RUN and OWN RUN agree. I checked out the branch's tests/smoke.sh in rename-skills-review at b75b35a: exit 1 at "skill folder skills/pitlane still exists (renamed to work and watch)" after ok 1, then restored it (status clean). I also ran file-question.sh from the head on a scratch board in $TMPDIR. A clean body exits 0 with no warning. A hedged body (positive control) gets "lint-ask warning: 3 question marks …", so lint-ask was found and ran. A copy without work/ (negative control) prints "no lint-ask.sh at …/work/scripts/lint-ask.sh".
  test adequacy:            The guard sits with the syntax check at the top of smoke and uses the same `ok` line style. It would pass if a stale folder or plugin entry came back with a new name. E2 holds for its stated scope: folder and plugin entry only. Citations are covered by check-refs (ok 26).
  blast radius:             34 files, +80/-76, all inside the card's Touches list. The two items beyond the card are the README sizes re-measured in full and the Names section rewrite. Both are flagged in UNCERTAINTY, and the card's Touches already names "sizes" and "the motor-racing section". check-refs.sh is unchanged: it is generic and names no skills. No unexplained churn.
  population:               Smoke at the head: "smoke: 30 passed", exit 0, read directly; 30 `ok` lines out of 30. Grep: 18 hits read one by one, none unexplained. Board: validator "failures 0 over 0 of 146 documents" (board 1, lane 8, card 32, comment 99, attachment 6), warnings 0, deprecated 0. Old labels: the 7 cards still carrying text: pitlane or pitwall are all in Done. Open cards relabelled: 3 (eb3ae7da Active, b9693bcb Ideas, 04cb88f0 Approved). The board sheet's Skill line reads lanework, work, watch, discovery, merge, repo.
  adversarial only:         I wrote these hypotheses before reading the reports. H1, a broken lint path in file-question.sh: did not hold (verified by run). H2, a stray `/pitwall`, "Pitlane:" or racing wording: did not hold. H3, a state path, env var or lockfile named pitwall in watch-boards.sh changing behaviour: did not hold, only the comment changed. H4, check-refs hardcoding skill names: did not hold. H5, README numbers wrong: held weakly (note 1). H6, conflicts with merge-skill: held, and they are mechanical (note 8). H7, smoke unable to catch a wrong lint path: held, and it was there before the branch (note 2).

UNRESOLVED: whether to keep "Pitlane" as a migration trigger word in `work`'s description until the folder rename lands (note 3). That is the owner's call, and the card doesn't ask for it.
```
