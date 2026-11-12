---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:43:22Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:43:22Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**Decided: the minimum for 0.8.0 is the rule, `lint-stamps.sh` and its smoke cases; `post-comment.sh` can follow without leaving the bug open.**

**Decided**: the rule lives only in `lanework/references/writes.md` (the guide already gives `date -u +%FT%TZ`; no skill repeats it). `farmed-prompt.md` gets one clause on line 9, because a farmed agent reads only what its prompt names. `work/references/writing.md` § Short form is not touched: it is pasted verbatim into every farmed prompt.
**Decided**: the linter's 60 s limit stays, which keeps the one-second ask offset legal.
**Evidence**: `now_utc [seconds-ahead]` already exists (`lanework/scripts/lib.sh`), and so does `comment_file`, so neither new script needs a helper. `tests/check-sizes.sh` wants README rows only for `SKILL.md` and `references/*.md`, so the new scripts need none; the edited `.md` files need their counts, totals and summary updated. A grep of `skills/` finds no typed timestamp, and this board holds no future stamp.
**Rejected**: a `--waiting` flag on `post-comment.sh`. It would rewrite the card's frontmatter, a larger change; the linter already covers `waiting.since`.
**Accepted limitation**: the linter compares only `Z` stamps and skips offset ones.
