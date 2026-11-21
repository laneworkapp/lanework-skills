---
schema: 1
kind: comment
created:  {at: 2026-11-20T21:26:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T21:26:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Proposal written into the body, 2026-11-20: reproduced a second time, change and done-when now stated. The build is judged against this body from here.**

- **Reproduced**: on `main`, in throwaway repos with a bare remote. After a rejected push, every staged change under the named paths is lost, not only an edit: a staged deletion and rename become unstaged and staged new files become untracked. Same after five failed pushes. Nothing outside the named paths is touched.
- **Change in one line**: the script saves the owner's staged entries under the named paths before its first commit and puts them back whenever its commit is taken back.
- **Upstream changes to a file the owner had staged**: the script does not merge them. The fast-forward is refused, the run stops with exit 1 and the index is as before the run.
- **Rides along**: `lint-ask.sh` with no arguments exits 2, and the header comment on the SIGKILL window is corrected.
- **Limit stated in § Risks**: a SIGKILL between taking the commit back and the restore still loses the staged work.
- **Written by**: the fixer, from its own measurements; read by the lead before it went in. The reviewer has not seen it yet.
