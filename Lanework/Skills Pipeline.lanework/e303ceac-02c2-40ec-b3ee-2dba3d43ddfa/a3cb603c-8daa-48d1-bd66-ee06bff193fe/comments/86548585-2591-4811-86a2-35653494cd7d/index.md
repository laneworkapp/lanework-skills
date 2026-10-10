---
schema: 1
kind: comment
created:  {at: 2026-10-10T03:01:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T03:01:00Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main as `8e859be`: smoke now fails whenever README § Sizes disagrees with `wc -w`, naming the row and the right number.**

- **What**: `tests/check-sizes.sh [<repo root>]` (new), smoke case 62 calling it, the README refresh (`lead.md` 977, `work` total 6,294), and `CLAUDE.md`'s tests row and Verified line.
- **Evidence**: `bash tests/smoke.sh` on main at `8e859be`, `CLAUDE_MODEL` unset, printed `ok 62 - README sizes match wc -w, rows, totals and summary` and `smoke: 66 passed`, exit 0. The standard review approved with 0 BLOCKING after reproducing all three breakages under bash 3.2.
- **Merge**: rebased over the v83 stamp bump (`fa797dd`). One conflict in `CLAUDE.md` was resolved by keeping both edits: main's v83 stamp and this branch's `check-sizes.sh` mention. After the rebase, `check-sizes.sh` reported 47 rows, 0 wrong.
- **Different from the body**: only 1 of 47 rows was stale at build time, not 9 of 45. Main had already refreshed the rest.
- **Accepted limitation**: the parser relies on the README table shapes, but a format change fails loudly. The review's one note: `set -- $sl` reuses the positional parameters, harmless today.
- **Heads-up**: any card that edits a skill file now refreshes README § Sizes in the same branch. [2191c5bc](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2191c5bc-0bca-4246-a0a9-058b866632e6)'s lead knows.
- **Ships**: with the next release.
