---
schema: 1
kind: card
title: "Active lane text still says a card is claimed with a comment"
order: 11264
labels: [{text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T15:02:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:42:50Z}
---
Replace the Active lane's owner-facing sentence "claiming it with a comment naming the session and branch" with one that says what the claim becomes once leases exist, and teach the heal to bring boards founded with the old sentence up to it.

~~Open call: the exact new sentence.~~ **Ruled 2026-11-17: A.** The Active lane says: `An agent moves a card in as it starts, holds it with a lease while it works, and moves it to Done when its done-when is met.`

## Files

- `skills/lanework/templates/pipeline-lanes.md`, line 13, the Active row: the body becomes the ruled sentence. The first sentence ("Work in progress.") stays. The second sentence is the actor and trigger sentence the heal reads (the file's header says so), so it must still name who acts and what starts it. No `|` in it, because the table splits on it. Every new pipeline board is founded from this row, so this is what new boards get.
- `skills/heal/scripts/heal-descriptors.py`, the `OLD_BODIES` table, `"pipeline"` then `"Active"`:
  - Line 92 is not the expected sentence, as the card first said: it is already a predecessor ("The build lane. One session holds a card at a time, claiming it with a comment naming the session and the branch."). It stays as it is. The expected body is read from the template at run time, so there is nothing to change in the code that checks.
  - Add the body v0.8.0 shipped, word for word (the current row: "Work in progress. An agent moves a card in as it starts, claiming it with a comment naming the session and branch, and moves it to Done when its done-when is met."), as a second entry. The file's own rule says a released body change adds the body it replaces here, in the same commit; `skills/heal/references/descriptors.md` line 31 says the same. That body is released: the v0.8.0 tag carries it.
  - The comment above the table says the bodies run "up to 35ba2ce"; reword it to name v0.8.0, so the next editor knows where the table stops.
- `tests/smoke.sh`, the heal-descriptors cases (lines 1013 to 1037):
  - Line 1019 area: add `setbody Active '<the v0.8.0 body>'` beside the existing Approved, Tasks and Shaping setups.
  - Line 1023: the dry run must also list `lane Active: replace-body`, and the count becomes `4 changes in 4 files`.
  - Lines 1030 to 1034: after `--apply`, the Active body equals the template's, and the restamp loop covers Active.
  - New gate after line 1004's table check: a grep of `skills/` for "claiming it with a comment" finds only `heal/scripts/heal-descriptors.py`.
- Not touched: `skills/lanework/references/board-kinds.md` (its Active row says "an agent moves a card in as it starts: build, evidence, move to Done", with no comment claim), `skills/heal/references/descriptors.md` (its rules already cover this; editing it changes a README word count), `README.md`, `plugin.json`. `skills/plan/templates/lanes.md` has a different claim (a plan ticket claimed by a session); it is not this sentence and is left to the plan card. `CHANGELOG.md` gets one entry at release, shared with the lease cards.

## What happens to boards already founded

All of this was checked by reading `heal-descriptors.py` and by a dry run on a scratch copy of this board.

- **Founded from v0.8.0 and never edited** (Active body equals the old row): with the new `OLD_BODIES` entry the dry run lists `replace-body` and `--apply` swaps in the new body. Without the entry the heal would treat the body as customised and add the new sentence after the first one, leaving the old claim sentence beside it. That is why the entry is part of this card.
- **Founded from an earlier template** that matches `OLD_BODIES`: the same `replace-body`.
- **Customised bodies are never replaced**; the heal's rule is that it only inserts the actor sentence. The dry run today already proposes inserting the old claim sentence into this board's Active lane, and after the change it would insert the new one and leave the old claim text beside it (`descriptors.md` already names this as an accepted limitation).
- **This board's own Active body** is "The build lane. One session holds a card at a time, claiming it with a comment that names the session and the branch." It differs from the stored predecessor by "that names", so it is a customised body. The heal will not rewrite it. The owner edits it once by hand; that edit is not part of this card's done-when.
- The heal never runs by itself: the `heal` skill shows the dry run and applies only what the user confirms, so no board changes under anyone.

## Verified

`tests/smoke.sh` passes, with these cases changed or added, all on throwaway boards:

1. The existing heal-descriptors dry-run case now also lists `lane Active: replace-body` and counts 4 changes in 4 files.
2. The existing `--apply` case now also shows the Active body equal to the template's, restamped with the agent, and a second `--apply` finds nothing.
3. New gate: a grep of `skills/` for "claiming it with a comment" finds only `heal/scripts/heal-descriptors.py`, and a board founded from the new template has an Active body without the phrase.
4. The existing "every lane has two sentences" case passes on the new body.

`python3 -m py_compile` passes on `heal-descriptors.py`, and `tests/check-refs.sh` and `tests/check-sizes.sh` stay green. Prose read through against the guide version the skills target.

## Done when

- `pipeline-lanes.md` has the ruled Active sentence, and a board founded from it carries that sentence.
- `OLD_BODIES["pipeline"]["Active"]` lists the v0.8.0 body, and a dry run on a board founded from v0.8.0 lists `replace-body` for Active.
- `tests/smoke.sh` is green with the cases above.
- A grep of `skills/` for "claiming it with a comment" finds only `heal-descriptors.py`.

## Risks

- **The sentence must not run ahead of the build.** A board founded after this ships would read "holds it with a lease" while no `lease.sh` exists. Build this after the lease cards, and release them together.
- **The heal appends, never merges.** A board whose Active body is customised keeps its old claim text; only its owner can fix it. Accepted, and already the heal's stated limit.
- **A second predecessor now sits in the table for a lane whose old text is short.** Harmless: matching is word for word.
- **The sentence is the second sentence of the template body**, which the heal copies into customised boards as the actor sentence. A long or clause-heavy wording makes every future insert long; hence the short recommended wording.

## Depends on

Build after [the lease script](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb) and [the work skill's lease checks](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa): the new sentence describes what they build, and none of the files above need them to compile or test, so the order is about truth, not code. [Watch and dispatch](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233), [plan](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b808e18c-2160-48a7-a45a-6174702ec5a5) and [the lease trial](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b) share no file with this card.

## Recommendation

Ready to build once the wording is ruled. Take option A: it keeps the sentence one clause longer, says plainly that a lease is what holds the card, and carries the same actor and trigger the heal expects. Build it last of the lease family, in one commit with its `OLD_BODIES` entry.
