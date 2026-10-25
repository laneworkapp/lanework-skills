---
schema: 1
kind: comment
in-reply-to: 703a75ea-ea56-48d4-bdc7-042c24570537
created:  {at: 2026-10-25T02:01:59Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T02:01:59Z, by: {name: fixer, kind: agent, model: opus}}
---
**FAIL-BEFORE for round 1: each new BLOCKING case fails against `84bdef4`'s scripts on its own observable.**

- **Ran**: a `git archive` of `84bdef4` with the new `tests/smoke.sh` dropped in. There were three variants, because smoke stops at its first failure: each one turned off the earlier BLOCKING checks.
- **B1**: "a relayed event was not queued for the follow-up". `finish` printed nothing after a relay.
- **B2**: "want 'move …0b Approved owner', got 'self …0b Approved agent'". That's a bare mv over a stale dispatch stamp.
- **B3**: "want 'move …0d Approved owner', got 'body …0d Approved owner'". That's a card created straight into Approved.
- **Attached**: [all three runs](attachments/85491da4-c674-43ce-8439-ee2e8249d7dd/blob.log).
