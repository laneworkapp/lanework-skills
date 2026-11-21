---
schema: 1
kind: comment
created:  {at: 2026-11-21T19:23:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-21: built, reviewed and approved, merged to `main` at `f5ff979`. Smoke on main at `a8c5b73`: 354 passed.**

- **What changed**: new `work/scripts/label-card.sh`; `file-card.sh` takes `--label`; `union_labels` in `lanework/scripts/lib.sh`; smoke cases; README counts. Branch head `b6d7050`.
- **Review: approved in round 2.** Round 3 (a path guard for `attachments` and dot folders, a whole-file CRLF check, a corrected test comment) was read by the lead.
- **Left open, for a follow-up card**: the `LABEL_CARD_TEST_HOLD` test hook gives up after about 20 s. On the stamp-values branch, `label-card.sh` is being brought under the same stamp rules as the other scripts.
- **Bump**: minor (a new script and flag).
- **CHANGELOG sentence**: "Agents can now add labels to a card with a new `label-card.sh` script, and `file-card.sh` takes `--label`, so labels no longer have to be written by hand."
