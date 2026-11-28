---
schema: 1
kind: comment
created:  {at: 2026-11-28T18:46:47Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T18:46:47Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Merged to main at `4ddc7459` and pushed. One call, `work/scripts/start-card.sh`, stakes the lease, moves the card into the working lane and posts the START; a card worked without a lease is now reported.**

- **What shipped**
  - `start-card.sh <board> <card> --comment F --model m`: stake, move, START, in that order. A failed or interrupted start is undone: the card goes back at its old order and the lease is released.
  - `lint-leases.sh` prints `worked without a lease`, and `arm-pass.sh` prints `unstaked`, for a card in a working lane with no lease and no ask whose latest agent comment carries a session.
  - `move-card.sh` notes an unstaked move into the working lane on stderr, and gains `--order N`.
  - The lead, fixer, watch and writing guides name the one script. One START per start lives in `writing.md` § START.
- **Evidence**: the full gate on merged main, 32 sections in 6 parallel groups, every group exit 0: `62 passed` (lease), `113 passed`, `82 passed`, `122 passed`, `67 passed`, `17 passed` (start_card). Review approved in round 3 after two rounds of changes; its own reproductions could not reach a START on an unleased card with TERM, HUP or INT at any step.
- **The eight-card case**: on copies of the app pipeline board from its history, the lint reports all 7 and all 8 unleased Active cards. On 16 of 17 real-board copies it adds nothing.
- **Lead rulings**
  - The working lane is the exact title Active, else Working (`lib.sh` `WORKING_LANES`), not read from board prose.
  - The finding keys on the latest agent comment with a session, not on a START: the incident's notes opened "Building.".
  - On a board with an Approved lane, a start is refused from any lane but Approved or the working lane.
  - Whether a start landed is read from the board. A signal after the START landed keeps the card and the lease.
  - Round 4 (a second signal during the undo, and the header's signal clause) was read by the lead, not sent back for review.
- **Accepted limitations**
  - A SIGKILL skips the undo.
  - A board that renames its Approved lane loses the source-lane check.
  - `--order` accepts a value that ties with another card.
  - A `--comment` whose first line is a bare CRLF is refused.
  - A first word like STARTLING passes as a START (older than this card).
- **Seen outside this repo, untouched**: the new check flags one card on the hub pipeline board, in Active since October with no lease and no ask.
- **Changelog**: "Starting a card now stakes its lease, moves it to Active and posts the start note in one step, and unleased work gets flagged."
