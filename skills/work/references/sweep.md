# Sweeps: inventory → triage → farm

Bounded, user-requested pass over one or more boards. Ends in a **triage report**, plus **farmed work** when the request includes working the board. Runs once, reports, stops. Cadences (/loop, schedules) are the user's to set up, never self-granted.

## 1. Scope

- "Sweep the boards" = the pipeline boards. "Sweep Acme Pipeline" = that one.
- No board named → the current project's boards + `~/` boards (`lanework/references/finding.md`: folders, order, legacy offer). Skip archive and schema boards unless asked.
- A board's instruction sheet may narrow or widen this. Guidance, not a gate.

## 2. Inventory

Per board, after the authority chain:

- **Skip** `.trash/`, Done, and any lane whose body marks itself out of scope, unless the owner asks (archive sweep, "what shipped?").
- List lanes in order with card counts (`lanework/scripts/read-board.sh`).
- Read every card's frontmatter; skim bodies; full threads only for cards that look actionable.
- The lane says who acts next (`lanework/references/board-kinds.md` tables): that's the primary classifier.

| workload | shows up | who acts |
|---|---|---|
| **Unanswered question** | any lane: `waiting` in the frontmatter, or a thread ending in a question. `waiting.for` / the mention names the human → on them; addressed to an agent → on you | answer, or surface |
| **Approved, unstarted** | Approved, Tasks | farm: build |
| **Approved, unruled** | Approved or Active, with an open call and no ruling | don't build; post or re-post the ask (`writing.md` § When to ask), report it |
| **Active, stalled** | Active, no thread movement | resume, or report why stuck |
| **Shaping to advance** | Shaping, below the board's proposal bar | farm: shape; an open call → ask |
| **At a human gate** | Ideas (triage), Proposed (review) | report only, never move |
| **Issue** | Issues | diagnose; fix if the board policy allows |
| **Hygiene** | Done / Rejected overdue for archive | only on the owner's explicit ask |

## 3. Triage report

Always before, or alongside, farming. Per board: what waits on the human (gates, mentions, questions with stated defaults), each a link to its card's ask, never a question restated for the chat, what's being farmed and at which tier, what's deliberately left alone. "Anything on the boards?" → the report IS the deliverable. Stop there.

## 4. Farm

- Execution leaves the main session. Synthesis, review of agent output, and every judgment-call board write stay.
- Tier: `tiers.md`. Prompt: `templates/farmed-prompt.md`.
- Workflow-scale orchestration needs the user's explicit opt-in. A handful of Agent-tool subagents doesn't. Enough parallel work for a workflow → say so and ask.
- Substantial coding (≥2 independent Approved or Tasks cards, or review independence matters) → a build team, `team.md`. Below that, work the card directly.

## 5. Close

- **An unfiled finding is lost.** Anything uncovered but not worked gets a card before the sweep ends, after a duplicate search on the **mechanism**, not your title phrasing. Grep Done too.
- Every touched card: thread updated, stamps correct.
- Board commits per the board's git rules (`lanework/references/writes.md`).
- Final report: what moved, what shipped, what waits on the user, cost (agents, tiers).
