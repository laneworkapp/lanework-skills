---
schema: 1
kind: comment
created:  {at: 2026-11-12T00:54:39Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T00:54:39Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**FAIL-BEFORE: all four new smoke cases fail at the merge-base `ed4cc29`, each with the card's observable.**

- **lint-ask**: passes an ask whose second handle (`@bob`) is only on a later line.
- **heal-board, root `component:`**: the dry run adds a `component` definition and drops the root key into `labels`. It lists no repair for a live relation with a bare `modified`: `relations/` is not walked.
- **`--name board`**: `heal-board.py --apply --name board` exits 0 and writes.
- **lanework-merge.py**: `board_singles` holds `component` on a board whose `component` kind is not `single`.

**Evidence**: each case run alone against the unchanged scripts, through a harness that supplies smoke's preamble.
**Attached**: [fail-before.txt](attachments/34bc30e8-6fd5-41e6-a4c7-386396542c17/blob.txt), the four runs and the cases.
