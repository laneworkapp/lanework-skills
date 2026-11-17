---
schema: 1
kind: comment
created:  {at: 2026-11-14T14:58:45Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-14T14:58:45Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Shaped without an open call; three places where the filed body disagreed with the rulings or the code are fixed in the new body.**

- **Fixer does not stake**: the filed body had `fixer.md` stake before START. The session-holds ruling says subagents never stake, and a fixer is the lead's subagent. The lead stakes at dispatch and releases at close.
- **START has no home today**: `writing.md` has no START section (only a rule that START carries no handle), so the filed "START's shape in writing.md" is a new section. It stays the one place; `companions.md`, `fixer.md` and `lead.md` link to it.
- **"No file calls START a claim" was wider than the file list**: `dispatch/scripts/arm-pass.sh` (claim = last comment opening START, stale after 30 minutes), `dispatch/references/routing.md`, `watch/references/arming.md`, `plan`, `lanework/templates/pipeline-lanes.md` and `heal/scripts/heal-descriptors.py` all read a START or a claiming comment as the claim. The done-when is narrowed to `skills/work/`. Those need their own cards.
- **Decided**: the check reads the holder id from `CLAUDE_CODE_SESSION_ID`, never from `--session`: stamps in this repo carry free labels there, and the lease's holder is the harness session id.
- **Decided**: release rides on the closing comment as `post-comment.sh --release`, the literal "same write as the closing comment" of the release ruling. A move's release belongs to `move-card.sh` ([7655176d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f)).
- **Decided**: exit 3 for a lost lease, so a caller tells it from a refusal (1) and a usage error (2). The lease script posts the "lease lost" record, so the check never calls back into `post-comment.sh`.
- **Rejected**: a check in `lib.sh` for every script. One caller exists, and the lease script is the one place the rules live.
- **Needs confirming on the lease card**: `check` must tell "held, lost, or never held" apart, which means the lease script remembers which cards its session staked. The lease card's body does not say how. Recorded under Risks.
