---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:30:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:30:56Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: 73eb138f-b0ce-429c-8c03-409b8e5b52e3
---
**Mostly you would not call it: an agent does, and under A the plain way to see leases is to ask one, or to read a report that already lists them.**

- **The script**: the one lanework script from Q11, called `lease.sh` here (its name is not settled). `lease.sh list <board>` prints one line per held card: title, holder, time left.
- **By asking an agent**: "which cards are held on Skills Pipeline?" or "free that card". Any session with the skills runs the script through its shell and answers. A forced release posts a record on the card saying you asked for it.
- **In reports, unasked**: a sweep's triage report and a watch's arming report can list held cards and flag a lapsed lease, as `dispatch` flags a stale START today. Not in the first option A, added below.
- **By hand, in a terminal**: the script sits inside the installed skills, so the path is long and differs by install: `~/.claude/skills/lanework/scripts/lease.sh` for a symlinked install, a versioned folder under `~/.claude/plugins/cache/` for the plugin. Inside Claude Code, a line starting with `!` runs it in the session.
- **With no script at all**: a lease is one line in a plain file. `grep -rl '^claimed:' <board>` lists held cards, and deleting that line in any editor frees one.
- **What A does not give you**: anything on the board itself. Seeing a held card at a glance in the app is what B (a label) and C (the app draws it) are for.
