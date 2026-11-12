---
schema: 1
kind: card
title: "Agents write future timestamps: the work skill never says a stamp comes from the clock"
order: 5120
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-11T23:17:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Main"}}
modified: {at: 2026-11-12T00:44:11Z}
---
Agents type `created`, `modified` and `waiting.since` by hand, some land in the future, and the skills never say a stamp comes from the clock. This adds that rule once, a linter that catches a future stamp, and a script that posts a comment with a clock-taken stamp.

## Problem

A sonnet shaper wrote all three stamps as literals, up to 26 minutes ahead (Lanework Pipeline cards 6f7089ca on 2026-10-11 and 59ddaede on 2026-11-10). A later agent bumped its own stamps past them, so the error spread, and threads sort by `created.at`, so an owner's answer can sort above its question.

Why the skills allow it, checked on `main`:
- `lanework/references/writes.md:7` gives a stamp's shape and `by`, not where its time comes from. The guide does (`date -u +%FT%TZ`, § Stamping your work); no skill file repeats it.
- `work/templates/farmed-prompt.md:9` says to stamp with `by` and nothing about the time.
- `work/scripts/` holds only `lint-ask.sh`. Nothing stamps or checks stamps for `work`. `plan` and `discovery` scripts stamp through `now_utc` (`lanework/scripts/lib.sh`), so they cannot go wrong.
- A grep of `skills/` finds no hand-typed timestamp shown as an example, so the "nothing shows one" done-when already holds and only needs a check.

## Scope

**Minimum for 0.8.0** (fixes the bug and catches a repeat):
1. **The rule, once**, in `lanework/references/writes.md` § Every write: extend the "Stamp it" bullet at line 7, and add `lint-stamps.sh` to the "Validate before committing" bullet at line 12. `work/templates/farmed-prompt.md` gets one clause on line 9, not the rule restated: a farmed agent reads only what its prompt names, and the prompt line is the place it is missed. `work/references/writing.md` § Short form is left alone, since it is pasted verbatim into every farmed prompt.
2. **`work/scripts/lint-stamps.sh`**, next to `lint-ask.sh`.
3. **Smoke cases** for it.

**Can follow** (a convenience; the bug is closed without it):
4. **`work/scripts/post-comment.sh`** and its smoke cases, plus a one-line pointer in `work/references/writing.md` § The ask (line 48) and `work/templates/ask.md`. It makes the correct path the easy one for the most frequent write, but the rule plus the linter already catch a bad stamp.

