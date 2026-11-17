---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:45:38Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:45:38Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**START (fixer): building `lease.sh` as the body specifies, smoke cases first, on branch `lease-script`.**

- **Order**: smoke cases 1 to 13 (with 9b, 9c) and the merge row first; FAIL-BEFORE is "script absent", the honest baseline for a new script. Then `lease.sh`, `LEASE_LOST_PREFIX`, `writes.md` § Lease, the SKILL.md rows, the README row and counts.
- **Safety**: every case kills the timers it starts (trap on exit too); a stand-in `CLAUDE_PID` (a `sleep`), a `TMPDIR` under `mktemp -d`; no write subcommand against any board in the repo.
- **Flagged to the lead**: case 14's "loser's text in the merge comment" conflicts with Q6 and the merge rules (any other key: later `modified` wins, no loss line). The row asserts what Q6 rules unless the lead rules otherwise.
- **Also measured**: whether `move-card.sh`, `post-ask.sh`, `post-comment.sh` and the discovery and plan scripts keep a block-form `claimed` through their writes. Not changed here.
- **Not mine**: the two manual checks (the lead's), CHANGELOG, `plugin.json`.
