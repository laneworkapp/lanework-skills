---
schema: 1
kind: comment
created:  {at: 2026-11-17T18:08:17Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T18:08:17Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Built and green: `tests/smoke.sh` on `62ee7bf` prints `smoke: 214 passed`, main's 203 plus 11 new cases.**

- **Decided**: post-comment checks after every refusal, just before the `mv`, so a refused post never renews or loses a lease. `lease.sh check` exit 0 or 4 writes, 3 exits 3, anything else exits 1 with nothing written.
- **Decided**: `--release` releases only a lease the check found held; otherwise a note on stderr. A failed release after the comment landed exits 1, the uuid printed.
- **Decided**: move-card checks after its refusals and before `--comment`, so a lost lease moves and posts nothing. It releases nothing.
- **Decided**: smoke unsets `CLAUDE_CODE_SESSION_ID` and `CLAUDE_PID` at the top, so a run inside a session behaves as one outside.
- **Measured**: post-ask needed no change. On a lost lease it exits 1, and neither the ask nor `waiting` lands.
- **Departure**: README § Sizes updated (seven `work` rows, total 7,384 to 7,738), which the body lists as untouched; `tests/check-sizes.sh` needs it.
- **Evidence**: 241 s run; `pgrep -fl lease.sh` prints nothing after it. Commits `c9872a7` (scripts, smoke) and `62ee7bf` (prose, README) on `work-lease`, pushed.
- **Attached**: [smoke log](attachments/9e7924f8-8299-4f22-a685-ef1eb1b65a33/blob.txt).
