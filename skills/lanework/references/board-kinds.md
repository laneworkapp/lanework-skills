# Board kinds

Defaults to copy and change. The app knows nothing about lane names: meaning = lane titles + lane bodies. Lanes and their bodies: `templates/<kind>-lanes.md`.

**Lane actors**: each kind's table below is the one place that says who acts on a lane and what starts it. Every lane body names both (its second sentence), and other files cite these tables, never restate them. **Agent = acts unasked** on a card in that lane, standing instructions being the board sheet + lane bodies, never chat. Owner = waits on the owner; an agent surfaces it and stops. A board's own bodies win where they differ.

## Pipeline

Work from raw idea to built. **Lanes = stages of commitment; a card's lane says who acts next.** Ideas → Shaping → Proposed → Approved → Active → Done, with Issues and Tasks as side entrances.

- **Card** = one piece of work (feature, fix, chore). Body = spec, growing from a one-liner in Ideas to a brief in Approved an agent can pick up cold. Thread = journal: why, plan, decisions, evidence.
- **Moves**: agents shape, build, answer, report, and move cards between the lanes on either side of their own work. **Humans hold two gates**: triage (out of Ideas) and review (out of Proposed: approve, bounce to Shaping, reject). Agents surface a card at a gate and stop. **Review approves the card, not its open calls**: an open call is ruled only through an ask on the card (`work/references/writing.md`). **Tasks** = owner-filed chores, pre-approved → build via Active. Agent-found chores → Ideas, never Tasks.

| lane | who acts | what starts it |
|---|---|---|
| Ideas | owner | triage: moves each card on to Shaping, or out. Agents file here, never move out |
| Issues | agent | a card lands: diagnose and shape in place, move to Proposed |
| Tasks | agent | a card lands: build it through Active, no instruction needed |
| Shaping | agent | a card lands: develop the proposal, move to Proposed |
| Proposed | owner | review: approve, bounce to Shaping, reject. Agents never move out |
| Approved | agent | approval is the go-ahead: take the top card into Active |
| Active | agent | the claimed card: build, evidence, move to Done |
| Done | none | an agent moves a card in when its done-when is met |

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
| Sittings | owner | the owner walks the card. An agent records the rulings |
| Chosen | owner | the owner picks. An agent then files build cards on a pipeline board |
| Dead ends | agent | the owner rules a direction out: file it with one line why |

## Datapoint

One card per value that exists whether or not anyone is working on it (listing field, setting, published number, policy). Cards are permanent; lanes track the value's state.

- **Card** = one datapoint. **Above the first `##` = the current value, verbatim**, as the live system shows it. Below = its facts: limit, file, surface, last read-back. Thread = the value's evolution.
- **Moves**: agents draft, file in the same commit that writes the file, and read back. **Pushing is the owner's**: Pushed only after a read-back that agrees with the body. A value breaking a house rule → back to Drafting, with a comment.

| lane | who acts | what starts it |
|---|---|---|
| Brief | agent | the record changes: keep the map current |
| Ideas | owner | decides which ideas become cards. Agents file here unasked |
| Drafting | agent | a card lands, or its body changes: write the value |
| Filed | agent | the file is written: file the card in the same commit. Then wait on the owner |
| Pushed | owner | the owner pushes. An agent moves the card in only after a read-back that agrees |

- **Optional task lanes**: `Checklist` 6144, `Active` 7168, `Done` 8192, for release steps. Mark task cards with a label kind. Group Filed / Pushed by `component` (guide § Frontmatter, lanes).

## Discovery

A project's problem and domain space, one question per card. Owned by the `discovery` skill.

| lane | who acts | what starts it |
|---|---|---|
| Brief | agent | a round closes: rewrite the map. A resuming session reads it first |
| Facts | agent | a fact is established: file it with its source, unasked |
| Asked | owner | the owner answers on the card or in chat. Only the agent moves a card out |
| Settled | agent | the owner rules: write the ruling into the body, move it in |
| Decisions | agent | a ruling produces an ADR or PDR: file it before the question settles |
| Parked | agent | the owner defers or declines: move it in with the reason |
