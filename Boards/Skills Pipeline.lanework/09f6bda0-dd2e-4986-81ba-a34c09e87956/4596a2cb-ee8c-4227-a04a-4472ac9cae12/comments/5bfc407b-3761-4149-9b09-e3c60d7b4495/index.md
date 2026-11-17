---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:06:34Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:06:34Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: `next_cite` reads a zero-padded number as octal, so it reissues a citation or aborts the filing; everything else meets done-when, with 7 notes.

- **Stance**: adversarial (trigger: the branch changes what three filing scripts write on every discovery and plan board, gated on a version read from the board)
- **Round**: 1
- **Card**: [4596a2cb](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12)
- **Branch**: `cite-as` at `2538f29`

**Blocking**

1. `skills/lanework/scripts/lib.sh:114 @ 2538f29` "`printf '%s%s' "$2" $((max + 1))`": the trailing number is compared with `[ -gt ]` (decimal) but incremented in `$((…))` (octal for a leading 0). Measured on a throwaway board: `cite-as: ADR9` plus `cite-as: ADR010` → `next_cite` prints `ADR9`, a reissue of an existing citation (done-when: "A citation is never reissued"). `cite-as: Q08`, or a legacy title `Q09: …` → `08: value too great for base`, rc 1, so `file-question.sh` aborts on that board. Zero-padded citations (`FR001` style) are a plausible hand convention on the boards this card reads. The same shape is in the legacy `MAXQ` / `MAXT` paths on main (pre-existing, unchanged code). Fix: base 10 on both the comparison operand and the increment (`n=$((10#${BASH_REMATCH[1]}))`), plus a smoke line pinning `ADR010` → `ADR11`.

**Questions for the lead**

1. Hand-written cards on unstamped boards: `discovery/templates/topic-card.md` (`cite-as: Topic`, bare title) and `fact-card.md` (`cite-as: F<n>`, bare title) carry no gate, and a discovery board is always unstamped when its topic card is written (`found-board.sh` writes no `CLAUDE.md`). `lanework/references/writes.md` § cite-as says "else keep the `<prefix><n>: ` title", which these templates never had (`Topic: `, `Fact: `). The body's Change table asked for exactly these templates, so this is spec-level: keep as is (the gate covers scripts only), or have the templates name both shapes?

**Notes**

