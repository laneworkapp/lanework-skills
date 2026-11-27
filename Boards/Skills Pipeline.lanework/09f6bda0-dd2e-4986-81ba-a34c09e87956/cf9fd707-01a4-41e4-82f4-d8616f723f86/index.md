---
schema: 1
kind: card
title: "Guide moved to v122: read the skills against it and bump the stamp"
order: 3072
labels:
  - {text: "merge", kind: {type: "skill", text: "Skill"}}
  - {text: "lanework", kind: {type: "skill", text: "Skill"}}
  - {text: "watch", kind: {type: "skill", text: "Skill"}}
  - {text: "repo", kind: {type: "skill", text: "Skill"}}
created:  {at: 2026-11-24T00:21:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T15:09:19Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-27T15:39:19Z
---
The app's guide moved from v120 to v122, and reading every skill against it found one real bug and a handful of small gaps: merging a board silently drops emoji reactions on comments.

## What moved in the guide

- **v121** (app commit `d2ed9169b`): comment `reactions` are new, a list of `{emoji, at, by}` entries. The `move-receipts` config key is new in the config list. The schema count reads eight files, with `relation` named.
- **v122** (app commit `5bb87c36d`): the config path is printed from `~`. No rule moved.
- The reserved writer names (`anyone`, `board`, `healer`, `shortcuts`) are unchanged.

## What the audit found

Everything was run on a throwaway board carrying the v122 guide and schema, with hand-written move receipts and reactions shaped as the app writes them.

- **Move receipts are already handled.** `arm-pass.sh`, `lint-waiting-clears.sh`, `lint-stamps.sh`, `lint-leases.sh`, `lease.sh list`, `read-board.sh` and the validator all read a receipt as a record, in both its one-line and its indented form. None takes it for an owner comment or a human answer.
- **Reactions are lost in a merge.** A reaction never changes a comment's `modified`, so the merge driver's "later `modified` wins" cannot choose. When each side adds a reaction, one is dropped. When one side removes and the other adds, both are dropped. The merge exits 0 and writes no merge comment.
- **The writers accept reserved names.** `post-comment.sh --name board` and `file-card.sh --name board` both succeed, and so do `healer`, `shortcuts`, `tracker` and `anyone`. A comment signed `board` is then invisible to `arm-pass.sh`. This is older than v120.
- **Nothing else drifts.** No skill says seven schema files, none bundles a copy of the schema or validator, and no script parses the config path line.
- **Smoke passes on the v122 board**: 419 cases, with only the drift note.

## Scope

| file | change |
|---|---|
| `skills/merge/scripts/lanework-merge.py` | merge a comment's `reactions` three ways, as a union by emoji and `by`, where a removal on one side holds |
| `skills/merge/references/rules.md` | one row for `reactions` |
| `tests/merge-case.sh` | two cases: both sides add, and one removes while the other adds |
| `skills/lanework/scripts/lib.sh` | the writers refuse `anyone`, `board`, `healer`, `shortcuts` and `tracker` as a signer name, with a smoke case across them |
| `skills/lanework/references/reading.md` | one line: a move receipt is a record, and its `moved.by` is who moved the card |
| `skills/watch/references/events.md` | a receipt is known by its signer `board`, as `arm-pass.sh` already tests it, and one line: a comment whose reactions changed is not an event |
| `skills/lanework/references/writes.md` | one line: agents never add or remove a reaction, and never read one as an answer |
| repo `CLAUDE.md` | the stamp reads `lanework-agent-guide v122` |

## Ruled: reactions

Ruled by the owner on 2026-11-25: **A**. Agents never write a reaction, and a reaction is never an answer. A question is answered by a reply comment, because an emoji has limited auditability.

- A reaction on any comment is not an event and gets no reply.
- Not taken: B, agents reacting to acknowledge a comment, and C, a reaction on an ask counting as its answer. The owner first chose C and then withdrew it.

## Decided here, not asked

- Founding templates leave `move-receipts` off, which is the app's default.
- `lint-stamps.sh` does not check a reaction's `at`.
- `tests/fixtures/app-writes/` stays as it is: no app write made under v122 is committed yet, so there is nothing to re-copy. The first one committed becomes the source, as its README says.

## Not in this card

- `skills/lanework/scripts/heal-board.py` lags the board's own healer, which moved to heal v6 ("no thread, no drop"). Filed apart.
- The app-written guides on disk: the Skills Pipeline pair is v122 and carries no home path. The Board Runner Discovery and Card Lease Discovery pairs still carry the absolute home path until the app reopens those boards, so those four stay out of commits.

## Risks

- A reaction union can bring back a reaction that one side removed and the other never saw removed. The three-way base settles that, as it does for labels, and the second merge case pins it.
- Refusing reserved names could break a caller that signs as one of them. None in `skills/` or `tests/` does.

## Verified by

`bash -n` on each changed script, the two new merge cases and the reserved-name case on throwaway boards, and a full `tests/smoke.sh` run with no drift note. The changed prose is read through against the v122 guide.

## Done when

- Merging two sides that each changed a comment's reactions keeps every reaction that neither side removed.
- Each writer exits non-zero when asked to sign as a reserved name.
- The stamp in the repo's `CLAUDE.md` reads v122 and smoke prints no drift note.
- `writes.md` and `events.md` say what the reactions ruling ruled.
