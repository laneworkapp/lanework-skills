---
schema: 1
kind: card
title: "Script headers disagree with their code in about forty places"
order: 1024
labels:
  - {text: "lanework", kind: {type: "skill", text: "Skill"}}
  - {text: "work", kind: {type: "skill", text: "Skill"}}
  - {text: "plan", kind: {type: "skill", text: "Skill"}}
  - {text: "discovery", kind: {type: "skill", text: "Skill"}}
  - {text: "merge", kind: {type: "skill", text: "Skill"}}
  - {text: "heal", kind: {type: "skill", text: "Skill"}}
  - {text: "watch", kind: {type: "skill", text: "Skill"}}
created:  {at: 2026-11-21T18:45:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T18:45:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
Script header comments disagree with their code in about forty places across seven skills, so an agent that reads a header as the script's contract gets wrong exit codes, wrong refusals and a few wrong promises.

## Problem

Each script's header states its usage, what it writes and its exit codes, and the skills point agents at those headers. A read of all 28 scripts against their code found the mismatches below. Most are omissions (an exit code or a fallback the header never mentions). A few are promises the code does not keep. Each item is from one read of the source and has not been re-checked line by line: shaping re-checks each before it is proposed.

## Where the code looks wrong, not the header

Recommended: fix the code for these, since the header states the better behavior.

- `work/scripts/move-card.sh:95-98, 114-115`: with `--comment`, the comment is posted before the move, so it stays on the card when a later step fails, and the "nothing written" messages are then false. A lease-lost exit 3 from `post-comment.sh` during `--comment` is reported as "comment was refused" with exit 1 (`:97`).
- `lanework/scripts/found-board.sh:68-70`: an unfilled template slot is caught after `mkdir -p "$BOARD"`, so that refusal leaves an empty board folder.
- `merge/scripts/lanework-merge.py:730, 1098`: `resolve --model` with no value, or a driver call with fewer than 4 arguments, ends in a Python traceback with exit 1, not a usage message.
- `work/scripts/lint-ask.sh:17`: the unreadable-file message goes to stdout, not stderr.
- `lanework/scripts/heal-board.py:1204`: the usage string printed on a bad board omits `--ignore-board-copy`.
- `lanework/scripts/lease.sh:33`: the usage string shows `[--force]` on every subcommand; only `release` takes it. `_timer` with a wrong argument count exits 2 silently (`:261`).

## Where the header should follow the code

**lanework**

- `found-board.sh:2-12`: exit 2 lists only the label-kind refusals. Also exit 2: a blank flattened title (`:37`), a reserved `--var` name (`:41`), a missing `--labels` when the template holds `{{label_entries}}` (`:46`), `--labels` with no slot for it (`:60`). Exit 1 for unknown arguments, an unreadable template or lanes file, and a non-empty folder is unstated.
- `found-board.sh:3-4` and every script that calls `require_model`: `--model` is shown as always required; `CLAUDE_MODEL` is accepted in its place (`lib.sh:26-30`). In `work`: `file-card.sh:3,16`, `move-card.sh:3,23`, `post-ask.sh:3,22`, `post-comment.sh:3,21`.
- `heal-board.py:1-55`: no exit codes. Code: 64 for bad usage, an unknown flag, `--apply` without `--model` or with a reserved or empty `--name`; 2 when the board ships its own heal and `--ignore-board-copy` is absent. `-h`/`--help` is unstated.
- `lease.sh:12-13`: the exit-2 list names a missing `CLAUDE_PID`, which applies to `stake` only (`:280`), and omits an unknown subcommand or argument, `--force` off `release` (`:272`) and "not a board" (`:282`). Exit 3 is described only as "lost"; it also covers `renew` on a card another session holds that this one never held (`:321`), and `stake` or `release` after this session already lost the card.
- `read-board.sh:4`: a missing `order` prints as `999999999` (`:17-25`), and a card id is cut to 8 characters (`:25`). Neither is stated.

**work**

- `lint-ask.sh:2-13`: exit 2 is unstated (`:16` no argument, `:17` unreadable file). "Under 80 words" is tested as `-le 80` (`:41`), so exactly 80 passes.
- `move-card.sh:6-8`: "every other line stays byte for byte", but indented continuation lines under `order` and `modified` are dropped (`:107-111`).
- `file-card.sh:11-13`: exit 1 for a brace in the stamp values is unstated (`:43`), as is a validator line containing `DEPRECATED` counting as failure (`:51`; same rule at `move-card.sh:121`).
- `commit-board.sh:52-56`: unstated: exit 1 when the save file cannot be created (`:123`), exit 1 on a fetch failure under `--push` (`:175`), a fetch failure without `--push` only warning (`:176`). Line 52 lists a bad `LANEWORK_PUSH_TIMEOUT` unconditionally; it is an error only with `--push` (`:73`, as line 18 says).
- `lint-waiting-clears.sh:11-12`: the sentence is garbled before "then `QUOTED <n>, NO-QUOTE <m>`". QUOTED-only output exiting 0 is unstated (`:96`).
- `post-comment.sh:7`: says an ask goes one second after its record through `--ahead 1`; `post-ask.sh` waits for the clock instead (`:74-76`). Lines 16-18 read as if a never-held result allows `--release`; only a held result does (`:72`).

**plan**

- `claim-ticket.sh:6`: the comment is `**Claimed** by <name>`; the code appends `, session <s>` with `--session` (`:88`).
- `file-ticket.sh:8`: a dependency is "a ticket already on the board"; the code checks only that the card exists, in any lane, and refuses only Out of scope (`:53-63`).
- `resolve-ticket.sh:6-8`: says `waiting` is dropped; `claimed` is dropped too, on every resolve (`:94`). Stated only in the lease paragraph (`:12`).

**discovery**

- `found-discovery-board.sh:3`: the usage line omits `[--labels k,...]`, which line 4 and the code support (`:17-24`).
- `settle-question.sh:5-6`: reads as if the card comes from Asked; the code takes it from any lane (`:41-43, 102`).
- Exit-code convention differs inside the skill: `settle-question.sh` uses 2 for usage errors and 1 for refusals; `file-question.sh` and `file-record.sh` (and `plan/scripts/file-ticket.sh`) use 1 for bad arguments and 2 only for a missing model. Decide during shaping whether to align the code or only state each.

**merge**

- `lanework-merge.py:4-8`: no exit codes (2 with the usage text for an unknown subcommand or fewer than 2 arguments, `:1241-1243`). `install` is described as one driver; it also registers `merge.lanework-inner`, run with `--quiet`, and `merge.lanework.recursive` (`:1224-1228`). `--quiet` always exiting 0, even when text would be lost, is unstated (`:745-746`).
- `merge-board.sh:5`: exit 1 for a bad argument or a path that is not a repo is unstated (`:15-17`).

**heal**

- `heal-descriptors.py:3-16`: names exit 2 and 3 only. Exit 64 covers every other usage error (`:493-521`). The reserved `--name` values are unstated (`:62, 514`), and the usage line omits `-h`/`--help` (`:499`).

**watch**

- `watch-boards.sh:15`: "the root joins fswatch"; the code passes the resolved `watch`, `work` and `lanework` subfolders (`:62-63, 76`). The header states no exit codes and does not name `fswatch` and zsh as requirements.
- `arm-pass.sh`: no exit codes stated (2 at `:31, 34, 44`; 1 when `lease.sh list` fails, `:112`).

## Scope

- Touches only header comments, docstrings and usage strings in the 21 scripts named above, plus the code fixes in the first list if approved.
- Out of scope: any behavior change beyond that list, and the skill reference files.

## Risks

- A header rewritten from a wrong reading replaces one mismatch with another: re-check each line before editing.
- The `move-card.sh` and `found-board.sh` fixes change what is left on disk after a refusal; each needs a smoke case that fails without the fix.

## Verify

`tests/smoke.sh` passes. Every changed script passes `bash -n` (or `python3 -m py_compile`). Each code fix has a new smoke case on a throwaway board.

## Done when

Every item above is either fixed (header or code) or ruled out with a reason in the thread, and a fresh read of each touched header against its code finds no mismatch.
