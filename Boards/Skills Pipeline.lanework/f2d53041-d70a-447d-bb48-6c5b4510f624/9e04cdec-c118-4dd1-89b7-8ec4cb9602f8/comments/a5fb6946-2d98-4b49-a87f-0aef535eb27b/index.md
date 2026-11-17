---
schema: 1
kind: comment
created:  {at: 2026-11-12T18:57:18Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
**Shaped and moved to Proposed: no open call remains.**

- **Decided**: gate `@anyone` on the board's own guide version through a new `ask_handle` in `lanework/scripts/lib.sh`, because the guide says older builds draw no buttons for it. No open call: the guide settles it.
- **Decided**: no skill mints or copies a `cite-as`, so it gets one line of rule and no script.
- **Found beyond the filing**: `lint-ask.sh` would pass a correct `@anyone` ask unchecked, and `file-question.sh` writes the machine handle into `waiting.for`.
- **Rejected**: switching every board to `@anyone` unconditionally (breaks v114 boards).
- **Accepted limitation**: smoke stays red in the main checkout until the app's v117 files are committed; the build cannot fix that.
