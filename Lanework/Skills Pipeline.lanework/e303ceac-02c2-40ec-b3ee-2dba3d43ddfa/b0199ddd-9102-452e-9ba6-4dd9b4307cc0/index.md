---
schema: 1
kind: card
title: "discovery: a superseding record states a supersedes relation"
order: 58368
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T14:53:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T15:05:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
When a new ADR or PDR card replaces an older one, `file-record.sh` should write a `supersedes` relation on the new card pointing at the old, so the link between the two is a typed fact on the board and not only a line of prose under Related.

## Today

- `discovery/references/records.md` § Superseding: new card, old card's status set to `superseded`, a dated comment on the old card linking its replacement, the old card linked under the new one's Related. All by hand.
- `discovery/scripts/file-record.sh` files a record card and knows nothing of the record it replaces.
- No skill writes a relation.

## Change

- **`file-record.sh` gains `--supersedes <record-card-uuid>`**, repeatable. For each, the new card is staged with `relations/<uuid>/index.md`: `kind: relation`, `rel: supersedes`, `to:` the full link to the old card, stamped as the card is. Shape: the board guide's § Relations.
- **The target must be a card in the board's Decisions lane.** Anything else (a question, a short id, a path, an unknown uuid) is refused with exit 1 and nothing written.
- **No inverse.** Nothing is written on the old card by the script. The guide stores a relation once, on the card that makes the statement.
- **Stdout is unchanged**: one line, the new card's link.
- **`records.md` § Superseding** gains the relation as a step and names the flag. The script's header and the row in `discovery/SKILL.md` § Scripts name it too.

## Out of scope

- Setting the old card's status to `superseded` and posting its dated comment stay by hand, as `records.md` says today.
- Relations for anything else: a question's Depends on, a record's Related, a ticket's dependencies.
- The `plan` skill needs no change: it files its records through this same script.

## Touches

- `skills/discovery/scripts/file-record.sh`
- `skills/discovery/references/records.md`
- `skills/discovery/SKILL.md`
- `tests/smoke.sh`
- `README.md` § Sizes, if a word count moves

## Verified by

- `tests/smoke.sh` passes whole in a clean worktree, with a new case: a record filed with `--supersedes` carries one relation with `rel: supersedes` and the old card's full link, the board validates, the old card is byte for byte unchanged; two flags give two relations; each bad target is refused and leaves Decisions as it was.
- The new case fails against the script as it is today.
- `tests/check-refs.sh` and `tests/check-sizes.sh` pass.

## Done when

- `file-record.sh --supersedes <old>` files a record whose `relations/` holds a valid `supersedes` relation to `<old>`, and the validator counts it.
- `records.md` § Superseding tells an agent to pass the flag.
- Smoke is green on main after the merge.
