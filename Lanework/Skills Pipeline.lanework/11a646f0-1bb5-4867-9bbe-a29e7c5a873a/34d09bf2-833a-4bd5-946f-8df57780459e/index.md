---
schema: 1
kind: card
title: "Smoke case 40 flakes on SIGPIPE in a cat | grep -q pipe"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-25T11:08:17Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
modified: {at: 2026-10-25T11:08:17Z, by: {name: handler, kind: agent, model: opus, session: "board dispatch"}}
---
Smoke case 40 sometimes fails with "claim did not move to Working with a Claimed comment" even though the claim worked.

## Reproduce

`tests/smoke.sh:429`: `cat "$PL"/*/"$T1"/comments/*/index.md | grep -qx ...` under `set -euo pipefail`. `grep -q` exits on its first match, `cat` dies on SIGPIPE while writing the next file, and the pipeline returns 141. Seen in 1 of 3 smoke runs going at the same time. The board those runs left shows the card in Working with its Claimed comment.

## Fix

Drop the pipe: `grep -qx '<line>' "$PL"/*/"$T1"/comments/*/index.md`. Sweep `tests/smoke.sh` for other `| grep -q` and `| head` pipes under pipefail.

## Done when

No `... | grep -q` or `... | head` pipe in `tests/smoke.sh` can return 141. Smoke passes 5 runs in a row, run at the same time.
