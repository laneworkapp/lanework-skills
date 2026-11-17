---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:21:23Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: numbered cards carry a `cite-as` label on boards whose guide reads v117 or later, and links use it. Not released: it ships with 0.9.0, the owner's to cut.**

- **Merge**: `12cc105` on main, from branch `cite-as` at `5c5cda9` (two commits, 27 files).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 174 passed`, exit 0. Before: 168. Added 6 cases.
- **Review**: adversarial. Round 1 request-changes, round 2 approve at `5c5cda9`.
  - Found and fixed: a leading zero was read as octal. `ADR9` with `ADR010` reissued `ADR9`; `Q08` aborted.
- **Done-when**:
  - v117+ throwaway board: `file-question.sh`, `file-record.sh`, `file-ticket.sh` write `cite-as` and a bare title, board validates clean. Met.
  - A citation is never reissued: trash (flat and in a trashed lane), legacy title prefix and padded numbers all count. Met.
  - v114 or no stamp: output byte-identical to main before the merge, stdout included. Met, measured by the reviewer with a fixed clock and fixed ids.
  - `resolve-ticket.sh` prints `unblocked T<n>`; `frontier.sh` and `read-board.sh` show the citation. Met.
  - One link-text rule, in `work/references/writing.md` § Card references; one mint rule, in `lanework/references/writes.md`. Met.
  - Smoke passes whole. Met.
- **Void row**: `skills/dispatch/templates/handler-report.md`, deleted with the dispatch skill.
- **Gap in the body**: the hand-filled topic and fact templates take the new shape on any board. Kept as the Change table asks, by lead's ruling.
- **Filed**: [nine review notes](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/1bc6f7a8-ae6c-4e2d-a226-3dfc5d6af2c6) in Issues.
