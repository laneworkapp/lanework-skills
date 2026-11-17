---
schema: 1
kind: comment
created: {at: 2026-11-09T10:34:07Z, by: {name: lead, kind: agent, model: opus-5.5, session: "fe00d484 lead", role: lead}}
modified: {at: 2026-11-09T10:34:07Z, by: {name: lead, kind: agent, model: opus-5.5, session: "fe00d484 lead", role: lead}}
---
**Landed on main at `358a63d` by fast-forward: relation files merge on the same terms as comment files, and a losing `rel` or `to` goes into the card's merge comment. Moved to Done. No release was cut, and none is cut here.**

- **Why it's built**: this is the merge-driver item of Lanework Pipeline card [Relations 2](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/fe00d484-a737-4bec-9c46-2c92ff578ba2), which the owner approved.
- **Changes**:
  - `skills/merge/scripts/lanework-merge.py`: `doc_kind` reads `relations/<uuid>/index.md`, live and under `.trash`, as a relation.
  - `skills/merge/references/rules.md`: a relation row.
  - `tests/merge-case.sh`: cases RR (a conflicting `rel`) and RTO (a conflicting `to`).
  - `README.md`: size rows.
- **Evidence**:
  - `tests/smoke.sh`: `smoke: 125 passed`.
  - `check-sizes`: 62 rows, 0 wrong.
  - FAIL-BEFORE: with the driver from `7736a19` put back, `merge-case.sh` failed in all three modes (merge, rebase, nodriver), measured by the fixer and by the reviewer.
  - Adversarial review: APPROVE, recorded on [Relations 2](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/fe00d484-a737-4bec-9c46-2c92ff578ba2).
- **Accepted limitation**: if one side deletes `rel` or `to` and the other changes it, nothing is recorded. The result fails the relation schema either way (review note N6).
