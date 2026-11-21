---
schema: 1
kind: card
title: "A brace, quote or backslash in a stamp value can still write invalid front matter"
order: 1024
labels: [{text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-20T23:06:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:21:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Every script that stamps a name, model or session writes the same valid stamp for the same arguments, or refuses before writing anything, so no value an agent passes can leave a board with invalid front matter.

## Problem

Measured on throwaway boards under `mktemp -d` (made-up values, validator copied from the repo board's `.schema` and run with `python3 -I`). "invalid" = the board validator reports a failure afterwards.

- Scripts that write a stamp (all through `by_of` in `skills/lanework/scripts/lib.sh`, which writes `name` and `model` bare and quotes only `session` without escaping):

| script | through `stamp_lines_ok`? |
|---|---|
| `lanework/scripts/found-board.sh` | no (never called) |
| `lanework/scripts/lease.sh` (`write_card`, `post_record`) | `write_card` yes (`modified claimed`); `post_record` writes its comment through `comment_file` unchecked |
| `work/scripts/file-card.sh`, `post-comment.sh`, `post-ask.sh`, `move-card.sh` | yes |
| `discovery/scripts/file-question.sh`, `settle-question.sh`, `file-record.sh` | yes |
| `plan/scripts/file-ticket.sh`, `claim-ticket.sh`, `resolve-ticket.sh` | yes (claim-ticket's Claimed comment is written unchecked) |
| `heal/scripts/heal-descriptors.py` | no, but its own `scalar()` already quotes `name` and `model` and escapes `session` |
| `merge/scripts/lanework-merge.py` `signer()` | no: writes `model` bare |

- `--name '{n}'` (reproduced): `found-board.sh` exits 0 and every document is invalid (18 failures); `file-card.sh` exits 1 with the card left invalid (2 failures); `post-comment.sh` exits 0 with an invalid comment (2); `move-card.sh` exits 1 after writing (1); `post-ask.sh` exits 0 with 3 failures. `--model '{n}'` is the same through `found-board.sh` (exit 0, 18 failures); the other four refuse, nothing written.
- `--session 'a"b'` (reproduced): `file-card.sh` and `move-card.sh` exit 1 with an invalid card, `post-comment.sh` exits 0 with an invalid comment, `post-ask.sh` exits 0 with 2 failures. `--session 'a\'` behaves the same, except `move-card.sh` exits 0 and writes `session: "a"` plus a swallowed quote, valid but different.
- The `awk -v` restamp (reproduced): `--session 'a\\b'` gives `session: "a\\b"` from `post-comment.sh` and `session: "a\b"` from `move-card.sh`, because `awk -v` interprets backslash escapes. The same `-v` is in `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh` and `lease.sh`.
- Wider than the card says (reproduced through `post-comment.sh`, all exit 0, board invalid): a name or model that starts with `"`, `'`, `[`, `*`, `&`, `!`, `|`, `%` or `@`, or holds `: ` or ` #`. A comma (`a, b`) validates but splits the flow mapping, so the stamp is silently wrong. `a{b` is refused only by accident of the brace count.
- `merge/scripts/lanework-merge.py` `signer()`: `--model 'a: b'` (or `LANEWORK_MERGE_MODEL`) gives `model: a: b`, which fails to parse; `--model '{n}'` parses as a mapping. Reproduced by calling `signer()` and `yaml.safe_load`.
- Not a problem: `a"b`, `a\` and `a\"}}}` as `--session` through `post-comment.sh` and `file-card.sh` when the quote is escaped by the caller; `name` and `model` containing `"` or `\` in the middle of a word parse as plain scalars. These are values the fix must keep valid, not defects.

## Change

- `skills/lanework/scripts/lib.sh`: `by_of` becomes the one writer. `name` and `model` are written bare when they match `[A-Za-z0-9._-]+` (so every existing stamp stays byte for byte), else double-quoted with `\` and `"` escaped; `session` is always double-quoted with the same escaping. `heal-descriptors.py` `scalar()` already uses this rule, so the two agree. Add `stamp_args_ok <name> <model> [session]`, called right after `require_model`, that refuses (exit 2, "nothing written") any value that is empty or holds a control character or newline, which no quoting can carry. Then `stamp_lines_ok` stays as the last guard but its comment drops the claim about unquoted values.
- `lanework/scripts/found-board.sh`: call `stamp_args_ok`, and run `stamp_lines_ok` on the staged `index.md` and each lane file before the `mv`.
- `work/scripts/file-card.sh`, `post-comment.sh`, `post-ask.sh`, `move-card.sh`, `discovery/scripts/file-question.sh`, `settle-question.sh`, `file-record.sh`, `plan/scripts/file-ticket.sh`, `claim-ticket.sh`, `resolve-ticket.sh`, `lanework/scripts/lease.sh`: call `stamp_args_ok` once after argument parsing; keep each existing `stamp_lines_ok`.
- The four `awk -v m="modified: ... $BY"` restamps (`move-card.sh`, `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh`, and `lease.sh` `write_card` with its `by` and `until`): pass the stamp through `ENVIRON`, not `-v`, so no backslash is interpreted.
- `lease.sh`: reject a session id holding a backslash beside the existing slash, quote and space checks (the id is also a directory name).
- `merge/scripts/lanework-merge.py` `signer()`: quote `model` with the same rule as `heal-descriptors.py` `scalar()`; refuse a control character with a note, since the driver never aborts a merge.
- No new topic file: the rule lives in `lib.sh`; the one-line statement of it goes in `lanework/references/writes.md` where stamps are described, and other places keep linking to it.

## Verified

New smoke cases in `tests/smoke.sh`, next to the existing brace cases, driven by one loop over the values `{n}`, `a"b`, `a\`, `a\"}}}`, `x: y`, `#x`, each as name, model and session:

- For `found-board.sh`, `file-card.sh`, `post-comment.sh`, `post-ask.sh`, `move-card.sh`, `file-question.sh`, `settle-question.sh`, `file-record.sh`, `file-ticket.sh`, `claim-ticket.sh`, `resolve-ticket.sh` and `lease.sh stake`: the run exits 0 and the board validator reports no failures, or it exits non-zero and the board snapshot is unchanged. Fails today for `{n}`, `a"b` as session and `x: y`.
- Byte identity: the `session`, `name` and `model` substring of the `modified` line is the same after `post-comment.sh` and after `move-card.sh` for each value. Fails today for `a\`.
- A control character or empty name, model or session is refused by each script with nothing written (a newline value, an empty `--name`).
- `found-board.sh --name '{n}'` is refused with no folder created, or the founded board validates.
- `lanework-merge.py` signer: `--model 'a: b'` and `'{n}'` produce a comment the validator accepts.
- Existing bare stamps are unchanged: `--name claude --model claude-fable-5-2` writes `name: claude` unquoted (guards against churn in every board).

## Done when

- `tests/smoke.sh` passes with the new cases, and the new cases fail when `by_of` is reverted to its current body.
- For each of `{n}`, `a"b`, `a\`, `a\"}}}` as name, model and session, every stamp-writing script listed above either refuses with nothing written or writes a stamp that `python3 -I <board>/.schema/bin/lanework-validate.py <board>` accepts, byte-identical across scripts.
- `grep -n 'awk -v m=' skills/*/scripts/*.sh` shows no restamp that passes a stamp through `-v`.
- `found-board.sh` calls `stamp_args_ok` and `stamp_lines_ok`.

## Risks

- Quoting `name` and `model` changes stamps only for values outside `[A-Za-z0-9._-]+`; a model id with a space, slash or colon (`vendor/model`) now gets quotes. Readers: `lease.sh` reads `name` with `"?([^",}]*)`, which stops at an escaped quote, so a name holding `"` shows truncated in `lease.sh list` only; `work/scripts/lint-stamps.sh` and `lint-leases.sh` need a check that quoted values still read. The app reads real YAML, so no change there.
- Refusing control characters is a new exit 2 for values that used to be written; none can have been valid.
- Two implementations of the same quoting rule remain (bash `by_of`, Python `scalar()`); the smoke loop covers both with the same values.

## Recommendation

Build all. The card's four items are real and reproduced, and the same root cause is wider than listed (leading indicator characters, `: `, ` #`, commas, the merge driver's unquoted model). One quoting rule in `by_of` fixes them together and keeps today's stamps unchanged; the refusal check and the `ENVIRON` change are small and mechanical.
