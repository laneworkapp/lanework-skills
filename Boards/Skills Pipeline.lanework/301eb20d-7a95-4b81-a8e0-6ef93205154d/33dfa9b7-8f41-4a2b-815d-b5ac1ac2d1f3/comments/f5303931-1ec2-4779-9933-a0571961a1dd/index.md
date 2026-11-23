---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:44:15Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:44:15Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: the proposal is in the body; two calls are open, each asked below.**

- **Settled by evidence**: `suspect` is out of scope. Plan never reopens or edits a Resolved ticket, so nothing can make a dependency suspect.
- **Found while shaping**: relations entered the guide at v111, and a board below it fails its own validator on any `relations/` folder. The AUP Skills Plan board is at v109, so the proposal gates the new behavior on the board's guide version.
- **Run on a throwaway board**: today a dependency added as a relation in the app is invisible to plan. `frontier.sh` reports the ticket as naming no dependency, and resolving the dependency does not unblock it.
- **Also in scope**: `discovery/scripts/file-record.sh` moves onto the one shared relation writer, with byte-identical output.
