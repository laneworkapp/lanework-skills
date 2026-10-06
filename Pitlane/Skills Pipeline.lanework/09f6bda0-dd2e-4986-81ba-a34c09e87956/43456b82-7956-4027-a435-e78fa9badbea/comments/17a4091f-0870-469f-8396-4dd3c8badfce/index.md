---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:40:51Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T22:40:51Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**FAIL-BEFORE and verification for `pointer-audit`.**

**Smoke check added** (`tests/smoke.sh`, "no skill prescribes priority: or component: as a card key"): greps `skills/` for a `priority:`/`component:` key with a value, or a "root key" claim naming them, ignoring lines that say "reserved".
**Fail-before** (skills tree identical to merge-base 3908fde, new check only): `a skill prescribes priority/component as a card key ... skills/lanework/references/writes.md:10:- **Priority, component = root keys, never `labels` entries**: `priority: {text: "Medium", rank: 2}`...`, exit 1 at step 19.
**After** (264b6ca): `ok 19 - no skill prescribes priority: or component: as a card key`.
**Gate**: `tests/smoke.sh` stops at the last step, `claude plugin validate . --strict`, on a warning that `CLAUDE.md` at the plugin root is not loaded. Same failure at 3908fde, so it predates this card (installed CLI newer than the repo). With that one command shimmed to exit 0: `smoke: 21 passed`.
