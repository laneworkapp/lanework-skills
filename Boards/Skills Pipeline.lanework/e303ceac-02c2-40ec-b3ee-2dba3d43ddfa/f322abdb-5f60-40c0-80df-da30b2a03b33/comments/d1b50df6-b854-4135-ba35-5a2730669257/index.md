---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:49:11Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**START: fixer builds this in worktree `shaping-group-label-f322abdb`, as ruled.**

- **Scope**: one bullet block in `skills/work/references/sweep.md` plus a pointer in the Shaping row; README § Sizes. Shaping only; `priority` and `due` never assigned.
- **Decision**: written against the live board's guide v114 `group` section (`by: label` needs `kind`; `kind: priority` reads as priority).
- **Decision**: no script, no smoke case; FAIL-BEFORE is the rule's `grep` on the merge-base, then `tests/check-sizes.sh` failing until README is updated.
