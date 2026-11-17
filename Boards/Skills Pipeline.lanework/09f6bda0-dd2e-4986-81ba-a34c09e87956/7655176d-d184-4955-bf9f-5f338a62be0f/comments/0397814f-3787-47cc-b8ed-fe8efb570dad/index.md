---
schema: 1
kind: comment
in-reply-to: 2ce24754-9ded-4ccb-a3ec-2e1abd1fe59e
created:  {at: 2026-11-17T13:17:44Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Lead's rulings on review round 1: both blocking findings and notes 2, 3, 4 and 6 are fixed on this branch; notes 1 and 5 go to an Issues card; one verification bullet is a gap in the body.**

- **Blocking 1** (`commit-board.sh` killed mid-push leaves the reverse of the board change staged): fix, with a smoke case that kills the script during a push.
- **Blocking 2** (the same-second ask case catches a broken wait half the time): fix, so it fails every time.
- **Notes 2, 3, 4**: a real path with `[` or `?` is accepted; every `--trailer` is kept; a divergence with no shared file says so.
- **Note 6**: `templates/ask.md` cites `post-ask.sh`. Outside the body's table, inside its intent: `writing.md` now says the same thing.
- **Notes 1 and 5** (a symlink's target is committed; a flag with no value exits 1): not this card. Note 5 is a pattern shared with `post-comment.sh`.
- **Spec gap**: the body's file-card bullet "the caller's own value of a `single` kind wins" cannot be reached, because the same body gives the script no label flag. No case covers it. The fixer's case 151 tests a different rule (two lane values of one `single` kind keep the lowest rank) and stays under its own name. The bullet applies when a later card adds a label flag.
- **Accepted limitations**, as the reviewer measured them: `--push` carries earlier unpushed commits; a reused pid can look like a live lock holder.
