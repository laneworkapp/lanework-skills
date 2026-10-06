---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:51:40Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:51:40Z, by: {name: fixer, kind: agent, model: opus}}
---
**Decisions while building: the heal follows the card body, and the app's semantics where the guide is silent, with five calls of its own.**

- **Decided**: `modified` is restamped as the running agent, as the body says. The app's own heal and migration never restamp, by its 2026-09-07 ruling; that divergence is the body's, kept on purpose.
- **Decided**: a missing `by` is never written. The guide reads it as the owner, so filling it would invent authorship. Lossless spellings are healed: a bare timestamp becomes `{at: …}`, a bare `by: name` becomes `{name: …}`.
- **Decided**: a repair that drops a fact (extra entries of a `single` kind, a reserved root key under an existing entry) posts a record on the card, signed as the running agent and quoting what went. `healer` stays the app's.
- **Decided**: like the app's migration, the board gains the suggested `priority`/`component` definition when its cards use the kind and its vocabulary lacks it. Cards are then healed against that vocabulary in the same run, so one run is idempotent.
- **Decided**: definitions are the board's `config.labels` plus the built-in `text`. The machine level is read only through `--global <file>`.
- **Decided**: the skill's copy exits 2 where the board ships `.schema/bin/lanework-heal.py`, naming it; `--ignore-board-copy` overrides.
- **Decided**: `.trash/` is never healed, as in the app.
- **Added beyond the body's list**: flat `icon`/`iconColor`, `modified-by`, and titles continued over several lines. A dry run on a copy of a real board showed these alone kept the validator unclean.
- **Not covered**: the retired `config.priorities` roster, `author`, and a file with no frontmatter (listed as `skip`).
- **Accepted limitation**: a rewritten `labels` list or `config` comes back with every string double-quoted and in the guide's flow-or-block length rule, untouched entries included.
