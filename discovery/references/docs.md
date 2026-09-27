# The documents discovery writes

The board holds the examination. The documents outside it hold what the codebase should keep from it: a **glossary**, and a set of **decision records**. There are two kinds of record, ADRs for architecture and PDRs for product. All of them are written at the close of a round, from that round's rulings. Never batch them to the end of the session.

## Glossary: `CONTEXT.md`

One file at the repo root. When a `CONTEXT-MAP.md` exists there, use the `CONTEXT.md` of the context the topic belongs to instead. Create the file the first time a term is pinned, and add each later term to it as it is pinned.

The file is a glossary and nothing else: no implementation detail, no spec, no scratch notes. A definition says what a thing **is**, in one or two sentences. Each term lists the words to avoid, so that the whole codebase and every board use one word per concept.

```markdown
# <Context name>

<One or two sentences: what this context is and why it exists.>

## Language

**Tracker**:
An external issue-tracking system a board can be bound to: Gitea, GitHub, GitLab, Jira.
_Avoid_: backend, integration, connector (the connector is the code that talks to a tracker)

**Remote**:
The tracker-side object a local object mirrors; an issue, for a card.
_Avoid_: counterpart, upstream, origin
```

Rules:

- **Be opinionated.** Pick the best word and list the rest under `_Avoid_`.
- **Include only this project's terms.** A general programming concept does not belong, however much the project uses it.
- **Group terms under subheadings** only when clusters form on their own.
- **Check answers against it during the session.** When the owner uses a term the glossary defines differently, or uses two words for one thing, the next round carries a question that names the conflict and proposes the canonical term.

A term pinned by a ruling is written in the same round, and the Settled card names it: `Glossary: **Tracker**, **Remote** in CONTEXT.md`.

## Decision records

Discovery produces two kinds of record. They share a format and a bar, and differ in what the decision is about.

| record | folder | settles | typical subjects |
|---|---|---|---|
| **ADR**, architecture decision record | `docs/adr/` | how the system is built | architectural shape, boundaries between contexts, integration patterns, technology choices with lock-in, data ownership and storage, deliberate deviations from the obvious technical path, constraints that are invisible in the code |
| **PDR**, product decision record | `docs/pdr/` | what the product does, and for whom | target users and the needs chosen to serve, scope and non-goals, behavior and user-facing rules, what is traded away for what, packaging and editions, success criteria, deliberate deviations from what users would expect |

To tell them apart, ask who would challenge the decision later. An engineer asking "why is it built like this?" is reading an ADR. A user, a stakeholder or a product owner asking "why does it do this, and not that?" is reading a PDR. A ruling that settles both gets one of each, and each links the other.

### Format

Each record is a short file, numbered per folder (`0001-slug.md`, `0002-slug.md`, …), and the folder is created with the first record in it. Scan the folder for the highest number and add one. ADRs and PDRs number independently.

```markdown
---
status: accepted
date: 2026-09-27
discovery: lanework://<board-id>/<card-id>
---
# <Short title of the decision>

<1 to 3 sentences: the context, what was decided, and why.>
```

- `status` is `proposed | accepted | deprecated | superseded by ADR-NNNN` (or `PDR-NNNN`). A record written from a ruling is `accepted`.
- `discovery` links the Settled card the record came from, so a reader can get from the record to the question, the options and the owner's words.

Add these sections only when they earn their place:

- **Considered options**, when the rejected routes are worth remembering.
- **Consequences**, when a downstream effect is not obvious.
- **Related**, for the ADR or PDR on the other side of a ruling that produced both, or a record this one supersedes.

### The bar

Write a record only when **all three** of these hold:

1. **Hard to reverse.** Changing the decision later costs something real: code, data, contracts, users' habits, or promises made.
2. **Surprising without context.** A future reader of the code, or of the product, would ask why.
3. **A real trade-off.** There were genuine alternatives, and one was chosen for reasons.

A ruling that fails any of the three gets no record, and its Settled card is its record. Explicit no's pass the bar as often as yes's: a non-goal that someone will propose again next quarter is exactly what a PDR is for.

A ruling that produced a record links it from the Settled card, one line per record: `ADR: docs/adr/0003-engine-in-app.md`, `PDR: docs/pdr/0002-sync-is-free.md`.

### Superseding

A record is never edited to say something new. When a later discovery overturns a decision, write a new record, set the old one's `status` to `superseded by ADR-NNNN` (or `PDR-NNNN`), and link the old record from the new one under **Related**. The ruling that overturned it is a new Settled card that links the old card, as the board requires anyway.

## Where the project already keeps this

Some projects have a design corpus of their own: a `DESIGN/` folder, a `SCHEMA.md`, a terminology section in a README, or an existing decision log under another name. When a ruling changes what those documents say, write the change there too, in that project's own conventions, and have the Settled card name the file. When a project already keeps decision records somewhere else, write ADRs and PDRs there in its format rather than starting a second log. The glossary and the records do not replace a project's corpus. They are the compact, machine-readable layer beside it.
