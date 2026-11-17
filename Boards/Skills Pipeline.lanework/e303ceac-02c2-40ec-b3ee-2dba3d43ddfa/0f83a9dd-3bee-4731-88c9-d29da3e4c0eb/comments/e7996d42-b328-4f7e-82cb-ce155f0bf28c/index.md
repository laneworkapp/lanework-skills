---
schema: 1
kind: comment
created:  {at: 2026-11-17T15:02:22Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T15:02:22Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Built and green: `tests/smoke.sh` on `lease-script` at `112c236` says `smoke: 198 passed` (183 on main + 15 new lease cases); pushed.**

- **FAIL-BEFORE**: the lease cases run against `5e7519f` stop at case 1, `lease.sh: No such file or directory` (script absent: the honest baseline for a new script). [log](attachments/0d31f7b4-0d16-4631-ae02-693fd9419eda/blob.txt)
- **Gate**: 198 `ok` lines, exit 0, 201 s; the lease cases add about 22 s. `pgrep -fl lease.sh` after the run: empty. [log](attachments/0fdc8b29-0112-4135-8e47-9246563eb300/blob.txt)
- **Decided, layout**: `lease.sh` runs `compact_fm`, so the heal's layout wins (the body's Risk). A real session id gives the 3-line block; a short id fits one flow line. Case 1 uses a uuid-length id and asserts the block.
- **Decided, `CLAUDE_PID`**: required by `stake` only. `check` and `renew` restart a timer with the environment's `CLAUDE_PID`, else the one saved at stake, so a script without it is never blocked.
- **Decided, lost memory**: a `<card>.lost` directory (`mkdir`, atomic) gates the one loss record between timer and `check`. `stake`, `renew` and `release` on a lost card exit 3 and write nothing, unless `release --force`.
- **Decided, `<other>`** in the loss record is `none` when `claimed` was removed. The branch is read with `git symbolic-ref`, so an unborn branch is named.
- **Decided, `list`**: tab-separated: uuid, title, `name (session)`, `N min left` / `N min lapsed` / `-`, state.
- **Departure (lead's ruling)**: the merge row asserts the later side's `claimed` whole and no merge comment; the body's "loser's text in the merge comment" is not built. Measured: the merged board names the losing session nowhere; only git history keeps it. [log](attachments/1bf6dfca-786d-4624-8f66-cee77a841697/blob.txt)
- **Measured, front matter**: a block-form `claimed` survives byte for byte through `move-card.sh` (plain, `--top`, `--clear-waiting`), `post-ask.sh`, `settle-question.sh` (settled, parked), `claim-ticket.sh` and `resolve-ticket.sh`; `post-comment.sh` never rewrites the card. Each result validates. [log](attachments/39357b5a-e34f-4533-881e-f0079bae0832/blob.txt)
- **Pending, the lead's**: the two manual checks; the CHANGELOG entry at release.
