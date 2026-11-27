---
schema: 1
kind: comment
created:  {at: 2026-11-27T19:21:28Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-27T19:21:28Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: a name padded with a Unicode space (no-break space, em space, ideographic space) still passes `stamp_args_ok`, so row 1's disagreement with `heal-board.py` survives the fix; 4 notes.

- **Stance**: adversarial, because the fixer ran at opus and the diff changes how persisted comment files merge
- **Round**: 1
- **Card**: [0aaece7c](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0aaece7c-ea58-4023-a16e-f821e883e284)
- **Branch**: `v122-leftovers` at `d60e7f38`

**Blocking**

1. `skills/lanework/scripts/lib.sh:200 @ d60e7f38` "case \"$1\" in [[:space:]]*|*[[:space:]])": the function runs under `local LC_ALL=C` (line 193), so `[[:space:]]` matches ASCII whitespace only. Tab, CR, VT and FF are already caught as control characters, so in practice the new check refuses only the ASCII space. Repro (own run, `/bin/bash` 3.2, throwaway board): `post-comment.sh B C --body b.md --model smoke --name $'\xc2\xa0board'` exits 0 and writes `name: " board"` with a leading U+00A0. The same goes for U+2003 and U+3000. `heal-board.py --apply --model smoke --name $'\xc2\xa0board'` exits 64 ("board is reserved"), because `canon()` uses Python's `str.strip()`, which strips Unicode whitespace. So the two guards still disagree on a padded name, which is the card's row 1 (E12). Fix: under the same byte match, also refuse a name that starts or ends with the UTF-8 forms of the spaces `str.strip()` removes (`C2 A0`, `E1 9A 80`, `E2 80 80`-`8A`, `E2 80 A8`/`A9`/`AF`, `E2 81 9F`, `E3 80 80`), and add `$'\xc2\xa0board'` to the smoke `RNS` list. U+200B is not stripped by Python, so it is not a disagreement.

**Notes**

1. `skills/lanework/scripts/found-board.sh:13 @ d60e7f38` "empty or control-character --name or --model": this header still lists two of the shared causes, and the new comment says they are "listed here only". The card ruled no header changes, so the stale partial list stays. A later card could drop those words.
2. `skills/heal/scripts/heal-descriptors.py:527 @ d60e7f38` "name.lower() in RESERVED_NAMES": no strip, so `--apply --name ' board'` is accepted there, while `heal-board.py` and now `lib.sh` refuse it. A third guard, outside this card's scope.
3. `skills/lanework/references/writes.md:13-14 @ d60e7f38`: both bullets point at the `stamp_args_ok` comment ("listed once, in `scripts/lib.sh`" and "the causes: its comment"). The list itself is in one place, so this is only a doubled pointer. One of the two could go.
4. `README.md` "Measured on" line: `discovery` (11-20) and `import` (11-26) have later Markdown edits (`33b3e99c` 11-22, `7c4ac250` 11-27), but `check-sizes` confirms their counts are unchanged, so the dates are when the counts were measured. No change needed. Recorded so nobody re-checks it.

**Checked**

- **Correctness vs done-when**:
  - `--name ' board'`, `'board '`, `' alice '`, `'   '`: exit 2, message `'<n>' has leading or trailing whitespace; sign as yourself; nothing written`, board file count unchanged (own run, `post-comment.sh`). `'Rouslan Z'` and `'a  b'` are accepted and written quoted.
  - `lease.sh check` on a never-held card: `alice` 4 and `'Rouslan Z'` 4 (control), `' board'` and `' alice '` 2, board bytes unchanged, no timer left running (own run). Founding wrappers `found-discovery-board.sh` and `found-plan-board.sh` exit 2 on `' board'` with no folder (own run).
  - Two identical no-emoji entries survive a merge where both sides changed `reactions`: `merge-case.sh reactions` exits 0, and the file keeps both carol entries plus 🎉 and 👀 (own run).
  - The `stamp_args_ok` comment lists all three causes plus empty values. `writes.md` points there. README dates for `lanework`, `watch` and `merge` match their last Markdown change (11-27).
- **Project conduct**: no guide version string under `skills/` (grep empty). Board writes are not mixed into the skill commits. The wording is telegraphic. No "assume Y" shapes. `--model` and `--session` with padding are written as before, old and new identical (own run, `file-card.sh`, 4 cases).
- **Both paths**: `stamp_args_ok` has 13 callers (grep): `post-comment`, `file-card`, `post-ask`, `label-card`, `move-card`, `file-question`, `settle-question`, `file-record`, `file-ticket`, `claim-ticket`, `resolve-ticket`, `lease`, `found-board`. All 13 are in the smoke loop. The two founding wrappers go through `found-board.sh`.
- **Fail-before**: OWN RUN agreed with FIXER RUN.
  - Padded name at `670f8b85` (extracted with `git archive`): `post-comment.sh --name ' board'` and `'board '` exit 0 and write the name. `lease.sh check --name ' board'` exits 4.
  - Merge: the branch's `tests/merge-case.sh reactions` run against the `670f8b85` driver fails with `1 of them kept (want 2)`, the card's observable.
  - The smoke lease row is discriminating: the old code returns 4 for `' alice '`, where the row wants 2.
- **Test adequacy**: the merge case sits in the existing `reactions` case of `merge-case.sh`, and the name cases are in the existing reserved-name loop of `smoke.sh`, both like their neighbours. Unit runs of `merge_reactions` over 13 three-way shapes, both `win` sides: one side removes a copy (held), both remove one (1 left), one removes both, base empty, one side adds a third copy, reorder, differing `at`, a key-order-only difference, an edited copy, non-dict entries. All give the union result. Emoji duplicates still collapse as before, which is out of scope.
- **Blast radius**: 6 files and +48/-20, as Scope lists. `writes.md`'s second bullet was changed beyond Scope, which the fixer flagged (+13 words, README updated to match).
- **Population**:
  - `bash -n` clean on the 3 changed shell files. `py_compile` clean on the driver.
  - `check-refs: 260 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`.
  - Smoke (`--only braces,merge`): `smoke: 34 passed (sections: braces, merge)`, exit 0. The full run is the lead's.

**Hypotheses**, written before reading the fixer's report (read with the thread). 3 of 9 held.

1. `[[:space:]]` under `LC_ALL=C` misses Unicode spaces that Python strips: held, blocking 1.
2. A name of only spaces slips through: refuted, exit 2.
3. An inner space ("Rouslan Z") is wrongly refused: refuted, accepted.
4. Occurrence keying mishandles a one-side removal or a reorder: refuted, 13 shapes correct.
5. Tagging changes the order of emoji entries or merges them differently: refuted, order is ours then theirs-only, as before.
6. The smoke lease row passes on old code because another usage check exits 2: refuted, old code gives 4.
7. A caller of `stamp_args_ok` is missing from the loop: refuted, 13 of 13.
8. A header still repeats the shared causes: held, note 1.
9. Another reserved-name guard disagrees: held, note 2 (`heal-descriptors.py`).
