---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:20:28Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:20:28Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Review of `guide-v114-2c29a34f` at 25a7cbe: REQUEST-CHANGES. One blocking finding: a list-form `waiting` long enough to take the block form leaves settle-question.sh and resolve-ticket.sh writing a card whose frontmatter does not parse.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer ran at opus; Phase-2 blast radius differed from Phase-1: the Damaged-case assertion moved in 25a7cbe)
ROUND:   1

CARD:   Active/2c29a34f "Skills target agent guide v114: waiting lists, short links, relations, component retired"
BRANCH: guide-v114-2c29a34f at 25a7cbe (read off origin and the local ref)

BLOCKING: 1
  skills/discovery/scripts/settle-question.sh:43 @ 25a7cbe "n==1 && /^waiting:/ { next }" (same line at skills/plan/scripts/resolve-ticket.sh:50): the awk drops only the waiting: line. A list for four people, waiting: {for: [rzen, bobsmith, carol, dave], since: ..., comment: <uuid>}, is 121 chars, so the compact form (lanework/references/writes.md; lib.sh compact_fm and the heal's compact-collection both rewrite it so) is a block: waiting: then indented for/since/comment lines. The script leaves those three lines under order:, and the frontmatter no longer parses ("mapping values are not allowed here"): the app refuses the card. Before v114 a scalar for reached the block form only with a 29+ char handle. The list form makes it reachable, and the card's Scope says these scripts "need no change". Smoke's list cases (smoke.sh:378, :538) use two short handles, one flow line, so they pass either way. Fix direction: also skip the key's indented continuation lines in both awks; add a block-form waiting to both smoke cases. Same class, display only: plan/scripts/frontier.sh:34 fm_value reads a block waiting: as empty, so no "(waiting)" mark. Measured: the awk run on the compact_fm output, see attachment.

NOTES: 5
  skills/work/scripts/lint-ask.sh:27 @ 25a7cbe "grep -o -E '(^|[^[:alnum:]_])@[[:alnum:]_-]+'": fails "- A: Pin `@types/node` to 20" ("handle @types is not on the first line") and a link https://mastodon.social/@someone/123 on a later line. Both are word-boundary tokens, which the guide's § Mentions parses as mentions (of nobody), and writing.md's budget bars paths. So the lint fails loud on a rewordable ask, never silently passes. Stripping code spans and link targets before the scan would end both. Dots, dashes, email, a record naming nobody and the human named twice all lint right.
  skills/work/references/writing.md:50 @ 25a7cbe "only on a board whose guide line reads v105+": the one guide version named under skills/, against CLAUDE.md "stamped here and nowhere else". smoke.sh:1117 matches only "lanework-(agent-guide|schema) vN", so it misses it. A floor, not a target stamp, so no drift on a bump. A version-free form: "only where the board's guide § Mentions allows a list".
  tests/smoke.sh:162 @ 25a7cbe "priority: High": with card 5's component: {text: Sync} gone, nothing runs the mapping branch of root-key (heal-board.py:924 "elif isinstance(v, dict):"). Card 6's mapping goes to root-key-dropped. A card with priority: {text: High, rank: 1} and no priority entry would cover it again. added-definition itself is still proven: Solo's dry-run grep and its --apply check both fail if the repair breaks.
  skills/watch/references/events.md:11 @ 25a7cbe "A bare move with no comment = the owner acting at a gate": on a config.move-receipts: true board an app move arrives with a board-signed receipt comment (guide § Stamping, v108+). The line does not say a receipt leaves the move bare, or that moved.by names the mover. classify-event.sh already emits move + agent comment.
  README.md:42 @ 25a7cbe "Measured with `wc -w` on 2026-10-10": rows for lanework, work and merge changed, the date line did not.

CHECKED:
  correctness vs done-when: stamp v114 in CLAUDE.md:29 only. No skill names component as reserved, suggested or a by: value (grep component over skills/: writes.md:10 "no reserved key", heal-board.py:24, catalog rows board-kinds.md:25,44, founding.md:17). Every row of the card's Scope table was read against the v101 to v114 guide diff. Gap: the list-form waiting row (blocking above).
  project conduct:          stamp in one place (but the v105 floor, note 2). Board writes not in the branch. No "assume Y" shapes. The 4de5836b decision to drop root component: from card 5 was explained (v1 validator DEPRECATED).
  both paths:               the list-form waiting has two layouts, flow and block. Only flow is handled and tested (blocking). Heal walk: a live relation is walked; relations/.trash, a relation under a comment folder and one under a card in the board .trash are not.
  fail-before:              OWN RUN agreed. The four new cases were run alone at the merge-base 4e6d022 in the scratch worktree and all fail with the card's observables (lint passes the late handle; heal adds component and lists no relation repair; --name board rc=0; board_singles holds component). All four pass at 25a7cbe. The fixer's attachment names ed4cc29, the base before the rebase: same scripts, same results.
  test adequacy:            the cases sit in the heal/merge block of smoke.sh, with throwaway boards and the neighbours' style. Each one discriminates: it fails on the unfixed script, and the relation grep needs exactly "1 repairs in 1 files".
  blast radius:             22 files, all in Touches. Phase-2 change: the added-definition assertion moved from Damaged to Solo (25a7cbe). Explained, with one coverage loss (note 3).
  population:               fixtures: 5 of 5 byte-identical to their README sources (d14e3d6, dc404fe, 8e7fd1e, 99ac340, 281c22a). check-refs: 248 refs, 0 missing. check-sizes: 62 rows, 0 wrong. lint-ask: 11 inputs, 2 flagged false failures (note 1).
  adversarial only:         hypotheses before the reports: (1) list waiting breaks the drop-the-line scripts: HELD, blocking; (2) lint-ask false-fails on @ in code or URLs: HELD, note; (3) heal applies card repairs to relations or walks .trash: refuted (only stamps, retired keys and layout run; .trash is skipped by the uuid filter); (4) moved assertion stops proving added-definition: refuted, but the root-key mapping branch lost its case; (5) fixtures drift from their sources: refuted; (6) component left built-in somewhere: refuted.

UNRESOLVED: none
```

**Attached**: [review-evidence.txt](attachments/3556c968-7313-4aa0-9b54-5ed63194ece8/blob.txt): own fail-before runs, the block-waiting repro, the lint-ask inputs, the relation walk, the fixture cmp.
