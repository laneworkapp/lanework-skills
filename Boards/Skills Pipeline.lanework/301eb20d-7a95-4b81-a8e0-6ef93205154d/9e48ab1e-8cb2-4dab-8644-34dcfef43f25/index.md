---
schema: 1
kind: card
title: "An ask posted without waiting on its card goes unnoticed by every lint and by the arming pass"
order: 4096
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}, {text: "watch", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-26T12:53:20Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:57:43Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
---
The arming pass reports a card whose newest ask is still open but whose `waiting` key is missing, so an ask posted with `post-comment.sh` no longer goes unnoticed.

## What happens

The reporting session posted an ask with its own helper, which wrote the comment and stopped. `post-ask.sh` (plugin 0.9.0) does both steps, but the session kept the old helper and, after many context summaries, kept the wording rules for an ask and lost the `waiting` step. The app showed no waiting mark on card 1a2818a7 of its Pipeline board.

Reproduced on a throwaway board (`mktemp -d`, founded with `found-board.sh`, card filed with `file-card.sh` in Ideas, ask file with `@anyone` on line 1, posted with `post-comment.sh ... --ahead 1`, run with `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID`):

```sh
lint-stamps.sh <board>          # no output, exit 0
lint-ask.sh <comment> <board>   # no output, exit 0
arm-pass.sh <board>             # no output, exit 0
lint-waiting-clears.sh <board>
# NO-QUOTE 844bcf13-004e-4e03-8225-9c33783b2c91 04278121-8538-4ed5-ad4f-df644c294e2f
# QUOTED 0, NO-QUOTE 1          (exit 1)
```

The same ask through `post-ask.sh --for anyone` leaves `waiting: {for: anyone, since: 2026-11-27T12:56:13Z, comment: 00adb254-...}` on its card.

Two corrections to the card's account:

- `lint-waiting-clears.sh` does report this case. Its header says an ask that never got a mark and an ask whose mark an agent cleared "look alike", and both print `NO-QUOTE`. Nobody runs it except `settle-question.sh` and the owner's trial, and its label and the `work/SKILL.md` line ("cards whose latest ask an agent cleared") hide that it also catches a never-set mark.
- `arm-pass.sh` is not only silent. With the same card in Shaping (an agent lane) it printed `arm`, a work order: `arm` requires a card that waits on nobody, and an unmarked ask is exactly that.

The open-ask rule was also run on hand-written cards (agent ask first line starting with `@`, no human comment after it). `lint-waiting-clears.sh` listed these and no others:

| case | result |
|---|---|
| open ask, no `waiting` | listed (right) |
| ask answered by a human, `waiting` cleared by the app | silent (right) |
| ask answered, then a second ask open | newest ask listed (right) |
| ask addressed to `@rzen`, a person | listed (right) |
| ask followed by an agent record in reply (a withdrawal) | listed as `NO-QUOTE` (right: only the app clears `waiting`, so a mark that is gone is a finding) |
| card in Done | listed (the arming pass already skips Done) |
| ask with `waiting` set | silent (right) |
| record that mentions `@anyone` mid-line | silent (right) |
| ask line wrapped in bold (`**@anyone** ...`) | silent (a miss, but no skill writes a bold ask; `lint-ask.sh` and `lint-waiting-clears.sh` both read `^@`, so they agree) |

Cost: `lint-waiting-clears.sh` on a generated board of 150 cards with 4 comments each took 12 s, and `arm-pass.sh` alone took 19 s. Calling the lint from the arming pass would add about 12 s, so the arming pass reads its own rows instead.

## Scope

| file | change |
|---|---|
| `skills/watch/scripts/arm-pass.sh` | New line kind `unmarked` (7 fields: `unmarked`, board, card uuid, lane, title, `-`, the ask's path). Uses the rows the loop already reads (change `read -r uuid path _ who rep _` to keep the first body line): newest agent comment whose first line starts with `@`, no owner comment after it or `in-reply-to` it, card frontmatter has no `^waiting:` line. Any lane but Done. Printed before the `held`/`stale` case, and in place of `arm`: a card with an open ask waits on the owner, marked or not. Header comment lists the kind. |
| `skills/watch/references/arming.md` | One table row for `unmarked`: set `waiting` on that ask by hand (`lanework/references/` guide § Mentions, `comment` = the ask's uuid); never post the ask again; then the card is no work order. |
| `skills/watch/references/responding.md` | One line where it points at `writing.md` § The ask: post an ask with `work/scripts/post-ask.sh`, which sets `waiting`. |
| `skills/work/references/sweep.md` | One row in the table, next to "Owner action, no ask": "Ask, no mark": an ask with no later human comment and no `waiting`; `lint-waiting-clears.sh <board>` lists it; you: set `waiting` on it, report it. |
| `skills/work/scripts/lint-waiting-clears.sh` | Header comment only: say the `NO-QUOTE` line also covers an ask never marked and that the arming pass's `unmarked` reads the same rule. No logic change. |
| `skills/work/SKILL.md` | Line 30: "cards whose latest ask an agent cleared" becomes "or never marked". |
| `tests/smoke.sh` | New cases in the arm-pass block (near line 2021): ask with no `waiting` prints one `unmarked` line; marked, answered, record-only and Done print none; the Shaping case prints `unmarked` and no `arm`. One case that `lint-waiting-clears.sh` and `arm-pass.sh` name the same card set on the fixture. |

Not touched: `post-comment.sh`, `post-ask.sh`, `lint-ask.sh`, `lint-stamps.sh`, `lint-leases.sh`, `commit-board.sh`, `plugin.json`, `README.md` (no skill added).

Overlap with card `b9a35b00` (missing lease): it also adds a finding line to `arm-pass.sh` and a sentence to the header kind list and `arming.md` table. Both use the same pattern, one tab-separated line per card and kind, report-only. The two cards touch the same three places (header list, the `case "$lstate"` area at the foot of the per-card loop, the `arming.md` table), but add separate lines. Whichever card lands second rebases on the other's kind line. Neither touches `lint-leases.sh`.

## Decided here, not asked

- The check lives in the arming pass plus the existing `lint-waiting-clears.sh`, not in a new lint script. A new script would repeat the rule that script already holds, and `smoke.sh` has about 40 lines that read its `NO-QUOTE` output, as do `settle-question.sh` (field 3) and the owner's trial (ten `QUOTED`, no `NO-QUOTE`). Adding a new verdict there would touch all of them.
- `post-comment.sh` is not changed. It cannot refuse a first-line handle: `post-ask.sh` calls it, `writing.md` § The ask tells the reader to post a several-person ask with `post-comment.sh --ahead 1` then set `waiting` by hand, and `tests/smoke.sh` posts asks through it in many places (the `bask.md` and `ask1.md` cases). A warning on stderr would fire on every legitimate ask, so it would be noise within a week.
- `commit-board.sh` does not run the lint. It runs no lint today and takes named paths, not a board. The arming pass and the sweep row are the two places a session already looks.
- An agent that withdraws an ask posts a record and leaves `waiting` alone: only the app clears it, so a missing mark after a withdrawal is a finding. This is the existing rule, not a new one.
- `unmarked` replaces `arm` for the card: arming a card that waits on an answer starts work the owner has not ruled on.
- Done is skipped by the arming pass, as for every other line. The lint still lists Done cards, unchanged.
- Bold-wrapped asks stay out: no skill writes one, and both lints read `^@`.
- The third suggestion (a long watch re-reads the scripts table after a plugin update) is not part of this card. It has no file to check and no way to fail a test. File it as its own Idea if wanted.

## Risks

- The rule exists twice (awk in the lint, bash in the arming pass). The smoke case that compares the two card sets on one fixture is what keeps them equal.
- A false `unmarked` when a human comment is older than the clock-second ordering allows (same second as the ask): the existing lint orders by `created.at` then uuid, and so must the arming pass.
- An ask whose first line starts with `@` but is a record (an agent quoting a handle) would be listed. `lint-ask.sh` has the same reading, and the guide says a handle on line 1 is an ask.
- A card that today prints `arm` with an open unmarked ask stops being armed. That is the intent: it waits on the owner.
- No new cost: the arming pass reads no extra file. Without the change the same lint would add about 12 s on a 150-card board.

## Verified by

- `tests/smoke.sh` passing with the new arm-pass cases (run by the implementer; the full run is not part of this shaping).
- A throwaway board under `mktemp -d`: card in Ideas, ask posted with `post-comment.sh`, then `arm-pass.sh <board>` prints one `unmarked` line with the ask's path; the same ask through `post-ask.sh` prints none.
- The same board with a human comment after the ask, with `waiting` set by hand, and with the card moved to Done: no `unmarked` line each time.
- `arm-pass.sh` timing on a generated 150-card board unchanged within a second.

## Done when

- On a throwaway board, an ask posted with `post-comment.sh` and no `waiting` is printed as one `unmarked` line by `arm-pass.sh` and as a `NO-QUOTE` line by `lint-waiting-clears.sh`.
- Marked, answered by a human, record-only and Done cards print no `unmarked` line.
- `arming.md`, `responding.md`, `sweep.md` and `work/SKILL.md` name the new line and `post-ask.sh` as described under Scope.
- `post-comment.sh` and the `NO-QUOTE` output are unchanged.
- `tests/smoke.sh` passes, including the new cases, and no change to `b9a35b00`'s lines is overwritten (rebased in whichever order they land).
