---
schema: 1
kind: card
title: "Lint leftovers 2: tab in a name, unsplittable lines, a lane read twice"
order: 2048
labels: [{text: "work", kind: {type: "skill", text: "Skill"}}, {text: "lanework", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:18Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T16:45:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
The three lints print one finding per line that can be read back, and a lane that is a symlink to a sibling lane no longer makes every finding print twice.

## Problem

1. A tab in a card name garbles `lint-stamps.sh`. Reproduced on a throwaway board with a card folder named `tab<TAB>x`: the output was `.../L1/tab: x/index.md modified.at^I2026-11-21T16:53:55Z is 0s ahead`. The path is cut at the tab, the field is the rest of the name, and the stamp lands in the wrong column, so the seconds are computed from a bad value (`0s ahead` for a stamp 597 s ahead). Cause: `lint-stamps.sh` passes `path<TAB>field<TAB>value` to a `read -d $'\001'` loop, and the path itself may hold a tab.
2. The lines cannot be split back apart, and the three lints disagree. Reproduced: a comment folder `e2<TAB>z` prints in `lint-waiting-clears.sh` as `NO-QUOTE c3 e2 z` (tab turned into a space, so the ask id reads as two fields), while a card name is printed raw, and `lint-stamps.sh` prints paths raw. `lint-leases.sh:34` (`gsub(/[\t\n]/, " ", rel)`) turns a tab or newline in any folder name into a space: a card `c4<TAB>w` printed as `c4 w`. Readers of these lines: `skills/discovery/scripts/settle-question.sh` takes only field 3 of a `NO-QUOTE` line (the ask id, a uuid the app or `post-ask.sh` writes) and otherwise matches the leading word; `scripts/release.sh` does not call any lint; `tests/smoke.sh` asserts raw newline paths for `lint-stamps.sh` and the card name for `lint-waiting-clears.sh` in `sent_check` (line 898 to 899). Nothing outside the repo parses them. So the change is not a break for any consumer, and it is not an owner's call.
3. A lane symlinked to a sibling lane of the same board is read twice. Reproduced with `ln -s L1 A.lanework/L2`: `lint-stamps.sh` printed every finding under both `L1/` and `L2/`, `lint-waiting-clears.sh` printed `NO-QUOTE c2 e1` and `NO-QUOTE c3 e2 z` twice with a tally of 4 instead of 2, and `lint-leases.sh` printed the two-STARTs finding for `L1/c4 w` and `L2/c4 w` with `leased cards: 2` instead of 1. Cause: `board_index_files` in `skills/lanework/scripts/lib.sh` runs `find -L` and lists both spellings of one card.
4. `lint-waiting-clears.sh` `comment_row` sets `LW_ID` on its own statement (`LW_ID="${1%/index.md}"; LW_ID="${LW_ID##*/}" awk`), so the first assignment is a global shell variable. Not reproduced: reasoned from the line, harmless.

## Change

1. and 2. One escaping rule, in one place. Add `show_name` to `skills/lanework/scripts/lib.sh`: prints its argument with a tab as `\t`, a newline as `\n` and a carriage return as `\r`, and a backslash as `\\\\`, so a name that already holds the two characters `\\t` cannot be mistaken for a tab (names without those four characters print as they do now). Each lint applies it to every path, card name and comment id it prints. `lint-stamps.sh` also stops carrying the path through a tab-split `read`: the awk emits the path with the escape already applied (a `\001`-ended record whose first field is the escaped path cannot hold a tab), so the split is exact. `lint-leases.sh` replaces its `gsub(/[\t\n]/, " ", rel)` with the same escape on the printed card path but keeps the real folder parts for `split`. `lint-waiting-clears.sh` drops its tab-to-space `gsub` and prints `${card##*/}` and the ask id through `show_name`. State the rule once in `skills/work/SKILL.md` where the lints are listed (one sentence: a tab, newline, carriage return or backslash in a name prints as `\t`, `\n`, `\r` or `\\\\`, so one finding is one line), and drop the per-lint wording that says a newline name "is read".
3. `board_index_files` in `skills/lanework/scripts/lib.sh` lists a card once. When the board holds any symlink (`find -L "$d" -type l` finds one, so plain boards pay nothing extra), it keeps the first spelling per physical folder (`cd "$(dirname "$p")" && pwd -P`) in `sort -z` order, so output is deterministic. A lane symlinked to a folder outside the board, and a symlinked board, still read as before.
4. `skills/work/scripts/lint-waiting-clears.sh`: compute the id in a local (`local id=...`) and pass it on the awk line as `LW_ID="$id" awk ...`. No behavior change.

## Verified

New smoke cases in `tests/smoke.sh`, next to the existing symlink and newline cases (around line 1230):
- Item 1 and 2: a card folder with a tab in its name, and a comment folder with a tab in its name, on a throwaway board. Each lint's output must be exactly `...tab\tx...`-style escaped lines, the line count must equal the finding count, and `lint-stamps.sh` must report the true seconds. Fails today: the stamps line is split and wrong, the leases and waiting-clears lines print a space.
- Item 1 and 2: update the existing newline-name expectations in `sent_check` (the raw newline path for `lint-stamps.sh`, the raw card name for `lint-waiting-clears.sh`) to the escaped form; add the escaped form to the `lint-leases.sh` finding.
- Item 3: the sentinel card under a lane, plus a second lane that is a symlink to it. Each lint must report the card exactly once; `lint-leases.sh` must tally `leased cards: 1`. Fails today: every finding twice.
- Item 3: the existing symlink-to-an-outside-folder case (`f2000000-...-0000ff`) must still report its card.
- Item 4: no case; a `bash -n` and the existing waiting-clears cases cover it. Optionally assert `LW_ID` is unset after sourcing is not testable, so leave it.

## Done when

- `tests/smoke.sh` passes, with the new cases listed above.
- On a throwaway board with a card `tab<TAB>x` and a stamp in the future, `lint-stamps.sh` prints one line containing `tab\tx/index.md` and the right seconds.
- On a board with `ln -s L1 L2`, each of the three lints prints each finding once.
- `grep -n "LW_ID" skills/work/scripts/lint-waiting-clears.sh` shows it only as a prefix on the `awk` command.
- `tests/check-refs.sh` and `tests/check-sizes.sh` still pass.

## Risks

- Anyone who matched the old raw or space-turned names in a script sees a changed line, but only for names with a tab, newline or carriage return, which no in-repo consumer parses. A smoke grep-check on the `settle-question.sh` path confirms its field-3 read is untouched.
- Deduping by physical folder costs one `pwd -P` per index.md on boards with symlinks; skipped when there are none.
- If two spellings of one card exist, only the first in sort order shows; a finding then names that spelling, not the other.
- An escaped path is not directly openable; acceptable since a finding is for reading, and such names are rare.

## Recommendation

Build all four. Items 1 to 3 are real and reproduced, the escaping rule has no outside readers so it is a plain default, and item 4 is a one-line tidy in a file already being edited.
