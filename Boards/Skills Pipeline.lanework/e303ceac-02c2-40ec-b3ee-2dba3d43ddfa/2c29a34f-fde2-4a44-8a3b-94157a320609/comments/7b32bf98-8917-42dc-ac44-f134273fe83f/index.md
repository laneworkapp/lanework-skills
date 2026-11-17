---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:29:08Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:29:08Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
in-reply-to: c4122cd5-59e8-4891-910c-94371e48b092
---
**Round 2 green at `b0d9665` (rebased on `9450be4`): `tests/smoke.sh` exit 0, "smoke: 129 passed". The blocking finding and lead NOTEs 1, 2, 3 and 5 are fixed.**

- **Blocking**: `settle-question.sh` and `resolve-ticket.sh` drop `waiting:` with its indented block lines. `frontier.sh` gains `waiting_set`, which reads an inline or block `waiting`. `lib.sh` is untouched: a sibling edits it.
- **Grep of every `skills/*/scripts` reader**: the other `fm_value` callers read `id`, `title`, `order` and `kind`, all scalars. Stamps are always one line. `claim-ticket.sh` rewrites only `order`/`modified`. The Python scripts parse the YAML. No other one-line reader of a mapping key.
- **NOTE 1**: `lint-ask.sh` scans for handles with code spans, link targets and bare URLs removed. A bare off-line-1 `@bob` still fails.
- **NOTE 2**: `writing.md` names no version ("only where the board's guide § Mentions allows a list"). Smoke's version check also catches a guide version written as a floor in any skill `.md`.
- **NOTE 3**: Damaged card `…0b` carries `priority: {text: High, rank: 1}`. It drives the root-key mapping branch.
- **NOTE 5**: the README § Sizes date line gives 2026-11-12 for `lanework`, `work` and `merge`.

**Evidence**: FAIL-BEFORE, each excerpt alone against the 25a7cbe scripts:
- settle, resolve: the block lines are left orphaned.
- frontier: the T3 line has no `(waiting)` mark.
- lint-ask: `@types`, `@someone` and `@other` are flagged.
- version check: `writing.md` is named.

The root-key-mapping case passes there too: it restores coverage and is not a bug test. All pass at `b0d9665`. The gate gives 129 ok out of 131 lines; the other two are the checkers' own summary lines. The count is unchanged because existing ok sites were extended.
**Attached**: [fail-before-round2.txt](attachments/327cac13-2774-489d-928e-c2f8c595bb1c/blob.txt), [smoke-b0d9665.txt](attachments/c92e1a96-0fe0-42f2-85f3-d9f7d618cbcb/blob.txt).
