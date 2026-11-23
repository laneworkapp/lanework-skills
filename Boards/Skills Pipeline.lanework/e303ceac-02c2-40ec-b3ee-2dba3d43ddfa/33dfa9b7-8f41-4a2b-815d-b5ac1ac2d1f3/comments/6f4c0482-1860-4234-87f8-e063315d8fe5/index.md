---
schema: 1
kind: comment
created:  {at: 2026-11-23T22:53:43Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T22:53:43Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done: plan ticket dependencies are `depends-on` relations, on main.**

- **Write**: `file-ticket.sh --depends` writes one relation per dependency inside the new ticket, before the single move. No body list is written.
- **Read**: `frontier.sh` and `resolve-ticket.sh` read relations only. A ticket with two dependencies unblocks when both resolve. Old body lists are ignored, with a hint on a Blocked ticket that has no relation.
- **Gate**: `--depends` is refused on a board whose guide predates relations or carries no stamp.
- **Shared**: `file-record.sh` writes `supersedes` through the same helper, with identical bytes.
- **Evidence**: full smoke on the rebased tree: 418 passed. Independent review: approved with nits, on a throwaway board.
- **Changed output, found in review**: `frontier.sh` now prints the full link for a missing dependency, where it printed 8 characters of the id.
- **Review nits not fixed**, since you ruled to remove `plan` for now. They matter if it returns: relation folders not named by a uuid are read though the app ignores them, an inline YAML comment after `rel` or `to` hides a dependency, and a self-dependency or a duplicate is not flagged.
- **Commits on main:** `9dcad683`, `b1ec2333`.
- **CHANGELOG:** Plan tickets now record what they depend on as relations, so the app shows each dependency as a link between cards.
