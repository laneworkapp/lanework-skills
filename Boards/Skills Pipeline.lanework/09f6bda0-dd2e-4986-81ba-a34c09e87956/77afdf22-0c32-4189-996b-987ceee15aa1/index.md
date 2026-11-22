---
schema: 1
kind: card
title: "Script headers disagree with their code in about forty places"
order: 3072
labels:
  - {text: "lanework", kind: {type: "skill", text: "Skill"}}
  - {text: "work", kind: {type: "skill", text: "Skill"}}
  - {text: "plan", kind: {type: "skill", text: "Skill"}}
  - {text: "discovery", kind: {type: "skill", text: "Skill"}}
  - {text: "merge", kind: {type: "skill", text: "Skill"}}
  - {text: "heal", kind: {type: "skill", text: "Skill"}}
  - {text: "watch", kind: {type: "skill", text: "Skill"}}
created:  {at: 2026-11-21T18:45:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-22T03:39:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Script headers will state the exit codes, refusals and outputs their code actually produces, and seven small code defects behind those headers get fixed, so an agent that reads a header as the script's contract stops getting wrong exit codes, a stray comment or an empty board folder.

## Problem

Every listed item was re-checked line by line against `main` at `95dd278` (which includes the `label-card` and `settle-recap` merges). Line numbers below are as they are on `main` now. Of the card's items, 36 are confirmed, 4 are partly wrong and 2 are wrong (dropped). Checking turned up 6 more. Reproductions ran on throwaway boards under `mktemp -d` with a made-up session id, and those folders have been removed.

### Code defects

1. **`work/scripts/move-card.sh:95-98` posts `--comment` before its last refusals.** Confirmed and reproduced. The comment goes through `post-comment.sh` at `:95-98`, and the frontmatter and triple-brace refusals come after it at `:114-115`, each saying "nothing written". A card whose `index.md` has no frontmatter, moved with `--comment c.md`, printed `move-card.sh: .../index.md has no frontmatter; nothing written`, exit 1, and `comments/` then held one new comment. A validator failure after the `mv` (`:121`) also leaves the comment, which the header never says.
2. **`move-card.sh:97` reports a lost lease as a refused comment.** Confirmed and reproduced with a stub `lease.sh` in a copied skills tree, answering `never-held` (4) to the move's check and `lost` (3) to the comment's. Output: `post-comment.sh: this session's lease on 83ddaaed is lost ...; nothing written`, then `move-card.sh: the comment was refused; card not moved`, exit 1. The header (`:18`) promises exit 3 for a lost lease. In real use this needs the lease lost between the two checks, so it is a narrow race. `post-ask.sh:77` already passes a 3 through.
3. **`lanework/scripts/found-board.sh:68` creates the board folder before the template is rendered (`:70`).** Confirmed and reproduced. `found-board.sh "$T/Slot.lanework" --index pipeline-index.md --lanes pipeline-lanes.md --var project=x --model smoke` printed `render: {{verified}} unfilled in .../pipeline-index.md` and exited 255, leaving `Slot.lanework/` empty. A retry succeeds, because an empty folder is accepted. Exit 255 appears in no header.
4. **`merge/scripts/lanework-merge.py:730, 1098` raise tracebacks on short argument lists.** Confirmed and reproduced. `resolve <repo> --model` ended `IndexError: list index out of range`, exit 1. `driver a b` and `driver --quiet a b c` ended `ValueError: not enough values to unpack`, exit 1. Found while checking: `resolve <not a repo>` and `install <not a repo>` end in `RuntimeError: git rev-parse --show-toplevel: fatal: cannot change to ...`, exit 1. `merge-board.sh:18` guards that path for its own callers. Git always passes the driver four arguments, so only a hand call reaches the driver case.
5. **`work/scripts/lint-ask.sh:17` prints its unreadable-file message on stdout.** Confirmed and reproduced: with stderr discarded, `lint-ask.sh missing.md` still printed `no such file: ...`, exit 2. Every other message and usage line in the lints goes to stderr. Found while checking, also a code fix: `:41` tests `-le 80`, so an ask of exactly 80 words passes (reproduced: 80 words, exit 0; 81 words, exit 1). The rule in `work/references/writing.md:43` and the lint's own message both say "under 80".
6. **`lanework/scripts/heal-board.py:1205` prints a usage line without `--ignore-board-copy`.** Confirmed (the card said `:1204`). On a non-board the output was `usage: heal-board.py <board> [--apply --model M [--name N] [--session S]]`, exit 64. The docstring's usage line (`:5`) does list the flag.
7. **`lanework/scripts/lease.sh:33` and `:261`.** Confirmed and reproduced. The usage string puts `[--force]` after all four subcommands, but `check ... --force` printed `lease.sh: --force is release's`, exit 2 (`:272`). `lease.sh _timer a b` exited 2 with no output (`:261`).
8. **Found while checking: `watch/scripts/watch-boards.sh:83` exits 0 when `fswatch` is missing.** Reproduced with `PATH=/usr/bin:/bin`: the only output was `watch-boards.sh:83: command not found: fswatch`, and the exit was 0. A Monitor running the watch just ends, and nothing reads as a failure.

### Header items, by skill

**lanework**

9. `found-board.sh:2-12` states exit 2 only for label kinds. Confirmed: it also exits 2 for a blank flattened title (`:37`), a reserved `--var` (`:41`), a template with `{{label_entries}}` but no `--labels` (`:46`) and `--labels` with no slot (`:60`). It exits 1 for an unknown argument (`:30`), a flag with no value (`${2:?}`, `:23-29`), an unreadable template or lanes file (`:34-35`), a missing `label-kinds.md` (`:50`) and a non-empty folder (`:62-63`; line 12 says "Refuses" but gives no code). None of those codes is stated.
10. `CLAUDE_MODEL` stands in for `--model` (`lib.sh:26-30`), but no script header says so, and every usage line shows `--model m` as required. Confirmed, and wider than the card says: all 13 callers of `require_model` are affected (`found-board.sh`, `lease.sh`, `file-card.sh`, `label-card.sh`, `move-card.sh`, `post-ask.sh`, `post-comment.sh`, `file-question.sh`, `file-record.sh`, `settle-question.sh`, `file-ticket.sh`, `claim-ticket.sh`, `resolve-ticket.sh`). Only `found-plan-board.sh:8` and `found-discovery-board.sh:5` mention it.
11. `heal-board.py:1-55` states no exit codes. Confirmed. From `:1187-1252`: 64 for an unknown argument, no board or not a board, `--apply` without `--model`, and `--apply` with a reserved or empty `--name`; 2 when the board ships its own heal and `--ignore-board-copy` is absent; 0 otherwise. `-h`/`--help` prints the docstring and exits 0, which is unstated. Reasoned from `:1180`: a card moved during the heal exits 1 with a message.
12. `lease.sh:12-13`. Partly confirmed. "Not a board" exits 2 and is unstated (`:282`; reproduced, exit 2). `renew` on a card another session holds, which this session never held, exits 3, not 1 (`:321`), and the header calls 3 only "lost". The exit list names `no CLAUDE_PID` without saying it applies to `stake` only (`:280`), although line 11 says it. Wrong in part: an unknown subcommand or argument, and `--force` off `release`, are usage errors, which the header already covers under "2 usage". `stake` and `release` after this session lost the card (`:289`, `:337`) are "lost", which it also covers. `lanework/references/writes.md:68`, which the header names as the authority for the codes, has the same two gaps.
13. `read-board.sh:4-5`. Confirmed: a lane or card with no `order` prints `999999999` as its order (`:17`, `:23`), not just sorting last, and a card id prints as its first 8 characters (`:25`). It exits 1 for no argument (`:8`) or not a board (`:9`), which is unstated.

**work**

14. `lint-ask.sh:2-13` never states exit 2. Confirmed: exit 2 for no argument (`:16`) or an unreadable file (`:17`). (The 80-word item is in item 5.)
15. `move-card.sh:9` says "Every other line stays byte for byte". Confirmed, as a wording gap: the indented continuation lines of a block-form `order`, `modified`, or `waiting` with `--clear-waiting`, are dropped with their key (`:107-112`). The comment at `:103` says so, and the header does not.
16. `file-card.sh:11-13`. Confirmed at moved lines: a brace in the stamp values exits 1 (`:45`, the card said `:43`), and a validator line containing `DEPRECATED` counts as a failure (`:53`; same rule at `move-card.sh:121`). Neither is stated. Found while checking: a `--label` value that a closed kind does not list also exits 1 through `union_labels --strict` (`:43`, `lib.sh:235`). `label-card.sh:13` states this, and `file-card.sh` does not.
17. `commit-board.sh:52-56`. Confirmed. Unstated exits: 1 when the save file cannot be created (`:123`) and 1 on a fetch failure under `--push` (`:175`). Also unstated: a fetch failure without `--push` only warns (`:176`). Line 52 lists a bad `LANEWORK_PUSH_TIMEOUT` as exit 2 unconditionally, but it is checked only with `--push` (`:73`), as line 18 says.
18. `lint-waiting-clears.sh:9-12`. Confirmed: lines 9-11 were inserted between the output list and "then `QUOTED <n>, NO-QUOTE <m>`", so line 12 now dangles. Output with QUOTED lines only exits 0 (`:96`) and is not silent, which is unstated.
19. `post-comment.sh:6-7` says an ask goes one second after its record through `--ahead 1`. Confirmed: `post-ask.sh:72-74` waits for the clock instead. Wrong in part: lines 16-17 already say `--release` acts "only for a lease the check found held". What is unstated is that `--release` on a never-held card prints a note on stderr and exits 0 (`:87`).

**plan**

20. `claim-ticket.sh:6` says the comment reads `**Claimed** by <name>`. Confirmed: with `--session`, `:88` appends `, session <s>`.
21. `file-ticket.sh:8` says a dependency is "a ticket already on the board". Confirmed: `:53-54` checks only that a card with that uuid exists in some lane, and `:57-61` refuses only Out of scope. The header states no exit codes at all (`:31`, `:40`, `:42-45`, `:52`, `:54`, `:58`, `:87` all exit 1, and `require_model` exits 2).
22. `resolve-ticket.sh:5-8` says `waiting` is dropped, but `claimed` is dropped on every resolve too (`:94`), not only on a held lease, which is where lines 12-13 put it. Confirmed. Found while checking: each unblocked ticket also loses its `waiting` (`:116`, `restamp` without `claimed`), and the script prints a `resolved <id> -> <lane> (order <n>)` line before the link (`:101`). Line 10 names only the link.

**discovery**

23. `found-discovery-board.sh:3` leaves `[--labels k,...]` out of the usage line. Confirmed (`:17-19`), and the `${1:?}` message at `:9` omits it too.
24. `settle-question.sh:5-6` "reads as if the card comes from Asked". **Wrong, dropped**: no line of the header (`:2-11`) names a source lane, and Asked is not mentioned.
25. Exit codes differ by script for usage errors. Confirmed and tabulated under Open call below.

**merge**

26. `lanework-merge.py:4-8`. Confirmed: no exit codes (2 with the docstring for an unknown subcommand or fewer than 2 arguments, `:1241-1243`; `resolve` 0 or 1, `:1213`). `install` is described as one driver, but it registers `merge.lanework` plus `merge.lanework.recursive = lanework-inner`, whose driver runs with `--quiet` (`:1224-1228`). `--quiet` writes the merged file and exits 0 even when one side's text would be lost (`:745-746`). It still exits 1 for a non-board path, a rename-paired card or an error (`:736-741`, `:760`).
27. `merge-board.sh:5`. Confirmed at moved lines: it exits 1 for an unknown argument (`:15`), a path that is not a repo (`:18`) and no argument (`:10`, reproduced), and passes on `resolve`'s 1 when anything is left. Only exit 0 is stated.

**heal**

28. `heal-descriptors.py:3-16` names only exits 2 and 3. Confirmed: 64 covers a flag with no value, an unknown argument, no board, `--expect` without `--apply`, an empty or reserved `--name`, a non-board and missing templates (`:493-521`). The reserved names (`:62`: anyone, board, healer, shortcuts, tracker) are unstated, and the usage line (`:5`) omits `-h`/`--help` (`:499`).

**watch**

29. `watch-boards.sh:15` says "the root joins fswatch". Confirmed: fswatch gets the resolved `watch`, `work` and `lanework` folders (`:58-59`, `:83`), not the root. Partly wrong about exit codes: line 12 states exit 2 for a bad `--skills` root. Still unstated: exit 2 for usage (`:35`, `:40`, `:42`), not a board (`:47`) and two boards sharing a name (`:52`). The `zsh` shebang is the requirement, and fswatch is named on line 2. The real gap is item 8.
30. `arm-pass.sh`. **Partly wrong**: exit 1 when `lease.sh list` fails is stated at `:22`. Exit 2 is unstated: no argument (`:29`), not a board (`:31`), no `board-kinds.md` (`:41`). The card's `:34, 44` are now `:31, 41`.

## Change

Each group below can go to one fixer. Header-only means comment, docstring or usage-string text with no behavior change: `bash -n` or `python3 -m py_compile` is its check. A code fix needs a smoke case that fails before the fix. A header must state each exit code with the literal phrase `exit <n>` (case-insensitive), so the guard in `## Verified` can find it.

### lanework (`skills/lanework/scripts/`)

- **Code, item 3**: `found-board.sh`: move `mkdir -p "$BOARD"` below `render` and `compact_fm`, and wrap `render` so a failure prints its message and exits 2, nothing written.
- **Code, item 6**: `heal-board.py:1205`: add `[--ignore-board-copy]` to the usage string, worded like docstring line 5.
- **Code, item 7**: `lease.sh:33`: write the usage as `lease.sh stake|renew|check <board> <card-uuid> --model m [--name n] | lease.sh release <board> <card-uuid> --model m [--name n] [--force] | lease.sh list <board>`. At `:261`, a wrong `_timer` argument count prints `lease.sh: _timer is internal (started by stake, check, renew)` on stderr before its exit 2.
- **Header, items 9, 11, 13**: in `found-board.sh` (with item 3's exit 2), the `heal-board.py` docstring and `read-board.sh`, add the exit codes as listed in `## Problem`.
- **Header, item 12**: `lease.sh:12-13`: add "not a board" to exit 2, scope `no CLAUDE_PID` to `(stake)`, and extend 3 to "lost, or renew on another session's claim". Make the same two additions to `lanework/references/writes.md:68`, the file the header names as the authority. This is the one reference-file line the card touches.
- **Header, item 10**: in each of the 13 `require_model` callers, the no-model clause reads `no model (--model, else CLAUDE_MODEL)`. Usage lines keep `--model m`.

### work (`skills/work/scripts/`)

- **Code, items 1 and 2**: `move-card.sh`: move the `--comment` block (`:95-98`) below the staging checks (`:114-115`), just before the first `mv` at `:117`. A post-comment exit 3 is passed through as exit 3 with move-card's own lease-lost line, as `post-ask.sh:77` does. Header `:9-15`: the comment lands only once every refusal has passed, and a validator failure after the `mv` leaves it.
- **Code, item 5**: `lint-ask.sh:17`: the message goes to stderr as `lint-ask.sh: no such file: <f>`. `:41`: `-lt 80`. The message stays as it is.
- **Header, items 14-19**: `lint-ask.sh` (exit 2), `move-card.sh:9` (block-form continuation lines go with their key), `file-card.sh:11-13` (brace exit 1, `DEPRECATED`, closed-kind value), `commit-board.sh:7` and `:52-56` (fetch failure: exit 1 with `--push`, a warning without it; save file exit 1; `LANEWORK_PUSH_TIMEOUT` "with --push"), `lint-waiting-clears.sh:9-12` (move "then `QUOTED <n>, NO-QUOTE <m>`" up to follow line 8; QUOTED-only output exits 0), `post-comment.sh:6-7` (`post-ask.sh` waits for the clock; by hand, `--ahead 1`) and `:16` (never held: a note, exit 0).

### plan (`skills/plan/scripts/`), header only

- Items 20-22: `claim-ticket.sh:6` (`**Claimed** by <name>[, session <s>]`), `file-ticket.sh:8-12` (any existing card in any lane, only Out of scope refused, plus its exit codes), `resolve-ticket.sh:5-10` (`claimed` and `waiting` both dropped on every resolve, unblocked tickets lose `waiting`, the `resolved` line is printed).

### discovery (`skills/discovery/scripts/`), header only

- Item 23: add `[--labels k,...]` to `found-discovery-board.sh:3` and to the `:9` usage message. The exit-code statements in `file-question.sh`, `file-record.sh` and `settle-question.sh` follow the open call.

### merge (`skills/merge/scripts/`)

- **Code, item 4**: `lanework-merge.py`: `cmd_driver` with fewer than 4 paths, or `cmd_resolve` with `--model` last, writes the docstring to stderr and returns 2, as `main` does. `main` catches the `RuntimeError` from `git rev-parse` in `resolve` and `install`, and prints `lanework-merge: not a git repo: <path>`, exit 2.
- **Header, items 26-27**: the docstring states the exit codes per subcommand, the inner-merge-base driver and `--quiet` returning 0. `merge-board.sh:5` states exit 1.

### heal (`skills/heal/scripts/`), header only

- Item 28: the docstring states exit 64 and what it covers, lists the reserved names, and adds `[-h|--help]` to line 5.

### watch (`skills/watch/scripts/`)

- **Code, item 8**: `watch-boards.sh`, before the first `snap`: `command -v fswatch >/dev/null || { echo "watch-boards.sh: needs fswatch (brew install fswatch)" >&2; exit 2 }`.
- **Header, items 29-30**: `watch-boards.sh:15` ("the resolved watch, work and lanework folders join fswatch"), plus its exit 2 list and the fswatch requirement. `arm-pass.sh`: add exit 2.

### Exit-code convention (owner's ruling: option C)

A usage error (an unknown flag, a missing positional or flag value, a missing required flag, a value outside its set) exits 2 in every shell script and in `lanework-merge.py`. A refusal stays 1, and a lost lease stays 3. Twelve scripts change:

- `file-question.sh`, `file-record.sh`, `file-ticket.sh`: every bad-argument path, now 1.
- `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh`: the `${N:?}` paths (a missing positional or flag value), now 1.
- `found-board.sh`: an unknown argument and a flag with no value, now 1. `found-discovery-board.sh` and `found-plan-board.sh` pass its codes through, and their own `${1:?}` paths exit 2 as well.
- `read-board.sh`, `frontier.sh`, `merge-board.sh`: no argument or an unknown argument, now 1. "Not a board" and "not a repo" are refusals and stay 1.

Each replaces `${N:?}` with an explicit check that prints the usage line on stderr and exits 2, the form `post-ask.sh` uses. The two heal scripts keep 64 for usage errors: `heal/references/descriptors.md` documents it and smoke asserts it. Each header states the result. State the convention once, in `lanework/references/writes.md`, and nowhere else.

### Guard against new drift (`tests/smoke.sh`)

One smoke case. For every file in `skills/*/scripts/` except `lib.sh`: run it with no arguments (`</dev/null`, `env -u CLAUDE_MODEL -u CLAUDE_CODE_SESSION_ID`, under a 10-second `perl -e 'alarm 10; exec @ARGV'`). Assert the exit is 2 (64 for the two heal scripts, and whatever a script that needs no arguments returns is listed by name in the case), and assert that the file's first 60 lines contain `exit <that code>`, case-insensitive. This needs no board and costs about 29 short runs. It catches a new script with no stated usage code, and a code change that leaves its header behind. It does not check refusal codes, so a wrong reading of those can still slip through.

## Verified

- Item 1: a card with no frontmatter, `move-card.sh ... --comment c.md`: exit 1, and no `comments/` folder on the card. Before the fix, one comment is left.
- Item 2: a skills copy with a stub `lease.sh` (4 on the first call, 3 on the second), `CLAUDE_CODE_SESSION_ID=s-test`, `move-card.sh --comment`: exit 3. Before the fix, exit 1.
- Item 3: `found-board.sh` with one `--var` slot unfilled: exit 2, and the board path does not exist. Before the fix, exit 255 and an empty folder.
- Item 4: `lanework-merge.py resolve <repo> --model`, `driver a b` and `resolve <not a repo>`: each exits 2 and has no `Traceback` on stderr. Before the fix, exit 1 with a traceback.
- Item 5: `lint-ask.sh missing.md 2>/dev/null` prints nothing on stdout. An 80-word ask exits 1. Both fail before the fix.
- Item 6: `heal-board.py <non-board>` stderr contains `--ignore-board-copy`.
- Item 7: `lease.sh _timer a b` stderr is non-empty, exit 2. The usage text printed by `lease.sh` has `[--force]` exactly once.
- Item 8: `watch-boards.sh` with `PATH=/usr/bin:/bin` exits 2 with `needs fswatch`. Before the fix, exit 0.
- Guard: the no-argument case above. Before the header edits it fails on at least `read-board.sh`, `heal-board.py`, `file-ticket.sh` and `merge-board.sh`.
- Header-only items: `bash -n` (`zsh -n` for `watch-boards.sh`) and `python3 -m py_compile` on every touched file, then `tests/smoke.sh`.

## Done when

- `tests/smoke.sh` passes with the nine new cases above, plus one case per changed script in the exit-code convention: a bad flag exits 2 and writes nothing. Each fails before the change with exit 1.
- For each of items 9 to 30, except the dropped 24, a fresh read of the touched header against its code finds no mismatch. A reviewer checks each against the line numbers in `## Problem`, re-resolved after the merges named in `## Risks`.
- `grep -L -i 'exit [0-9]' skills/*/scripts/*` lists only `lib.sh`.
- `grep -c CLAUDE_MODEL` is at least 1 in each of the 13 `require_model` callers.

## Risks

- **Build from `main` after these branches merge, and re-read the headers in their files then.** `stamp-values` touches `lib.sh`, `found-board.sh` (it adds a brace check and `rm -rf "$BOARD"` near the `mkdir` that item 3 moves), `lease.sh`, `lanework-merge.py` (signer only), `writes.md`, and every stamping script's `--name` handling, which ends in exit 2 on an empty name. `commit-board-leftovers` rewrites `commit-board.sh:17-19` and the timeout check. `smoke-under-load` changes the `lease.sh` timer. Approved cards also touch these files: Lint leftovers 2 (`f8cc20c4`, `lint-waiting-clears.sh`), lease.sh leftovers 2 (`6f0e0512`, the `lease.sh` write path) and the leading-handle card (`675df1a2`, `lint-ask.sh` and `post-ask.sh`). This card changes none of their lines. Its edits sit beside theirs, so line numbers and exit lists must be re-checked on the merged `main`.
- Item 5's `-lt 80` makes an ask of exactly 80 words fail where it passed. `post-ask.sh` and `file-question.sh` lint asks, so such an ask would now be refused (`post-ask.sh`) or warned about (`file-question.sh`).
- Item 1 moves where the comment lands. A failure between the comment and the `mv` (a full disk) can still leave it. The header says so rather than claiming none.
- Item 8 makes `watch-boards.sh` refuse where it used to exit 0. A Monitor without fswatch now ends with exit 2, which is the point.
- The convention edits the argument handling of twelve scripts, most of which `stamp-values` also edits for `--name`. Build after that branch is on `main`, on its lines as merged.
- The guard reads prose with a grep, so a header that says "exit 2" about something else satisfies it. It is a floor, not a proof.
- Item 12 edits one line of `writes.md`. That file is also on the `stamp-values` branch, and `tests/check-sizes.sh` checks its README word count, so the README row moves with it.

## Recommendation

Build it all, in one fixer per skill group after the listed branches merge: items 1 to 8 as code fixes with their smoke cases, items 9 to 30 (without 24) as header edits, plus the no-argument guard. The owner ruled option C on the exit-code convention: usage errors exit 2 in all twelve scripts that returned 1, which the guard then holds in place.

## Ruled: one exit-code convention (option C)

What each script does now, for usage errors (bad or missing arguments) against refusals:

| Script | Usage error | Refusal |
|---|---|---|
| `file-card.sh`, `label-card.sh`, `move-card.sh`, `post-comment.sh`, `post-ask.sh`, `commit-board.sh`, the four `lint-*.sh`, `lease.sh`, `arm-pass.sh`, `watch-boards.sh` (13) | 2 | 1 (3 lease lost) |
| `settle-question.sh`, `claim-ticket.sh`, `resolve-ticket.sh` (3) | 2, but a missing positional or flag value (`${N:?}`) is 1 | 1 |
| `found-board.sh` (and `found-discovery-board.sh`, `found-plan-board.sh`, which pass its codes through) (3) | mixed: unknown argument and missing value 1; label, var and title errors 2 | 1 |
| `file-question.sh`, `file-record.sh`, `file-ticket.sh` (3) | 1 (no model: 2) | 1 |
| `read-board.sh`, `frontier.sh`, `merge-board.sh` (3) | 1 | 1 |
| `heal-board.py`, `heal-descriptors.py` (2) | 64 (`heal-descriptors.py`: no model 2) | 2, 3 |
| `lanework-merge.py` (1) | 2 (tracebacks are 1 until item 4) | 1 |

In-repo callers: no skill prose depends on a usage-error code of the scripts that would change. `refused()` in `tests/smoke.sh` (`:566-574`, and the plan set near `:725`) asserts exit 2 for no model, and that holds under every option. `smoke.sh:397` asserts 2 for a bad `--record`, and `:616`, `:636` and `:1734-1810` assert 2 for found-board's label, var and title errors. All of these are unchanged by any option. The bad-argument cases for `file-question.sh`, `file-record.sh` and `file-ticket.sh` (`:517`, `:520`, `:654`, `:656`, `:706-710`) test only for a non-zero exit. The script-to-script callers read refusal and lease codes only: `post-ask.sh` reads post-comment's 3, `move-card.sh`, `label-card.sh`, `claim-ticket.sh` and `resolve-ticket.sh` read `lease.sh` codes, and `settle-question.sh` reads lint-waiting-clears' 2 and above. The heal scripts' 64 and 2 are asserted (`:274`, `:902`, `:1866`) and documented in `heal/references/descriptors.md:46`.

Options:

- **A.** Bad arguments exit 2 in `file-question.sh`, `file-record.sh` and `file-ticket.sh`: an unknown flag, a missing value, a missing required flag, a value outside its set. That changes 3 scripts' code, and their headers state the result.
- **B.** No code change. Each header states its codes as they are. That changes 0 scripts.
- **C (ruled).** A plus the `${N:?}` and unknown-argument paths in the other 9 scripts that exit 1 for usage errors (the 3, 3 and 3 rows above, counting `found-board.sh` and its two pass-throughs). That changes 12 scripts' code and overlaps `stamp-values`' `--name` edits in most of them. The heal scripts' 64 stays in every option.
