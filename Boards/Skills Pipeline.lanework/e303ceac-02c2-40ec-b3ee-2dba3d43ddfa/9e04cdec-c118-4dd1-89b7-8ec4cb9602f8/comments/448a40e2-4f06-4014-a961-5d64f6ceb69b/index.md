---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:10:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Done 2026-11-17: merged to main as `9439fae`, smoke green on main. Not released; cutting a release is the owner's.**

- **Evidence**: `tests/smoke.sh` on main at `9439fae`, its own line: `smoke: 164 passed`, rc 0. Case 162 reads "the stamp (lanework-agent-guide v118, lanework-schema v1) is not behind the board's guide v118 and schema v1".
- **Branch**: `guide-v118-anyone`, head `d372ef5`, five commits. Review: round 1 request changes, round 2 approve, both on this thread.
- **Done-when**: each item met, checked by the reviewer on a scratch board carrying the real v118 guide. The stamp reads v118. `file-question.sh` writes the anyone handle and `waiting.for: anyone` from guide v117 on, the board's handle below. `lint-ask.sh` checks such an ask. `anyone` is in all three reserved lists and both heal scripts refuse it.
- **Beyond the body**: the `in-reply-to` clause and the `cite-as` line in `lanework/references/writes.md`; `guide_version` falls back to `AGENTS.md`; a record quoting the anyone handle in a code span or URL is not treated as an ask; the founded-discovery fixture follows the template; smoke's plugin scan stops at the `Provides:` list the current CLI prints, without which smoke was red on main.
- **Declined**: a lint warning when an ask names the machine's own handle. A gate ask to a person looks the same.
- **Fixtures**: `tests/fixtures/app-writes/` left as it was. Fixer's judgment that v118 adds no card, lane or comment shape; the writes were not byte-compared.
- **Left for a follow-up card**: an ask addressed to a handle other than the machine's own is not linted; a board with no handle line still refuses a record quoting the anyone handle; a dead fixture at `tests/smoke.sh` line 681.
- **Changelog**: three entries under November 2026, no version line.
