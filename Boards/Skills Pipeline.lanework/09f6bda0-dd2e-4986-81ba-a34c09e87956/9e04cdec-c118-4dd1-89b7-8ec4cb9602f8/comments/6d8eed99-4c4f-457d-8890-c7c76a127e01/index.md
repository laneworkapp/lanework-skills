---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:00:50Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: on a v117+ board, `lint-ask.sh` now treats a record that quotes `@anyone` in a code span as an ask, so `post-comment.sh` refuses it.

- **Stance**: adversarial; the change alters how every skill addresses the human, ships to all plugin users, and carries two changes the card did not name
- **Round**: 1
- **Card**: [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8)
- **Branch**: `guide-v118-anyone` at `07143bc`

**Blocking**

1. `skills/work/scripts/lint-ask.sh:20 @ 07143bc` "grep -q -i -E '(^|[^[:alnum:]_])@anyone": the `@anyone` test runs on the raw body, code spans included. Input: a record on a v118 board reading "asks now start `@anyone` on v118 boards" (in backticks). Branch: `lint-ask.sh` prints "handle @anyone is not on the first line", rc 1, and `post-comment.sh` says "the body fails lint-ask.sh; nothing written". 0.8.0: the same record posts (rc 0, measured on a scratch board). Records about asks quote `@anyone` routinely, and line 28 of the same script already treats code spans and URLs as no mention. Fix: strip code spans and URLs with line 28's `sed` before the line-20 test, and add a smoke case: a record quoting `@anyone` in backticks passes on a v118 board.

**Questions for the lead**

1. The scan change in `07143bc` is test-only and already its own commit. Keep it on this branch, or land it on `main` alone, since `main` is red on this CLI without it?

**Notes**

