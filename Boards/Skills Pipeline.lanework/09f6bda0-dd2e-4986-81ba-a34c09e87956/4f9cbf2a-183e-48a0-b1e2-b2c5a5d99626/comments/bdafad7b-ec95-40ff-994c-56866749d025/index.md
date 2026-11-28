---
schema: 1
kind: comment
in-reply-to: 59e1694d-e87b-441d-910e-03cc1d20b58d
created:  {at: 2026-11-28T03:17:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T03:17:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Round 3: `sign-board.py` given no argument now exits 2, and the generic sections pass.**

- **Failed**: the full run on merged main stopped in `usage_guard` with `…/skills/lanework/scripts/sign-board.py with no arguments exits 0, want 2`. That line is the fail-before.
- **Fix**, `f2d4b67c`:
  - With no argument, or more than one, the script prints `usage: sign-board.py <board>` on stderr and exits 2.
  - Given one board, it still always exits 0.
  - The module docstring states the exit 2 within its first 60 lines.
- **Why exit 2 is safe**: every caller passes exactly one board and ignores the status.
  - `sign_board` in `lib.sh` ends `|| true`.
  - Both heal scripts call `subprocess.run` with no `check`, inside `except Exception: pass`.
- **`writes.md`**: § Signature never claimed exit 0, so it is unchanged, and `check-sizes` stays green.
- **Pass-after, by hand**: no argument gives rc 2, two arguments give rc 2, and one missing board gives rc 0.
- **Gate**, at `f2d4b67c`:
  - `smoke: 41 passed (sections: static, versions, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0.
  - `check-refs: 262 references, 0 missing`
  - `check-sizes: 59 rows, 0 wrong`
  - `py_compile` OK, with no `__pycache__` left.
- **Not run**: the full smoke run, and every section not named above. No two-argument row was added to smoke: `usage_guard` proves the no-argument code.
