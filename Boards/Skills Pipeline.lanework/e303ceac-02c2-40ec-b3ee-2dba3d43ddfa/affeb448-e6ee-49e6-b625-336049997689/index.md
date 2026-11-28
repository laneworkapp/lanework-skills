---
schema: 1
kind: card
title: "heal-board.py lags the board healer, now at heal v6"
order: 115712
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "heal", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-25T04:51:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T06:04:04Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The skills' own healer, `skills/lanework/scripts/heal-board.py`, is brought up to the board healer's heal v6 by hand, so it stops losing values the board healer keeps, and it no longer steps aside for a board copy older than itself.

## What lags

`skills/lanework/scripts/heal-board.py` (1260 lines) and `Boards/Skills Pipeline.lanework/.schema/bin/lanework-heal.py` (1524 lines, header `# lanework-heal v6`, rules in `.schema/HEAL.md`, header `lanework-heal-catalog v6`) share one ancestry. A plain `diff` of the two files has 110 hunks and 678 changed lines. The skills' copy has no rule ids and implements 15 of the catalog's 17 rules, some only in part.

Why it matters today: `heal-board.py` already exits 2 on a board that carries its own `.schema/bin/lanework-heal.py` (`skills/lanework/references/writes.md` § Healing). So the lagging copy runs on boards the app has not opened yet (every board `found-board.sh` or `file-ticket.sh` makes starts without `.schema/`) and wherever someone passes `--ignore-board-copy`. Those are the boards `writes.md` sends an agent to heal "when a board is worked without the app".

Rule by rule, what v6 does that `heal-board.py` does not (each read from both scripts and `.schema/HEAL.md`):

| Rule | v6 board healer | `heal-board.py` | Loses data? |
|---|---|---|---|
| H03 bare-icon | An `iconColor` the icon mapping already overrides, or one with no colour reading, is quoted in a record on a card, and left as written (skip) on a board or lane. | Removes `iconColor` with no record and no skip, on cards, lanes and the board. | Yes, silently. |
| H05 definition | A bare `glyph:` beside an `icon` naming another glyph is left as written and reported as a skip, since a board has no thread (`definition_drops`, `shadowed_glyph`). | Folds it and drops the glyph without a word. | Yes, silently. |
| H01 title-quote | Rewrites only a title YAML cannot read as one line; skips a title that reads as null (`~`, `null`, leading `#`); leaves single-quoted and readable plain titles byte for byte. | Rewrites every plain or single-quoted title to double quotes, and turns `title: ~` into the text `"~"`. | Yes: a null title becomes the literal text `~`. The rest is needless churn. |
| H07 to H11, H13 | Before a rewrite replaces anything the card wrote (the entry's own `rank`, `color`, `icon`, text, or its kind's), it posts a record quoting the card's `labels` lines (`lost_stamps`, `restamp_fact`). | Posts a record only for single-kind, root-key-dropped and retired-key. A re-stamp that drops a `rank` writes no record. | Yes, silently. |
| Unknown rides through | Unknown subkeys survive on the entry, on its `kind` and on its `icon` (`flattened`, `restamped`). | `flattened` rebuilds `kind` from the definition's four keys and keeps unknown subkeys on the entry only. A `kind` subkey is lost. | Yes, silently. |
| H11 root-key | A root `priority:` mapping keeps its `text`, `rank`, `color`, `icon`; the rest is quoted in a record. | Keeps the same four and drops other subkeys with no record. | Yes, silently. |
| H15 config-priorities | Converts the retired `config.priorities` roster into the `priority` definition (or skips a roster it cannot carry whole) and reads the roster as the definition while the cards heal. | Does not know the key. It leaves the roster and treats the board as having no `priority` definition. | Yes: see the reproduction below. |
| H16 config-collapse-empty | Removes an empty `config.collapse-empty`; skips one with a value. | Not implemented. | No (a missed repair). |
| H06 added-definition | Skips adding when `config.labels` already defines the kind, and defines "priority" from the roster first. | Adds the suggested definition whenever the cards use `priority` and the parsed definitions lack it. | See H15. |
| definitions read | A value with an unreadable `rank` drops out of the definition, so its entries stay foreign and are never re-stamped. | Keeps that value, giving it a position rank, so its entries are re-stamped. | Possibly. |
| Idempotent record | `post_record` skips a record already posted by an interrupted run. | Posts it again on the rerun. | No (duplicate comment). |
| Output | `<file>: H05 definition ...` with the rule id (the format `HEAL.md` specifies). | `<file>: definition ...` with no id. | No. |