1. `tests/smoke.sh:1560 @ 07143bc` "sed '/^Provides:/,$d'": sound for CLI 2.1.326, where "Provides:" (line 9 of the output) comes before "Plugin directory checks" (line 20), so both are cut. The comment says "only warnings above both count", but the old `/^Plugin directory checks/,$d` cut was dropped. A CLI that prints the directory checks without a Provides list would count ICON_MISSING again and go red. Keep both patterns: `sed -e '/^Provides:/,$d' -e '/^Plugin directory checks/,$d'`.
2. `skills/work/scripts/lint-ask.sh:19 @ 07143bc` "handle=$(owner_handle": an ask addressed to a person who is not this machine's handle (`@bob Should we ship it; or wait — maybe later? And now?`) passes unchecked on a v118 board (0 violations, the same on 0.8.0). This predates the branch, but writing.md now sends gate asks to the person's handle, and the fixer's record says "a person-addressed gate ask is still linted". That holds only when the person is the machine's own handle.
3. `skills/work/templates/ask.md:6 @ 07143bc` "@anyone [@<handle>…]": the skeleton reads as `@anyone` plus extra handles. The guide puts a person's handle in place of `@anyone`, for that person's question. `[@anyone | @<handle>…]` would match it.
4. `skills/lanework/scripts/lib.sh:75 @ 07143bc` "/CLAUDE.md" ] && v=$(head -1": a board that has only `AGENTS.md` (copied from the real v118 guide) gets an empty `guide_version` and an empty `ask_handle` (rc 1), so `file-question.sh` writes `@human` and `for: human`. `owner_handle` already behaved this way, and the app writes both files byte-identical, so this is rare. Reading `AGENTS.md` as a fallback in both functions would close it.

**Checked**

- **Correctness vs done-when**:
  - stamp: `CLAUDE.md` reads `lanework-agent-guide v118`.
  - `file-question.sh`: on a scratch board carrying the real v118 guide, the card gets `waiting: {for: anyone, …}` and the ask starts `@anyone`.
  - smoke: covers the v114 board (`@kim`) and both heal scripts (rc 64 on `--name anyone`).
  - reserved names: `anyone` is in all three lists.
  - leftover wording: `grep -rn -i` over all of `skills/` (watch, plan, discovery, merge, heal, dispatch and templates) finds no "no reserved" and no "Mentions section" handle source. The remaining "handle" hits are handler names, "no handle" on records, and the lint's own variables.
- **Prose vs guide v118**: checked against § Mentions, § Stamping and the `in-reply-to` clause.
  - `writes.md`: the `in-reply-to` line now reads "whoever wrote it" and "Not only an answer to an ask", matching the guide. The `cite-as` line matches "never carry a `cite-as` into a card you copy".
  - `writing.md` line 39 matches "never take it from the line above" and "Agents ignore `@anyone`".
  - `sweep.md` matches the waiting-clause reading of `anyone`/`human`/`operator`/absent.
  - No sentence contradicts the guide.
- **Project conduct**:
  - no `lanework-agent-guide v<digits>` under `skills/`; the gate number 117 lives only in `ask_handle`, per the lead's START.
  - Board writes and skill changes are in separate commits.
  - Agent text is telegraphic.
  - CHANGELOG has three one-sentence user-facing entries in the existing format, with no version line.
  - README § Sizes moved with the files, and `check-sizes.sh` is green inside smoke.
  - `dispatch/` is untouched.
- **Both paths**:
  - v117+ and older boards are both gated and tested, with v116 as the boundary control.
  - A missing guide gives an empty result with rc 1. Both callers use `|| true` under `set -euo pipefail`, so neither aborts.
  - Real line 1 (`<!-- lanework-agent-guide v118 — …`) parses to 118. Two- and three-digit versions compare numerically.
  - A mid-sentence `@anyone` in a record is caught (1 violation). Case-insensitive `@Anyone` is matched. `@anyone-else` and `anyone@example.com` are not.
  - The gap: a person handle that is not the machine's (Note 2).
- **Fail-before**: OWN RUN agrees with the FIXER RUN.
  - Scratch worktree at `edc2bf8` with the branch's `tests/`; each of the five new blocks run alone.
  - Failures at the base: `ask_handle: command not found`, "lint-ask passed any-late on a v118 board", "file-question on v118: want anyone", "heal-board.py --name anyone: rc=0".
  - The v114 lint block passed at the base, as the fixer recorded (it is the control).
  - All five pass at the head.
  - Would they pass with the fix wrong? A version-blind `ask_handle` fails the v116 and v114 assertions. No case covers a record quoting `@anyone` (Blocking 1).
- **Test adequacy**: the cases sit after the existing lint-ask block, and their `ok` lines are worded like their neighbours'.
- **Blast radius**:
  - 17 files, all named by the card or the START record, except the two unnamed changes.
  - The fixture is forced: it holds `found-discovery-board.sh`'s expected output, and the template sentence changed.
  - The scan change is explained by the measured `claude plugin validate` output (Note 1). On `main`'s scan, the eight Provides lines `❯ skills: lanework:…` match `^ +❯ `, so the claim that `main` is red holds.
- **Population**: smoke prints `smoke: 163 passed`, rc 0, at `07143bc` in the fixer's worktree, with 163 `ok` lines, matching the fixer's count.

**Hypotheses**, written after reading the card and the diff (the thread, read first as told, already held the fixer's [FAIL-BEFORE](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) and green records). 3 of 7 held.

1. A record quoting `@anyone` in code fails the lint: held (Blocking 1).
2. A gate ask to a non-machine handle goes unlinted: held, and it predates the branch (Note 2).
3. The Provides cut drops the directory-check exclusion: refuted for this CLI, held for one without Provides (Note 1).
4. An AGENTS.md-only board falls back to `human`: held, and it predates the branch (Note 4).
5. A non-zero `ask_handle` aborts a `set -e` caller: refuted.
6. Prose was left taking the handle from § Mentions: refuted.
7. The new cases would pass with a version-blind gate: refuted.
