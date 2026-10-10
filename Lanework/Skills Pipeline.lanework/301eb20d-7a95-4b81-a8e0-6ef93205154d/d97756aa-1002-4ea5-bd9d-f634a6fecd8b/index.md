---
schema: 1
kind: card
title: "found-discovery-board.sh: --labels edge cases match found-board.sh"
order: 5120
labels: [{text: discovery, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T03:16:45Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T11:34:35Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Repeated and empty `--labels` behave differently across the two founding scripts. One rule fixes both: repeated lists accumulate, and an empty list is an error everywhere.

## Today

- **Repeated**: both `found-board.sh:25` (`LABELS="${2...}"`) and `found-discovery-board.sh` (`EXTRA="${2...}"`) keep only the last `--labels`, so `--labels type --labels size` silently drops `type`.
- **Empty**: `found-board.sh --labels ""` exits 2, since an empty name is an unknown kind. `found-discovery-board.sh --labels ""` skips the empty `EXTRA` and founds a board with `round` alone, exit 0.

## Proposal

- **Accumulate**: each `--labels` appends to the list (`LABELS="${LABELS:+$LABELS,}$2"` in `found-board.sh`, the same for `EXTRA`). `found-board.sh` already dedupes through `SEEN`, so a kind named twice is written once.
- **Empty is an error in both**: `found-discovery-board.sh` passes a given-but-empty list through, so `found-board.sh` rejects it with exit 2 and writes nothing. The wrapper no longer skips an empty `EXTRA`.
- **Rejected**: refusing a repeated `--labels` with exit 2. Accumulating matches the comma list, and callers building a list from parts don't need to join it first.

## Touches

`skills/lanework/scripts/found-board.sh`, `skills/discovery/scripts/found-discovery-board.sh` (and its usage comment), `tests/smoke.sh`. Built on the post-[c8cf1d23](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c8cf1d23-38bf-4981-bce6-6df61091bacb) `found-board.sh` (lanes table `| order | title | collapsed | icon | body |`).

## Verify

`bash -n` on both scripts, then `tests/smoke.sh` passes with new cases on scratch boards. `--labels type --labels size` writes both kinds, through each script. `--labels type --labels type` writes it once. `--labels ""` exits 2 and writes no board, through each script. Discovery boards still carry `round` first.

## Done when

Both scripts accumulate repeated `--labels`, both reject an empty list with exit 2, and the smoke cases pass.
