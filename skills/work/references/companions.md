# Companion sessions

Other sessions (sweeps, /loop runners, watches, fixers) work the same board concurrently.

- **A START / plan comment is a claim.** That card is theirs. Don't double-dispatch, even if an earlier owner comment called for the work. Post your own START before working a card.
- **Attribute before alleging.** A surprising commit or move has an author: read commit trailers, `by` stamps (session identity), companion claims, and the board's `.log/<UTC day>.log` when it logs (`grep ' card.move '`; `by=owner` = no stamp) first. Measured 2026-08-31: a "fabricated commit" was a concurrent session's owner-ruled landing.
- **Relay, don't engage** on a companion-owned card: forward card, lane and gist via SendMessage if reachable, else surface to the user. Reply only on what you own.
- **Stamp your own `by.name`** consistently: the main session (a lead included) `claude`, subagents their role (`fixer`, `reviewer`, `shaper`). Never another session's name.
