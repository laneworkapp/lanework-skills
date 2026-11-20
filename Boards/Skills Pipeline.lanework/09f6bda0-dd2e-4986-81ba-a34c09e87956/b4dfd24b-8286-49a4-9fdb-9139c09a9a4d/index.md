---
schema: 1
kind: card
title: "Scripts refuse valid cards that contain a triple closing brace"
order: 6144
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: plan, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T15:55:55Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T20:17:00Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Seven scripts abort when the staged card (or new card) contains `}}}` anywhere, so they refuse valid cards (a label whose kind carries an icon, or a JSON example in the body). The fix is one shared check in `lanework/scripts/lib.sh` that reads only the lines a script writes, used by every script, with `lease.sh` moving onto it.

Found in the review of [the lease script card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb), where `lease.sh` got its own narrowed guard (now on main).

## Today

The guard exists to catch a stamp glued together wrongly. Every restamping script greps the whole staged file, including lines it only copied.

| script | line | greps |
|---|---|---|
| `work/scripts/move-card.sh` | 114 | whole staged card |
| `work/scripts/post-ask.sh` | 93 | whole staged card |
| `discovery/scripts/settle-question.sh` | 50 | whole staged card, after the ruling is appended to the body |
| `plan/scripts/claim-ticket.sh` | 86 | whole staged card |
| `plan/scripts/resolve-ticket.sh` | 64 | whole output of `restamp` |
| `discovery/scripts/file-record.sh` | 62 | whole rendered front matter of a new card |
| `plan/scripts/file-ticket.sh` | 87 | whole rendered front matter of a new card |

`lanework/scripts/lease.sh:77-81` already checks only the `modified` and `claimed` lines. `lanework/references/writes.md:13` states the whole-file grep as the rule for every script.

- **Measured** (throwaway copy of the Skills Pipeline board, `move-card.sh`, no session id): a card whose front matter holds `labels: [{text: Low, rank: 3, icon: {glyph: arrow.down}, kind: {type: priority, text: Priority, icon: {glyph: flag}}}]` passes the board validator, and `move-card.sh` exits 1 with "triple brace after the restamp; nothing written". A card whose body holds `{"a": {"b": {"c": 1}}}` is refused the same way.
- **Read**: the other four restamping scripts use the same whole-file grep and fail the same way. `settle-question.sh` also greps the ruling text it appends, so a JSON example in a ruling is refused.
- **Read**: the two filing scripts write a whole new card. A title or label value that contains `}}}` is refused, though the title is a quoted string.
- The old body's line numbers for `claim-ticket.sh` (46), `resolve-ticket.sh` (56) and `post-ask.sh` (90) are stale; the table above is current. The old counts (497 of 2,323 cards) are the reviewer's and were not re-measured.

## Change

One approach: a shared function, not seven edits to the grep.

1. `lanework/scripts/lib.sh`: add `stamp_lines_ok <file> <key>...`. It reads the front matter of `<file>` (first `---` to the second), keeps each top-level line whose key is in the list plus its indented continuation lines, and returns 1 if any kept line contains `}}}`. The awk is the one now inline in `lease.sh`, made generic.
2. `work/scripts/move-card.sh`, `plan/scripts/claim-ticket.sh`, `plan/scripts/resolve-ticket.sh` (inside `restamp`), `discovery/scripts/settle-question.sh`: replace the whole-file grep with `stamp_lines_ok "$STAGE/index.md" order modified`. In `settle-question.sh` the check moves before the ruling is appended, so it never reads the body.
3. `work/scripts/post-ask.sh`: `stamp_lines_ok "$STAGE/index.md" waiting modified`.
4. `discovery/scripts/file-record.sh`, `plan/scripts/file-ticket.sh`: `stamp_lines_ok "$STAGE/fm.out" created modified`. The title is a quoted string and the label values are the script's own, so only the stamps can be glued wrongly.
5. `lanework/scripts/lease.sh`: call `stamp_lines_ok "$stage/index.md" modified claimed` in place of the inline awk, so one rule lives in one place. Behavior is unchanged.
6. `lanework/references/writes.md:13`: replace "`grep '}}}'` every touched file after" with "check `}}}` on the stamp lines you wrote only, with `stamp_lines_ok` in `lanework/scripts/lib.sh`; valid copied lines end in `}}}`".
7. `tests/smoke.sh`: see Done when.

A `}` in a `--model` or `--name` value (the card's item 5) still trips the check, because it lands on the `modified` line the script writes. That is the guard working, so it needs no separate fix here.

## Not in scope

The smaller findings from the same review stay as they are; each is its own card if the owner wants it:

- lease dates with fractional seconds or `+00:00` read as unreadable (`lease.sh`)
- a body with no trailing newline gains one on the first write
- CRLF cards refused as "no frontmatter" (`lease.sh`, `move-card.sh`)
- `compact_fm` rewriting a labels line the script does not own, on every lease write
- sanitizing `--model` values

Also not in scope: a validator-based check in place of the grep (heavier, and the board validator is not always present).

## Risks

- A stamp glued wrongly on a line outside the listed keys is no longer caught. The scripts write only the listed keys, so nothing else can be glued.
- `lease.sh` is the most-run script; swapping its inline awk for the shared function must be byte-for-byte equivalent. The existing lease smoke cases cover it.
- `stamp_lines_ok` must stop at the closing `---`, or a body line starting with a key name would be read as a stamp.

## Done when

- `tests/smoke.sh` passes.
- New smoke cases, one per script (`move-card.sh`, `post-ask.sh`, `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh`), on a throwaway board with a card holding an iconed label kind in its front matter and a `{"a": {"b": {"c": 1}}}` block in its body: the script exits 0, the board validates, and the card's labels line and body are byte for byte unchanged.
- A smoke case per filing script: a title containing `}}}` files and validates.
- A smoke case per script: a `--model` value containing `}}}` exits 1 and writes nothing.
- `grep -rn "grep -q '}}}'" skills/` prints nothing.

Bump: patch.
