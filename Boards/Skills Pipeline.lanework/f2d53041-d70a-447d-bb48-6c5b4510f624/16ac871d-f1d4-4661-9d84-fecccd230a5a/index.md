---
schema: 1
kind: card
title: "Smoke's guide-version check has no positive control and skips scripts"
order: 5120
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:34:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-20T17:55:04Z}
---
Smoke's guide-version check scans only Markdown and has never been shown to catch anything, so this makes it scan every file under `skills/` and adds cases that prove it flags and does not flag.

## What is wrong

`tests/smoke.sh` has a rule: no file under `skills/` names a guide version, because the one stamp lives in the repo `CLAUDE.md`. The check is at "# versions: no skill names a guide version" (lines 1332 to 1339 on `main` at `210b30f`). It has two greps:

- **The stamp form** (`lanework-agent-guide v114`, `lanework-schema v1`) runs over every file under `skills/`.
- **The floor form** ("guide ... v105+", or a bare `v` plus two or more digits) runs over `find "$SK" -name '*.md'` only.

Two gaps, both measured on scratch files:

- **Scripts slip through.** Fed `# on a guide v117+ board`, `# needs guide v105 or later` and `# floor: v117 or later` in a `.sh` and a `.py`, the current check flags none of them. The same text in a `.md` is flagged.
- **No case proves the check works.** No smoke case feeds it a file that names a version. The controls near the advisory gate (the "release gate (advisory)" block) test the board-against-stamp note, a different check. A broken pattern would pass green.

## Proposal

Move the scan into a function, run it on the real tree, and run the same function on scratch trees as controls. One function means the controls and the real check cannot drift apart.

### Files touched

**1. `tests/smoke.sh`**, at the versions block.

- Add `names_guide_version <dir>`: lists, sorted and unique, every file under `<dir>` that matches either pattern, over all file types (`grep -r -l -i -E`, no `-name` filter). Today `skills/` holds only `.md` (68), `.sh` (20) and `.py` (3); scanning all types also covers a future `.json` or `.yaml`.
  - Stamp pattern, unchanged: `lanework-(agent-guide|schema) +v[0-9]+`
  - Floor pattern, one change: `guide[^.]*[^[:alnum:]_$-]v[0-9]+|(^|[^[:alnum:]_$-])v[0-9]{2,}([^[:alnum:].]|$)`. The only difference from today's is a `$` in the preceding-character class, so a shell variable such as `$v10` is not read as a version. Measured: today's pattern flags `echo $v10`, the new one does not, and every positive case below is still flagged.
- Replace the current two-grep `H=` line with `H=$(names_guide_version "$SK")`; the failure message and the stamp-count checks after it stay as they are.
- Add three cases after the existing `ok "no skill names a guide version; one stamp ..."`:
  - **Positive control.** A scratch tree `$T/gv-pos/` with five files: `a.md` holding `Needs guide v105+ on the board.`, `b.sh` holding `# on a guide v117+ board, ask anyone`, `c.py` holding `# needs guide v105 or later`, `d.json` holding `{"note": "lanework-agent-guide v114"}`, `e.sh` holding `# floor: v117 or later`. The function must print exactly those five paths. Passes with `ok "the guide-version check flags a stamp or a version floor in .md, .sh, .py and .json files"`. The old Markdown-only scan prints only `a.md` and `d.json` for this tree (measured), so this case fails on today's check.
  - **Negative control, fixture lines.** A scratch tree `$T/gv-neg/` whose files hold: `schema v1, v0.8.0, v10.2.1, v2→v5` (a `.md`), `echo $v10 and x=$v12` (a `.sh`), the numeric comparison as `lib.sh` writes it, `  if [ -n "$v" ] && [ "$v" -ge 117 ]; then printf anyone; else owner_handle "$1"; fi`, and the stamp reader's regex line, `grep -o -E 'lanework-agent-guide v[0-9]+'`. The function must print nothing. Passes with `ok "the guide-version check does not flag schema v1, semvers, a one-digit range, a shell variable, or a numeric comparison such as -ge 117"`.
  - **Negative control, the real file.** Copy `$SK/lanework/scripts/lib.sh` to a scratch tree with its comment lines removed (`sed -E 's/^[[:space:]]*#.*$//'`); the function must print nothing. This is the control that shows the guide-v118 branch's `guide_version` reader and `-ge 117` comparison are not flagged, and it keeps showing it if that code changes. Passes with `ok "the guide-version check does not flag the code of lib.sh, comments aside"`.

