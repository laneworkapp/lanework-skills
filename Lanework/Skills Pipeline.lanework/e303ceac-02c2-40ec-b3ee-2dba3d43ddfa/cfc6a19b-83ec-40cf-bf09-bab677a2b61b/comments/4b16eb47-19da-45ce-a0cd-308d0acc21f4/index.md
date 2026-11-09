---
schema: 1
kind: comment
created:  {at: 2026-11-09T08:23:17Z, by: {name: fixer, kind: agent, model: opus-5.5, session: "fe00d484 fixer", role: fixer}}
modified: {at: 2026-11-09T08:23:17Z, by: {name: fixer, kind: agent, model: opus-5.5, session: "fe00d484 fixer", role: fixer}}
---
**Filed and started by the fixer on [Relations 2](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/fe00d484-a737-4bec-9c46-2c92ff578ba2): the Lanework format gained relation files, and the merge driver is one of the places that card carries them through.**

- **Decided**: same terms as a comment, as the Relations 2 START record rules. The later `modified` wins every key. The losing body goes in the card's merge comment. A relation has no title, so no title row.
- **Decided**: the trashed form `relations/.trash/<uuid>/index.md` merges as a relation too, on the card's say-so ("and its `.trash` form").
- **Accepted limitation**: when `rel` or `to` changes on both sides, the earlier value goes silently to the later side, as any non-title key on a comment does today.
- **Branch**: `card/cfc6a19b-relation-merge`. The Relations 2 lead lands it after review. No plugin version bump and no release.
