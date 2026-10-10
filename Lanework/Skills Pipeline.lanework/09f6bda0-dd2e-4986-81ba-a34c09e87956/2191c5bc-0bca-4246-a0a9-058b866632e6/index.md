---
schema: 1
kind: card
title: "lanework: a catalog of common label kinds for founding boards"
order: 7168
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T00:16:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T02:52:31Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
---
Boards founded by hand each invent their own label kinds, so the same idea gets a different name, scale or shape on every board. A catalog in the `lanework` skill gives founding a uniform set to pick from, written into the new board's own `config.labels`.

## Catalog

| kind | shape | values | why |
|---|---|---|---|
| `priority` | closed, single | Urgent 0, High 1, Medium 2, Low 3 | the guide's suggested scale; lanes group by it |
| `component` | open, single | per project | the guide's suggested kind; lanes group by it |
| `type` | closed, single | Bug 1, Feature 2, Chore 3, Docs 4, Spike 5 | the most common split after priority; filter "bugs only" |
| `size` | closed, single | XS 0, S 1, M 2, L 3, XL 4 | effort at triage; picks a model tier |
| `platform` | open, multi | iOS, macOS, watchOS, web… | one card can span targets |
| `release` | open, single | `0.3.0`, `Winter`… | what ships together; filter a release |
| `epic` | open, single | per project | a body of work spanning components and releases |
| `round` | open, single | `1`, `2`… | which discovery round asked a question; discovery boards' existing kind |

**Rejected**: `status` (the lane is the status), `state` (reserved for the tracker engine).

**Deferred**: `assignee`. Useful, but no good way yet to manage it alongside the claims that live in the thread and stamps.

- ~~**Open call, scope**: which kinds make the catalog.~~ **ruled 2026-10-10: B plus epic: priority, component, type, size, platform, release, epic.**
- **Added 2026-10-10 (owner, in chat)**: `round`, discovery's existing `{type: round, text: Round}` plus `single: true`. No icon: one would restamp every existing discovery card's kind. `discovery/templates/board.md` takes its `round` entry from the catalog, so there is one definition.
- ~~**Open call, home**: board `config.labels` or machine `default-labels`.~~ **ruled 2026-10-10: A, the board's own `config.labels`.**

## Proposal

- **One data file**: `skills/lanework/templates/label-kinds.md`, one row per kind: `| type | entry |`, the entry a one-line flow mapping ready for `config.labels` (`type`, `text`, `icon`, `single`, `values` with `rank`). Same table shape `found-board.sh` already reads for lanes.
- **Glyphs**: `priority` and `component` exactly as the guide suggests. `type` `square.grid.2x2`, with value icons Bug `ladybug`, Feature `sparkles`, Chore `wrench`, Docs `doc.text`, Spike `magnifyingglass`. `size` `ruler`. `platform` `laptopcomputer.and.iphone`. `release` `shippingbox`. `epic` `mountain.2`. No colours beyond the guide's priority tints: the glyph says enough.
- **Founding**: `found-board.sh --labels <kind,...>` splices the named rows into the index's `config`, via a `{{labels}}` slot in each index template. Unknown kind → exit 2, nothing written. No `--labels` → no kinds, as today.
- **Defaults per lane set**, in `references/board-kinds.md`: pipeline → `priority, component, type`; design loop → `priority, component`; datapoint → none. `references/founding.md` offers the set's default and the rest of the catalog in one line, then passes `--labels`.
- **One source for the suggested kinds**: `heal-board.py`'s built-in `SUGGESTED` priority and component read from the same file, so healing and founding cannot drift.
- **Name `type` kept**: `{type: type, text: Type}` reads oddly in YAML but renders as "Type". `work-type` stays the fallback.
- **After the app drops machine `default-labels`** ([4392544b](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/4392544b-bf94-40bf-b4cf-6a346af84b22)): remove `heal-board.py --global` and its line in `references/writes.md`. Not this card: until the guide drops it, the skills follow guide v82.

## Out of scope

- Adding catalog kinds to existing boards. A later `/heal` option ([0d374675](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0d374675-f23c-4959-95dc-07e10f99d345)), if wanted.
- Re-labelling this board: its `skill` kind stays as is.

## Touches

`skills/lanework/`: `templates/label-kinds.md` (new), `templates/index.md` and `templates/pipeline-index.md` (`{{labels}}` slot), `scripts/found-board.sh` (`--labels`), `scripts/heal-board.py` (`SUGGESTED` from the file), `references/founding.md`, `references/board-kinds.md`, `SKILL.md` (script table row). `tests/smoke.sh`. `README.md` key features line.

## Build order

After [0d374675](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0d374675-f23c-4959-95dc-07e10f99d345) (branch `lane-actors`: `board-kinds.md`, `founding.md`, `SKILL.md`, `smoke.sh`) and [4ff216a4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ff216a4-e8d1-4d7a-b5f4-ae4c34773e03) (branch `script-stamps`: `found-board.sh`, `SKILL.md`, `smoke.sh`) land on main. Branched from main after both.

## Verify

`tests/smoke.sh` passes, with new cases: `found-board.sh --labels` naming all seven kinds founds a board whose `config.labels` holds exactly those seven, and it validates. An unknown kind exits 2 and writes nothing. A card carrying one flattened entry of each kind validates with no `DEPRECATED` line. The existing `heal-board.py` cases still pass with `SUGGESTED` read from the file. Prose read through against guide v82.

## Done when

The catalog file holds all eight kinds, discovery's board template takes `round` from it, founding writes any subset into the board's own `config.labels`, each lane set names its default kinds, `heal-board.py` reads its suggested kinds from the same file, and the smoke cases pass.
