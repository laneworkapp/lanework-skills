---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:40:50Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T22:40:50Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Audit done on branch `pointer-audit` (commit 264b6ca): 9 restated rules became pointers, the rest stay as procedure.**

**Method**: grepped `skills/` for every frontmatter key, value shape and stamp (`priority`, `component`, `kind`, `labels`, `background`, `color`, `icon`, `by`, `created`, `modified`, `order`, `waiting`, `group`, `filter`, `collapsed`). No skill states the retired `default` kind or a scalar `background`.

| where | rule | outcome |
|---|---|---|
| lanework/references/writes.md:10 | priority/component are root keys | **removed**, replaced by a pointer to the guide's § Frontmatter (`labels`) and `.schema/card.json`; "root `priority:` reserved" and the 2026-10-02 copy-shape trap stay |
| writes.md:7 | stamp shape `{at, by}` and `by` keys | pointer (guide § Stamping your work); kept: missing `by` claims the owner, reserved names |
| writes.md:9 | quoting rules | pointer (guide § Frontmatter); kept the 2026-09-12 why-it-bites |
| writes.md:13 | icon shape | pointer (guide § Colors and icons) |
| writes.md:30-32 | 1024 ladder, `card-defaults` | pointer (guide § Creating a card, § Frontmatter lanes) |
| lanework/references/founding.md:19 | board/lane keys, `config`, `background`, `group`, `filter` | pointer (guide § Frontmatter, `.schema/board.json`, `lane.json`) |
| lanework/references/board-kinds.md:11,26 | `filter`/`group` literals | pointer to guide lanes section, shapes dropped |
| pitlane/references/lead.md:27 | "the board's priority field" | now "the card's priority, as the board's guide defines it" |
| pitlane/references/writing.md:51 | `waiting` literal | pointer (guide § Mentions) |
| pitlane/templates/farmed-prompt.md:9 | `by` literal | pointer (guide § Stamping your work) |
| writes.md:11, 15, 36, 40 | validate command, rewrite-whole, `created.at` distinct second, tracker keys | stays: procedure or app-state the guide does not state as a workflow |
| discovery/templates/*, lanework/templates/*, scripts (`lib.sh`, `found-board.sh`, `file-question.sh`) | emit `kind`, `order`, stamps, `labels` | stays: generated output, validated by smoke against the board's schema; each `labels` entry already stamps its `kind` |
| format.md, reading.md, sweep.md, pitwall/events.md | orientation, `fm_value`/`yq` reads | stays: no format rule |

**v82 checks**: built-in kind `text` (no skill names `default`), every label entry stamps `kind` (discovery `Round` label does), `background` mapping (no skill writes one). `authority.md` § Versions left at v78 as instructed.
