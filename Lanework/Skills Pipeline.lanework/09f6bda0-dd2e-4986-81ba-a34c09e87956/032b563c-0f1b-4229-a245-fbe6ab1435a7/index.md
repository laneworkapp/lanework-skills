---
schema: 1
kind: card
title: "Filing scripts: union the lane's card-defaults labels into new cards"
order: 7168
labels: [{text: plan, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T11:22:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:54:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
`plan/scripts/file-ticket.sh`, `discovery/scripts/file-question.sh` and `discovery/scripts/file-record.sh` file cards straight onto disk without unioning the destination lane's `card-defaults.labels`, as the guide requires (§ Frontmatter, `card-defaults`).

## Scope

One helper in `lanework/scripts/lib.sh`, called by the three scripts. The rule is already written once in `lanework/references/writes.md:34` (§ Placing) and stays as it is.

- **Helper**: `union_lane_defaults <lane> <board> <staged-fm>` in `lib.sh`, shaped like `compact_fm` (`lib.sh:94`): a `python3 -B` heredoc that loads `heal-board.py` by path and rewrites the staged frontmatter's `labels`. It reuses the heal's label model rather than a second one: `Doc` (parse, `get`, `set`, `text`), `definitions_of`, `flattened`, `entry_of`, `canon`, `numeric_rank`, `emit_key` (`heal-board.py:477,624,695,643,549,656,373`). Everything the guide asks for is already there, so the heal and the filers cannot disagree.
- **Semantics** (guide, `CLAUDE.md` § Frontmatter, lanes; `writes.md:34`):
  - Lane has no `card-defaults`, or no `labels` in it: no-op, the staged file is untouched.
  - A bare name in the defaults becomes `{text: <name>, kind: {type: text}}`, the free-label form the heal writes. A kinded entry of a kind the board defines is stamped with `flattened(entry, defs)` against the board's current `config.labels`. An entry whose kind the board does not define is kept as written.
  - Union is case-insensitive: a default is dropped when the card already has an entry with the same `canon(text)` and `canon(kind.type)`. The card's own entry stays as written.
  - `single` kind: when the card names its own value of that kind, the lane's default of that kind is left out. When the card has none and the lane lists several values, keep one (lowest `rank`, a ranked entry before an unranked one, else the first), the same pick as heal rule `single-kind` (`heal-board.py:975-990`).
  - Order: the card's own entries first, then the lane's that were added.
  - The staged `labels` line is rewritten with `doc.set("labels", emit_key(...))` and `compact_fm` runs after, as it does now. An unreadable lane or board `labels` aborts the helper with a message and exit 1, writing nothing.
- **Callers**: each script runs the helper on `fm.out` after `render` and before `compact_fm`, with the destination lane it will `mv` into: Frontier or Blocked (`file-ticket.sh:76-83`, after `DEST` is chosen), Asked (`file-question.sh`, `ASKED`), Decisions (`file-record.sh:50-53`). `file-question.sh` writes its frontmatter inline into `index.md` with no `compact_fm` (`file-question.sh:75-82`): stage it to `fm.out` first, as the other two do, so the union result is compacted.
- **Not touched**: `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh` (moves; the rule is "at birth, never on a move") and the `found-*` scripts (they write lanes, and the lane templates carry no `card-defaults`). Cards the founders write into a lane (topic and map cards) are out: they are written by the founder, from a template that already names the labels it wants, and lanes of a fresh board have no defaults.

## Files

- `skills/lanework/scripts/lib.sh`: the helper, with its usage comment.
- `skills/plan/scripts/file-ticket.sh`, `skills/discovery/scripts/file-question.sh`, `skills/discovery/scripts/file-record.sh`: one call each; `file-question.sh` also stages and compacts its frontmatter.
- `skills/lanework/references/writes.md`: one clause at line 34 saying the filing scripts do this for you (the rule text stays; no second copy).
- `tests/smoke.sh`: new cases below.
- No change to `plugin.json`, `README.md` or the guide stamp (v114 on the board; the skills stamp is v101 and is a separate card).

## Smoke cases

Throwaway boards only, never this one. Add `card-defaults` to a lane with `sed` after founding.

1. **discovery, file-record**: Decisions lane with `card-defaults: {labels: [needs-review, {text: Proposed, kind: {type: status, text: Status}}]}`. File an ADR (which carries `accepted` of the `single` kind `status`): the card has the ADR's `record` entry, its own `accepted`, `needs-review` as a free label, and no `Proposed` (card's own single value wins). Board validates, heal finds nothing.
2. **discovery, file-question**: Asked lane with `card-defaults: {labels: [Round 1, urgent]}` while the script writes `Round 1` of kind `round`: no duplicate (case-insensitive, same kind); `urgent` added; the ask lints clean.
3. **plan, file-ticket**: Frontier with `card-defaults: {labels: [{text: Grilling, kind: {type: ticket}}, extra]}`, filed `--type research`: `Ticket` is not `single`, so `Grilling` is stamped from the board's definition (rank and glyph from `config.labels`) alongside `Research`, plus `extra`; and a ticket filed with `--depends` an open one lands in Blocked, which has no defaults: none added.
4. **single kind with several lane values**: lane defaults list two values of a `single` kind (higher rank first in the file); the card gets the lower-rank one only, and the one the card names itself beats both.
5. **no-op and failure**: a lane without `card-defaults` produces a byte-identical card to today's (compare against the existing smoke expectations, which must keep passing unchanged); a malformed lane `card-defaults` (a scalar, not a mapping) exits non-zero and leaves the board untouched (`sum` check as at `smoke.sh:221`).

## Risks

- **Second parse path**: the helper must not drift from the heal. It does not copy it: it imports it, and smoke case 1-4 run `heal` after to prove nothing is left to repair.
- **Template vs lane clash**: `ticket-card.md` and `record.md` already stamp kinded labels (`Ticket`, `Record`, `Status`). On a `single` kind (`status` in discovery boards) the template's value wins, which is what the guide asks.
- **A kind in the defaults that the board no longer defines**: kept as written, per the guide. Not stamped, not dropped.
- **Python dependency**: already required by `compact_fm`; no new one.

## Verified

`tests/smoke.sh` passes with the new cases, `bash -n` on the changed scripts, and the new cases quote the resulting `labels` line of each filed card. Per the board's bar: each run against a scratch board, output quoted in the closing comment.

## Done when

On a scratch board whose Frontier, Asked and Decisions lanes each carry `card-defaults.labels` (a free name, a kinded entry, and a `single`-kind value), a ticket, a question and a record filed by the three scripts each carry the lane's labels unioned with their own: case-insensitive, kinded entries stamped from `config.labels`, the card's own value winning on a `single` kind. The same filings on lanes with no defaults are byte-identical to before. `tests/smoke.sh` passes, and `lanework-validate.py` plus the heal report nothing on the filed boards.

## Recommendation

Build as scoped: one shared helper that reuses `heal-board.py`, three one-line callers, one clause in `writes.md`. Small enough for 0.8.0. Deferred: a `--no-defaults` flag (nothing asks for it; the guide has no opt-out for agent filings), and teaching `found-*` about lane defaults (they have no source for them).