1. `skills/discovery/templates/lanes.md:11 @ 2538f29` and `skills/plan/templates/lanes.md:12` "titled `ADR:` or `PDR:`": on a gated board the Decisions lane body contradicts the bare titles `file-record.sh` now writes. Not blocking: no script reads it, and an agent filing a record follows `records.md`, which is right. Follow-up card, together with `heal/scripts/heal-descriptors.py:155-156`, which mirrors the text.
2. `skills/discovery/templates/map-card.md:5 @ 2538f29` "`cite-as: Map`" under the title "Discovery map": the face reads "Map Discovery map". The body asked for it, and it is cosmetic, so no follow-up unless the owner dislikes the face.
3. `skills/lanework/scripts/read-board.sh:12 @ 2538f29` "`printf '%s: %s' "$c"`": a hand-migrated card carrying both `cite-as: T9` and the title `T9: legacy` prints `T9: T9: legacy` (measured; `frontier.sh` likewise). Harmless; e39d824 stripped the prefixes, so the worked example never hits it.
4. `skills/lanework/scripts/lib.sh:107 @ 2538f29` "`re_c="^$2([0-9]+)\$"`": case-sensitive, while the validator's `duplicate-cite-as` case-folds (positive control: `q1` beside `Q1` warns twice on the live board's validator). A hand-typed `q7` lets a script mint `Q7`. Also a YAML trailing comment (`cite-as: Q15 # x`) is not counted. Both are rare.
5. Mutation survivors: un-anchoring `re_c` (dropping `^`) and reverting `frontier.sh`'s warning names to titles both leave all five cite cases green. Prefix anchoring itself measured correct (`T5` vs `Topic`, `F` vs `FR12`, `ADR` vs `PDR4`, `Q1` vs `Q10`); a smoke line with a `Topic` and an `FR12` card would pin it.
6. Validator: the branch's committed `Boards/Skills Pipeline.lanework/.schema/bin/lanework-validate.py` has no `duplicate-cite-as` (0 matches); the live copy, app-updated and uncommitted on main, has it. Smoke's `validate()` ignores warnings anyway, so even after that copy is committed it would not catch a duplicate. The `uniq -d` check over the five minted citations is enough for what this card tests; a warning-aware `validate` would belong to a separate card.
7. `skills/discovery/scripts/file-question.sh:76 @ 2538f29` "nothing narrower than this closes a race": `lint-ask.sh` still runs between the scan and the `mv` (line 98); moving the scan after the lint narrows the window slightly. Separately, `card_ref` escapes `[`, `]` and backslash but not a backtick, so a title holding a code span with `]` inside renders the escaping backslash (reasoned; the escaping is main's, moved verbatim).

**Checked**

- **Correctness vs done-when**: v118 fixture (board paths with spaces), branch scripts, full uuids. `file-question.sh` writes `cite-as: Q1` and `Q2` with bare titles (a title with colon, quotes and backslashes round-trips as valid YAML), and prints `cite Q<n>`. `file-record.sh` writes `ADR1`, then `PDR1` with `--supersedes` (one `supersedes` relation), and line 1 `Question: [Q1](lanework://…)`. `file-ticket.sh` writes `T1`, `T2` and `- [T1](lanework://…)`. `frontier.sh` prints `waits on T1 (Frontier)`; `resolve-ticket.sh` prints `unblocked T2`. Both boards validate with the live validator: `failures 0`, `warnings 0`. Every header documents what its script prints. Founding and ask comments carry no card links. `cite-as` sits after `title`; the guide sets no top-level key order.
- **Project conduct**: `plugin.json` untouched. CHANGELOG has one user-facing sentence under the unreleased 0.9.0 line (latest tag `v0.8.0`), no new Version line. README § Sizes passes (`check-sizes: 57 rows, 0 wrong`). The mint rule is only in `lanework/references/writes.md` and the link-text rule only in `work/references/writing.md` § Card references; every other site links (grep for `highest`, `.trash`, `link text`, `cite-as` over the Markdown under `skills/`). The guide number appears only in `lib.sh` (`ask_handle` and `cite_enabled`, two literals), and smoke's version guard passes. No "assume Y" shapes. The `dispatch` row is void as ruled.
- **Both paths**: ungated boards are byte-identical to main. With deterministic `uuidgen` and `date` shims, the same question, record, `--supersedes`, ticket, claim, resolve, `frontier.sh` and `read-board.sh` run on main's and the branch's `skills/` gives an identical `diff -r` of both boards plus stdout, with no stamp and with v114. Positive control: at v118 the same run differs in 6 cards plus stdout. One intended stdout change on any board: `resolve-ticket.sh` prints a colon title with no `T<n>: ` prefix whole (`unblocked Wire: both`; main printed `unblocked Wire`), as the Change table says.
  - Gate measured with `cite_enabled`: on for v117, v118, v1170, v0118 and AGENTS.md only; off for v116, v11, no file, and a stamp on line 2.
- **Fail-before**: OWN RUN agrees with the fixer's. Each new case was split out and run alone against the merge-base `4d3b9f9` scripts: cases 1, 2, 4 and 5 fail on their own messages, and case 3 (v114, v116, unstamped) passes, as designed.
  - The guard is adequate: mutating the gate to always-on, or to `-ge 116`, fails it.
  - Mutations that each fail a case: gate always-off, `-ge 118`, no `.trash` scan, no trashed-lane scan, no legacy title count, no `cite-as` count, `card_ref` title-only, `card_ref` unescaped, `resolve-ticket.sh` reverted, `read-board.sh` reverted, one shared counter for ADR and PDR, no `cite Q<n>` print. Survivors: note 5.
- **Test adequacy**: five cases sit beside the other `ok` blocks at the end of `tests/smoke.sh`, on throwaway boards under `$T`, with the stamp written by `mkguide`. Full `tests/smoke.sh` in the fixer's worktree at `2538f29` (tree clean): `smoke: 173 passed`.
- **Blast radius**: 27 files, all in the Change table except `discovery/templates/ruling.md` (link shapes, in scope). No churn outside it.
- **Population**: 173 = 168 on main plus 5 new `ok` calls in the diff. The `next_cite` probe covered 19 inputs: an empty board; `Topic`, `T5`, `FR12`, `PDR4`, `Q10`, `Q1`; a double-quoted `Q12` and a single-quoted `Q13`; `q20`; a title with `Q30: ` mid-text plus `cite-as: Q40` in the body; `cite-as: Q50` in a comment's front matter; `Q14a`; `Q14` with a trailing space; `Q15 # c`; padded `Q07`, `Q08`, a `Q09: ` title, `ADR010`. All correct except the padded ones (blocking 1) and those in note 4.

**Hypotheses**, written after reading the whole thread, which included the fixer's START, FAIL-BEFORE and built records on [4596a2cb](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12), but before reading the diff. 4 of 10 held.

1. A zero-padded number breaks `$((…))`: held (blocking 1).
2. `cite-as` in a body or comment counts, or the trash glob misses the layout: refuted (`fm_value` stops at the closing `---`; the guide's `.trash/` is flat, with trashed lanes one level down).
3. Prefix confusion: refuted (anchored).
4. A quoted `cite-as` is misread: refuted.
5. `card_ref` leaves a backtick unescaped: held, pre-existing (note 7).
6. The gate misreads thresholds, line 1 or `AGENTS.md`: refuted.
7. Ungated output drifts from main: refuted for scripts; the hand templates are unconditional (question 1).
8. `resolve-ticket.sh` changes output on ungated boards: held, as specified.
9. A card with both a citation and a legacy prefix prints twice: held (note 3).
10. The v114 guard passes even with a broken gate: refuted by mutation.
