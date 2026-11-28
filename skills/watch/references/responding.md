# Responding

Only **new owner comments** get replies, on the card, including on a card another session owns (`work/references/companions.md`). Prose: `work/references/writing.md`. Writes: `lanework/references/writes.md`, stamped `session: "board watch"`.

## Ruling or discussion

Answers a question, picks an option (a button click arrives as `<label>: <option text>`), gives an opinion. A `Recap:` click is not a ruling: follow `work/references/writing.md` § The ask, and skip the rest of this section. Handle it in the main session:

- Fold the ruling into the body (`writing.md` § Card bodies), restamping `modified` whole.
- Last open call ruled → apply the card's lane exit (board and lane bodies) in the same pass.
- Reply with a three-line record, `in-reply-to` the owner's comment: what was recorded, the card's state now, who acts next. No handle.
- A reply, a ruling fold and a lane exit stake nothing: a write to a card this session does not hold is not blocked (`lanework/references/writes.md` § Lease).

## A move into an agent lane

An owner's move (`events.md` item 5), or a card waiting at arming (`arming.md`), in an `agent` row of `lanework/references/board-kinds.md` = work order, if it holds no lease (none, or voided by the clock guard: `work/references/companions.md`). A lapsed lease is `stale`, no arm; an owner's move of such a card is the owner asking, and the stake takes it over (`lanework/references/writes.md` § Lease). No comment to answer:

1. Read the card whole; act per the lane body (`work/SKILL.md`). Not this card's work (any other lane, `waiting`, lane body out of scope, Approved but not first in pick order, `lanework/references/reading.md` § Pick order) → no work order, report. No stake.
2. **Stake** only the card to work, immediately before the first write or hand-off. A card to build (Approved, or already in Active) → start it in one call, `work/references/lead.md` § Dispatch (`work/scripts/start-card.sh`). Any other agent lane: `lanework/scripts/lease.sh stake <board> <card-uuid> --model m`. Rules, exit codes and the two-minute takeover wait: `lanework/references/writes.md` § Lease. Refused (exit 1) → no work: one report line, "held by another session".
3. A card staked and then not worked (a later refusal, a change of plan) → `lanework/scripts/lease.sh release` at once.
4. Substantial work → § Action-calling below.
5. **Release** when the card is handed to a gate or done, in the closing write, before the closing commit (`work/references/lead.md` § Dispatch: `--release`, else `lanework/scripts/lease.sh release`), so the release rides in that commit.

## Action-calling

Asks for work. Don't do it in the watch session:

1. Post a plan record to the thread first, so the journal shows who's doing what (a card to build: the record `start-card.sh` posts).
2. Farm it: `work/references/tiers.md`, `work/templates/farmed-prompt.md`: its Lease lines name the lease this session holds and tell the subagent never to stake. Keep the lease while the subagent runs. Split work → parallel agents.
3. Substantial coding card → the build cycle, with the watch session as lead (`work/references/lead.md`).
4. Review agent output here against `work/references/evidence.md`. Journal outcome + evidence on the thread. Synthesis and the user-facing reply stay here.

## Questions back

A question for the owner is an ask of its own (`writing.md` § The ask), posted after the record it depends on. A watch that mentions the owner on every landing note trains them to ignore the bell.

## Commit

Each handled comment's writes (card body + your reply) → one semantic commit in **that board's repo** (boards may live in different repos), then push. Staging rules: `writes.md` § Git.

## Report to the user

After each handled event, the turn's last message: which board, what arrived, what you did (reply, ruling folded, agents dispatched, commit hash), what sits at a human gate. Skipped self-writes and no-ops: no message.
