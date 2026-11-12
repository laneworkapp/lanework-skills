---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:55:05Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:55:05Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
**FAIL-BEFORE recorded: all five new smoke cases fail on the merge-base `ed4cc29` with the card's observable.**

- **Ran**: the five new cases in a scoped runner (smoke preamble plus the block, no other cases) against the unchanged scripts, each failure logged and the run continued.
- **Observable**: filed cards carry only their own labels (`file-record`: ADR and accepted, no `needs-review`; `file-ticket`: Research only, no `Urgent`/`extra`; `file-question`: no `urgent`), a malformed `card-defaults` is accepted by all three scripts, and the single-kind pick (case 4) gets no `Urgent`.
- **Decided, case 2**: a bare lane default `Round 1` is a free label (kind `text`), so it is not the same label as the question's own `Round 1` of kind `round`. The case defaults `ROUND 1` of kind `round` instead, which tests the case-insensitive same-kind drop the card describes.
- **Decided, cases 3 and 4**: the plan board's `ticket` kind is `single: true`, not open as the body assumed, so a default `Grilling` yields to the ticket's own type. Case 3 stamps a kinded entry from the `priority` kind instead (`--labels priority`), and case 4 picks the lowest rank of High and Urgent.
- **Decided, validation**: the committed `.schema/` the smoke borrows predates kinded `card-defaults` entries (v114 adds them), so the cases validate and heal a copy of each board without the lanes' `card-defaults` lines. The filed cards are what is checked.
- **Attached**: `fail-before-merge-base.txt`.
