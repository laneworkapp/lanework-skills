---
schema: 1
kind: card
title: "lanework: a catalog of common label kinds for founding boards"
order: 7168
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
waiting: {for: rzen, since: 2026-10-10T00:16:24Z, comment: d9aa853e-8804-4e3e-abfb-0f4a698cc3f3}
created:  {at: 2026-10-10T00:16:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T00:16:24Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
Boards founded by hand each invent their own label kinds, so the same idea gets a different name, scale or shape on every board. A short catalog in the `lanework` skill gives founding a uniform set to pick from, stamped into the new board's `config.labels`.

**Candidate kinds** (closed = fixed values with rank; open = free text):

| kind | shape | values | why |
|---|---|---|---|
| `priority` | closed, single | Urgent 0, High 1, Medium 2, Low 3 | guide's suggested scale; lanes group by it |
| `component` | open, single | per project | guide's suggested kind; lanes group by it |
| `type` | closed, single | Bug, Feature, Chore, Docs, Spike | the most common split after priority; filter "bugs only" |
| `size` | closed, single | XS, S, M, L, XL (rank 0–4) | effort at triage; picks a model tier |
| `platform` | open, multi | iOS, macOS, watchOS, web… | one card can span targets |
| `release` | open, single | `0.3.0`, `Winter`… | what ships together; filter a release |

**Rejected**: `status` (the lane is the status), `state` (reserved for the tracker engine), `assignee` (claims live in the thread and stamps), `epic` (`component` or `release` covers it).

- **Touches**: `skills/lanework/references/label-kinds.md` (new: the catalog, each kind as a ready `config.labels` entry), `references/founding.md` (pick kinds at founding), `references/board-kinds.md` (default kinds per lane set), maybe `scripts/found-board.sh` (a `--labels` flag) and `scripts/heal-board.py` (its built-in priority/component defaults read from one place).
- **Open**: which kinds make the catalog. Board `config.labels` or machine `default-labels`.
- **Done when**: the catalog file exists, founding cites it, a board founded with the kinds validates clean, and smoke covers it.
