---
schema: 1
kind: comment
created:  {at: 2026-11-14T22:14:13Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: 09fa38c2-61ab-4568-a9bb-3a74bc986220
---
**Advisory works, and it differs from the body's recommendation in one place: whether `release.sh` refuses or only warns.**

- **The owner, 2026-11-14, on this card**: "perhaps we soften the role of agent guide version and just let it be advisory rather than gating?"
- **Advisory, concretely**: the stamp line stays as the record of which guide the skills were last read against. Smoke prints one note when the board's guide is ahead and stays green. `release.sh` prints the same warning, with both versions, and goes on. Nothing fails on a version number.
- **What is given up**: a release can ship unread against a newer guide. From the table above, that risks the three silent rows (who an ask reaches) and nothing that loses data.
- **What still catches drift**: the watch files a "Skills target agent guide vN" card when the guide's line 1 changes; the smoke cases written at each catch-up; the validator; and the warning shown to the person cutting the release, who is the owner.
- **Assessment**: the release is already the owner's call, so a refusal there mostly repeats a decision the owner is making in front of the warning. Advisory is sound if the silent rows keep their smoke cases, and the `anyone` sweep row gets one with [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8).
- **Where it could bite**: a release cut by an agent on the owner's word, where nobody reads the warning. The dry run printing it first covers most of that.
- **Body**: unchanged until the route is picked. Under advisory, the `release.sh` row becomes a warning, and done-when drops "cannot cut a release".
