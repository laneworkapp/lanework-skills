---
schema: 1
kind: card
title: "Plan: record ticket dependencies as depends-on relations"
order: 1024
labels: [{text: "plan", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-23T16:34:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Scratch"}}
modified: {at: 2026-11-23T16:34:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Scratch"}}
---
Plan tickets record their dependencies as a `## Depends on` section of links in the body. The guide has a typed link for exactly this, the `depends-on` relation (guide § Relations), and plan does not use it. The app shows a relation on both cards and draws nothing for a body link.

**Today**
- `plan/scripts/file-ticket.sh --depends <link>` appends `## Depends on` to the body and files into Blocked.
- `plan/scripts/frontier.sh` and `plan/scripts/resolve-ticket.sh` read that section to find open dependencies and to unblock dependents.
- `plan/references/tickets.md` § Depends on names the section as the record.
- Relations already written by the skills: only `supersedes`, by `discovery/scripts/file-record.sh`.

**Idea**
- `file-ticket.sh` writes one `depends-on` relation per `--depends`, at `<ticket>/relations/<uuid>/index.md`, on the dependent ticket only (no inverse, per the guide).
- `frontier.sh` and `resolve-ticket.sh` read `relations/` to decide what is blocked and what to unblock.
- A reopened or re-ruled dependency could mark the relation `suspect`, so the dependent ticket shows it needs a re-check.

**To settle in shaping**
- Whether the body keeps `## Depends on` as well, or relations become the only record.
- Plan boards already charted carry body sections only: read both shapes, or migrate them.
- Whether `suspect` is in scope or a follow-on card.
- Smoke cases for the new script behavior, and the wording in `tickets.md`.

**Files**: `skills/plan/scripts/file-ticket.sh`, `frontier.sh`, `resolve-ticket.sh`, `skills/plan/references/tickets.md`, `skills/plan/templates/`, `tests/smoke.sh`.
