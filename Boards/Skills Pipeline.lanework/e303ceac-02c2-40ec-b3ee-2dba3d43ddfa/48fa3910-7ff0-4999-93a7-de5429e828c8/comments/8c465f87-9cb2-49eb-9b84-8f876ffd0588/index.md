---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:36:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:36:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main (head `48cf882`): `watch-boards.sh --skills <root>` emits `SKILLS CHANGED` when a rule file changes, live and across a restart. `events.md` item 8 has the watch re-read its rules and re-run the arming pass.**

- **Evidence**: `bash tests/smoke.sh` on main at `48cf882`, `CLAUDE_MODEL` unset, printed `smoke: 92 passed`, exit 0. `tests/check-sizes.sh` printed 48 rows, 0 wrong. The adversarial review approved in round 2. Output without `--skills` is byte-identical to `bca7ced` on comment posts, card moves and BULK, run side by side twice.
- **Found in review, fixed before merge**: per-skill symlink installs, this repo's documented install, fired nothing. Each skill folder is now resolved through its link, and a root with no `watch/SKILL.md` exits 2. Covered by smoke 44 to 46.
- **Scope, ask default applied**: B. Symlinked and in-place installs only. Plugin installs re-read on a new `/watch`, as `arming.md` says. Answering A on the ask opens a follow-up card for following the newest cache version.
- **Accepted limitations**: a skill symlink re-pointed mid-watch is seen only at the next board change or re-arm. Two watchers sharing one state path split the event, and that setup was already unsupported.
- **Ships**: with the next release.
