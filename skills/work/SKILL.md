---
name: work
description: "The work skill: working Lanework boards. Filing and moving cards, writing card bodies and comments (records vs asks to the human), answering board questions, sweeping a pipeline board for workloads, triaging them, and farming the work out to model-tiered subagents, with a lead/fixer/reviewer build cycle for coding cards. Use whenever the user mentions Lanework or a pipeline board (e.g. 'Acme Pipeline'), or says 'sweep the pipeline board', 'check the lab board', 'file a card on X', 'any open questions on the boards?', 'triage Ideas', 'work the approved cards'. Board fundamentals come from the lanework skill. Not for generic kanban advice unrelated to Lanework."
---

# Work

Working a board: cards are specs, threads are journals, and on a pipeline **a card's lane says who acts next**.

**Base**: `lanework`, for the authority chain, reading and write rules. Read `lanework/references/authority.md` before touching any board. Pipeline lanes, gates, and which lanes agents act on unasked: `lanework/references/board-kinds.md`.

On a pipeline, agents **shape** Shaping cards into proposals that meet the board's bar, with every open call left to the owner as an ask on the card, at filing as at shaping and never as a question in chat (`references/writing.md` § When to ask), then **move** each on as the board and lane bodies say, never leaving an agent's move to the owner, **build** Approved → Active → Done with evidence in the closing comment, **answer** questions on any card, and **report** what sits at a human gate: surface it, never push through it.

## Topics

| task | file |
|---|---|
| writing a card body, a record, or an ask | `references/writing.md` |
| sweeping and triaging a board, farming work | `references/sweep.md` |
| picking a model tier | `references/tiers.md` |
| who's on a build team, how they talk, review stance | `references/team.md` |
| a multi-card build campaign (lead) | `references/lead.md` |
| fixing one card in a worktree (fixer) | `references/fixer.md` |
| reviewing a card's branch (reviewer) | `references/reviewer.md` |
| trusting a number, a zero, or a green | `references/evidence.md` |
| other sessions on the same board | `references/companions.md` |
| a command about to do something subtle | `references/traps.md` |
| ask, farmed prompt, phase reports, verdict | `templates/` |

Fill templates with the structure they give, not free-form prose. `scripts/lint-ask.sh <file> <board>` checks an ask before it lands. `scripts/lint-stamps.sh <board>` checks no stamp is in the future. `scripts/lint-leases.sh <board>... [--since <ts>] [--first <n>]` finds lease collisions (read-only). `scripts/lint-waiting-clears.sh <board>` lists cards whose latest ask an agent cleared. Findings print one per line: a tab, newline, carriage return or backslash in a name prints as `\t`, `\n`, `\r` or `\\`.

Board writes, usage in each header: `scripts/file-card.sh` files a card (`--label Text[:kind]` adds labels), `label-card.sh` labels an existing one, `move-card.sh` moves one, `post-comment.sh` posts a record, `post-ask.sh` an ask with its `waiting`, `commit-board.sh` commits named board paths.
