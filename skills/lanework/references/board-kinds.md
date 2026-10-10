# Board kinds

Defaults to copy and change. The app knows nothing about lane names: meaning = lane titles + lane bodies. Lanes and their bodies: `templates/<kind>-lanes.md`.

**Lane actors**: one table per kind, the only place for who acts and what starts it. A lane body's second sentence names both; other files cite these tables, never restate. **agent** = acted on unasked (standing instructions = board sheet + lane bodies, not chat). **gate** = the owner rules; agents move cards in only. **holding** = agents read, link, research, answer; move out or start only on request. **none** = never a work order. A board's own bodies win.

## Pipeline

Work from raw idea to built. **Lanes = stages of commitment; a card's lane says who acts next.** Ideas → Shaping → Proposed → Approved → Active → Done, with Issues and Tasks as side entrances.

- **Card** = one piece of work (feature, fix, chore). Body = spec, growing from a one-liner in Ideas to a brief in Approved an agent can pick up cold. Thread = journal: why, plan, decisions, evidence.
- **Moves**: agents shape, build, answer, report, and move cards between the lanes on either side of their own work. **Humans hold two gates**: triage (out of Ideas) and review (out of Proposed: approve, bounce to Shaping, reject). Agents surface a card at a gate and stop. **Review approves the card, not its open calls**: an open call is ruled only through an ask on the card (`work/references/writing.md`). **Tasks** = owner-filed chores needing no shaping; owner moves one to Approved. Agent-found chores → Ideas, never Tasks.

| lane | who acts | what starts it |
|---|---|---|
| Ideas | holding | owner triages to Shaping or out. Agents file here |
| Issues | holding | owner moves it on |
| Tasks | holding | owner moves a chore to Approved |
| Shaping | agent | the owner places a card here: develop the proposal, move to Proposed |
| Proposed | gate | review: approve, bounce to Shaping, reject. Agents move finished proposals in |
| Approved | agent | the owner moves a card in, which is the go-ahead: take the top into Active |
| Active | agent | an agent moves a card in as it starts: build, evidence, move to Done |
| Done | none | the agent that built a card moves it in when its done-when is met |

- **Default label kinds**: priority, component, type (`templates/label-kinds.md`).
- **Common additions**: `Rejected` (collapsed, terminal, one line why), `Deferred` (collapsed). A busy Done: a `modified` `filter` (newer than 2d) + `group` by `modified`, descending (shapes: guide § Frontmatter, lanes).

## Design loop

One surface or question worked through drawn alternatives until the owner picks. Cards loop between the middle lanes rather than marching right.

- **Card** = one thing being designed (screen, menu, gesture, name). Body = the current proposal, rewritten as it moves. Attachments = renders. Thread = the argument, incl. every rejected route and the sentence that rejected it.
- **Moves**: agents inventory, draw, compare and argue, and move Brief → Alternatives → Mockups themselves. **The owner rules**: no agent chooses, Sittings need the owner present, and rulings are recorded in the owner's words. Chosen leaves as pipeline cards, linked both ways.

| lane | who acts | what starts it |
|---|---|---|
| Brief | agent | evidence or a ruling arrives: keep it current. The owner rules the open calls |
| Alternatives | agent | a direction worth drawing: move it to Mockups |
| Mockups | agent | a card lands: draw every variant, light and dark |
| Sittings | gate | the owner walks the card. An agent records the rulings |
| Chosen | gate | owner picks; build cards on a pipeline board only on request |
| Dead ends | none | the owner rules a direction out: an agent files it with one line why |

- **Default label kinds**: priority, component.

## Datapoint

One card per value that exists whether or not anyone is working on it (listing field, setting, published number, policy). Cards are permanent; lanes track the value's state.

- **Card** = one datapoint. **Above the first `##` = the current value, verbatim**, as the live system shows it. Below = its facts: limit, file, surface, last read-back. Thread = the value's evolution.
- **Moves**: agents draft, file in the same commit that writes the file, and read back. **Pushing is the owner's**: Pushed only after a read-back that agrees with the body. A value breaking a house rule → back to Drafting, with a comment.

| lane | who acts | what starts it |
|---|---|---|
| Brief | agent | the record changes: keep the map current |
| Ideas | holding | owner decides which ideas become datapoints. Agents leave ideas here, promote one only when asked |
| Drafting | agent | the owner places a card here, or its body changes: write the value |
| Filed | none | the file is written: file the card in the same commit. Then wait on the owner |
| Pushed | gate | the owner pushes. An agent moves the card in only after a read-back that agrees |

- **Default label kinds**: none.
- **Optional task lanes**: `Checklist` 6144, `Active` 7168, `Done` 8192, for release steps. Mark task cards with a label kind. Group Filed / Pushed by `component` (guide § Frontmatter, lanes).

## Discovery

A project's problem and domain space, one question per card. Owned by the `discovery` skill.

| lane | who acts | what starts it |
|---|---|---|
| Brief | agent | a round closes: rewrite the map. A resuming session reads it first |
| Facts | none | a fact is established: file it with its source |
| Asked | gate | the owner answers on the card or in chat. Only the agent moves a card out |
| Settled | none | the owner rules: write the ruling into the body, move it in |
| Decisions | none | a ruling produces an ADR or PDR: file it before the question settles |
| Parked | none | the owner defers or declines: move it in with the reason |
