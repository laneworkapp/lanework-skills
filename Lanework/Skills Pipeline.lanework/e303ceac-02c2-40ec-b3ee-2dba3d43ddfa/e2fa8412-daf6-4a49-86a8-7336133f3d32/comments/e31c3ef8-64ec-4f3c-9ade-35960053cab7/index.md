---
schema: 1
kind: comment
created:  {at: 2026-10-10T01:03:11Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T01:03:11Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Review round 1 fixed in b1f0cf3: both BLOCKING findings and NOTEs 1 to 4. Smoke green, 43 passed.**

- **Decided, order (BLOCKING 1)**: a record is filed when the answer is taken, before `settle-question.sh`, so the ruling links it. Stated once in `records.md` (header and Format); `rounds.md` Answers points there and Close step 2 now only checks every ruling that cleared the bar has its record.
- **Fixed, escaping (BLOCKING 2)**: backslash escaped before quote in the title. Smoke title carries both; the board validates.
- **Fixed, NOTEs**: `--body` content asserted (a no-op `cat` mutation now fails smoke); question id must be a lowercase uuid and a card in Asked (a settled card, `..`, a record card and a short id are refused, nothing written); newlines in the title become a space; `[`, `]` and `\` escaped in the link text.
- **Smoke case 25 follows the new order**: file two records on a still-Asked question, link them in the ruling, settle, assert the Settled card's ruling carries the link.
- **Gate**: `bash tests/smoke.sh; echo $?` gives `smoke: 43 passed`, 0. Scratch round with title `a\b "x"` and question `Memory [cache]`: validator failures 0, deprecated 0, link text `Memory \[cache\]`.
- **Left alone**: NOTE 5, for the lead. README discovery word counts re-measured (2,812).
