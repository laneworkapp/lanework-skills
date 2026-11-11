---
schema: 1
kind: card
title: "Agents write future timestamps: the work skill never says a stamp comes from the clock"
order: 2048
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-11T23:17:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Main"}}
modified: {at: 2026-11-11T23:17:38Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills Main"}}
---
Agents working cards with the `work` skill type `created`, `modified` and `waiting.since` by hand, and some of those values are in the future. A later agent then bumps its own stamps past them to stay "later", so the error spreads. Threads sort by `created.at`, so an owner's answer can sort above the question it answers.

## Reproduce

Seen twice on the Lanework Pipeline board (app repo): up to 26 minutes ahead on 2026-10-11 (card 6f7089ca) and on 2026-11-10 (card 59ddaede). In the transcripts a sonnet shaper wrote all three stamps as literals and never ran `date -u`. A second shaper then pushed its own stamps past the bad one.

Why the skills allow it:
- `lanework/references/writes.md` § Every write ("Stamp it") and `work/templates/farmed-prompt.md` give a stamp's shape and its `by`, never where its time comes from.
- `work/scripts/` holds only `lint-ask.sh`. Nothing stamps or posts for `work`. The `plan` and `discovery` scripts stamp through `lanework/scripts/lib.sh` `now_utc`.
- Nothing checks for a future stamp.

## Fix

1. **Rule, stated once** in `lanework/references/writes.md` § Every write, and pasted into `work/templates/farmed-prompt.md`: every stamp comes from the clock at the moment of writing (`now_utc`, or `date -u +%FT%TZ`). Never type, copy or bump one past an existing stamp. The deliberate offset stays: the ask goes one second after its record (`work/references/writing.md`), taken as `now_utc 1`, not by bumping.
2. **`work/scripts/post-comment.sh <board> <card-uuid> --body F --model m [--in-reply-to u] [--ahead s]`**, stamped by `now_utc`, resolving the card's path fresh (`writes.md` § Paths). Point `writing.md` and `templates/ask.md` at it.
3. **`work/scripts/lint-stamps.sh <board|file>`** next to `lint-ask.sh`: fails any `created.at`, `modified.at` or `waiting.since` more than 60 s past the clock. Run it before every commit (`writes.md` § Every write, next to the validator).
4. Smoke cases for both scripts on a throwaway board, including a planted future stamp.

Out of scope: the matching WARN in the app's `lanework-validate.py` belongs to the Lanework side.

## Done when

- `writes.md` and `farmed-prompt.md` carry the clock rule. Nothing under `skills/` shows a hand-typed stamp as the thing to do.
- `post-comment.sh` and `lint-stamps.sh` exist, pass `bash -n`, and have smoke cases. `lint-stamps.sh` fails on a stamp 2 min ahead and passes at 1 s ahead.
- `tests/smoke.sh` passes.
