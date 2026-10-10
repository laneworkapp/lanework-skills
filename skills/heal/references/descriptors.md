# Descriptors

Board descriptors = lane bodies + the pipeline board sheet. After a skills release they can lag the templates: a lane that names no actor or trigger stalls the watch.

```bash
scripts/heal-descriptors.py <board>...                                # dry run, writes nothing
scripts/heal-descriptors.py <board>... --apply --model M [--name N] [--session S]
```

## Match

- Source = the template tables, read at run time: `lanework/templates/{pipeline,design-loop,datapoint}-lanes.md`, `discovery/templates/lanes.md`. The script holds no copy of the current text.
- Board's lane titles pick the set: ≥ 75% of a set's titles, one set clearly best. No match → data repairs only, nothing else.
- Lanes outside the set (`Rejected`, `Deferred`) are never touched.

## Per lane

Actor/trigger sentence = the template body's second sentence (the tables: `lanework/references/board-kinds.md`).

| the board's body | change |
|---|---|
| empty | `fill-body`: the current template body |
| a predecessor template's, word for word | `replace-body`: the current body |
| the current template's | none |
| already carries the sentence, word for word | none |
| anything else (customised) | `insert-actor`: the sentence goes after its first sentence. Never a replacement. A paraphrase does not count as carrying it, so the owner sees the insert in the dry run and can decline |

- Predecessors = `OLD_BODIES` in the script, from `git log -p` of the template tables. **A template body change adds the body it replaces there, same commit.**

## Pipeline board sheet

Missing the `Agent lanes` bullet → `insert-permission`: the template's line, after the `Two human gates` bullet (else after the first bullet list under the first `##`). No `##` heading → `skip`, left to the owner.

## Stamping

- A descriptor edit restamps the edited file's `modified` whole with the running agent (`--model` required; without it exit 2, nothing written).
- Data repairs (`heal-board.py`) keep its no-restamp rule.
- Writes staged outside the board, then `mv`ed in. A file changed since it was read is skipped, not overwritten.

## Output

`<where>: <code> <what>`, then `N changes in M files`. `skip <where>: <why>` = left for the owner.
