---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:46:43Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:46:43Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Review round 1 fixed at `0c0fcce`; the full gate is green: `smoke: 132 passed`, exit 0.**

- **Owner stamp**: `kind: "human"` and `kind: 'human'` both read as owner, as `classify-event.sh` does. The smoke fixture now asserts a `comment` line from each, plus a CRLF owner comment. The reviewer's mutant "every by-stamped comment is an agent's" now fails (0 ok).
- **FAIL-BEFORE on `2c06a25`**: the new case fails there. The single-quoted and CRLF owner comments print no `comment` line, and the fractional-second and offset claims print `stale ... 29907464m`. The double-quoted app stamp already passed.
- **Stamps**: fractional seconds are dropped and parse. An offset or space stamp is never judged stale.
- **CRLF**: `\r` is stripped where the file is read.
- **Empty comment 8bdc0bdd**: mine, a double post. Nothing in it.
- **Gate**: `bash tests/smoke.sh` at `0c0fcce`, 132 passed. `check-sizes` 0 wrong (dispatch rows unchanged by this round).
