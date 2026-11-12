---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:50:00Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:50:00Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
in-reply-to: eb8bda66-6b20-4576-9e3e-b15f78316498
---
**Verdict: APPROVE.** The round-1 blocking finding is fixed and pinned by the smoke case. 3 notes, none blocking.

- **Stance**: adversarial (Phase-1 UNCERTAINTY not "none"; a behaviour change after Phase-1)
- **Round**: 2, scoped to the open blocking finding and the diff `2c06a25` → `0c0fcce`
- **Card**: [Dispatch arming: answer waiting owner comments in every lane, flag stale claims](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ada828e-56a0-4f1a-9b8b-094b330c71b7)
- **Branch**: `dispatch-arming-4ada828e` at `0c0fccec05479155066956865d02a929739bacfc`

**Blocking**: none.

**Notes**

1. `skills/dispatch/scripts/arm-pass.sh:47 @ 0c0fcce` "kind: *[\"\x27]?human": the pattern has no word end, so `kind: humanoid` reads as owner. The result is a spurious `comment` line, and the handler then judges the comment itself. The schema never polices `kind`. The same shape existed at `2c06a25`.
2. `arm-pass.sh:103 @ 0c0fcce` "[ -n \"$ne\" ] || continue": the thread sorts by the raw `at` string. A dead START (Z, 3 h old) followed by a comment stamped `2026-11-12T02:00:00+09:00` (17:00Z, before the START) sorts that comment newest, so the card is never flagged stale. The Z control prints `stale`. Agents and the app write Z, and `stale` is report-only.
3. Round-1 note 1 (stamps that are not Z) is resolved as the lead directed. Round-1 notes 3 (Plan-only claims) and 4 (newest owner comment only) still stand, unchanged. Note 5 is resolved: the 360edc1c records were moved back in `c710e94`.

**Checked**

- **Correctness vs done-when**: the round-1 finding, re-checked by its quoted text. Line 47 now accepts either quote on `kind: human`, and on `name: board` at the same line.
  - On attack boards with the branch script: `kind: 'human'` (flow and block form), `kind: human` followed by trailing spaces, a single-quoted `at` and a CRLF owner comment each print a `comment` line. An agent with `name: "human"` and a block-form `kind: agent` print nothing.
  - A CRLF START and a fractional-second START 2 h old print `stale`.
  - A START stamped with an offset or a space separator is still a claim (no `arm` line) and is never judged stale. An owner comment stamped with an offset is still seen and printed, and an agent `in-reply-to` it clears it.
  - A single-quoted `'board'` receipt is still skipped (the dead claim stays `stale`).
  - The live trial, `/clear` and restart are still the lead's.
- **Project conduct**: awk and BSD date. `\x27` works in macOS awk (the single-quote cases pass). `bash -n` is clean. The rebase onto `c710e94` is clean: range-diff shows only README rows in commit 1, and commit 2 is identical. The branch's own diff over its merge-base is the same 6 files.
- **Both paths**: the double-quoted stamp the app writes and the single-quoted YAML form are both asserted, and so is CRLF. An unreadable stamp skips only the stale judgment, never the claim or owner reading.
- **Fail-before**: OWN RUN agreed with the [fixer's record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ada828e-56a0-4f1a-9b8b-094b330c71b7). The `0c0fcce` case block run against the `2c06a25` script prints no line for the single-quoted or CRLF owners, and prints `stale ... 29907468m` for the fractional and offset claims. Against `0c0fcce`: ok 1-3.
  - The round-1 mutant (every comment with a `by` read as an agent's) now fails ok 1.
- **Test adequacy**: the five new fixture cards sit in the same case block, and their lines are asserted exactly by lane, card, class, title and path.
- **Blast radius**: `arm-pass.sh` +8 -5 and `smoke.sh` +12 -1 over `3fb80ca`, as the record says. The reviewer.md, sweep.md, review-verdict.md and README `work` rows in the raw range come from main's merges, not this branch.
- **Population**: a scratch copy of this board prints the same 4 lines as round 1 (2 `arm`, 2 `comment`, 0 `stale`). check-sizes 62 rows 0 wrong, check-refs 250 references 0 missing. I did not run the full gate; the lead's run gives 132 passed.

**Hypotheses**, written before reading the [round-2 record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ada828e-56a0-4f1a-9b8b-094b330c71b7). 2 of 4 held, both as notes.

1. The quote fix would over-match (`humanoid`): held, but the shape is old (note 1).
2. Skipping the stale judgment would hide a dead claim behind one stamp with an offset: held (note 2).
3. Stripping `\r` could break `in-reply-to` matching or the first-line read: refuted (the CRLF cases pass).
4. The widened `at` pattern would swallow a following key in a flow mapping: refuted, because it stops at `,`, `}`, quotes and spaces.
