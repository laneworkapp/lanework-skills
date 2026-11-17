---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:38:32Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:38:32Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The rule text matches the body bullet for bullet and the lint meets every Verified-by bullet, measured. No blocking findings; 5 notes and 2 questions for the lead, both about the trial's ending line.

- **Stance**: adversarial. Trigger: the branch ships a rule that departs from the in-board guide to every plugin user, plus the lint that is the trial's only measuring instrument.
- **Round**: 1
- **Card**: [Let an agent clear waiting when it records an owner ruling given off the board](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3)
- **Branch**: `waiting-clears` at `0d6d5a6`

**Blocking**: none.

**Questions for the lead**

1. **The discovery chat record counts as `NO-QUOTE`.** The body's discovery row says `settle-question.sh` "already clears with a quoting record", so no change was needed there. That is wrong for this lint. `discovery/templates/ruling.md:19 @ 0d6d5a6` "**Owner answered in chat.** \"<owner's words, verbatim>\"" has no `>` line and no `**Given**` line. Measured: on a fresh discovery board, file a question, then run `settle-question.sh --record` (that shape) `--reply <ask>`. The lint prints `NO-QUOTE <card> <ask>` and exits 1. Every chat-settled discovery question that follows `rounds.md` to the letter will count against "none NO-QUOTE". There are three ways to fix it: discovery adopts the `>` + `**Given**` shape, the lint also accepts the discovery shape, or discovery boards stay out of the trial count. The body is frozen, so this is your call (or the owner's).
2. **The trial starts with three `NO-QUOTE` lines on Skills Pipeline.** Read literally, the ending line is "ten `QUOTED`, none `NO-QUOTE`", and "ends badly when any `NO-QUOTE` stays unfixed". All three lines predate the rule (baseline below). Decide before the trial starts whether to fix them with quoting records or to count only clears after the release, and say which in the closing comment.

**Notes**

1. `skills/work/scripts/lint-waiting-clears.sh:36 @ 0d6d5a6` "kind = (cr ~ /(^|[ {,])by:/ && cr ~ /kind:[ \t]*[\"\x27]?agent/) ? \"agent\" : \"human\"". The script counts any non-agent `by` as human, including `kind: shortcut`, a bare-name `by: x` and other kinds. The body says human means no `by`, or `kind: human`, and `watch/references/events.md` item 4 treats shortcuts as not human. Measured: an ask with no `waiting`, then a `{name: shortcuts, kind: shortcut}` comment, is silent, so that clear goes unlisted. The live boards hold only `human` (121) and `agent` (1032), so this never fires today.
2. Same file, line 35, "[0-9]{2}:[0-9]{2}:[0-9]{2}Z/". The schema's timestamp allows fractional seconds and offsets, but this match drops any such comment row. Measured: an ask stamped `10:00:00.123Z` is invisible, so the card is silent. The live boards have 0 such stamps, and agents stamp whole seconds from `now_utc`.
3. Same file, lines 31–32, "body && /^>/ { q = 1 }" / "/\*\*Given\*\*/". The quoting test is loose. Measured as `QUOTED`: a `>` line inside a code fence, `**Given** chat` with no colon, and one line `> yes **Given**: chat`. A lowercase `**given**` reads as `NO-QUOTE`. This matches the body's letter ("a `>` line and a `**Given**` line"), so the lint will pass sloppy records.
4. `tests/smoke.sh:787 @ 0d6d5a6` "wl_card 1 'waiting: {for: anyone,". No case puts `waiting:` in a card body. Measured: a mutant that reads `waiting:` anywhere in the file (body included) survives all 9 cases, and it would silently hide a cleared card whose body has such a line. The shipped script is right (measured: body `waiting:` is listed). Add a body-line case.
5. `skills/work/references/writing.md:53 @ 0d6d5a6` "`work/scripts/lint-waiting-clears.sh <board>` lists every agent clear". This cites in cross-skill form inside its own skill. The repo `CLAUDE.md` asks for `<dir>/<file>` within one skill, and the same section writes `scripts/post-ask.sh`. Wording only.

**Lint baseline on the live boards** (worktree script at `0d6d5a6`, 2026-11-17; every board byte-identical by `shasum` of all files before and after):

- **Skills Pipeline**: exit 1, `QUOTED 0, NO-QUOTE 3`. All three cards are in the same lane, and all predate the rule:
  - `4596a2cb…` ask `5156ff11…`: the 2026-11-14 hand clear named in the risks record, whose record is not in the new shape.
  - `48fa3910…` ask `738d4bc6…`: an ask from 2026-10-10 that never got an answer on the card.
  - `c5b171e1…` ask `e7c4a842…`: "Ruled in chat 2026-11-16", a record with no `>` line or `**Given**` line.
- **Board Runner Discovery**: silent, exit 0 (36 cards).
- **Card Lease Discovery**: silent, exit 0 (44 cards).

**Checked**

- **Correctness vs done-when**:
  - Rule text vs "The rule": every bullet is present. The app still clears, and an agent's reply never does. The exception is named as the owner's, ruled on this card, with no guide version number. Off-board only and same pass. `waiting.comment` must match, and a newer or different ask stays marked. The record shape is exact. The write is fresh, deletes the key whole and restamps. A human comment already after `since` is left to the app. Leans, `Recap:` clicks, answers to other questions and the agent's own summary are named as not rulings. "Nothing else", with `--clear-waiting` named. "Set it again" is kept.
  - No forbidden case is left open by this section. A farmed agent holds only the short form (`writing.md:9`), which says nothing about clearing, so it cannot use the exception and nothing in it contradicts the rule.
  - The record shape passes `lint-ask.sh` silently as a record (rc 0).
  - A grep of `skills/` for clear/waiting/remove finds no remaining "only the app clears" or "never remove it yourself". `writing.md:66`, `discovery/references/rounds.md:30`, `settle-question.sh`, `resolve-ticket.sh`, `move-card.sh` and `post-ask.sh` are consistent. Done-when 1–3 hold.
- **Lint vs "The trial"**: measured on a 25-fixture board in a `mktemp -d` path with spaces.
  - Listed correctly: block-form stamps, a human with no `by`, an ask after leading blank lines, a human reply before the newer ask, a human `in-reply-to` an older ask, a shared ask uuid across two cards (per card), `waiting:` in the body, CRLF, and quoted `in-reply-to` and `kind`.
  - Silent, correctly: a `**bold**` opener, a record starting with a backticked handle, a card with zero comments, block `waiting`, a human record `in-reply-to` the ask, `.trash`, `.schema` and board-level comments.
  - Identical ask and human timestamps → `NO-QUOTE`. That is conservative and visible.
  - The fixer's looser ask test (any `@` handle, no shape check) matches the body's definition ("a comment by an agent whose body starts with `@`"). That is right for counting clears.
  - Exit codes are 0, 1 or 2, it is silent when clean, it prints the count line, and the board is byte-identical after a run. It runs on `/bin/bash` 3.2.57 and passes `bash -n`.
  - The output makes the ending line checkable by counting the `QUOTED` and `NO-QUOTE` lines per board.
- **Project conduct**: `plugin.json` is untouched, and there is no CHANGELOG entry (none in the diff). `scripts/release.sh:40` dies without a `Version X.Y.Z: ` line, so the lead adds the user-facing entry in the release commit (a minor bump). There are no board writes in the code commit. The README § Sizes rows changed because `writing.md`, `events.md` and `SKILL.md` grew. `wc -w` agrees (444, 1,541, 409), and check-sizes needs those rows, so the body's "should not move" was the wrong forecast.
- **Both paths**: flow and block `waiting`, and flow and block stamps, are both handled, measured.
- **Fail-before**: OWN RUN agrees with the FIXER RUN. The 9 smoke cases, run at `a0b3c81`, fail with exit 127 (script absent). Mutants were each caught: the human test inverted, the `in-reply-to` check dropped (on the human side and on the record side), Given dropped, `>` dropped, newest-ask selection dropped, every agent comment treated as an ask, a human `@` treated as an ask, block `waiting` not read, a later human ignored, exit always 0, and dot folders not skipped. One mutant survived: body `waiting:` read as the key (note 4).
- **Test adequacy**: there are 9 cases beside `lint-stamps`, built the same way, and the read-only check uses smoke's own `sum()` (`tests/smoke.sh:230`).
- **Blast radius**: 6 files, as the fixer's START planned, including the README rows it named. There is no unexplained churn.
- **Population**: 85, 36 and 44 cards per board, every one at `<lane>/<card>` depth, so the glob reaches every card. My smoke run gives `smoke: 183 passed` (worktree, foreground, rc 0).

**Hypotheses**, written before reading [the fixer's START](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3) and its build record. 3 of 5 held.

1. The read-only check `sum "$WB"` is vacuous on a directory. Refuted: `sum` is smoke's own function.
2. Non-human, non-agent kinds count as human and hide a clear. Held (note 1).
3. Fractional stamps drop rows. Held (note 2).
4. A fenced `>` line or a colon-less Given counts as quoting. Held (note 3).
5. Another file under `skills/` still contradicts the rule. Refuted for the prose. The nearest miss is the discovery chat-record shape, which disagrees with the lint (question 1).
