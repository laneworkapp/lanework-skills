---
schema: 1
kind: card
title: "Citation leftovers: an unchecked stamp, a reissue on older boards, stale ADR: lane text"
order: 8192
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: plan, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T14:21:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T17:55:04Z}
---
Four small edges of the citation work can still put a wrong citation or a muddled face on a board: an unchecked stamp, a reissued number on older boards, a stale lane description, and a doubled prefix. The fix is one numbered list of small changes, each separable; items 1 and 2 are the ones that matter.

## Today

Checked against main (read and measured on throwaway boards only). Rows 1 to 9 of the old table all still hold, except where noted.

1. `lanework/scripts/lib.sh:119`, `stamp_cite`, does not check that the stamp took. If the substitution fails, `cite-as: CITEPENDING` lands and the script prints the citation, exit 0. Read; the old body measured it by mutation. No real input reaches it.
2. `discovery/scripts/file-question.sh:79` and `plan/scripts/file-ticket.sh:83` compute `$((MAXQ + 1))` and `$((MAXT + 1))` on the older-board path. A padded number is read as octal. Measured: `$(( 08 ))` aborts with "value too great for base"; the scan's `[ 010 -gt 9 ]` is decimal, so `Q010` wins the scan and `$((010 + 1))` is 9: a second `Q9` is filed. The comparison is fine; only the `+ 1` is wrong. The gated path already uses `10#` in `next_cite`.
3. `discovery/templates/lanes.md:11`, `plan/templates/lanes.md:12` and `heal/scripts/heal-descriptors.py:156-157` say Decisions cards are "titled `ADR:` or `PDR:`". On a gated board `discovery/scripts/file-record.sh` writes a bare title with `cite-as` (smoke asserts it). Read.
4. `discovery/templates/topic-card.md` and `fact-card.md` carry `cite-as: Topic` and `cite-as: F<n>`. Filled by hand, so no version gate applies. Documented in `lanework/references/writes.md:42` ("a fact by hand"). Read; the gap is the design.
5. `discovery/templates/map-card.md`: `cite-as: Map` above the title "Discovery map" reads "Map Discovery map". `Map` is a fixed citation in `lanework/references/writes.md:42`, so the citation stays; the title is the problem. Read.
6. `lanework/scripts/read-board.sh:12` and `plan/scripts/frontier.sh:29` print `cite: title`. A card with `cite-as: T9` and the title `T9: legacy` prints `T9: T9: legacy`. Measured by the reviewer; read now. Only a hand-migrated card gets both.
7. `next_cite` (`lib.sh:111`) matches case-sensitively and `cite_of` keeps a trailing YAML comment, so `cite-as: q7` is not counted and `cite-as: Q15 # x` is not counted. Measured: on a board holding both, `next_cite <board> Q` prints `Q1`. The validator's duplicate check is case-insensitive, so a hand-typed `q7` lets a script mint `Q7`.
8. `card_ref` (`lib.sh:104`) does not escape backticks in link text. Reasoned; main's escaping, moved unchanged.
9. `tests/smoke.sh:1987` covers the legacy `Q7:` title, but every title it uses starts at the anchor, so deleting `^` from `re_t` (`lib.sh:107`) leaves it green. Read.

## Change

Which items could be dropped: 4, 6 and 8 are dropped below; 3, 5 and 9 are cheap wording and test fixes that can ship alone; 1, 2 and 7 change script behavior.

1. `lanework/scripts/lib.sh`: in `stamp_cite`, die when `c` is empty, and after the substitution die if `CITEPENDING` is still in the staged file. One smoke case runs it on a file without the placeholder and on an empty prefix result.
2. `discovery/scripts/file-question.sh` and `plan/scripts/file-ticket.sh`: write `$((10#$MAXQ + 1))` and `$((10#$MAXT + 1))`. `tests/smoke.sh`: one case on an older-stamp board holding `Q9: nine` and `Q010: padded` expects `Q11`, and one with `Q08:` expects `Q9`, same for tickets.
3. Reword to "titled by its citation (`ADR1`, `PDR2`) on a board that draws citations, else `ADR:` or `PDR:`" in `discovery/templates/lanes.md`, `plan/templates/lanes.md` and both strings in `heal/scripts/heal-descriptors.py`, together, so heal does not flag the new text. Check what smoke's descriptor cases pin.
4. Dropped: the gap is documented in `lanework/references/writes.md`. Nothing changes.
5. `discovery/templates/map-card.md`: retitle to "Every decision, by corner" so the face reads "Map Every decision, by corner"; keep `cite-as: Map`. Grep `skills/` for text that names the "Discovery map" card by title and update it with the template (`discovery/templates/lanes.md:7` does).
6. Dropped: a hand-migrated card is the user's to fix, and the validator does not flag it. Revisit only if a real board shows it.
7. `lanework/scripts/lib.sh`: in `next_cite`, match the prefix case-insensitively and strip a trailing `# comment` from the `cite-as` value before matching. Smoke: `q7` and `Q15 # x` cards make `next_cite` print `Q16`.
8. Dropped: reasoned only, and unchanged from before the citation work.
9. `tests/smoke.sh`: add a card titled `See Q40: not a prefix` (no `cite-as`) to the legacy-scan case and expect it not to count.

## Not in scope

Item 4's templates, item 6's double prefix, item 8's backtick escaping, and any validator change to flag a double citation. Releasing.

## Risks

Item 2 changes output only on an older board that reissues or aborts today. Item 3 touches the heal's own descriptor text: a board already healed to the old wording will be flagged once and rewritten. Item 5 renames a template title that boards may already have under the old name; the heal does not touch titles. Item 7's case-insensitive match could now count a stray lowercase `q7` that a person meant as prose in `cite-as`; that field is a citation by definition.

## Done when

- `tests/smoke.sh` passes with the new cases: stamp_cite failure (1), padded numbers on the older path for questions and tickets (2), `q7` and `Q15 # x` counted (7), and an unanchored title not counted (9).
- `grep -rn 'titled `ADR:`' skills` prints nothing.
- Deleting `^` from `re_t` in a scratch copy of `lib.sh` makes smoke fail.
- Founding a discovery board from `discovery/templates/map-card.md` and running `read-board.sh` shows `Map: Every decision, by corner`.

Bump: patch.
