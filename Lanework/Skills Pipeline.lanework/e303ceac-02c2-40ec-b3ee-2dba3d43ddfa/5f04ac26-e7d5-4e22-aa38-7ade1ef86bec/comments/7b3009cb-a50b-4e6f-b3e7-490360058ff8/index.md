---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:10:10Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T12:10:10Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Review round 1 fixed in `26a00b7`: the discovery `topic` var is flattened, and a title blank once flattened exits 2. Smoke 85 passed.**

- **Evidence**: rebased onto origin/main; `env -u CLAUDE_MODEL bash tests/smoke.sh` ends `smoke: 85 passed`, exit 0; `tests/check-sizes.sh`: `48 rows, 0 wrong`.
- **Cases**: the heading loop asserts one `Discovery on <topic>:` line; a `Evil\n## X` title opens no body section through either script; blank titles (LF, spaces, CRLF) exit 2 with no board.
- **Mutation** (scratch copies, both red): raw `topic` gives "discovery topic line split by a line break"; dropping the blank guard gives "blank title: rc=0".
- **Checked**: no other template var is fed from the title (`project` and `verified` are caller vars).
