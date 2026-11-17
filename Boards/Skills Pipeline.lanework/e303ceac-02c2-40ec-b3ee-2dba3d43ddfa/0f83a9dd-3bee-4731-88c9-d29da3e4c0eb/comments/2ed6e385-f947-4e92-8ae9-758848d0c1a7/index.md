---
schema: 1
kind: comment
in-reply-to: 3f2417d7-87b2-457e-8043-f4fc85e9e406
created:  {at: 2026-11-17T15:36:33Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T15:36:33Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Round 1 fixes in as ruled: `tests/smoke.sh` at `8068d52` says `smoke: 200 passed` (198 + 2 new cases); pushed.**

- **Blocking 1**: the triple-brace guard reads the front matter only (`frontmatter_of`). New case 5b: a `}}}` body is staked, renewed, checked (lapsed, renewed) and released, the body byte for byte.
- **Question 1**: `stake` on a remembered card whose `claimed` is gone → one **Lease lost** record (`session none does`), exit 3, no write. Added to case 6.
- **Question 2**: `renew` with nothing to renew stays exit 1; `writes.md` § Lease: 1 = held by another, backed off, or nothing to renew.
- **Note 1**: `mkdir -p` for the comments folder (the only place). `lose()` takes the `.lost` mark back when the record fails to land, and writes `state=lost` only after it lands.
- **Note 2**: new case 6b: the timer and six concurrent `check` calls on one loss → exactly one record. On a copy with the once-guard removed it fails 5 of 5 runs (2, 4, 6, 6, 4 records). [log](attachments/ad3f9ba5-f31a-43f5-aa2d-bfd0a5671241/blob.txt)
- **Note 3**: a `claimed` with no `until` is staked over with **Lease ignored** (`until none`). Added to case 7.
- **Note 5**: `git --no-optional-locks status`. Not covered by a test (reasoned).
- **Note 6**: `is_timer` matches `lease.sh _timer <board> <card-uuid> ` (`ps -ww`). Case 9c plants A's timer pid in B's memory file, releases B, and checks that A's timer lives.
- **Note 9**: `list` row: uuid, holder, minutes, state, title last. The script header was updated; `writes.md` never stated the format.
- **FAIL-BEFORE** at `112c236` (assertions made non-fatal): `}}}` stake and renew rc 1, check rc 1; claimed-gone stake rc 0 and check `held`, 0 records; no-until 0 ignored records; release of B stopped A's timer; all four list rows were in the old order. The race case passed there: the guard was already present, and the mutant is its discriminating run. [log](attachments/0c9622df-d42e-44e6-af9d-83545619099a/blob.txt)
- **Gate**: 200 `ok`, exit 0, 229 s; `pgrep -fl lease.sh` empty. README § Sizes: `writes.md` 1,907, total 5,136; `check-sizes.sh` 0 wrong. [log](attachments/b89b3c37-51d4-4e4c-8680-4f51a1bd1d1a/blob.txt)
- **Left as is (outside the ruling)**: `stake` on a remembered card now held live by another session still exits 1 with no loss record, while `check` there says `lost`.
