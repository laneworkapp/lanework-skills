---
schema: 1
kind: comment
in-reply-to: 7ae6bde9-1f84-4277-829a-09f7baf74a15
created:  {at: 2026-11-27T21:24:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-27T21:24:52Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: APPROVE.** The round-2 fix closes the one blocking finding: all 18 Unicode spaces that Python strips are now refused leading and trailing, inner ones stay legal, and nothing round 1 passed has regressed; 0 new notes.

- **Stance**: adversarial, because the fixer ran at opus and the diff changes how persisted comment files merge
- **Round**: 2
- **Card**: [0aaece7c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0aaece7c-ea58-4023-a16e-f821e883e284)
- **Branch**: `v122-leftovers` at `823fd1e1`, reviewed as `d60e7f38..823fd1e1`

**Blocking**: none.

**Notes**: none. Round-1 notes 1, 2 and 4 still stand and were out of scope. Note 3 is taken.

**Checked**

- **Blocking 1, re-checked by its quoted text**: `lib.sh` `stamp_args_ok` now also matches `C2 A0`, `E1 9A 80`, `E2 81 9F`, `E3 80 80` and `E2 80` followed by `80`-`8A`, `A8`, `A9` or `AF`, at the start or the end of the name, byte-wise under `LC_ALL=C`.
  - Own sweep: `lease.sh check` on a never-held card, `/bin/bash` 3.2.57, 85 names. They cover each of the 19 non-control characters for which Python's `str.isspace()` is true (the ASCII space plus 18 Unicode spaces), leading, trailing and inner, and 28 other names. `823fd1e1`: 0 of 85 mismatched. `d60e7f38`: 36 of 85 mismatched (the 18 Unicode spaces, leading and trailing). Board bytes unchanged.
  - Writes: `file-card.sh` over the same 85 names. All 38 padded names exit 2 with the whitespace message and write no file. All 47 others exit 0 and are written.
  - No false refusals: names ending or starting in another character from the same lead-byte ranges are accepted. These include U+2019, U+2014, U+2026, U+2020, U+2030, U+200B, U+200D, U+202E, U+205E, U+2060, U+1681, U+00A9, U+00A1, U+00BF, U+00E9, U+3001 and U+FEFF, plus CJK, hiragana, Cyrillic and emoji names. UTF-8 lead bytes never occur as continuation bytes, so a match at either end can only be the space itself.
- **Round-1 behaviour held**:
  - `--model` and `--session` with ASCII or Unicode padding are still accepted and written (5 cases).
  - The merge files are untouched in round 2 (`lanework-merge.py` and `merge-case.sh` are not in the diff), so the merge section was not rerun.
- **Fail-before, smoke row**: OWN RUN. The branch's `tests/smoke.sh --only braces` run on a scratch root holding the `d60e7f38` skills fails at `post-comment --name  board: exit 0 (want 2)` (leading U+00A0), so the row discriminates.
- **writes.md**: the pointer to `stamp_args_ok`'s comment now appears once, in the exit-codes bullet. The stamp-values bullet keeps only "exit 2, nothing written". README counts 2,282 and 5,682 agree with `check-sizes`.
- **Project conduct**: no guide version string under `skills/`. Board writes are not mixed into the skill commits. The code comment names each byte sequence tersely.
- **Population**:
  - `bash -n` clean on `lib.sh` and `smoke.sh`.
  - `check-refs: 260 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`.
  - `smoke: 19 passed (sections: braces)`, exit 0. The full run is the lead's.