**2. `skills/lanework/scripts/lib.sh` and `skills/work/scripts/lint-ask.sh`: one comment line each, after the guide-v118 branch lands.** Measured on branch `guide-v118-anyone` at `07143bc`: the new scan flags exactly these two files, and only because of comments. `lib.sh` line 81 reads "`anyone` on a board whose guide is v117 or later" and `lint-ask.sh` line 4 reads "on a guide v117+ board". The code itself is clean: `-ge 117` has no `v` in front of it, and `lib.sh` with comments stripped prints nothing. Reword both comments so they name no `vNNN`, for example "on a board whose guide has `@anyone` (older builds draw no buttons for it)". The `117` in the code stays: it is the one place the threshold lives. If the branch lands with the comments already reworded, this file change is empty.

No other file changes. `CLAUDE.md` already says smoke fails on a guide version anywhere under `skills/`; after this the check does that. No `CHANGELOG.md` entry: nothing a plugin user sees changes.

### Verified by

Verified for this repo means `tests/smoke.sh` passing, plus a new case for new behavior. So:

- `bash -n tests/smoke.sh` clean, and `tests/smoke.sh` exits 0 with the three new cases printed as `ok` lines. Counts rise by three, and no README or other file holds a fixed case count.
- By hand, in a scratch copy of the repo and never on the Skills Pipeline board, break the check two ways and read what smoke prints. Restore the Markdown-only scan: the positive control fails listing `b.sh`, `c.py` and `e.sh` as missing. Change the floor pattern's `{2,}` to `{9,}`: the positive control fails, with `e.sh` the one file no longer flagged (the `guide ...` half still catches the others, measured). Quote both outputs in the closing comment.
- Run smoke on the guide-v118 branch with its comments as they are: it fails naming `lib.sh` and `lint-ask.sh`. After the rewording it passes.

### Done when

- `tests/smoke.sh` passes on the tree with the three new `ok` lines in its output.
- Writing `# guide v105+` into any `.sh`, `.py`, `.md` or `.json` file under `skills/` makes smoke fail and name that file.
- Each of the two mutations above fails the positive control.
- `lib.sh` and `lint-ask.sh` on `main` name no `vNNN`, and the negative controls pass against the current `lib.sh`.

## Risks

- **Ordering.** The scan fails on the two comments in the guide-v118 branch. Build this after that branch lands, then reword in the same change if still needed. Building before it passes on `main` but breaks the branch on merge.
- **Bare numbers are not caught.** The check looks for a `v` plus digits. The `117` in `lib.sh` is a guide version by another name and passes. Accepted: the number has to live somewhere, and the one place is a script, not prose.
- **A new false positive is possible.** Any script word that is `v` plus two digits, such as a Python variable `v10`, is flagged. None exists today (zero hits across `skills/` on `main`). `$v10` is excluded. A range of two-digit versions such as `v10→v12` is flagged on purpose: it names guide versions, and the card's `v2→v5` exclusion only ever held for one digit.
- **Scope is `skills/` only.** `tests/` and `scripts/` may name a version; they are the repo's own, not the product.
- **The control strings are the contract.** If someone later edits the check's patterns, the control files above show what must still be flagged; widen them, never delete one to get green.

## Dependencies

- After [Skills target agent guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8), whose branch `guide-v118-anyone` adds the version reader to `lib.sh` and the two comments this card rewords.
- Origin: [the guide v114 catch-up](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2c29a34f-fde2-4a44-8a3b-94157a320609) round-2 review.

## Recommendation

Build it, in a single change after the guide-v118 branch lands. The check is cheap to widen, the controls are small scratch files, and nothing here needs an owner decision. Open calls: none.
