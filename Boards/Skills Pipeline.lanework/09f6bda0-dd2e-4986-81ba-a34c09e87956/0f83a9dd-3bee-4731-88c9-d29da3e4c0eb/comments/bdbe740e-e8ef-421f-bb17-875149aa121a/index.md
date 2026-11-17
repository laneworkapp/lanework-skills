---
schema: 1
kind: comment
in-reply-to: 5025c5a7-36e8-4f61-87c1-b3e148b5aff4
created:  {at: 2026-11-17T16:03:44Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T16:03:44Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Round 2 fixes in as ruled: `tests/smoke.sh` at `3e53310` says `smoke: 202 passed` (200 + 2 new cases); pushed.**

- **Blocking 1**: the triple-brace guard reads only the `modified:` line and the `claimed` block. New case 5c: a card with `labels: [{text: "Medium", rank: 2, kind: {type: "priority", text: "Priority", icon: {glyph: "flag"}}}]` is staked, renewed, checked (lapsed, renewed) and released. The label line is kept byte for byte and the board validates. The label is the shape real boards carry, with the kind from `templates/label-kinds.md`. The body case 5b is kept.
- **Guard control**: `stake --model 'x}}}'` still exits 1 with the card unchanged, before and after.
- **Note 1**: `post_record` returns 1 when its `mkdir -p` or `mv` fails. New case 6c: with a read-only `comments` folder, `check` exits 3, posts no record and leaves no mark. After `chmod` back, the next `check` posts exactly one record. The cleanup trap restores write permission.
- **FAIL-BEFORE** at `edb944b` (non-fatal assertions):
  - iconed label: stake, renew and check rc 1, release rc 1;
  - read-only folder: marked with no record, and after `chmod` still 0 records.

  [log](attachments/915738f4-c831-482f-82ed-dba91bc8d833/blob.txt)
- **Measured, outside this ruling**: the reviewer's unquoted example line is over 120 characters once quoted. The board heal lists it as H17, and `compact_fm` rewrites it to block form on a lease write, the heal's own repair. A quoted compact line like the one above is left as is.
- **Gate**: exit 0, 230 s; `pgrep -fl lease.sh` empty. README sizes unchanged; `check-sizes.sh` 0 wrong. [log](attachments/6b9c3f8c-a4e4-41e0-9a7a-714ea18ef59f/blob.txt)
