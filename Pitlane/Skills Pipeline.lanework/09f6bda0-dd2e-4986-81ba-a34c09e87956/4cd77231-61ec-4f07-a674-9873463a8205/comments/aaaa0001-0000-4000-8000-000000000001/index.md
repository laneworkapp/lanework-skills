---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:10:00Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T23:10:00Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: fixer on `smoke-plugin-validate` (worktree `.claude/worktrees/smoke-plugin-validate`, from `95549b3`).**

**FAIL-BEFORE**: `bash tests/smoke.sh` at `95549b3` exits 1 after `ok 19`, at the plugin validate step. `claude plugin validate . --strict` (2.1.292) exits 1 on the single warning "root: CLAUDE.md at the plugin root is not loaded as project context". Without `--strict` it exits 0 and prints the same warning as a `  ❯ <field>: <message>` line.

**Decision**: run without `--strict`, so errors fail by exit status; then fail on any `  ❯ ` line that is not the known CLAUDE.md one. Skipped when `claude` is absent.
