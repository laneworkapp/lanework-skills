---
schema: 1
kind: comment
created:  {at: 2026-10-25T11:08:12Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T11:08:12Z, by: {name: fixer, kind: agent, model: opus}}
---
**Evidence: smoke green at `e58deea` on branch `guide-v101` (rebased onto `origin/main` `7c8a801`, pushed). The new checks fail on the old skills.**

- **Gate**: `bash tests/smoke.sh` in the worktree at `e58deea`, exit 0, `smoke: 121 passed` (116 at `9a12b5d` before the stamp gate, plus 3 new cases and the 2 the stamp gate had blocked). `ok 118` and `ok 120` read v101. `check-sizes: 62 rows, 0 wrong`. Log: [smoke-after.log](attachments/10009ba2-aac6-4f3e-afae-60ba993df8e3/blob.log).
- **FAIL-BEFORE, stamp**: smoke at `9a12b5d` stopped on `board guide v101 is newer than the stamp` (recorded above).
- **FAIL-BEFORE, heal**: the new smoke with the `skills/` tree from `9a12b5d` stops at `compact-collection dry run lacks: index.md: compact-collection config written in the compact form, 2 lines to 1`. Log: [smoke-newtests-oldskills.log](attachments/c387740b-1805-47a0-99ca-b87b2d7370b2/blob.log).
- **FAIL-BEFORE, merge**: `tests/merge-case.sh merge` with the old `lanework-merge.py` fails on `merged keys not in the compact form: …: H17 compact-collection labels written in the compact form, 5 lines to 8`. Log: [merge-before.log](attachments/dff36922-8dde-4e47-a1d6-4e31781e98dc/blob.log).
- **FAIL-BEFORE, writers**: on the throwaway boards from a smoke run at `9a12b5d`, the board's heal dry run printed H17 on PL2, `Sync: v2 Plan` (config and 3 tickets), `Sync: v2 Discovery` (config and 2 records) and `D Discovery` (config). The same boards now give none (`ok 119`, whose control is the layout seed, where H17 fires).
- **Parity**: over 7 boards from that run, the skill heal and the board heal `--apply` left byte-identical trees (`diff -r` empty). On the 6 layout cases they differ only in stamp spacing (`ok 22`).
- **Found while building**: `compact_fm` loaded `heal-board.py` with bytecode on and left `__pycache__` under `skills/`. It now runs `python3 -B`, and smoke fails on any `__pycache__` in the skill tree.
