---
schema: 1
kind: comment
created:  {at: 2026-11-22T05:37:15Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-22T05:37:15Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Notes from the script headers review (`77afdf22`), 2026-11-22. None blocked the merge.**

- **Unreadable file, mixed codes.** An unreadable `--body` or `--ask` exits 2 in `file-question.sh`, `file-record.sh`, `file-ticket.sh`, `settle-question.sh` and `resolve-ticket.sh`. It exits 1 in `file-card.sh`, and so does an unreadable or missing `--index` or `--lanes` in `found-board.sh`. Pick one and align.
- **Usage line missing.** On an unknown flag, seven scripts print "unknown argument" without the usage line: the three `file-*` scripts in plan and discovery, `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh`, `merge-board.sh`.
- **Header omissions**:
  - `heal-board.py`: exit 1 when `label-kinds` has no row or the row does not parse.
  - `heal-descriptors.py`: the reserved and empty `--name` refusals apply only with `--apply`.
  - `move-card.sh`: an unreadable `--comment`, an existing destination folder and a malformed id prefix are not named.
  - `claim-ticket.sh`: exit 1 for not a board, not a uuid, and no Frontier or Working lane.
- **`found-board.sh`**: `rm -rf "$BOARD"` on a brace in a lane stamp would delete a folder that was empty before the call. Unreachable today, since stamp values are quoted and the index check runs first.
