---
schema: 1
kind: card
title: "Skills target agent guide v117: asks address @anyone, cite-as, the reserved name anyone"
order: 2048
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: heal, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:57:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-12T18:57:17Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
The skills target agent guide v114, and the app has moved this board to v117, so this card brings the skills' asks, reserved names and stamp up to it: asks go to `@anyone` with `for: anyone` by default, and `anyone` becomes a name nobody signs.

## What moved (v114 to v117, read off the working-tree diff)

- **`@anyone` / `for: anyone`** are the default for an ask. A person's handle only for a question that belongs to one person, a gate the board's instruction sheet names. Only on a board whose guide line reads v117 or later; below that, `for: human` and the machine's handle. Agents ignore `@anyone`.
- **`anyone` is a reserved name**, beside `shortcuts`, `healer` and `board`: never signed on a stamp or comment.
- **`waiting.for`**: `anyone` reads as any human, alone or in a list.
- **`cite-as`**: a card's display name, unique by convention, never carried into a copy. Validator v5 warns `duplicate-cite-as`.
- **Locked lanes**: copy and paste keep `locked`. No skill touches this.

## Confirmed drift, by file

| file under `skills/` | drift | change |
|---|---|---|
| `lanework/scripts/lib.sh` | `owner_handle` is the only handle source; no guide-version reader | add `guide_version <board>` (the `lanework-agent-guide vN` stamp on line 1) and `ask_handle <board>`: `anyone` when the version is 117 or later, else `owner_handle` |
| `work/scripts/lint-ask.sh` | takes the board's own handle as "the human"; a body that mentions only `@anyone` passes as a record, unchecked | on a v117+ board treat `@anyone` as the human's handle; the first-line, 80-word, one-question, Recap and link checks all apply to it. Below v117 behaves as today |
| `work/references/writing.md` § The ask, `work/templates/ask.md` | "handle from the guide's Mentions section", "there is no reserved handle" | address `@anyone` by default, `for: anyone`; a person's handle only for a question that is theirs, per the board's sheet; v114-and-older boards keep the handle |
| `discovery/scripts/file-question.sh`, `discovery/templates/question-card.md` | `HANDLE=owner_handle \|\| human`, written into the ask and `waiting.for` | use `ask_handle` |
| `discovery/templates/board.md`, `plan/templates/board.md`, `discovery/references/conduct.md` | "with the handle on its first line" | say "`@anyone` (or the named person's handle)" in owner-facing wording |
| `lanework/references/writes.md` "Stamp it", `lanework/scripts/heal-board.py`, `heal/scripts/heal-descriptors.py` | `RESERVED_NAMES` / prose lists `board healer shortcuts tracker` | add `anyone` to all three |
| `work/references/sweep.md` § Unanswered question | `waiting.for` "names the human" | `anyone`, `human`, `operator`, an absent `for` and the handle all mean the human |
| repo `CLAUDE.md` | stamp `v114` (no skill file carries a guide version; smoke fails if one does) | bump to `v117`, and the fixtures step in the same entry |

## Checked, no change

- **`cite-as`**: no script mints or copies a card with one (`file-ticket.sh`, `file-question.sh` and `file-record.sh` build cards from templates). State the rule in `lanework/references/writes.md` in one line: never carry a `cite-as`, scan before minting.
- **`dispatch/scripts/arm-pass.sh`, `classify-event.sh`**: classify owner by `by` stamp, not `waiting.for`.
- **`plan/scripts/frontier.sh`, `resolve-ticket.sh`, `settle-question.sh`**: read `waiting` as present or absent, never its `for`.
- **`merge` skill**: `waiting` is later-`modified`-wins whatever its `for`.

## Verified by

- `tests/smoke.sh` green, new cases: `guide_version` and `ask_handle` on a v117 and a v114 throwaway board; `lint-ask.sh` fails a bad `@anyone` ask (late handle, over 80 words, no Recap) and passes a good one on a v117 board, and a v114 board's `@handle` ask is unchanged; `file-question.sh` on a v117 board writes `@anyone` and `waiting.for: anyone`, on a v114 board the handle; `heal-board.py` and `heal-descriptors.py` refuse `--name anyone`.
- Smoke's stamp gate passes once the stamp reads v117; `check-refs.sh` and `check-sizes.sh` stay green (README § Sizes updated if a word count moves).
- `tests/fixtures/app-writes/` re-copied only if the app wrote a card, lane or comment since the v114 copy; otherwise left, with the reason in the closing comment.
- An adversarial read-through of the changed prose against the v117 guide, as the v114 card got.

## Done when

- `CLAUDE.md` stamps `lanework-agent-guide v117` and `tests/smoke.sh` passes in the main checkout.
- On a v117 throwaway board, an ask written through `file-question.sh` starts `@anyone` and its card carries `waiting: {for: anyone, ...}`; on a v114 board it still names the handle.
- `lint-ask.sh` checks an `@anyone` ask on a v117 board and ignores one on a v114 board.
- `anyone` is in all three reserved-name lists and the heal refuses to sign it.
- No file under `skills/` says "no reserved handle" or tells an agent to take the handle from the guide's Mentions line for a default ask.

## Risks

- **v117 guide and validator are uncommitted** in the main checkout (app-written). Smoke fails at the stamp gate until the owner or the app commits them; the build cannot go green before. Committing app-written files is not the builder's: surface it, do not stage them.
- **Mixed-version boards**: a skill writing `@anyone` on a v114 board draws no buttons. `ask_handle` gating on the board's own stamp is the guard; a board with an unreadable stamp falls back to the handle.
- **`lint-ask.sh` loosening**: treating `@anyone` as the human must not make a body that mentions it mid-sentence pass as a record. Smoke covers it.
- **Release**: this is a guide-version move, so a minor bump. Whether 0.8.0 waits for it is the owner's release call, not this card's.

## Recommendation

Build as one change, in the order `lib.sh`, `lint-ask.sh`, the prose, the reserved lists, the stamp, so each step is testable alone. Gate on the board's guide version rather than switching all boards to `@anyone`: the guide itself says older builds draw no buttons for it. Medium size; sonnet can build it, reviewed against the v117 diff.
