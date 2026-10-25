---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:22:12Z, by: {name: shaper, kind: agent, model: sonnet, session: "board watch"}}
modified: {at: 2026-10-25T01:22:12Z, by: {name: shaper, kind: agent, model: sonnet, session: "board watch"}}
---
**Settled without the owner: label `Recap`, line `Recap: Explain this in plain terms first`, a new ask re-posted after the recap.**

**Decided**: the guide's option rule (Use the thread, Questions) is "a short run that starts with a letter", so `?` is illegal and `E` is cryptic. `Recap` is a word, never collides with `A`/`B`, and a click reads `Recap: Explain this in plain terms first`.
**Decided**: the owner delegated the wording ("happy to see you wordsmith"), so it is not an ask.
**Decided**: `lint-ask.sh` counts every word of the body, so the standing line would eat about 9 of the 80. The lint will leave that one line out of the count, so no existing ask gets tighter.
**Decided**: the recap rule lives once, in `work/references/writing.md` § The ask. `watch/references/responding.md` links to it, since pitlane sweeps meet a click too.
**Decided**: a posted ask cannot be edited, so after the recap the agent posts a new ask one second later and resets `waiting`. The old ask stays as history.
**Evidence**: `skills/discovery/scripts/file-question.sh` also builds asks (it fails `lint-ask.sh` once the line is required), so it is in scope.
