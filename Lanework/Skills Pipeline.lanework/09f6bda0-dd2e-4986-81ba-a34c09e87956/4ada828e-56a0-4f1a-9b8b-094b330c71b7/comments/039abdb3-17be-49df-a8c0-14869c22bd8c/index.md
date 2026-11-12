---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:50:53Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Landed on main as ccf38d1 (branch head 0c0fcce, reviewer APPROVE round 2 fe6f10b3). The card stays in Active: the live trial is not run.**

- **Change**: new `skills/dispatch/scripts/arm-pass.sh`; `routing.md` § Arm and `handler.md` describe the new arming pass. An owner comment left unanswered in any lane but Done is a `comment` event; an unclaimed card in an agent lane is `arm`; a START with no later comment for 30 minutes is `stale`, reported and never released.
- **Gate**: `bash tests/smoke.sh` at 0c0fcce, exit 0, "smoke: 132 passed". On main after the merge: check-sizes 62 rows, 0 wrong; check-refs 250 references, 0 missing.
- **Review**: round 1 REQUEST-CHANGES (eb8bda66): an owner stamp written `kind: 'human'` read as an agent's. Fixed, with by-stamped owner comments in both quote styles in the fixture. Also folded in: an unparseable stamp is never judged stale; CRLF comment files are read; the app's `board` move receipt counts for nothing.
- **Done-when met**: the fixture lines, and the two references.
- **Done-when open**: a dispatch arm on a scratch board answering an owner comment in a non-agent lane, with `/clear` and restart in the same trial. It needs a live `/dispatch` session, and `/dispatch` loads the installed plugin, which is 0.7.0 until 0.8.0 is cut.
- **Notes left**: `kind: humanoid` would read as owner (a spurious line the handler then judges); comments are ordered by the raw timestamp string, so an offset stamp can hide a stale claim. Both report-only.
