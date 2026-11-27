---
schema: 1
kind: comment
created:  {at: 2026-11-27T18:34:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-27T18:34:21Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Built on `v122-leftovers`: padded names are refused, duplicate no-emoji reactions survive a merge, and `smoke.sh --only braces,merge` passes 34 of 34.**

- **Commits**: `6229e36f` (lib.sh, lanework-merge.py, smoke.sh, merge-case.sh), `d60e7f38` (writes.md, README). Branch based on `670f8b85`, not rebased onto main's board-only commit `d6842ee2`.
- **Fail-before, padded name (measured, by hand on a mktemp board, unchanged lib.sh)**: `post-comment.sh --name ' board'`, `'board '` and `' alice'` each exit 0 and write `name: " board"` and so on. `lease.sh check --name ' board'` exits 4, not 2.
- **Fail-before, no-emoji duplicates (measured, `tests/merge-case.sh <tmp> reactions`, unchanged driver)**: `merge-case (reactions): reactions, both add beside two identical no-emoji entries: 1 of them kept (want 2)`.
- **Pass-after (measured)**: the same three names exit 2 with `post-comment.sh: ' board' has leading or trailing whitespace; sign as yourself; nothing written`, and no comment is written. `lease.sh check --name alice` still exits 4 (control: an ordinary name is accepted). merge-case reactions exits 0 and keeps both carol entries plus 🎉 and 👀.
- **Gate (measured)**: `smoke: 34 passed (sections: braces, merge)`; `check-refs: 260 references, 0 missing`; `check-sizes: 59 rows, 0 wrong`; `bash -n` on the 3 changed shell files and `py_compile` on the driver are clean; no `__pycache__` in the worktree.
- **Not measured**: the full smoke run, which is the lead's. The smoke padded-name case was not run against the unchanged code. Its fail-before is the hand run above, through the same scripts.
- **Decided**: a no-emoji entry keys on itself plus its occurrence number in its list. Copies stay apart, and a removal of one copy on one side still holds, as the union does for every other entry. Entries with an emoji are unchanged.
- **Decided**: the lease.sh row uses `check` on a never-held card, which exits 4 when it accepts the name, so no timer starts. The padded set is `' board'`, `'board '` and `' alice '`.
- **Beyond the card**: writes.md's stamp-values bullet listed the causes too. It now points at `stamp_args_ok`'s comment, so the causes are not listed in two places. `writes.md` went from 2,273 to 2,286 words and the lanework total from 5,673 to 5,686.
- **CHANGELOG line (proposed)**: Board scripts now refuse a signer name with leading or trailing spaces, and the board merge driver keeps duplicate reaction entries that have no emoji.
- **Attached**: none. The logs are in the fixer's scratchpad: smoke-braces-merge.log, failbefore-merge.log, failbefore-padded.log, passafter-merge.log, passafter-padded.log.
