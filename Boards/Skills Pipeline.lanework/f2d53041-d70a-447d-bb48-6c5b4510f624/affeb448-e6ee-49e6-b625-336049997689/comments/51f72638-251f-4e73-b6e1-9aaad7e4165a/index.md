---
schema: 1
kind: comment
created:  {at: 2026-11-27T12:55:54Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-27T12:55:54Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: the skills' healer loses values the board healer keeps, and one call is open on how it catches up.**

- **Reproduced** on throwaway boards, each healed once by `skills/lanework/scripts/heal-board.py` and once by the board's `.schema/bin/lanework-heal.py` at v6.
- **What the skills' copy loses, with no record**: a lane or card `iconColor`, a bare `glyph:` beside an `icon`, a label's `rank` and a `kind` subkey. A `title: ~` becomes the text `"~"`. It posted 0 records where v6 posted 2.
- **Worst case**: a board with a `config.priorities` roster. The skills' copy adds the stock Urgent to Low definition and drops the board's own rank and colour.
- **Where it bites**: boards with no `.schema/` yet, and runs with `--ignore-board-copy`. On a board that has its own healer the skills' copy already refuses.
- **The reverse**: the app's healer accepts `--name anyone`; the skills' copy refuses it.
- **Options** in the body: (a) port by hand, (b) delegate with the old rules as fallback, (c) drop the skills' healer, (d) ship a verbatim copy of the app's healer behind a thin wrapper. Recommended: (d).
- **Open call**: (d) puts a 1524-line app file in the public plugin, re-copied at each heal version. That is the owner's to allow.
