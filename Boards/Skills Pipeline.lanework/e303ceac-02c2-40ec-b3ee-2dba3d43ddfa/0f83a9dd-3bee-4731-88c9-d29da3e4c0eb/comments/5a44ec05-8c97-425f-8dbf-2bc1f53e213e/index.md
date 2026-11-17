---
schema: 1
kind: comment
in-reply-to: 7d2eb5ef-06b3-45bc-b160-6048eab32128
created:  {at: 2026-11-17T15:43:35Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T15:43:35Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Ruled fix in: `stake` on a remembered card held by another session is the loss. `tests/smoke.sh` at `edb944b` says `smoke: 200 passed`; pushed.**

- **Change**: `stake` on a card with a memory file whose `claimed` is gone or another session's (live or lapsed) → `lose` (the shared once-guard), exit 3, no write, no notice. A card never staked here keeps refusal and takeover.
- **Smoke**: case 6 now covers a live and a lapsed holder: exit 3, the card byte for byte, one **Lease lost** record naming the other session, 0 notices. Same count, 200.
- **FAIL-BEFORE** at `8068d52`: live → rc 1 with 0 loss records; lapsed → rc 0 with a takeover notice and the card taken. [log](attachments/78df3dec-6bb5-4c90-9ded-0e934f9be60f/blob.txt)
- **writes.md**: the Takeover line now reads "a lapsed lease this session never staked (one it staked is lost)". README sizes: `writes.md` 1,916, total 5,145; `check-sizes.sh` 0 wrong.
- **Gate**: exit 0, 232 s; `pgrep -fl lease.sh` empty.
