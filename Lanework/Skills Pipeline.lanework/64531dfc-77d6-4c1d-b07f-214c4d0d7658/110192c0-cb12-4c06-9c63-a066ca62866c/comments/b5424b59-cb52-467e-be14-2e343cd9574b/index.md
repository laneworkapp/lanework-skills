---
schema: 1
kind: comment
created:  {at: 2026-11-14T22:06:16Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: efc7a62c-b416-45ee-906a-5d709a5765c8
---
**Out-of-step skills lose no card data. The worst outcomes are an ask nobody sees, a heal that writes a retired thing back, and noisy diffs.**

**Skills older than the board's guide** (the usual case: the app upgraded, the skills were not read against it yet):

| feature | what an old skill does | outcome |
|---|---|---|
| `@anyone`, `for: anyone` (v117) | writes the owner's handle; `lint-ask.sh` reads an `@anyone` ask as a record and skips its checks; a sweep does not count `for: anyone` as waiting on the human | asks still work for one person. An unanswered `anyone` ask can go unreported. **Silent** |
| reserved name `anyone` (v117) | the heal's reserved list lacks it | a stamp signed `anyone` is not flagged. Unlikely to be written |
| `cite-as` (v117) | nothing: no script mints or copies one | none today |
| move receipts, reserved name `board` (v108 to v114) | the watch reads a receipt as a new comment | an agent answers a move as if the owner wrote. Wasted work, visible ([42019d3d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/42019d3d-d517-40da-956d-6962c771b9a2)) |
| `relations/` (v108 to v114) | the skill's heal does not know the folder | inferred, not reproduced: flagged or rewritten as a stray. The v114 smoke case exists to prove it is left byte-identical |
| `component` retired (v108 to v114) | the skill's heal suggests the built-in definition | a retired kind written back into `config.labels`. Visible in the diff |
| short links (v107) | scripts and prose expect full ids | a short link reads as broken. A lint may flag a good link |
| `waiting.for` list (v105) | never writes one; a sweep reads a list as not the human | an unanswered ask to several people can go unreported. **Silent** |
| compact form (v101) | writers emit the block form | the app rewrites the file on its next touch. Noisy diffs and merge conflicts between sessions, no loss |
| lane `card-defaults.labels` kinded (v101) | a filed card skips the lane's kinded defaults | a card born without a label the lane gives. Visible on the card |
| board-shipped heal (v93) | the skill's copy runs beside the board's | two repair lists disagree, and files get rewritten back and forth. The skill's copy now refuses |
| `waiting` clears on `in-reply-to` (v93) | prose says only a later comment clears | none: the app does the clearing |
| tracker engine removed (v93) | reserved names nobody uses | none |

**Skills newer than the board's guide** (a board the app has not upgraded):

| feature | outcome |
|---|---|
| `for: anyone` below v117 | the old build reads a handle nobody has: no mark for anyone, no option buttons. The ask is invisible. **Silent, the worst case here** |
| `for: [a, b]` below v105 | read as no one, and never cleared |
| everything else | harmless: the old build preserves keys it does not know |

- **The pattern**: three rows are silent, and all three are about who an ask reaches. The rest show up in a diff, on the card, or in the validator.
- **What the stamp catches**: it trips on any guide change and says nothing about which row. A red smoke does not tell silent drift from a no-op.
- **A sharper check, not proposed on this card**: one smoke case per row above, on the app-written fixtures. Rows 1, 4, 5, 6 and 8 to 11 already have cases from their catch-ups, so the stamp then guards only rows nobody has a case for yet.
- **Sources**: the catch-up cards in the body's table, `tests/smoke.sh`, guide § Mentions. "Inferred" marks what was read from code and not run.