What `heal-board.py` does that v6 does not: it refuses `--name anyone` (exit 64). The v6 healer's `RESERVED_NAMES` is `{board, healer, shortcuts, tracker}`, so it signs records and `created` stamps as `anyone`, a name `lanework/references/writes.md` says is reserved for the human mention. Everything else (H02, H04, H12, H14, H17) agrees on the cases tested here; `tests/smoke.sh` already compares H17 byte for byte.

Reproduced on throwaway boards under `mktemp -d` (`a scratch directory`), the same board healed once by each script, each started from an identical copy with no `.schema/`.

Board with a lane, and a card, that each carry `icon: {glyph: star, color: blue}` plus `iconColor: red`; a card with `labels: [{text: "bug", rank: 7, color: "#112233", kind: {type: "text", note: "k"}, icon: {glyph: bug, tint: x}}]`; a card with `title: ~`; a board definition `{kind: status, ..., glyph: circle, icon: {glyph: tag}, ...}`:

```
$ python3 skills/lanework/scripts/heal-board.py $T/skill.lanework
index.md: definition config.labels `status` into the current spelling
aaaa0000-.../index.md: bare-icon icon written as the mapping {glyph: "star", color: "blue"}
aaaa0000-.../c0000000-...-000000000001/index.md: bare-icon icon written as the mapping {glyph: "star", color: "blue"}
aaaa0000-.../c0000000-...-000000000002/index.md: stale-label "bug" re-stamped from the text definition
aaaa0000-.../c0000000-...-000000000003/index.md: title-quote unquoted: "~"
5 repairs in 5 files (dry run: --apply to write)

$ python3 "Boards/Skills Pipeline.lanework/.schema/bin/lanework-heal.py" $T/board.lanework
index.md: H17 compact-collection config written in the compact form, 3 lines to 8
aaaa0000-.../c0000000-...-000000000001/index.md: H03 bare-icon icon written as the mapping {glyph: "star", color: "blue"}
aaaa0000-.../c0000000-...-000000000002/index.md: H13 stale-label "bug" re-stamped from the text definition
skip index.md: config.labels `status` has a bare glyph its icon would replace, and a board has no thread to hold a record: left as written
skip aaaa0000-.../index.md: iconColor would be dropped, and no card holds a record: left as written
skip aaaa0000-.../c0000000-...-000000000003/index.md: title reads as null: write its text by hand
3 repairs in 3 files (dry run: --apply to write)
```

After `--apply --name fixer --model test` on each, the skills' copy wrote no comment at all (`find ... comments | wc -l` gave 0) and left the lane as `icon: {glyph: "star", color: "blue"}` with `iconColor` gone, the board definition without its `glyph`, the title as `title: "~"`, and the label as:

```
    kind: {type: "text", text: "Text", icon: {glyph: "tag"}}
```

