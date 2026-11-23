---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:34:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Scratch"}}
modified: {at: 2026-11-23T16:34:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Scratch"}}
---
**Founding: plan keeps ticket dependencies in body text, while the guide's `depends-on` relation goes unused.**
- **Found**: a grep of `skills/plan/` for "relation" returns nothing. `file-ticket.sh:100` writes `## Depends on` into the body.
- **Seen on**: the AUP Skills Plan board in `lanework-aup`, 15 tickets, 9 of them filed with dependencies, none with a `relations/` folder.
- **Prior art**: `discovery/scripts/file-record.sh:77-78` writes a `supersedes` relation in the guide's shape.
- **Asked for**: filed on the owner's word in chat ("yes, file it in Ideas").
