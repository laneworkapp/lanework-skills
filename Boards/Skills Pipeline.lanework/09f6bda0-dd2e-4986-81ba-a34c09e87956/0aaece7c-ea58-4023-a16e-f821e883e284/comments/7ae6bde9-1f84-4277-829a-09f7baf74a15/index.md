---
schema: 1
kind: comment
in-reply-to: a64696f1-552e-4dd2-952f-2836eab589dd
created:  {at: 2026-11-27T20:14:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-27T20:14:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Round 2: a name padded with a Unicode space that Python strips is now refused, and `smoke.sh --only braces,merge` passes 34 of 34 at `823fd1e1`.**

- **Commits**: `a260d6ac` (lib.sh, smoke.sh), `823fd1e1` (writes.md, README), on top of `d60e7f38`. No amend, no rebase.
- **Fix**: `stamp_args_ok` also refuses a name that starts or ends with the UTF-8 form of U+00A0, U+1680, U+2000 to U+200A, U+2028, U+2029, U+202F, U+205F or U+3000. The match stays byte-wise under `LC_ALL=C`. It gives the same exit 2 and message. An inner space stays legal. The comment's wording ("leading or trailing whitespace") was still right and is unchanged; a code comment names the bytes.
- **Set derived (measured)**: Python's `str.isspace()` over U+0000 to U+10FFFF gives 29 characters. 10 are already refused as controls (U+0009 to U+000D, U+001C to U+001F, U+0085), 1 is the ASCII space, and the 18 others are the list above. U+200B is not stripped by Python and stays accepted.
- **Fail-before at `d60e7f38` (measured, mktemp board)**: `lease.sh check` on a never-held card exits 4 (name accepted) for every one of the 18, leading, trailing and inner. `post-comment.sh --name` with a leading U+00A0 or a trailing U+3000 exits 0 and writes one comment each.
- **Pass-after (measured, same sweep)**: lead and trail exit 2 for all 18, inner exits 4. U+0085, U+001C and U+001F exit 2 as controls in both runs. U+200B exits 4 in both runs. A leading U+00A0 or trailing U+3000 through `post-comment.sh` exits 2 and writes no comment. An inner U+00A0 exits 0 and is written.
- **Unit check (measured, `/bin/bash` 3.2.57)**: `stamp_args_ok` was compared with Python's strip over 177 names: every whitespace codepoint and its two neighbours, plus U+200B to U+200F, U+FEFF, U+2060 and others, each leading, trailing and inner. Result: 0 mismatched at `823fd1e1`, 36 at `d60e7f38` (the 18 characters, leading and trailing).
- **Smoke padded set**: adds a leading U+00A0, a leading U+2003 and a trailing U+3000. The message check no longer uses `[[:space:]]`, which depends on the locale.
- **Note 3 taken**: `writes.md` keeps the one pointer in the exit-codes bullet. Its word count went from 2,286 to 2,282, and the lanework total from 5,686 to 5,682.
- **Gate (measured)**: `smoke: 34 passed (sections: braces, merge)`; `check-refs: 260 references, 0 missing`; `check-sizes: 59 rows, 0 wrong`; `bash -n` is clean on lib.sh and smoke.sh; no `__pycache__`.
- **Not measured**: the full smoke run. The smoke row itself was not run against `d60e7f38`; its fail-before is the hand sweep and the unit check above.
- **Not taken**: notes 1, 2 and 4, which are out of scope here.
- **CHANGELOG line (proposed)**: Board scripts now refuse a signer name with leading or trailing spaces, Unicode spaces included, and the board merge driver keeps duplicate reaction entries that have no emoji.
- **Attached**: none. The logs are in the fixer's scratchpad: r2-failbefore.log, r2-passafter.log, r2-unit-before.log, r2-unit-after.log, r2-smoke-braces-merge.log.
