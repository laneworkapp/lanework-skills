---
schema: 1
kind: comment
in-reply-to: ab838487-d1cf-4e04-8a23-602ee1c98577
created:  {at: 2026-11-12T01:58:16Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:58:16Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding. The round-1 finding is fixed for bare names, but the fix has its own version of the defect: the swapped scalar reader also turns a kinded default's numeric `rank` into a string on the card. 4 notes.

- **Stance**: adversarial (writes persisted card frontmatter; deviations from the card body after Phase-1)
- **Round**: 2
- **Card**: [Filing scripts: union the lane's card-defaults labels into new cards](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/032b563c-0f1b-4229-a245-fbe6ab1435a7)
- **Branch**: `card-defaults-032b563c` at `89be02d`. Its skills and tests match `7d4a1c9`; the only difference is 3 board files from the rebase on `a7c1cf2`.

**Blocking**

1. `skills/lanework/scripts/lib.sh:131 @ 89be02d` "hb.scalar = typed": the swap covers the whole `card-defaults` read, not just bare names and `text`. Every number and boolean in the lane value comes back as a string, the numeric keys of a kinded entry included. Failure: a Frontier lane with `card-defaults: {labels: [{text: Critical, rank: 5, kind: {type: priority}}, {text: Odd, rank: 2, kind: {type: epic}}]}` (an unlisted value of a closed kind, and a kind the board doesn't define). Through `file-ticket.sh`, the card gets `rank: "5"` and `rank: "2"`. At `6b1bf92` it got `rank: 5` and `rank: 2` (run, evidence § 4). That breaks the card body's "kept as written" and the guide's "`rank` — the number". The board's validator (lenient-integer) and both heals accept it, so nothing would ever flag it. This is the fixed defect showing up again inside its own fix (E12). Fix: keep the plain read for structure. Use the typed read only where a label name is meant: a scalar item of `labels`, the lone-name scalar, and an entry's `text` (and `kind.type`). Add a smoke case with a kinded default carrying `rank: 5` that asserts an integer on the card.

**Notes**

1. `lib.sh:126 @ 89be02d` "_scalar = hb.scalar": the swap relies on two private names in `heal-board.py` (`scalar`, `Plain`) and on the parser looking `scalar` up as a module global. That is covered, though. A rename crashes every filing, so smoke goes red everywhere. If the parser stopped calling the global, the swap would silently do nothing and case 6 would fail on `1.10`. A one-line comment in `heal-board.py` at `def scalar` would warn whoever edits it.
2. Swap leak, checked and clean: the swap is reverted before the board file and the staged card are parsed. The only other way out of the swapped read is the exception handler, which calls `die`, so the process ends there. Nothing else parses in that window.
3. Other typed scalars, checked: `0x1F`, `1e3`, `-5`, `+1`, `.5`, `yes`, `no`, `False`, `2026-11-12` and a quoted `"true"` all come out as typed text. `null` and `~` are skipped, and `labels: null` leaves the file untouched (run, evidence § 3).
4. Lead-directed items, done. `writes.md:34` now reads cleanly. The `lib.sh` comment states the exit-1 ruling. The attachment on 710c1d9a is now `attachments/84dca7a0…/index.md` + `blob.txt`, and the board validator reports "retired flat attachments 0".

**Checked**

- **Correctness vs done-when**: I re-ran both round-1 reproductions. `[v1, 2026, 1.10, true, "2027"]` gives five free labels as typed, and `labels: 2026` is one free label with exit 0. Block form keeps `1.10` too. Everything I passed in round 1 is unchanged in the diff since `6b1bf92`, apart from the new reader.
- **Project conduct**: `python3 -B`, and no `__pycache__` under `skills/` after every run. check-sizes: 62 rows, 0 wrong. check-refs: 251 references, 0 missing (run on a `git archive` of `89be02d`).
- **Both paths**: the reader change sits inside the helper, so all three callers get it. The board and the staged card are still read with the plain reader.
- **Fail-before**: OWN RUN agreed with the fixer's 7b102617. With the round-1 `lib.sh`, the new typed-scalar case fails on "not read as typed", with the card holding only `v1` and `2027`.
- **Test adequacy**: the two new cases follow case 5 in the same block. Mutants with the `have` check off, the `seen` check off, and both off each fail the case-insensitive case, on "a default equal to the card's own free label … was added" and/or "case-variants not merged" (run, evidence § 2). No case covers a numeric key inside a kinded default, which is the blocking gap.
- **Blast radius**: compared with `6b1bf92`, the branch's own diff adds the reader swap (+7 lines in `lib.sh`), the reworded `writes.md` clause, README § Sizes (+4 words) and two smoke cases. The `arm-pass` block in `git diff 6b1bf92 89be02d` comes from main.
- **Population**: 7 of 7 scoped cases ok. 4 of 4 mutants caught. 16 typed-scalar inputs and 2 end-to-end filings.

**Hypotheses**, written before reading [7b102617](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/032b563c-0f1b-4229-a245-fbe6ab1435a7). 1 of 4 held.

1. The swap leaks into the board or staged-card parse: refuted (note 2).
2. The swap isn't reverted on an error path: refuted, because every error path ends the process.
3. The swap reaches non-text scalars inside the lane value: held (blocking 1).
4. The new tests don't tell a right answer from a wrong one: refuted, since 4 of 4 mutants fail.

- **Attached**: [round-2 evidence](attachments/ff82f076-fc1c-4b82-acbb-39482a2a94d8/blob.txt): the scoped run, the mutants, the typed-scalar inputs and the rank comparison.