**Not now**: a script that sets `waiting` and restamps `modified` (the card edit stays by hand, and the linter covers `modified.at` and `waiting.since`); the validator WARN (the app's side, out of scope).

## The rule (wording for `writes.md`)

Every stamp (`created`, `modified`, `waiting.since`) comes from the clock when you write it, in the same command as the write: `now_utc` from `lanework/scripts/lib.sh`, or `date -u +%FT%TZ`. Never type one, copy one, or bump one past another stamp to stay "later". One deliberate offset: an ask goes one second after its record (`work/references/writing.md`), taken as `now_utc 1` (`date -u -v+1S +%FT%TZ`).

About 90 words, one bullet. The one-second offset stays allowed, which is why the linter's limit is 60 s and not zero.

## Interfaces

**`lint-stamps.sh <board|file> [--slack s]`**, in `lint-ask.sh`'s style: one line per violation on stdout, `path: field <value> is <n>s ahead`, exit 1; silent exit 0 when clean; exit 2 on a missing path. `--slack` defaults to 60.
- Reads each `index.md` frontmatter only (the `created:`, `modified:` and `waiting:` lines) and compares `at:` and `since:` values to `now_utc <slack>` as strings, one `awk` pass over the board. Skips `.trash`, `.log`, `.schema` and `attachments`.
- Limit: only `YYYY-MM-DDTHH:MM:SSZ` stamps are compared. An offset stamp is skipped, not failed (the app and every skill write `Z`).
- Run it before every commit, beside the validator.

**`post-comment.sh <board> <card-uuid> --body F --model m [--name n] [--session s] [--in-reply-to u] [--ahead s]`**, modelled on `plan/scripts/claim-ticket.sh` (same flags, `require_model`, exit 2 with usage and nothing written when no model).
- `F` is a bare body with no frontmatter (refused if it starts with `---`). The script writes the file with `comment_file`, stamps `created`, `modified` and `by` from `now_utc ${ahead:-0}`, stages it outside the board, resolves the card path fresh (`ls -d "$BOARD"/*/<uuid>`) just before the `mv`, and prints the new comment uuid, which the ask's `waiting.comment` needs.
- Refuses (exit 1, nothing written) if another comment on the thread already has that second ("distinct second per comment"), naming `--ahead 1`. It runs `lint-ask.sh` on the staged file, so an ask that fails the lint never lands.
- `--name` defaults to `claude`, as in the plan scripts.

## Files touched

| file | change |
|---|---|
| `skills/lanework/references/writes.md` | rule in the "Stamp it" bullet; lint-stamps in the validate bullet |
| `skills/work/templates/farmed-prompt.md` | one clause on line 9 |
| `skills/work/scripts/lint-stamps.sh` | new |
| `skills/work/SKILL.md` | line 30 names `lint-stamps.sh` beside `lint-ask.sh` |
| `skills/work/scripts/post-comment.sh` | new (can follow) |
| `skills/work/references/writing.md`, `skills/work/templates/ask.md` | one-line pointer (can follow) |
| `tests/smoke.sh` | new cases after the lint-ask block (about line 607) |
| `README.md` | § Sizes counts for each edited `.md` file, and the date line |
| `CHANGELOG.md` | one user-facing entry under the 0.8.0 line |

New scripts need no README § Sizes row: `tests/check-sizes.sh` requires rows only for `SKILL.md` and `references/*.md`, and the README leaves scripts out. The edited files do change: `writes.md` (974) and `farmed-prompt.md` (154) in the minimum, `SKILL.md` (397), `writing.md` (1,154) and `ask.md` (278) with the follow-up; update each row, the `lanework` (4,150) and `work` (6,449) totals, and the summary table, then run `tests/check-sizes.sh`. No `plugin.json` change (no new skill folder).

## Risks

- **Pre-existing future stamps** make `lint-stamps.sh` fail on a board it did not cause. Checked: this board has none now. The fix for one is a hand restamp from the clock, and the message names the file.
- **Clock skew** between machines that share a board can look like a future stamp. The 60 s default covers normal skew; `--slack` raises it.
- **A farmed agent ignores the new clause.** The linter is what catches it; the rule alone does not.
- `now_utc N` uses `date -v`, macOS only, as every script here does (`CLAUDE.md`).
- Lane-level `modified` is stamped by the app and by agents' moves; the linter reads lanes too, so a bad move stamp is caught.

## Verification

Per the board's bar: `bash -n` and a real run against a scratch board outside the repo, output quoted in the closing comment. Smoke cases in `tests/smoke.sh`, using a board founded earlier in the file (never this one):
- `lint-stamps.sh` on a clean founded board: silent, exit 0.
- A card whose `modified.at` is `now_utc 120`: exit 1 naming the file and field.
- The same at `now_utc 1`: exit 0.
- A future `waiting.since`: exit 1. A single-file argument works. `--slack 300` passes the 120 s case. Missing path: exit 2.
- `post-comment.sh`: lands one comment that `validate` accepts and `lint-stamps.sh` passes; prints its uuid; a second post in the same second is refused, with `--ahead 1` it lands; `--in-reply-to` is written; an ask failing `lint-ask.sh` is refused with nothing written; no model gives exit 2 (add it to the existing `refused` list near line 440).
- `tests/smoke.sh` passes (it runs `bash -n`, `check-refs.sh` and `check-sizes.sh`).

## Done when

- Minimum: `writes.md` carries the clock rule once; `farmed-prompt.md` points at it; `grep -rnE 'at: 20[0-9]{2}-' skills` finds no typed timestamp. `lint-stamps.sh` exists, passes `bash -n`, fails a stamp 2 min ahead, passes one 1 s ahead, and has smoke cases. `tests/smoke.sh` passes, README counts match `wc -w`.
- With the follow-up: `post-comment.sh` exists with the smoke cases above, and `writing.md` and `ask.md` point at it.

## Recommendation

Build all of it in 0.8.0: `post-comment.sh` is about 50 lines over `comment_file` and `claim-ticket.sh`, and it removes the hand-typed stamp on the most common write. If the release must shrink, ship the minimum and move item 4 to a later card; the bug is closed either way.

Open calls for the owner: none.
