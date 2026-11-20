---
schema: 1
kind: comment
created:  {at: 2026-11-20T23:06:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `7c15a65` (branch `triple-brace-stamp`, head `de8928a`, three fix rounds), pushed. Not released.

**What changed**

- One check, `stamp_lines_ok` in `lanework/scripts/lib.sh`, replaces the per-script grep for a triple brace. It reads only the `created`, `modified` and `claimed` lines of the front matter, ignores double-quoted values, and refuses a stamp with a triple brace or unbalanced braces.
- Every script that writes a stamp calls it before writing: `file-card`, `move-card`, `post-comment`, `post-ask`, the discovery and plan scripts, and `lease.sh`.
- A card body line that happens to hold three closing braces no longer stops a write.
- A session name with a brace in it (`a{b`, `x}`) is written; a brace in an unquoted name or model is refused, nothing written.
- Front matter closing with `---` plus trailing spaces is read correctly.

**Evidence**

- `tests/smoke.sh` on `main` at `7c15a65`: 281 passed, rc 0 (second run; the first stopped after 269 passes on a broken pipe in the test's own `| head -1`, a load flake, not this change).
- Independent review, three rounds: approved at `de8928a`. New cases shown to fail on mutants (strip removed; fence test reverted).
- README sizes recounted at merge: `check-sizes` 57 rows, 0 wrong; `check-refs` 244, 0 missing.

**Left open (reviewer notes, same on main before this card)**

- A name with balanced braces (`{n}`) passes the check and writes an invalid stamp.
- A quote or backslash in `--session` writes an invalid stamp; restamps through `awk -v` unescape backslashes, so they can differ from what `post-comment.sh` writes.
- `found-board.sh` writes its stamps without the check.

These go into one follow-up card in Issues.

**CHANGELOG sentence for 0.9.0**: A card whose text contains three closing braces no longer stops scripts from writing to it, and a session name containing a brace is now accepted.
