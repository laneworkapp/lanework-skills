---
schema: 1
kind: comment
in-reply-to: 3a264639-668d-4b6a-b5b5-de64420b074f
created:  {at: 2026-11-12T02:06:43Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T02:06:43Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Verdict: APPROVE.** The re-check finds the round-2 finding fixed at `4ba0186`. No blocking findings, 1 note.

- **Round**: lead-ruled re-check. Scope: the round-2 finding, plus the diff since `89be02d`. Outside the board, that diff is only `lib.sh` (+25/−7) and `tests/smoke.sh` (+15). README is untouched.

**Blocking**: none.

**Notes**

1. `lib.sh @ 4ba0186` "named(n, t)": a lane default in a retired spelling whose value is a bare number is skipped silently. Examples: `{value: 2026, kind: {type: area}}`, or `{text: x, kind: 2026}`. Only `text`, `kind.type` and `kind.text` take the typed read. The guide no longer reads either spelling, so this is cosmetic.

**Checked**

- **Finding**: I ran my rank scenario through `file-ticket.sh` on a founded plan board. The card now gets `rank: 5` and `rank: 2` as integers (at `89be02d` they were `"5"` and `"2"`). The card validates with 0 failures and 0 deprecated. Neither heal repairs the card; their one repair is on the lane line I wrote by hand, over 120 characters.
- **Edge cases**:
  - `{text: 2026, rank: 3, kind: {type: epic}}` gives text `"2026"` and integer rank 3. A float rank 1.5 stays 1.5.
  - `single: true` inside a default's kind is not stamped, as the guide says.
  - `kind: {type: 7, text: 1.0}` keeps `"7"` and `"1.0"`. Block form with `text: 2026, rank: 7` gives text `"2026"` and rank 7.
  - `null` items are skipped, and `0x1F` stays as typed.
- **Earlier reproductions**: `[v1, 2026, 1.10, true, "2027"]` gives five labels as typed. `labels: 2026` and `labels: true` each give one free label.
- **Swap scope**: `hb.scalar` is swapped only inside `read_lane`, and a `finally` puts it back. The board file and the staged card are parsed after that, with the parser's own reader.
- **Pairing**: the two reads differ only in scalar leaves, so their shapes always match. `named()` pairs items by position only when both reads are lists of the same length, else it keeps the parser's value. It cannot pair the wrong items.
- **Mutants**:
  - With the `have` check off, the `seen` check off, or both, the case-insensitive case fails.
  - With `89be02d`'s `lib.sh`, the new rank case fails.
  - With the typed read disabled, the typed-scalar case fails.
  - The branch passes all 8 cases of its card-defaults block in a scoped runner.
- **Conduct**: no `__pycache__` under `skills/`.
