---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:42:36Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:42:36Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**START: building the README sizes check on branch `readme-sizes`.**

- **Plan**: new `tests/check-sizes.sh`, sibling of `tests/check-refs.sh`, called from one new `tests/smoke.sh` case. Then refresh README § Sizes (incl. missing rows for `heal`'s files if absent).
- **Decided**: separate helper rather than inline: the README parse is ~40 lines and the scratch-copy breakages need to run it against a copied repo; `check-refs.sh` sets the precedent. It takes the repo root as an optional argument so the same script can be pointed at a scratch copy.
- **Order**: test first, FAIL-BEFORE against the unrefreshed README, then refresh.
