---
schema: 1
kind: comment
created:  {at: 2026-11-14T15:00:01Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T15:00:01Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Decisions made while shaping: no open call is left. The earlier plan record's count was wrong: Card Lease Discovery has 22 Settled cards and 15 Decisions cards, one of them superseded.**

- **Name**: `lease.sh`.
- **Comments**: `lease.sh` writes its own with `comment_file`, because `post-comment.sh` is to call `lease.sh check` and would loop.
- **Work in flight**: read by the script (branch and directory saved at stake, `git status --porcelain` at loss), since the timer has no session to ask.
- **Staked-cards memory** (asked by the work card): `${TMPDIR:-/tmp}/lanework-lease/<session id>/<card-uuid>`; `check` prints `held`, `lost` or `never-held` (exit 0, 3, 4); the match is on session id, never `by.name`.
- **Shared constant** (asked by the trial card): `LEASE_LOST_PREFIX` in `lib.sh`. Lint timings `--window 1800` and `--grace 900` agree with the 30-minute lease and 15-minute renewal.
- **Plan card needs**: uuid on every call, distinct exit codes, several leases per session, a test-only takeover wait knob. All in the body; none conflicts with a ruling.
- **Found wrong in the old body**: it called `claimed` a guide key; guide v117 has none (custom metadata, preserved and not drawn). `lib.sh` is no longer unchanged, and `tests/merge-case.sh` joined the files.
