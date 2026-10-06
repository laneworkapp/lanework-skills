# Board kinds

Defaults to copy and change. The app knows nothing about lane names: meaning = lane titles + lane bodies. Lanes and their bodies: `templates/<kind>-lanes.md`.

## Pipeline

Work from raw idea to built. **Lanes = stages of commitment; a card's lane says who acts next.** Ideas → Shaping → Proposed → Approved → Active → Done, with Issues and Tasks as side entrances.

- **Card** = one piece of work (feature, fix, chore). Body = spec, growing from a one-liner in Ideas to a brief in Approved an agent can pick up cold. Thread = journal: why, plan, decisions, evidence.
- **Moves**: agents shape, build, answer, report, and move cards between the lanes on either side of their own work. **Humans hold two gates**: triage (out of Ideas) and review (out of Proposed: approve, bounce to Shaping, reject). Agents surface a card at a gate and stop. **Review approves the card, not its open calls**: an open call is ruled only through an ask on the card (`pitlane/references/writing.md`). **Tasks** = owner-filed chores, pre-approved → build via Active. Agent-found chores → Ideas, never Tasks.
- **Common additions**: `Rejected` (collapsed, terminal, one line why), `Deferred` (collapsed). A busy Done: a `modified` `filter` (newer than 2d) + `group` by `modified`, descending (shapes: guide § Frontmatter, lanes).

## Design loop

One surface or question worked through drawn alternatives until the owner picks. Cards loop between the middle lanes rather than marching right.

- **Card** = one thing being designed (screen, menu, gesture, name). Body = the current proposal, rewritten as it moves. Attachments = renders. Thread = the argument, incl. every rejected route and the sentence that rejected it.
- **Moves**: agents inventory, draw, compare and argue, and move Brief → Alternatives → Mockups themselves. **The owner rules**: no agent chooses, Sittings need the owner present, and rulings are recorded in the owner's words. Chosen leaves as pipeline cards, linked both ways.

## Datapoint

One card per value that exists whether or not anyone is working on it (listing field, setting, published number, policy). Cards are permanent; lanes track the value's state.

- **Card** = one datapoint. **Above the first `##` = the current value, verbatim**, as the live system shows it. Below = its facts: limit, file, surface, last read-back. Thread = the value's evolution.
- **Moves**: agents draft, file in the same commit that writes the file, and read back. **Pushing is the owner's**: Pushed only after a read-back that agrees with the body. A value breaking a house rule → back to Drafting, with a comment.
- **Optional task lanes**: `Checklist` 6144, `Active` 7168, `Done` 8192, for release steps. Mark task cards with a label kind. Group Filed / Pushed by `component` (guide § Frontmatter, lanes).

## Discovery

A project's problem and domain space, one question per card. Owned by the `discovery` skill.
