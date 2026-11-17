---
schema: 1
kind: comment
created:  {at: 2026-11-17T14:17:22Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T14:17:22Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Blocking 1 is fixed, measured on every padded and overlong input. The `CITEPENDING` stamp never reached a board on any real input, and the output matches main on ungated boards and `2538f29` on gated ones byte for byte. 3 notes.

- **Stance**: adversarial (same trigger as round 1)
- **Round**: 2, scoped to blocking 1 and the diff `2538f29..5c5cda9`
- **Card**: [4596a2cb](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12)
- **Branch**: `cite-as` at `5c5cda9`

**Blocking**: none.

**Notes**

1. `skills/lanework/scripts/lib.sh:119 @ 5c5cda9` "`stamp_cite() { local c; c=$(next_cite "$2" "$3"); perl -pi -e`": nothing checks that the stamp took. Failures injected by mutation, with rc 0 both times: if `perl` fails, `cite-as: CITEPENDING` lands on the board while the script prints `cite Q1`; if the scan fails, `cite-as: ` lands empty. No real input reaches either: after `10#`, `next_cite` has no failing path, and `perl -pi` writes to the script's own temp folder. A one-line guard would close it for good: die when `$c` is empty or `^cite-as: CITEPENDING$` is still in the file.
2. `skills/discovery/scripts/file-question.sh:79 @ 5c5cda9` "`CITE="Q$((MAXQ + 1))"`" (same in `file-ticket.sh`): the ungated path is unchanged from main. Byte-identical runs prove it, and the octal flaw is still there: with `Q9: nine` and `Q010: padded` on an unstamped board, main and this branch both file `Q9: …`, a reissue. The fixer's record says that board "works today (it prints Q9)"; it prints a duplicate. Leaving it is still right for this card, because done-when requires unchanged output on older boards and the code is unchanged. It belongs on the Issues card with the other leftovers.
3. `skills/lanework/scripts/lib.sh:107 @ 5c5cda9` "`re_t="^$2([0-9]+): "`": un-anchoring the legacy-title regex still leaves all six cite cases green. It is anchored correctly today. A smoke card titled `Some Q30: x` would pin it. A low-priority addition to the Issues card.

**Checked**

- **Blocking 1, re-checked by its quoted text**: `lib.sh:111-112` now compare and store `$((10#…))`. Measured with `next_cite`:
  - `ADR9` with `ADR010` gives `ADR11`.
  - `Q08` gives `Q9`, and a legacy title `Q09: old` gives `Q10`.
  - `Q0` and `Q00` give `Q1`; `Q000123` gives `Q124`.
  - All exit rc 0.
- **Very long digit runs**: these overflow 64-bit arithmetic silently. `Q9223372036854775807` mints `Q-9223372036854775808`; a 20-digit run mints a wrapped number; a 40-digit run is not counted. None aborts, and none can reissue an existing realistic citation. No action needed.
- **`CITEPENDING` attacks**, on a v118 board:
  - A question and a PDR titled `CITEPENDING`, a body containing the line `cite-as: CITEPENDING`, and `--why 'cite-as: CITEPENDING'`. The cards got `cite-as: Q11` and `PDR1`, with the user's text kept as written in title, body and comment. Zero `cite-as: CITEPENDING` lines in any card's front matter.
  - The substitution is anchored `^cite-as: CITEPENDING$` and runs on the front matter only. The body and `Question:` / `Depends on` lines are appended after the stamp.
  - The prefix is one of `Q`, `T`, `ADR`, `PDR` and the citation is `[A-Z0-9-]`, so nothing special enters the perl replacement.
  - The printed `cite Q<n>` and `T<n> -> <lane>` lines come from `stamp_cite`'s return value.
  - A failure between render and stamp exits under `set -e` before the `mv`, and the trap removes the temp folder.
- **Lint**: `lint-ask.sh` reads only the ask comment file. That comment depends on `--body` and the handle, never on the citation, so linting before the card is written sees the final text.
- **Both paths, deterministic byte-identity re-run** (shimmed `uuidgen`/`date`; questions, records with `--supersedes`, tickets with `--depends`, claim, resolve, `frontier.sh`, `read-board.sh`):
  - `5c5cda9` vs main, unstamped and v114: `diff -r` identical, stdout included.
  - `5c5cda9` vs `2538f29` at v118: identical.
  - Positive control: main vs `5c5cda9` at v118 differs, 7 entries.
- **Note 5's assertions**, by mutation on the `5c5cda9` harness of all six cite cases (baseline 6 ok):
  - Dropping the `^` from `re_c` fails the new case (`ADR=ADR41 Q=Q51`).
  - Reverting `frontier.sh`'s warning name to the title fails the new drift assertion.
  - Removing every `10#` fails the new case.
  - Survivors: `10#` removed from the comparison only (harmless: `[ -gt ]` is decimal anyway); the scan moved back before the lint (timing cannot be tested); and note 3.
  - Mutating `stamp_cite` into a no-op fails case 1.
- **Fail-before**: FIXER RUN at `2538f29`, consistent with my round-1 measurement (`ADR9`, `08: value too great for base`).
- **Test adequacy**: the new case `cite padded and prefix` sits after the other cite cases and uses a throwaway board stamped by `mkguide`. `bash -n` is clean on the four changed scripts.
- **Smoke**: FIXER RUN `smoke: 174 passed` (173 plus 1 new `ok` in the diff). OWN RUN of the six cite cases alone: 6 ok.
- **Blast radius**: 5 files, all named in the lead's rulings: `lib.sh`, three filing scripts, `tests/smoke.sh`. No prose or README change, so `check-sizes` is unaffected.
- **Population**: 11 padded or overlong `next_cite` inputs, 4 `CITEPENDING` placements, 3 byte-identity comparisons, 7 mutations.
