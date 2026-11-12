---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:47:36Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:47:36Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**REQUEST-CHANGES: one blocking finding. A lane default that is a number or a boolean (`2026`, `1.10`, `true`) is dropped without a word, and `labels: 2026` makes all three scripts refuse to file into that lane. The schema reads both as free labels. Everything else meets done-when on my own runs, and the five cases fail at the merge-base and pass on the branch.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (writes persisted card frontmatter; three deviations from the card body after Phase-1)
ROUND:   1

CARD:   Active/032b563c-0f1b-4229-a245-fbe6ab1435a7 "Filing scripts: union the lane's card-defaults labels into new cards"
BRANCH: card-defaults-032b563c at 6b1bf92364df182b82e8e4cefb7b412d4fd4b4ff

BLOCKING: 1
  skills/lanework/scripts/lib.sh:136 @ 6b1bf92 "if hb.is_text(raw):" and :166 "if not hb.entry_of(n): continue": is_text accepts only str, but the heal's parser reads an unquoted 2026 as int, 1.10 as float and true as bool. The board schema's card-default-labels uses lenient-text ("Any scalar reads as the text the author typed"). Two failures (run, evidence § 5): (1) lane card-defaults: {labels: [v1, 2026, 1.10, true, "2027"]} validates with 0 failures, but the card gets only v1 and "2027". (2) card-defaults: {labels: 2026} validates too, but every file-ticket / file-question / file-record into that lane exits 1 ("neither a list nor one name"). Version and year labels are a plausible free-label shape. Fix: read a non-bool int or float, or a bool, as its text when it is a bare name, both in the list and as the one-name scalar. Add a smoke case with an unquoted number in the list and as the bare scalar.

NOTES: 5
  tests/smoke.sh:1184 @ 6b1bf92 "{text: ROUND 1, kind: {type: round, text: Round}}": round is single: true on the discovery board, so the single-kind rule drops ROUND 1 whether or not the same-text match works. A mutant with the 'k in have or k in seen' check turned off passes all five cases, yet on lane [URGENT, Bug] with own urgent it writes both urgent and URGENT (run, evidence § 3). The helper is right (own run, b1), but nothing in smoke tests the case-insensitive union, and the ok line and 710c1d9a say it does. Add a non-single overlap, e.g. a lane listing [extra, EXTRA] or a free name equal to one the card already carries.
  FAIL-BEFORE 710c1d9a ran at the pre-rebase base ed4cc29 with an earlier test version (its case 5 still treated {labels: nope} as malformed, which is now one free label). No FAIL-BEFORE is recorded for the current tests at 2dc7b75. My own run fills the gap and agrees. Its attachment is a flat file (comments/710c1d9a…/attachments/fail-before-merge-base.txt): the board validator counts it as "retired flat attachments 1".
  skills/lanework/references/writes.md:34 @ 6b1bf92 "do it too (…), a hand-written card needs it yourself": a comma splice that does not parse. Suggest "…do it too (…); for a hand-written card, do it yourself."
  Malformed card-defaults (a scalar, a list, labels as a mapping) makes the filing exit 1. The card ruled that, and it is atomic (run). The guide's posture is "a value with no reading is preserved and invisible", though, and the app still makes the card. Worth a line in the lib.sh comment so nobody "fixes" the app parity later.
  A CRLF lane: the helper reads it fine (run, b11). But lib.sh lane_by_title (pre-existing, not this diff) does not find a CRLF lane at all ("no Blocked lane"). That is the existing CRLF gap across the scripts.

CHECKED:
  correctness vs done-when: on scratch boards the three scripts unioned free names, kinded entries (stamped from config.labels: Urgent's rank, colour and glyph) and single kinds (own wins; lowest rank among several; ranked before unranked; a repeat counted once). Also checked: block-form and >120-char hand-written card-defaults, retired spellings in the lane (kind: priority string, value:, bare glyph:, no kind), a closed kind's unlisted value (left foreign, as the heal leaves it), YAML-special names (#hash, yes, a: b: all quoted), card-defaults with other keys, {}, labels: [], labels: null, an empty key, and no config.labels (an undefined kind is kept as written). Every filed card validates and both the skill heal and the board's heal v5 report 0 repairs on cards. The only repairs and the one FAIL are on the lane files I wrote by hand. Lines over 120 come out in block form and parse.
  project conduct:          bash -n on the four scripts. python3 -B, and no __pycache__ under skills/ after every run. The relative lib.sh source works from a ~/.claude/skills-style folder of per-skill symlinks (run). Board and code changes are not mixed (the branch has no board files). Cites follow the convention. check-sizes 62 rows 0 wrong, check-refs 249 references 0 missing (run on a git archive of 6b1bf92).
  both paths:               the three births each call the helper with their destination lane: Frontier and Blocked (a --depends ticket picked up Blocked's own defaults, run), Asked, Decisions. Moves are untouched, per the card. Failure is atomic: unreadable lane (chmod 000), config.labels not a list, malformed card-defaults all exit 1 before any mv. Smoke's sum check passes, and there is no stray in attachments/.
  fail-before:              OWN RUN agreed. The branch's five cases at 2dc7b75 with the unchanged scripts each fail on "lane defaults not unioned" / "wrong pick" / "accepted card-defaults". On 6b1bf92 they pass 5/5. FIXER RUN 710c1d9a is pre-rebase (NOTE 2).
  test adequacy:            placed before the release gate, named like the neighbours. A no-op helper fails cases 1-5. Appending every default without the single rule fails 1-4 (run). Case-insensitive union is not covered (NOTE 1). Deviations: (1) a bare "Round 1" is a free label per the guide ("a bare name, which is a free label"): fixer right, but the replacement lost its point (NOTE 1). (2) ticket is single: true in the founded plan board's config.labels: fixer right. (3) setdef writes the lane with emit_key: legit, since the lane layout is not under test, and my hand-written >120 line reads the same.
  blast radius:             7 files, as the body listed, plus README § Sizes (+15 words, matching check-sizes). No-defaults filings are byte-identical to the merge-base: 34 index.md files (2 questions incl. a >120 title and --depends, 1 record, 6 tickets incl. Blocked) with uuids and stamps normalized (run, evidence § 4). On a card that gets defaults, its own entries come back quoted. The values and order are unchanged, and neither heal repairs it.
  population:               mutants 2 of 2 run; edge cases 24 helper inputs plus 2 full-script boards (16 + 11 documents validated); byte comparison 34 of 34 files.
  adversarial only:         hypotheses written before reading the fixer's records: single-kind pick drift from the heal (did not hold); re-emission triggering a heal repair (did not hold); file-question compaction changing no-default bytes (did not hold); a malformed lane leaving a half card (did not hold); retired or YAML-special lane spellings (did not hold); a non-discriminating case for the case rule (held, NOTE 1). Found while attacking (b): non-str scalars (held, BLOCKING).

UNRESOLVED: none
```

- **Attached**: [review evidence](attachments/81a7f10d-3e10-47e0-b3aa-fad23d2dedf5/blob.txt): both scoped runs, the mutants, the byte comparison, the helper edge cases with validator output, and the full-script attack boards.
