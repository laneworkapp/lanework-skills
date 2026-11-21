---
schema: 1
kind: card
title: "Smoke fails under machine load: plan-claim timing cases and a broken pipe from head -1"
order: 1024
created:  {at: 2026-11-20T23:06:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T13:15:44Z}
---
## Problem

`tests/smoke.sh` fails on a busy machine in cases that have nothing to do with the change under test. Seen on 2026-11-20 with the load average between 30 and 100 (Xcode builds plus other smoke runs), on branches that touch no plan or lease script:

- `plan claim ended at the move: rc 143` and `plan claim ended at the comment`, and `plan claim race`: the cases time a signal against a running script and lose the race under load.
- `file-ticket.sh: line 102: printf: write error: Broken pipe`, exit 141: smoke reads the script's output through `| head -1` (lines 1815 to 1858 and the `ptk` helper), so `head` can close the pipe before the script prints its last line.

Each cost one or more reruns before a merge could be pushed; a pass on `main` at the same commit followed every time.

## Wanted

Smoke gives the same result at load 5 and load 100.

- Timing cases wait on a state the script reaches (a marker file, a paused wrapper), not on a sleep.
- Output is captured whole and then cut (`out=$(…); first=${out%%$'\n'*}`), never through `| head -1`.

## Done when

- Ten consecutive smoke runs on `main` pass while a load generator holds the 1-minute load above 50.
- `grep -n '| head -1' tests/smoke.sh` finds no script under test on the left side.
