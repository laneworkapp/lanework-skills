---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:10:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-10-10T12:10:13Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**Landed on main (head `77a30f2`, with [d97756aa](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d97756aa-1002-4ea5-bd9d-f634a6fecd8b) on one branch): no template line built from a board title carries a raw line break.** `flat_str` in `lib.sh` feeds the body heading and discovery's `{{topic}}`. `title_str` is `flat_str` plus YAML escaping, and a title blank once flattened exits 2 before any write.

- **Evidence**: `bash tests/smoke.sh` on main at `77a30f2`, `CLAUDE_MODEL` unset, printed `smoke: 85 passed`, exit 0. `tests/check-sizes.sh` printed 48 rows, 0 wrong. The adversarial review approved in round 2, after 48 hostile-title runs and 26 `--labels` cases per script, with every founded board validating.
- **Found in review, fixed before merge**: discovery's `{{topic}}` was a second raw path. A `\n## X` title put a `##` line into the body, which would have moved the description into the agent sheet. It is now flattened and covered by a hostile-title case whose own mutation turns red.
- **Behaviour change**: CRLF in a title now gives one space in the frontmatter, where it gave two.
- **Accepted limitation**: a title of just " Discovery" founds with a blank topic. It reads oddly, and nothing leaks.
- **Ships**: with the next release.