The board healer left the lane's `iconColor: red`, the null title and the board's glyph as written, posted two records on the two cards (one quoting `iconColor: red`, one quoting the card's whole `labels` line, including `rank: 7`), and kept the kind's subkey:

```
    kind: {type: "text", text: "Text", icon: {glyph: "tag"}, note: "k"}
```

So the card's stated check holds: on a board or lane value that v6 skips, the two healers make different calls, and the skills' copy is the one that loses data.

Roster case (a board with `config: {priorities: [{name: Hot, value: 1, color: red}, Cold]}` and a card with root `priority: Hot`):

```
-- skill
index.md: added-definition config.labels gains `priority`, which the board's cards use
...c0000000-...-000000000001/index.md: root-key priority: "Hot" moved into labels
-- board
index.md: H15 config-priorities config.priorities converted into the `priority` definition
...c0000000-...-000000000001/index.md: H11 root-key priority: "Hot" moved into labels
```

After `--apply`, the skills' copy left `priorities:` in place, appended the suggested Urgent/High/Medium/Low definition, and wrote the card as `labels: [{text: "Hot", kind: {type: "priority", ...}}]`, with the board's own rank 1 and colour red gone. The board healer wrote `values: [{text: "Hot", rank: 1, color: "red"}, {text: "Cold", rank: 2}]` and `labels: [{text: "Hot", rank: 1, color: "red", kind: {type: "priority", ...}}]`.

The reserved-name case: `heal-board.py ... --apply --name anyone` exits 64 with `anyone is reserved for the app; sign as yourself`; the board healer exits 0 and writes `created: {at: ..., by: {name: anyone, kind: agent, model: t}}` on both records.

## Ruled: the skills keep their own healer

Ruled by the owner on 2026-11-27: the skill has its own full-featured healer, brought up to heal v6 by hand. A board in deep trouble that the app cannot open, or a stale board its user does not open, carries a stale healer too, so the skills cannot depend on the board's copy.

- Not taken: shipping a verbatim copy of the app's healer behind a wrapper, and dropping the skills' healer.
- The drift is accepted as real and expected to shrink as the schema settles during the beta.

## Scope

| File | Change |
|---|---|
| `skills/lanework/scripts/heal-board.py` | Bring every rule in the table above to the v6 behaviour: H01, H03, H05, H06, H07 to H11, H13, H15, H16, unknown subkeys riding through on `kind` and `icon`, a record before any rewrite that drops what the card wrote, an unreadable `rank` dropping out of the definition, no second record on a rerun. Print the rule id in each line (`<file>: H05 definition ...`). Carry a heal version constant, `6`. Keep refusing `--name anyone`. |
| `skills/lanework/scripts/heal-board.py`, which copy runs | Read the version from the header of the board's `.schema/bin/lanework-heal.py`. Board's copy at the same or a later version: refuse as today and name it. Board's copy earlier, or its version unreadable: run the skills' own and say so in one line. `--ignore-board-copy` stays. |
| `skills/lanework/references/writes.md` | § Healing: "Which copy" becomes the later heal version wins; "Repairs" names the rules added. |
| `skills/lanework/SKILL.md` | The `heal-board.py` row, if its wording needs it. |
| `tests/smoke.sh` | `sec_heal_board`: the greps that read the old line form move to the form with the rule id; the cases under Verified by; a drift note when the Skills Pipeline board's healer header reads a later version than the skills' constant. A note, never a failure. |
| `scripts/release.sh` | The same drift, printed as a warning. |
| repo `CLAUDE.md` | "The in-board agent guide wins": add the heal version the skills target, and "read `heal-board.py` against the board's `HEAL.md`" to the steps for a guide move. |

## Decided here, not asked

- **The later heal version wins**, in place of "the board's copy always wins". It follows from the ruling: a stale board copy must not block the skills' healer. A board whose copy is current still heals with its own.
- **Parity is checked by running both**: the smoke cases heal one throwaway board with each script and compare the files and the records. The board's healer is read from the Skills Pipeline board's `.schema/bin/`, never copied into `skills/`.
- **`anyone` stays refused** by the skills' healer. The app's healer accepts it; that fix belongs to the app, and the owner is told at close.
- **No vendored file**: nothing from the app is added under `skills/`.

## Risks

- About 700 lines change in one script, across 11 rules that differ in behaviour. The side-by-side smoke cases are the guard, one per rule.
- It lags again when the app's healer moves. The drift note and the release warning say so on the day it happens; the port is then a new card.
- "The later version wins" runs the skills' healer on a board that ships an older one. An older board healer that knew a rule the skills' healer dropped would lose it; none exists today, since v6 is a superset in the rules compared here.
- The first `--apply` with the v6 rules on an old board can re-stamp more cards (H13, H14). `writes.md` already says to do that only on the owner's ask, and the dry run lists them.
- The line format gains the rule id. Nothing in the skills parses the line except `tests/smoke.sh`, changed in Scope.

## Verified by

- `bash -n` and `python3 -m py_compile` on the changed scripts.
- New smoke cases, each on a throwaway board healed once by `heal-board.py --ignore-board-copy` and once by the Skills Pipeline board's v6 healer, compared file by file and record by record:
  - a lane and a card with `iconColor` beside an icon mapping, a null title, a bare `glyph:` beside a different `icon`;
  - a card label with `rank: 7` and a `kind` subkey: the record quotes the card's `labels` line before the file changes, and the subkey survives;
  - a board with `config.priorities` and a card with root `priority: Hot`: the board gains the roster as its `priority` definition and the card keeps rank and colour;
  - an empty `config.collapse-empty`;
  - a rerun after an interrupted apply posts no second record.
- Which copy: a board with a stub healer at `v5` runs the skills' own; at `v6` and at `v7` it is refused and named.
- `--name anyone` exits 64 with nothing written.
- The full `tests/smoke.sh`, with `check-refs.sh` and `check-sizes.sh`.

## Done when

- `heal-board.py` and the board's v6 healer make the same call, skips and records included, on the throwaway boards above.
- A board that ships an earlier healer is healed by the skills' own, and one that ships the same or a later version is left to its own.
- `heal-board.py --apply --name anyone` still exits 64 with nothing written.
- Smoke prints a note, and `scripts/release.sh` a warning, when the Skills Pipeline board's healer is at a later version than the skills target.
- `writes.md` § Healing and the repo `CLAUDE.md` say which copy runs and name the heal version.
- `tests/smoke.sh` passes in full, and the closing record carries the changelog sentence.
- The owner is told that the app healer's `RESERVED_NAMES` lacks `anyone`.
