---
schema: 1
kind: card
title: "Active lane text still says a card is claimed with a comment"
order: 1024
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T15:02:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T15:02:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Once leases are built, the Active lane's owner-facing text is wrong: it says an agent claims a card "with a comment naming the session and branch", and the claim will be the lease.

**Where the sentence lives**
- `skills/lanework/templates/pipeline-lanes.md`, the Active row: the body every new pipeline board is founded with.
- `skills/heal/scripts/heal-descriptors.py`, the expected Active sentence the heal checks lane bodies against.
- Boards already founded carry the old sentence in their Active lane body. Whether the heal rewrites it or only reports it is for shaping.

**Why a separate card**
- The lease cards each stay inside one skill: [the work card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa) narrowed its done-when to `skills/work/`, and [watch and dispatch](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233) and [plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5) cover their own claim readers. These two files are covered by none of them.

**Depends on**: [the lease script](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb) and the work card, since the new sentence describes what they build.
