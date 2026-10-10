---
schema: 1
kind: card
title: "heal and board-kinds: follow-ups from the lane-actors review"
order: 12288
labels: [{text: heal, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-10-10T02:41:04Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "skills chat"}}
modified: {at: 2026-10-10T11:41:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
Three small gaps the review of [0d374675](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0d374675-f23c-4959-95dc-07e10f99d345) left as notes (verdict 2833db72), none blocking. All three are real at HEAD. Build after [c8cf1d23](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/c8cf1d23-38bf-4981-bce6-6df61091bacb) (lane icons) lands: it rewrites `read_templates` in `heal-descriptors.py` and smoke's lane fixtures, and both are edited here.

## 1. Asked vs the gate key

- **Gap**: `board-kinds.md:5` "**gate** = the owner rules; agents move cards in only", against `board-kinds.md:72` "| Asked | gate | ... Only the agent moves a card out |". Same sentence in `discovery/templates/lanes.md:9` and `heal-descriptors.py:145`.
- **Fix: reword the key, not the row.** The row is shipped lane-body text on users' boards, and changing it would need an `OLD_BODIES` entry and a `replace-body` on every healed discovery board. The key only documents what the row already does. Owner-facing semantics unchanged, so no ask.
- **New key text**: "**gate** = the owner rules; agents move cards in, and out only once the ruling is in the body (discovery Asked)." Pipeline Proposed and design-loop Sittings/Chosen stay agents-in-only; the exception is named once, in the key.

## 2. drop-stale context

- **Gap**: `heal-descriptors.py` (HEAD ~415): `re.compile(r"\s?" + re.escape(sentence))`, `sub(..., count=1)` over the whole body. Own bullet `- A chore ... both.` leaves a bare `-`. A hit in a fence or quote is removed. The first hit wins even when the real one comes later.
- **Fix**: do it per line. Walk `body.split("\n")`; toggle a fence flag on lines whose `lstrip()` starts with three backticks or `~~~`; skip lines in a fence and lines whose `lstrip()` starts with `>`. On every other line holding the sentence, remove it with one adjoining space (the leading one, else the trailing one). When what remains is empty, or only a bullet marker (`-`, `*`, `+`), drop the whole line. Remove every unfenced, unquoted hit, so a second run finds 0 whatever is left in fences or quotes. Report `drop-stale` only when something was removed.
- **Smoke case** (heal block of `tests/smoke.sh`, beside the pre-ruling sheet case), four fixtures of a healed sheet, each given a sentence copy:
  - own bullet: line gone, no bare `-`, neighbours byte for byte.
  - inside the Two human gates bullet: removed, the bullet ends at "not the owner's."
  - inside a fence: untouched, no `drop-stale` line, `0 changes` for it.
  - inside a quote (`> ...`): untouched, same.
  - Each fixture's pre-heal state asserts the sentence is present, and the board validates after apply.

## 3. Ideas in two sweep rows

- **Gap**: `work/references/sweep.md:27` "| **At a human gate** | Ideas (triage), Proposed (review) |" and `:28` "| **Holding** | Ideas, Issues, Tasks |". `board-kinds.md:16` makes Ideas `holding`, so the first row is the stale one.
- **Fix**: row 27 becomes "`gate` lanes (pipeline: Proposed, review)" and keeps "report"; its "never move" becomes "moves per the `gate` key in `lanework/references/board-kinds.md`", since item 1 lets Asked move out. Row 28 becomes "Ideas (triage), Issues, Tasks". Ideas then sits in exactly one row. The board sheet's "Two human gates" bullet is owner-facing and stays.

## Touches

`skills/lanework/references/board-kinds.md`, `skills/heal/scripts/heal-descriptors.py` (the `drop-stale` step, and its docstring line), `skills/work/references/sweep.md`, `tests/smoke.sh`.

## Verify

`bash -n` on `tests/smoke.sh`; `python3 -I -m py_compile` on the script; `tests/smoke.sh` passes with the new case and `tests/check-refs.sh` stays green. Smoke fail-before: restore the old one-regex step and the own-bullet, fence and quote fixtures turn it red. Items 1 and 3 are prose, read through against `lanework-agent-guide` v84 (the stamp move is [1a63eb6b](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/1a63eb6b-52b3-44b9-8b0a-a1aec41d4dcd)'s). Never run against the Skills Pipeline board.

## Done when

- `board-kinds.md` has no sentence that a table row contradicts: grep finds the gate key naming the Asked exception.
- `heal-descriptors.py` leaves no bare bullet, and no fenced or quoted sentence changes, in the four smoke fixtures.
- `sweep.md` names Ideas in one workload row.
- `tests/smoke.sh` ends "smoke: N passed" with the new case counted.
