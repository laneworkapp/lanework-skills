---
schema: 1
kind: comment
created:  {at: 2026-11-16T01:14:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**0.8.0 went out with the stamp four versions behind the board's guide: the gate did not hold the release, it moved where the release was cut.**

- **What happened**: `v0.8.0` was cut on 2026-11-16 from a fresh clone, where smoke passes, because the main checkout fails the guide-version gate. Source: the closing comment on [c5b171e1](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c5b171e1-a2de-4d0e-bdcf-1c9c707c4e2a).
- **Why a fresh clone passes**: the gate reads the working tree. The committed guide on this board is v114, equal to the stamp. The app's v118 guide is in the working tree only.
- **So today's gate is advisory already**, in effect: it blocks the checkout the app has touched and no other. The skills in 0.8.0 were not read against v117 or v118; [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) is still in Proposed.
- **Correction to the earlier record here**: it said `release.sh` "would refuse any release" on this machine. True of the main checkout only.
- **For the open call**: option B as written reads the committed guide, so it would have passed this release too. A release check that holds needs the app's guide committed first, or it reads the working tree and the fresh-clone route still gets round it.
