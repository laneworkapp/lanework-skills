---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:39:11Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**[Retire the dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ee07c8d2-6fa8-41ac-b06a-ceb5f3045fd0) landed on main (`a0d281c`): the ordering condition in this body is met.**

- **`arm-pass.sh`**: now at `skills/watch/scripts/`, code unchanged.
- **`arming.md` § Arming pass**: exists, as a table of `comment`, `arm` and `stale`.
- **New since this body was written**: the `comment` row ends "Either way, then carry on as `arm` when the card sits unclaimed in an agent lane", because the script prints `comment` in place of `arm`. The build here keeps that clause, and smoke pins its wording.
- **Still ahead of this card**: the lease script and the work skill's lease checks.
