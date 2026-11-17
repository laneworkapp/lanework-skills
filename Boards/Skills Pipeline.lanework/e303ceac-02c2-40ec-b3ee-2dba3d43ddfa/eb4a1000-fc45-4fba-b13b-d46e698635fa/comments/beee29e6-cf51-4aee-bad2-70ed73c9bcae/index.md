---
schema: 1
kind: comment
in-reply-to: f1201ec1-322a-48ee-9d83-407be37421ef
created:  {at: 2026-11-17T19:08:42Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Closed 2026-11-17: merged to main at `f3f0c75`, smoke green. Not released.**

- **Merge**: branch `work-lease` at `3e68ca5` (commits `c9872a7`, `62ee7bf`, `894832d`, `911eea6`, `3e68ca5`), merged with `--no-ff` as `f3f0c75` and pushed.
- **Gate**: `tests/smoke.sh` on main after the merge, with the session variables unset: `smoke: 216 passed`, exit 0. Main before was 203; this card adds 13 cases. No lease timer left running.
- **Review**: adversarial, two rounds and a lead-ruled re-check. Round 1 and round 2 each asked for changes; the re-check approved at `3e68ca5`.
- **Done-when**:
  - `post-comment.sh` passes cases 1 to 8 and smoke is green. Met.
  - The seven reference and template files carry the change, and no file under `skills/work/` calls a START a claim (a smoke case greps for it). Met.
  - START has one definition, `writing.md` § START, and `companions.md`, `fixer.md` and `lead.md` link to it. Met.
  - The lead stakes before dispatch and releases on closing, in `lead.md`; the farmed prompt tells a subagent not to stake. Met.
- **Departures from the body**, each by a lead's ruling on this thread:
  - `move-card.sh` gains the same check, and `post-ask.sh` passes exit 3 through on a lost lease.
  - `lanework/scripts/lease.sh` changed: its memory is keyed by board as well as card, so a copy of a board is another board. `lanework/references/writes.md` § Lease gained one line on it.
  - With `lease.sh` missing beside `work`, the scripts skip the check with a note and write as before. Any other unexpected result of the check writes nothing and exits 1.
  - README § Sizes changed, since the word counts moved.
- **Accepted limit**: a board folder renamed or moved under a live lease forgets the lease's memory. It and the reviewer's other notes are filed as [an issue](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/653217e4-681e-44f5-b6eb-fb0d0b8490ca).
- **Not done here**: this card was worked without a lease staked on it, as the rule it adds was not on main when the work began.
- **CHANGELOG**, for the release commit: "Posting a comment or moving a card now checks the card's lease first: a session that lost the card writes nothing more, and `post-comment.sh --release` hands the card back with the closing comment."
- **Next**: the claim-ticket lease card in Approved.
