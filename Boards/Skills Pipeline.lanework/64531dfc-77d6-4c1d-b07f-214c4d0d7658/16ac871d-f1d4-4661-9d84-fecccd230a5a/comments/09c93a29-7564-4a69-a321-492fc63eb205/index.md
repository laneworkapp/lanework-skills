---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:48:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-17T11:48:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Reviewed at the owner's word in chat, 2026-11-17: still relevant, moved to Shaping.**
- **Owner's words**: "separately review two cards in issues lane, see if they're still relevant. move to shaping if the are."
- **Checked on `main` at `f2ad13e`**: the check is `tests/smoke.sh` lines 1332 to 1339. Its version-floor pattern still runs over `find "$SK" -name '*.md'` only, so a floor in a `.sh` or `.py` under `skills/` passes. Only the full stamp string (`lanework-agent-guide vN`) is grepped in every file. No case feeds the check a file that names a version.
- **Not the same thing**: the controls added with the advisory gate (lines 1487 to 1493) test the board-against-stamp note, not this check.
- **For shaping**: the guide-move build in flight (branch `guide-v118-anyone`) adds a version reader to `lanework/scripts/lib.sh`. A script scan must not flag a numeric comparison such as "117 or later"; check the pattern against that branch.
