---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:41:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:41:57Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Correction: smoke was not green when this fix landed. It printed 19 ok lines, then exited 1 at its last step.**

**Evidence**: the last step, `claude plugin validate --strict`, has been failing on main for an unrelated reason, filed as [4cd77231](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4cd77231-61ec-4f07-a674-9873463a8205). The earlier "19 of 19" read `tail`'s exit status, not smoke's. The lane-body check itself passed, and it still fails on the old script.
