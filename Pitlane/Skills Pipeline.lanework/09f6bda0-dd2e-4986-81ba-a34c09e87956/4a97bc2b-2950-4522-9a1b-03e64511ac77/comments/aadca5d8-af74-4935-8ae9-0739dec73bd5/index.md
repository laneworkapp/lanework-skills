---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:51:22Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T22:51:22Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: building on branch `guide-stamp` (a8e1f3c), ruling A.**

**Plan**: stamp to `CLAUDE.md` at v82 / schema v1, drop § Versions and the two "Target versions" pointers, add the one line, rewrite smoke step (a) and add the gate, update README § Versioning.
**Decision**: the gate reads the board guide from line 1 of its `CLAUDE.md` via the existing `VAL` path, and compares numbers, not strings.
