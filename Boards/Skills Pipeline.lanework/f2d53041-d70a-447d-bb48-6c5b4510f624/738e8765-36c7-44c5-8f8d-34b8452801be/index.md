---
schema: 1
kind: card
title: "discovery records a chat answer in the work skill's quote format"
order: 7168
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-20T12:04:40Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-20T17:55:04Z}
---
Discovery writes its "owner answered in chat" record in a format the waiting-clear checker reads as unquoted, so the first chat answer on a discovery board after 0.9.0 would log a miss in the trial. Discovery should write the same record the `work` skill does.

Ruled by the owner on [the waiting-clear trial card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/818c5b26-a6c4-4d52-9463-52354af89bc3), 2026-11-20: "A: Change discovery to write the same quote format as the work skill. A small build card."

## Today

- `discovery/templates/ruling.md` § Chat record comment: `**Owner answered in chat.** "<owner's words, verbatim>"`. One line, no `>` line, no `**Given**` line.
- `work/references/writing.md` § The owner's exception: line 1 `**Owner ruled off the board.**`, the owner's words as a `>` quote line, then `**Given**: <where>, <date>`.
- `work/scripts/lint-waiting-clears.sh` counts a clear as `QUOTED` only with a `>` line and a `**Given**` line. Measured on a fresh board: `file-question.sh`, then `settle-question.sh --record --reply`, gives `NO-QUOTE`, exit 1.

## Change

- `discovery/templates/ruling.md`: the chat record takes the `work` shape. The rule itself stays in `work/references/writing.md`; the template links to it.
- `discovery/scripts/settle-question.sh`: with `--record`, refuse a record file that has no `>` line or no `**Given**` line, exit 2, nothing written. The script is where a discovery clear happens, so the check sits there.
- `discovery/templates/board.md` and `lanes.md`: read against the new shape; change only what contradicts it.
- `tests/smoke.sh`: the existing `settle-question.sh --record --reply` case writes the new shape and runs `lint-waiting-clears.sh` on that board, expecting `QUOTED 1, NO-QUOTE 0`. One new case for the refusal.

## Not in scope

- The lint. It keeps one accepted shape.
- Older discovery records on existing boards. Not rewritten; the trial counts only clears after 0.9.0.

## Risks

- **A record already drafted in the old shape** is refused by the script after the update. Intended; the usage line says what is missing.
- **Timing**: built after 0.9.0, the trial can log an unearned miss on a discovery board in between. Build before the release, or leave discovery chat answers out of the count until this ships.

## Done when

- A chat answer settled through `settle-question.sh --record --reply` on a throwaway board reads `QUOTED` in `lint-waiting-clears.sh`.
- `settle-question.sh` refuses a record without a quote line or a Given line and writes nothing.
- No file under `skills/discovery` shows the old one-line shape.
- Smoke passes with the changed case and the new one.

Bump: patch.
