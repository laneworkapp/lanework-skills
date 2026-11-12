---
schema: 1
kind: card
title: "Skills target agent guide v114: waiting lists, short links, relations, component retired"
order: 7168
labels:
  - {text: lanework, kind: {type: skill, text: Skill}}
  - {text: work, kind: {type: skill, text: Skill}}
  - {text: merge, kind: {type: skill, text: Skill}}
  - {text: heal, kind: {type: skill, text: Skill}}
created:  {at: 2026-11-06T00:08:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-11-12T00:49:29Z}
---
The skills are stamped `lanework-agent-guide v101` (`CLAUDE.md:29`), and this board's guide is now v114, so `tests/smoke.sh` fails only on its stamp gate (`tests/smoke.sh:1095-1101`; every other check passes on `main` today). This card is the catch-up: read every skill against v114, fix the drift below, re-copy the app-write fixtures, bump the stamp. It blocks release 0.8.0.

## Scope

Diffed from the last committed guide (v101, `9a12b5d`) to the working-tree copy (v114). Board Runner Discovery's working-tree guide is v107, which splits the range. Schema stays `lanework-schema v1` (`.schema/VERSION`), so that stamp does not move.

| guide change | since | what the skills need |
|---|---|---|
| `waiting.for` may be a list, `for: [a, b]`, only on v105+ boards. Each person @-named on the ask's first line. Any answer clears it | v105 | wording: `work/references/writing.md:50` (list form, the v105 floor, an `@` each on line 1), `work/templates/ask.md:3,6` (several handles on line 1), `work/references/sweep.md:22` (a list naming the human is on them). Script: `work/scripts/lint-ask.sh:20-26` also fails when an `@handle` in an ask is not on the first line. `discovery/scripts/settle-question.sh:43` and `plan/scripts/resolve-ticket.sh:50` drop the whole `waiting:` line, and `plan/scripts/frontier.sh:34` tests presence only, so they need no change, only smoke cases |
| Short `lanework://` links: each segment the first 8+ hex digits. Read by prefix, write the full form. Scripts match full ids only | v107 | wording: `work/references/writing.md:72-79` § Card references, one line on reading a short link. Nothing for `plan/scripts/frontier.sh:21`, `plan/scripts/file-ticket.sh:51` or `work/scripts/lint-ask.sh:38`: full ids only is what the guide asks |
| Heal H13 (stale-label) and H14 (single-kind) re-apply definitions: run only when the owner asks. Board Settings no longer re-stamps cards, and no app repair signs `healer` today | v101-v107 | wording: `lanework/references/writes.md:50-53` § Healing. Apply H13/H14 lines from a dry run only on the owner's ask. `heal/SKILL.md` step 2 (the user's go) already covers `/heal` |
| `component` retired as a built-in: no `group`/`filter` `by: component`, no suggested definition, a root `component:` is an unknown key, not reserved | v108-v114 | wording: `lanework/references/writes.md:10,53`, `lanework/templates/label-kinds.md:3` (only `priority` is the guide's suggestion; the `component` row at :8 stays a catalog kind), `lanework/references/board-kinds.md:62` (group by `{by: label, kind: <kind>}`), `merge/references/rules.md:23`. Script: `lanework/scripts/heal-board.py:18,24,74,76,226` (H06/H11 for `priority` only, as the board's heal v5 does), `merge/scripts/lanework-merge.py:20` (`SINGLE_KINDS = {'priority'}`, the board's `single` flags already join at :561-569), `tests/smoke.sh:1043-1057` (embedded suggested = `priority` alone). `tests/smoke.sh:1070-1073` (no skill prescribes a root `component:`) stays |
| `relations/<uuid>/index.md` under a card: typed links, `relations/.trash/` for deletes | v108-v114 | wording: `lanework/references/format.md:8` names `relations/`. Script: `lanework/scripts/heal-board.py:1089-1103` walks live relations, as heal v5 does. `merge/scripts/lanework-merge.py` already merges `relation` (:467, :511, :618). The watch snapshot already skips `*/.trash/*` (`watch/scripts/watch-boards.sh:54`) |
| App-reserved name `board` (move receipts, `config.move-receipts`) | v108-v114 | wording: `lanework/references/writes.md:7`. Script: `RESERVED_NAMES` in `lanework/scripts/heal-board.py:65` and `heal/scripts/heal-descriptors.py:62`. A receipt is `kind: agent`, so `watch/references/events.md:10` already ignores it |
| Lane `background` no longer read (cards only) | v108-v114 | nothing: no skill writes one (`grep background: skills/` is empty) |
| Lane `presentation`, lane `locked`, `config.short-id`, machine `return-posts-comment`, card `cite-as` (proposed), validator `unknown-value` WARN | v101-v114 | nothing: no skill writes these. `locked` binds the app only, and the board's instructions govern agents (`lanework/references/authority.md:6-9` already ranks those first). A WARN fails nothing (`lanework/references/writes.md:12`) |

`.schema/`: VERSION unchanged (v1). HEAL.md catalog v2→v5 and heal v5: `board` reserved, `relations/.trash` never walked, `component` dropped from H06/H11. These are folded into `heal-board.py` above. Validator v1→v4 adds `relation.json`, `required` and the WARN. Smoke borrows the board's validator (`tests/smoke.sh:7`), so nothing to copy.

## Fixtures

Re-copy under `tests/fixtures/app-writes/` (sources per its `README.md`), then update the ids and the `AE`/`AL` stamps in the `appside` case (`tests/merge-case.sh:194-195`) and the README table:

- `lane-rewrite.*`: the app's Shaping lane rewrite (`width: 3`, unstamped `modified` 2026-11-12T00:40:30Z), once it is committed. Before: the lane file at `HEAD`.
- `card-move.*`: `99ac340`, the owner's move of f322abdb from Ideas to Shaping (fresh `order`, unstamped `modified`).
- `comment-posted.md`: `281c22a`, comment `2bbea8c7` on f322abdb (quoted human `created`, `in-reply-to`).
- `card-title-edit.*`: keep. No app retitle has landed since `9a12b5d`.

## Touches

`skills/work/references/writing.md`, `skills/work/references/sweep.md`, `skills/work/templates/ask.md`, `skills/work/scripts/lint-ask.sh`, `skills/lanework/references/writes.md`, `skills/lanework/references/format.md`, `skills/lanework/references/board-kinds.md`, `skills/lanework/templates/label-kinds.md`, `skills/lanework/scripts/heal-board.py`, `skills/heal/scripts/heal-descriptors.py`, `skills/merge/references/rules.md`, `skills/merge/scripts/lanework-merge.py`; `tests/smoke.sh`, `tests/merge-case.sh`, `tests/fixtures/app-writes/`, `README.md` § Sizes, `CLAUDE.md:29` (stamp to v114).

## Risks

- **Order of commits.** The board's v114 `CLAUDE.md`/`AGENTS.md` and `.schema/` are app writes not yet committed. They go in as a board-write commit before the stamp bump, or CI smoke runs the v1 validator with no `relation.json`.
- **The guide may move again before release.** Re-run the gate. A newer guide is a follow-up card, not scope creep here.
- **`heal-board.py` is a derived copy, not the board's heal** (different header and repair list). Patch only the four drifts named. A full re-base on heal v5 (rule ids, catalog) is deferred.

## Verify

`tests/smoke.sh` green, with new cases. `lint-ask.sh` passes an ask with two handles on line 1, and fails one whose second handle is only on a later line. `settle-question.sh` and `resolve-ticket.sh` drop a list-form `waiting`. `heal-board.py` leaves a root `component:` alone, walks a card's `relations/`, and refuses `--name board`. `lanework-merge.py` treats `component` as single only where the board says so. The `appside` merge case passes on the new fixtures. Prose read through against the v114 guide.

## Done when

`CLAUDE.md` stamps `lanework-agent-guide v114`, smoke is green on `main` with the cases above, and no skill names `component` as reserved, as the guide's suggested kind, or as a `group`/`filter` `by:` value. It stays only as a catalog kind (`lanework/templates/label-kinds.md:8`, `lanework/references/board-kinds.md:25,44`, `lanework/references/founding.md:17`).

## Deferred

Plan tickets' `## Depends on` as `relations/` (`depends-on`); classifying a relation change in `dispatch/scripts/classify-event.sh` (today it reads as a body edit); re-basing `heal-board.py` on heal v5.

## Recommendation

Build as scoped: a minor-version move, already within 0.8.0. No open call: every item follows from the guide.
