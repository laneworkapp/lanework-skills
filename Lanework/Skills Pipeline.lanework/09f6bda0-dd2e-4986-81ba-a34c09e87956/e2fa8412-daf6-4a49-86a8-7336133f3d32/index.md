---
schema: 1
kind: card
title: "discovery: record ADRs and PDRs on the board, not in docs/"
order: 5120
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created: {at: 2026-10-09T23:21:18Z}
modified: {at: 2026-10-10T00:45:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Discovery writes each ADR and PDR as a numbered Markdown file under `docs/adr/` or `docs/pdr/`, where nobody looking at the board sees it. Instead, each record becomes a card in a dedicated Decisions lane on the discovery board, beside the questions that produced it, so the decisions are as visible as the rulings.

## Proposal

- **Lane**: Decisions, on the discovery board, between Settled and Parked. Order 4608. Cards never leave it, like Settled.
- **Card per record**: title `ADR: <short title>` or `PDR: <short title>`, one lane for both. Body = today's record template minus its frontmatter: 1 to 3 sentences of context, decision and why, then Considered options, Consequences, Related only when they earn it. Line 1 links the Settled question it came from.
- **Labels**: two closed, single kinds, declared in the discovery board's `config.labels` by `templates/board.md` beside `round`. Each record card stamps one value of each.
  - `{type: record, text: Record, single: true, values: [{text: ADR, rank: 1}, {text: PDR, rank: 2}]}`
  - `{type: status, text: Status, single: true, values: [{text: accepted, rank: 1}, {text: deprecated, rank: 2}, {text: superseded, rank: 3}]}`. `proposed` goes: a record is only written from a ruling.
- **Filing**: new `scripts/file-record.sh <board> <question> --record ADR|PDR --title t --body F`. Files the card straight into Decisions at the bottom, with flattened `record` and `accepted` status labels and line 1 linking the question. It prints the card's link for the ruling. Records never pass through Asked, so the Asked-only move rule is untouched.
- **No numbers**: cards are identified by `lanework://` links, so `NNNN-slug.md` numbering goes. A Settled card's ruling links its record card instead of a path.
- **Superseding**: the old card is never edited to say something new. It gets the `superseded` status label and a dated comment linking its replacement. The new card links the old under Related.
- **Bar unchanged**: the three-part bar in `records.md` still decides whether a ruling gets a record at all.
- **Older boards**: a discovery board without a Decisions lane gets one on resume, with the label kinds added to its config.
- ~~**Open call, where the lane lives**: A: a Decisions lane on each discovery board. B: one project-wide Decisions board. C: a lane on the project's pipeline board.~~ **ruled 2026-10-09: A, on each discovery board, beside its questions.**
- ~~**Open call, PDRs**: follow ADRs into the lane, or stay in `docs/pdr/`.~~ **ruled 2026-10-09: follow, labelled PDR, same lane and card shape.**

## Out of scope

- The glossary stays a file, `CONTEXT.md`: a glossary is read as one page, not as cards.
- Existing `docs/adr/` and `docs/pdr/` files are not migrated. Frame still reads them, and a new record that supersedes one links the file.
- A project with its own non-discovery decision log keeps the existing-corpus rule: records go there. A `docs/adr/` or `docs/pdr/` in discovery's own `NNNN-slug.md` format is not such a log, so new records go to the lane.

## Touches

`skills/discovery/`: `SKILL.md` (output line, Frame reads the Decisions lane first), `references/records.md` (folder column, Format, Superseding), `references/board.md` (lanes, cards table, moves), `templates/lanes.md` (the lane and its policy), `templates/board.md` (label config, the records bullet), `templates/record.md` (card shape with frontmatter and labels), `templates/ruling.md` (record lines become links), `scripts/file-record.sh` (new). Repo `CLAUDE.md` (the docs/adr and docs/pdr line). `README.md` discovery row and sizes.

## Verify

`tests/smoke.sh` passes: `found-discovery-board.sh` founds the Decisions lane in order, and the board validates with the new label kinds. A smoke assertion that the lane exists and its config labels parse. A smoke case for `file-record.sh`: one ADR and one PDR card land in Decisions, labels flattened, the board validates. `check-refs.sh` finds no cited `docs/adr` or `docs/pdr` path. A by-hand round on a scratch discovery board settles one question into one ADR card and one into a PDR card, validated. Prose read through against guide v82.

## Done when

A fresh discovery board has the Decisions lane. A settled ruling that clears the bar produces a card there, linked both ways with its question, and no file under `docs/adr/` or `docs/pdr/`. The smoke case and the scratch round pass.
