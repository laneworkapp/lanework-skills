---
schema: 1
kind: card
title: "Skills target agent guide v117: asks address @anyone, cite-as, the reserved name anyone"
order: 8192
labels: [{text: work, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}, {text: heal, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T01:57:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-12T01:57:22Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
The app moved this board's guide from v114 to v117 on 2026-11-12, about twenty minutes after the skills' stamp reached v114. The new guide and the validator (v4 to v5) sit uncommitted in the main checkout, so `tests/smoke.sh` fails there again at the stamp gate, and `scripts/release.sh` runs smoke in that checkout.

## What moved (v114 to v117, read off the working-tree diff)

- **`@anyone` and `for: anyone` are the default for an ask.** "Address your asks to `@anyone` and write `for: anyone` by default. Name a specific handle only for a question that belongs to one person." Only on a board whose guide line reads v117 or later; below that, `for: human` and the machine's handle. Agents ignore `@anyone`.
- **`anyone` is a reserved name**: never signed on a stamp or a comment, like `shortcuts`, `healer` and `board`.
- **`waiting.for`**: `anyone` reads as any human, alone or as a list entry, beside `human`, `operator` and an absent `for`.
- **`cite-as`**: a card's citation, a name and never an identity. Unique per board by convention: scan every card, `.trash/` included, before minting the next number. A copy never carries it; a cut and paste keeps it. The validator warns `duplicate-cite-as` on a whole-board walk.
- **Locked lanes**: copying or pasting a whole locked lane stays open and keeps the `locked` list.

## Where the skills are likely to drift (to confirm in shaping)

- `skills/work/references/writing.md` § The ask and `skills/work/templates/ask.md`: they tell the agent to use the human's handle from the guide's Mentions section, and say there is no reserved handle. v117 reserves `@anyone` and makes it the default.
- `skills/work/scripts/lint-ask.sh`: which handle an ask's first line must carry, and what `waiting.for` must say.
- `skills/work/scripts/post-comment.sh` if it lands, and the discovery and plan scripts that write an ask or `waiting` (`file-question.sh`, the ticket scripts).
- `skills/lanework/scripts/heal-board.py` and `skills/heal/scripts/heal-descriptors.py` `RESERVED_NAMES`, and `skills/lanework/references/writes.md` "Stamp it": add `anyone`.
- `skills/dispatch/scripts/arm-pass.sh` and `classify-event.sh`: anything that reads `waiting.for` or a mention as "addressed to the owner".
- `cite-as`: whether any filing script should mint one, and the copy rule for scripts that copy a card. Likely "nothing", stated.
- `tests/fixtures/app-writes/`, the stamp in the repo `CLAUDE.md`, README § Sizes.

## Verify

`tests/smoke.sh` green in the main checkout with the app's v117 files committed; new cases for each script change; the adversarial read-through the v114 card got.

## Done when

The stamp matches this board's guide, smoke is green in the main checkout, and an ask written by the skills on a v117 board addresses `@anyone` with `for: anyone` unless the question is one person's.
