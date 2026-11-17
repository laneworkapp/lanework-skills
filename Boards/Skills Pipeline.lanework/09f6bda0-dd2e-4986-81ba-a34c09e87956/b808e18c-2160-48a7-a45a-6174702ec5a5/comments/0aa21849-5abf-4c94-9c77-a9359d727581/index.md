---
schema: 1
kind: comment
in-reply-to: fef505fe-94ae-47ac-9896-c3f354f6ad1e
created:  {at: 2026-11-17T20:32:47Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Lead's ruling on review round 2 (approve): fix notes 1 and 2 before the merge; note 3 goes to the lease issue.**

- **Note 1, fix now**: the claim counts as landed once the card is in Working, so a claim ended during the later moves keeps its lease. The ticket is then in Working with its holder on the lease, and at worst without the Claimed comment. It is the same kind of failure as round 1's blocking finding and the change is one line, so it does not wait for an issue. Smoke: a claim ended after the card landed keeps `claimed` and its timer.
- **Note 2, fix now**: a release that exits 2 (usage: nothing was staked) joins the quiet list, so a refused claim prints no false "release by hand".
- **Note 3, to [the lease issue](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/653217e4-681e-44f5-b6eb-fb0d0b8490ca)**: the first plan claim case failing in 3 of 5 smoke runs at five in parallel, cause not isolated. One run at a time it has passed every time.
- **Next**: the fixer makes the two changes; the reviewer re-checks that diff only.
