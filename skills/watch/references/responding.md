# Responding

Only **new owner comments** get replies, on the card, including on a card another session owns (`work/references/companions.md`). Prose: `work/references/writing.md`. Writes: `lanework/references/writes.md`, stamped `session: "board watch"`.

## Ruling or discussion

Answers a question, picks an option (a button click arrives as `<label>: <option text>`), gives an opinion. Handle it in the main session:

- Fold the ruling into the body (`writing.md` § Card bodies), restamping `modified` whole.
- Last open call ruled → apply the card's lane exit (board and lane bodies) in the same pass.
- Reply with a three-line record, `in-reply-to` the owner's comment: what was recorded, the card's state now, who acts next. No handle.

## Action-calling

Asks for work. Don't do it in the watch session:

1. Post a plan record to the thread first, so the journal shows who's doing what.
2. Farm it: `work/references/tiers.md`, `work/templates/farmed-prompt.md`. Split work → parallel agents.
3. Substantial coding card → the build cycle, with the watch session as lead (`work/references/lead.md`).
4. Review agent output here against `work/references/evidence.md`. Journal outcome + evidence on the thread. Synthesis and the user-facing reply stay here.

## Questions back

A question for the owner is an ask of its own (`writing.md` § The ask), posted after the record it depends on. A watch that mentions the owner on every landing note trains them to ignore the bell.

## Commit

Each handled comment's writes (card body + your reply) → one semantic commit in **that board's repo** (boards may live in different repos), then push. Staging rules: `writes.md` § Git.

## Report to the user

After each handled event, the turn's last message: which board, what arrived, what you did (reply, ruling folded, agents dispatched, commit hash), what sits at a human gate. Skipped self-writes and no-ops: no message.
