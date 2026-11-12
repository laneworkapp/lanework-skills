---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:46:09Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:46:09Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**REQUEST-CHANGES: the minimum misses a future stamp in two forms (target `.`, a quoted stamp). `post-comment.sh` mints future stamps on request, posts into a ghost folder, and its "stamped by the clock" case passes a typed constant. The rule text and the split are sound.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none": timing-dependent same-second test, gate unrun, helpers copied into a scoped runner; blast radius grew in the rebase: block-form waiting)
ROUND:   1

CARD:   Active/360edc1c-b4b4-42e5-b3ff-f77038c6580f "Agents write future timestamps: the work skill never says a stamp comes from the clock"
BRANCH: clock-stamps-360edc1c at b3ac9dbb12c71fe162e44f3abee4ae335e002d53 (minimum 2c2383d)

BLOCKING: 5
  skills/work/scripts/lint-stamps.sh:23 @ 2c2383d "find "$target" \( -name '.*' -o -name attachments \) -prune": the start point is tested too, and "." matches '.*'. cd into a board holding a stamp 120 s ahead, run lint-stamps.sh . -> silent exit 0 (run). Fix: -mindepth 1 before the prune, or prune only below the root.
  skills/work/scripts/lint-stamps.sh:39 @ 2c2383d "(at|since): [0-9]{4}-": exactly one space and no quote. modified: {at: "<now+120>Z", by: ...} validates clean (failures 0, deprecated 0) and lints silent, exit 0. Same for a single-quoted value and for "at:  <stamp>". writes.md tells agents to double-quote every string value, so a literal reader writes this form. Fix: (at|since): *["']? before the date, and a smoke case with a quoted future stamp.
  skills/work/scripts/post-comment.sh:27 @ b3ac9db "case "$AHEAD" in ''|*[!0-9]*)": --ahead has no upper bound. --ahead 3600 lands a comment 1 h ahead with exit 0, and lint-stamps then reports "3600s ahead" (run). This is the card's defect recurring inside its fix (E12). Fix: refuse --ahead above a small cap (the lint slack, 60, or tighter), and add a smoke case.
  skills/work/scripts/post-comment.sh:34 @ b3ac9db "card() { ls -d "$BOARD"/*/"$CID" 2>/dev/null | head -1": resolves the card by folder, not by index.md (writes.md § Paths: ls "$BOARD"/*/<card-uuid>/index.md). An index-less <uuid> folder in an earlier-sorting lane, with the real card in a later lane -> exit 0, and the comment lands in the ghost (run). Line 47's mkdir -p "$C/comments" then builds comments/ inside it. Fix: resolve <uuid>/index.md, refuse unless exactly one match, and drop -p.
  tests/smoke.sh:667 @ b3ac9db "lands one comment stamped by the clock": nothing asserts the stamp is near the clock. A mutant with NOW = typed 2026-01-01T00:00:00Z + ahead passes all 12 scoped cases (run). Fix: take t0 and t1 around the post, then assert t0+ahead <= created.at <= t1+ahead.

NOTES: 6
  skills/work/scripts/post-comment.sh:38 @ b3ac9db "if grep -qs -F "created:  {at: $NOW,"": the refusal is check-then-act. Two posts started together landed 2 of 2 in the same second, in 5 of 5 trials (run). It also misses a comment stamped with one space (created: {at: X, ...}) or with no by (X}) (run). The header promises nothing more, but it is no guarantee. A mkdir lock outside the board would make it one.
  tests/smoke.sh:660 @ b3ac9db "sleep(1.02 - ($t - int $t))": the same-second case holds while post 1 takes under about 0.98 s. Measured 0.07-0.10 s here, so it fails falsely only on a heavily loaded runner. It does fail when the refusal is disabled (mutant run). Seeding a comment at the computed second would make it deterministic.
  skills/work/scripts/lint-stamps.sh:34 @ 2c2383d "NR == 1 && $0 != "---" { exit }": a CRLF file is skipped whole, so a stamp 120 s ahead is missed while the validator passes it (run). Fractional seconds (.500Z) are skipped, as is a bare stamp (the validator flags that one DEPRECATED). These match the card's "Z only" limit, but the CRLF case is a silent miss.
  skills/work/scripts/lint-stamps.sh:15 @ 2c2383d "slack=${2:-}; shift 2 || true": --slack with no value loops forever (killed by a 5 s alarm, rc 142). No arguments exits 1, not 2. "no such path" goes to stdout. The header says "exit 2 on ... a bad flag".
  skills/lanework/references/writes.md:8 @ 2c2383d "- **Every stamp comes from the clock**": a new bullet beside "Stamp it". The card and the repo CLAUDE.md ("extend an existing entry first") both ask for the existing bullet to be extended.
  attachments/ and .trash/ stamps are not linted (by the card's design). A by.session string holding "at: <future>" reads as a future stamp (false failure, run). Rare.

CHECKED:
  correctness vs done-when: a stamp 2 min ahead fails and 1 s ahead passes; the boundary holds (+60 pass, +62 fail); comment, lane, board index, block-form created, modified with no by, list- and block-form waiting all caught. TZ=America/Los_Angeles and TZ=Asia/Tokyo: scoped 12 of 12 ok, +120 fails, +1 passes. Misses: target ".", quoted or double-spaced at, CRLF.
  project conduct:          rule stated once (writes.md:8). farmed-prompt.md:9 is the card-specified clause. writing.md and ask.md carry pointers only. No "assume Y". The extend-not-append bar is missed (NOTE).
  both paths:               flow and block waiting both handled. The second resolution path (ghost or duplicate folder) is unhandled in post-comment (BLOCKING 4).
  fail-before:              OWN RUN agreed with FIXER RUN 9c181698: at 8849c03 the cases fail with "lint-stamps.sh: No such file or directory", rc 127, the only failure possible for a new script.
  test adequacy:            cases sit after the lint-ask block, named like their neighbours. Mutants: lint-stamps printing nothing -> caught. Same-second refusal disabled -> caught. post-comment from a typed constant -> NOT caught (BLOCKING 5).
  blast radius:             9 files, as the card's table lists. The rebase added block-form waiting plus one case, explained in 50d429a8. No unexplained churn.
  population:               scoped 12 of 12 cases (7 lint-stamps, 3 post-comment, 2 founding) with branch scripts. 2c2383d alone: 9 of 9. check-sizes 62 rows 0 wrong and check-refs 250 references 0 missing, at both shas. Copy of this board: 568 index.md read, 0 violations, with a positive control (planted +120 on a comment -> reported). grep -rnE 'at: 20[0-9]{2}-' skills: 0 hits.
  adversarial only:         12 hypotheses written before the reports. Held: "." prune, quoted stamp, CRLF, --slack hang, unbounded --ahead, ghost resolution, check-then-act race, typed-constant smoke. Fell: awk intervals, TZ handling, the split.

UNRESOLVED: none. Split: 2c2383d stands alone (no post-comment reference, its README counts and smoke pass without b3ac9db). Ship 2c2383d once BLOCKING 1-2 land. Ship b3ac9db only with 3-5 fixed, else drop it to a later card.
```

**Attached**: [review-evidence.txt](attachments/2e74d50a-2810-4b00-bd48-0f5eb68b71aa/blob.txt). It holds the scoped runs before and after, both timezones, 2c2383d alone, the mutants, and every probe above.
