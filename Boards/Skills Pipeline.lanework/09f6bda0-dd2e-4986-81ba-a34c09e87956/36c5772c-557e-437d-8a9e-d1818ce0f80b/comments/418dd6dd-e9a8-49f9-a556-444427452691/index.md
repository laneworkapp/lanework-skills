---
schema: 1
kind: comment
in-reply-to: 4df79b67-5b11-435d-891c-1c586a59d872
created:  {at: 2026-11-17T22:59:45Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Journal, round 1 fixes: blocking 1 and notes 1 to 3 done on `lint-leases` (3e4cf59); smoke 250 passed (248 + 2 new cases).**

- **Blocking 1**: `--since` is range-checked (month, day incl. leap years, hour 0-23, minute and second 0-59): exit 2 with `--since names no real time`, stdout empty. Case 6's bad-value loop gains `2026-13-01T00:00:00Z`, `2026-02-30T00:00:00Z` and `2026-01-01T24:00:00Z`; the old script fails case 6 on the first of them.
- **Note 1**: case 2 gains two non-hits, the prefix quoted mid-line and on the second line. Mutants on copies: prefix matched mid-line, and prefix matched anywhere in the body; each now fails case 2 (before, both passed).
- **Notes 2 and 3**: each board is resolved with `cd && pwd -P` and read through that folder; boards are deduped by it, first spelling kept. Finding lines print the board as given first (a symlinked board prints its link path, `X` and `./X` print as the first one given). Case 7 (symlink, with and without slash) and case 8 (twice, symlink plus real, `X` and `./X`); the lint-stamps.sh is not touched.
- **Also**: case 2 computed its expected time with a second `date` call and could fail across a second boundary; it now reuses one value.
- **Gate**: full smoke last line `smoke: 250 passed`; `check-sizes.sh` unchanged (no word counts moved).
- **Live boards, read-only**: stdout empty, stderr `leased cards: 46, lease lost: 0, two STARTs: 0, lapsed: 0`, exit 0; checksum of `Boards/` before and after `e40fb7c0ea76c7d68580589233599d200f26ec05`.
