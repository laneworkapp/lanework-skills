---
schema: 1
kind: comment
created:  {at: 2026-10-25T10:53:51Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-25T10:53:51Z, by: {name: fixer, kind: agent, model: opus}}
---
**Read through: v101 has real drift, and it is mostly layout. Only the compact form is written now, and skill scripts write config and labels lines past 120 characters, which the board's heal H17 rewrites.**

- **Measured**: the board's own `lanework-heal.py` v2, dry-run over the throwaway boards a smoke run leaves behind, prints H17 on every skill-founded board that has catalog kinds: `found-board.sh --labels` (config, 1 line to 9–37), the discovery and plan founders, and labels on discovery records and plan tickets (1 line to 2–3). Boards with no kinds come back clean.
- **Decided, writers emit compact**: a shared `compact_fm` in `lib.sh` runs the skill heal's H17 pass on a staged file. `found-board.sh` (and the discovery and plan founders through it), `file-ticket.sh` and `file-record.sh` call it.
- **Decided, mirror H17** in `lanework/scripts/heal-board.py` as `compact-collection`, with v2's guards (a key written twice, a comment inside the value, a block scalar, an anchor, an alias or a tag are left alone). A comment on the key's line stays, and a plain app timestamp stays plain. Smoke cases cover it, with the board's heal as the oracle on skill-written boards.
- **Decided, merge**: `lanework-merge.py` writes merged `labels` and `config` in the compact form. `config` was fully block, which v101 no longer writes.
- **Decided, prose**: in `writes.md`, the card-defaults bullet takes kinded entries (re-stamped, the card's own `single` value wins), a compact-form bullet is added, the Healing repairs list gains layout, and `.tracker.nosync/` is no longer git-ignored (seed v5). In `format.md`, `.tracker.nosync/` comes off the app-owned list.
- **No change**: Board Settings, `due-soon`, `thumb-sizes`, `logging` and the `text` kind wording. No skill says "no control in the app" or restates them. The merge `.gitignore` version rule reads `lanework-gitignore v5`. The removal of `--global` was already matched (`03a4252`).
- **Not done, for the lead**: `file-ticket.sh`, `file-question.sh` and `file-record.sh` don't union a lane's `card-defaults`. The rule predates v93, and skill-founded lanes carry none. Since v101, though, Board Settings can set them. This is a follow-up card, not drift.
- **NOTE (app repo)**: v101's "Ready-made skills" paragraph still names `pitlane` and `pitwall`. It is app text and out of scope here.
