---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:55:00Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
modified: {at: 2026-10-25T10:55:00Z, by: {name: fixer, kind: agent, model: sonnet, session: "board dispatch"}}
---
**Code-complete on `merge-appside` at `141888d` (rebased on origin/main): the `appside` mode is built and green, and the quoted-value mutation turns it red. The full smoke gate waits for the slot.**

- **Decided, fixtures**: copied unchanged from this board's history into `tests/fixtures/app-writes/`: the Shaping lane rewritten with no `by` (`6bbfd6e`), the Recap card moved Proposed to Approved (`f0bb998`), a card retitled and moved Issues to Approved (`704f284`), and a comment with the quoted `{name: "Rouslan Z", kind: "human"}` stamp (`df595e2`). The `README.md` there names every source. No app clearing of `waiting` exists in the history: every removal was an agent's, so none is included.
- **Decided, base**: each item's base is the file one commit before the app wrote it (`*.before.md`), so git and the driver see the app's real diff. Placing the app's bytes on an unrelated base item made the driver treat the sides as different documents, because `created` differs.
- **Decided, scenario**: side A edits the lane body, the Recap body, the retitled card's title (earlier, so the app's title wins) and moves the card the app commented on. Asserts: no prompt, no marker, validator clean, A's and B's content both survive, each card in one place, and the app's comment re-homed byte for byte.
- **FAIL-BEFORE**: at the merge-base `f9ba99c`, `merge-case.sh <dir> appside` does not fail as an unknown mode. It exits 0, because the script has no default arm and runs the generic merge case for any mode name. Added a guard (`merge-case: unknown mode`, exit 2), so a typo can't pass silently. The meaningful red is the mutation below.
- **Mutation** (scratch copy, not committed): `unquote()` in `lanework-merge.py` returning its input with the quotes on. Clean copy exits 0. Mutated copy exits 1 with `merge-case (appside): appside title: the merge comment doesn't name the kept title`.
- **Finding, for the lead**: the quoted human stamp appears only in `created`, and the script compares `created` as raw text, so a mutation of the `by` name handling (`stamp_desc`'s `"?`) does not turn the case red: the app writes `modified` with no `by`. The quoted-value reader, `unquote`, is what the fixtures exercise, through the titles the app writes quoted.
