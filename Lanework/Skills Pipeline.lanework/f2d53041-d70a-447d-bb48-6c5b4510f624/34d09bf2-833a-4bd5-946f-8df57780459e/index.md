---
schema: 1
kind: card
title: "Smoke case 40 flakes on SIGPIPE in a cat | grep -q pipe"
order: 0
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T11:08:17Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-11-12T00:49:17Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
Smoke case 40 sometimes fails with "claim did not move to Working with a Claimed comment" even though the claim worked.

## Reproduce

`tests/smoke.sh:531` (the card first named 429; the file has grown): `cat "$PL"/*/"$T1"/comments/*/index.md | grep -qx ...` under `set -euo pipefail` (`tests/smoke.sh:5`). `grep -q` exits on its first match, `cat` dies on SIGPIPE while writing the next comment file, and the pipeline returns 141. The line dates from `8a3dd62`. Seen in 1 of 3 smoke runs going at the same time. The board those runs left shows the card in Working with its Claimed comment.

A SIGPIPE needs an upstream that writes again after the reader has gone. Measured here under `set -o pipefail`, 1500 runs each: `cat` of 4 small files into `grep -q` returned non-zero 92 times; `cat` of one small file, `sed` of one small file, `ls | head -1` and `grep -l | head -1` returned it 0 times. A producer with one write (small output, flushed at exit) cannot be hit. A `cat` of several files, or of one over a pipe buffer (40 KB: 4 of 300), can.

## Sweep

Every pipe in `tests/smoke.sh` whose right side can stop early (`grep -q`, `head`). Lines rechecked on `main` today.

| line | pipe | can return 141? |
|---|---|---|
| **531** | `cat "$PL"/*/"$T1"/comments/*/index.md \| grep -qx` | **yes**: a glob of several files, one write per file. The only one |
| 60 | `grep -n 'Lanework/' "$F" \| head -1` | no: 4 matching lines, 391 bytes, one write |
| 62 | `grep -o ... "$F" \| head -1` | no: one short match |
| 76, 83 | `tail -1 "$L" \| grep -q` | no: one line |
| 87 | `ls "$X"/*/index.md \| head -1` | no: about 10 short paths, one write |
| 231-248 | `c N \| grep -q...` (15 lines, `c` = one `sed -n` over one card's frontmatter) | no: one file, under a pipe buffer; `sed` of 40 KB returned 0 in 300 runs |
| 252 | `sed -n '/^config:/,/^created:/p' "$H/index.md" \| grep -q` | no: one file, a short range |
| 386, 774 | `grep -l ... "$D"/*/index.md \| head -1` | no: file list under 1 KB, one write |
| 843 | `lane_text ... \| grep -qxF` (four) | no: `awk` over one lane file |
| 849 | `grep -A2 ... \| sed -n 3p \| grep -q` | no: `sed -n 3p` reads to EOF |
| 968, 1060 | `ls ... \| grep -v ... \| head -1` | no: a directory listing, one write |
| 474, 484 | `sed ... \| head -14` | no: failure-message path only, one small file |
| 1096, 1097 | `head -1 ... \| grep -o \| grep -o \|\| true` | no: no early exit, and `\|\| true` |

Outside the card's file, `tests/merge-case.sh` (`set -euo pipefail`, line 10) has the same shape at lines 93, 158, 185, 298, 310, 353 and 358; each is a single-write producer into `grep -q`, so none can fire today. Not touched here.

## Fix

Line 531 only: replace the pipe with a grep over the files, which has no upstream to kill:

```sh
[ "$(plane "$T1")" = Working ] && grep -qx '\*\*Claimed\*\* by claude, session s1.' "$PL"/*/"$T1"/comments/*/index.md || { ... }
```

Tried on 4 files, 1500 runs: 0 failures, and a non-matching pattern still fails. An empty glob still fails (grep reports the missing file), as `cat` did.

## Scope

- Touches only `tests/smoke.sh`, one line. No file under `skills/`, no `plugin.json`, no README or CHANGELOG entry (not user-facing).
- Deferred: rewriting the 30-odd single-write pipes to `grep -q ... <<<"$x"` or `<(...)`. They cannot return 141 (table above), and the churn would hide the real fix. File a card if a producer there grows past one write.
- Deferred: `tests/merge-case.sh` (same reason).

## Risks

- None for the skills. A wrong pattern would turn case 40 into a false pass or fail; the control run below catches that.

## Verification

- Baseline today: `tests/smoke.sh` runs 2m20s alone and ends red only on the last gate, `board guide v114 is newer than the stamp (lanework-agent-guide v101)` (`CLAUDE.md`, Working on a skill). Cases 1-123 print `ok`. That gate is unrelated to this card, so "passes" below means every case prints `ok` and the only failure is that gate, until the stamp moves.
- `bash -n tests/smoke.sh`, then `tests/smoke.sh` green once on its own (throwaway boards only, never this one).
- Control: against a scratch board with a claimed ticket, the new line passes; with the Claimed comment removed it fails.
- The race, hard to hit by luck, run as the card said: 5 smoke runs started at the same time, all exit 0.

## Done when

No pipe in `tests/smoke.sh` feeds `grep -q` or `head` from a producer that writes more than once (a `cat` of a glob, or output over one pipe buffer); the sweep table above is the checklist, and line 531 is its only row marked yes. Smoke passes 5 runs in a row, run at the same time (every case `ok`; see Verification for the stamp gate).

## Recommendation

Build as scoped: one line, one commit. The card's own done-when said "can return 141" for every `| grep -q` and `| head`; this body narrows it to the pipes where that is true, with the measurements above. If the owner wants the stronger reading (no such pipe at all), say so at review and the builder converts the rest mechanically.
