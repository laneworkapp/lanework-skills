---
schema: 1
kind: card
title: "heal-board.py lags the board healer, now at heal v6"
order: 1024
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}, {text: "heal", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-25T04:51:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
waiting: {for: anyone, since: 2026-11-27T12:58:50Z, comment: bb68f5fd-4075-4f4d-b2d2-8b3792ec5690}
modified: {at: 2026-11-27T12:58:51Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Replace the skills' hand-kept healer with a verbatim copy of the board healer at heal v6, behind a thin `heal-board.py` that keeps today's command and its reserved-name guard, so the skills heal exactly as the app's healer does and can be re-copied when it moves.

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

## Scope

| File | Change |
|---|---|
| `skills/lanework/scripts/lanework-heal.py` | New. Byte for byte copy of `.schema/bin/lanework-heal.py` at v6, header `# lanework-heal v6` intact. Never edited by hand. |
| `skills/lanework/scripts/heal-board.py` | Replaced by a short wrapper (about 40 lines). It keeps the usage and exit codes (64 usage, 2 refusal removed), rejects reserved names including `anyone`, then runs the board's own `.schema/bin/lanework-heal.py` when the board has one, and the vendored `lanework-heal.py` otherwise or under `--ignore-board-copy`. It passes every other argument through. |
| `skills/lanework/SKILL.md` | The scripts table row for `heal-board.py`: say it runs the board's own healer, else the vendored v6 copy. |
| `skills/lanework/references/writes.md` | § Healing: "Which copy" and "Repairs" lines (the board's copy now runs through `heal-board.py` instead of refusing it; the rule ids appear in the dry run); exit-code line unchanged. |
| `skills/lanework/templates/label-kinds.md` | No change; the vendored copy reads its `priority` row as today and falls back to its embedded copy. |
| `tests/smoke.sh` | `sec_heal_board`: update the greps that expect the old line (`index.md: root-key `, line 563) to the `<file>: H11 root-key` form; replace "heal defers to the board's own" (line 596) with a delegation case; add the cases under Verified by. `sec_label_kinds` (line 2578): `hb.EMBEDDED_SUGGESTED` and `hb.SUGGESTED` now come from the vendored module. Add a drift note: vendored copy `cmp` to the Skills Pipeline board's `.schema/bin/lanework-heal.py`; a mismatch prints a note and `scripts/release.sh` prints a warning, neither fails (same pattern as the guide-version stamp). |
| `scripts/release.sh` | Print the same drift warning. |
| `CLAUDE.md` (repo) | "The in-board agent guide wins" bullet: add the heal version stamp (`lanework-heal v6`) and the step "re-copy `lanework-heal.py` from the board" beside the fixtures step. |

## Options

Open call, asked on the thread: which way the skills' healer keeps up. Scope, Verified by and Done when below are written for (d), the recommendation.

- **(a) Port the missing rules into `heal-board.py`.** Touches `heal-board.py` (about 700 changed lines) and `tests/smoke.sh`. High risk: 11 rules differ in behaviour, not only in text, and the app moved to v6 without notice, so the port lags again at the next move. Stays in step only by a manual re-diff. Not recommended.
- **(b) Delegate to the board's `lanework-heal.py` when present, keep the old rules as fallback.** Touches `heal-board.py`, `writes.md`, `smoke.sh`. Low risk to write, but it fixes nothing where it matters: boards with no `.schema/` are exactly where the fallback runs, so the data-losing rules stay live. Today's refusal (exit 2) already gives the same effect for boards that have the copy. Not recommended alone.
- **(c) Drop `heal-board.py`, use only the board's healer.** Touches `SKILL.md`, `writes.md`, `smoke.sh`, `heal/SKILL.md`. A board founded by `found-board.sh` and worked by agents before the app opens it has no healer, and `writes.md` tells agents to heal such boards. Not recommended.
- **(d) Recommended: vendor the board healer verbatim, and let `heal-board.py` be the wrapper in front of it.** Same engine on every board, so parity is by construction, and the catalog's own promise ("a copy of this script that ships with an agent skill") is what the app intends. It stays in step by a re-copy (one `cp`) plus the drift note, which mirrors how the guide version and `tests/fixtures/app-writes/` are kept today. The wrapper exists for three reasons: it keeps the command name every skill and test cites, it keeps the reserved-name guard the app's copy lacks (`anyone`), and it delegates to the board's own copy so the right healer runs without a second command.

## Risks

- The vendored copy is 1524 lines the skills cannot edit. A guard the skills need (reserved names) lives in the wrapper for that reason, not in the copy.
- The app's healer signs as `anyone`. That is a bug in the app's copy (`RESERVED_NAMES` lacks `anyone`); the wrapper hides it for skill runs only. The fix belongs to the app, so the owner is told at close.
- The smoke case that compares the vendored copy with the Skills Pipeline board's copy depends on that board being on the same heal version; during a guide move the two can differ for a while, so it is a note, not a failure.
- The first `--apply` with v6 rules on an old board can re-stamp more cards (H13, H14), which `writes.md` already says to do only on the owner's ask; the dry run still lists them.
- A user who runs the old line format in a script (`<file>: <code> ...`) sees the rule id inserted. Nothing in the skills parses the line except `tests/smoke.sh`, fixed in Scope.

## Verified by

- `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only heal_board,label_kinds,compact_form` passes, then the full `tests/smoke.sh` once the other run on the machine is finished.
- New smoke cases, each on a throwaway board under the scratch directory:
  - A lane and a card with `iconColor` beside an icon mapping, a null title, a bare `glyph:` beside a different `icon`: `heal-board.py --apply` and the board healer produce byte-identical files and the same records.
  - A card label with `rank: 7` and a `kind` subkey: a record quoting the card's `labels` line is posted before the file changes, and the kind subkey survives.
  - A board with `config.priorities` and a card with root `priority: Hot`: the board gains `values: [{text: "Hot", rank: 1, color: "red"}, ...]` and the card keeps rank and colour.
  - A board that ships `.schema/bin/lanework-heal.py`: `heal-board.py` runs that copy (a marker line printed by a stub copy proves it), and `--ignore-board-copy` runs the vendored one.
  - `--name anyone` exits 64 with nothing written.
  - The vendored file is `cmp` equal to the Skills Pipeline board's copy, or prints the drift note.
- `tests/check-refs.sh` and `tests/check-sizes.sh` pass (the README word counts if `SKILL.md` text changes).

## Done when

- `heal-board.py` and the board's v6 healer make the same call, including skips and records, on a throwaway board holding a lane `iconColor` beside an icon mapping, a null `title`, a board definition with a shadowed `glyph:`, and a `config.priorities` roster.
- `skills/lanework/scripts/lanework-heal.py` is byte for byte the board's `.schema/bin/lanework-heal.py` at v6, and a drift against the Skills Pipeline board prints a note in smoke and a warning in `scripts/release.sh`.
- `heal-board.py --apply --name anyone` still exits 64 with nothing written.
- On a board that ships its own healer, `heal-board.py <board>` runs it instead of refusing.
- `skills/lanework/references/writes.md` § Healing, `skills/lanework/SKILL.md` and the repo `CLAUDE.md` describe the wrapper, the vendored copy and the re-copy step, and none cites a rule the copy lacks.
- `tests/smoke.sh` passes in full, and the closing record carries the changelog sentence.
- The owner is told that the app healer's `RESERVED_NAMES` lacks `anyone`, since the fix belongs to the app.
