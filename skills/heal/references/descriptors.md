# Descriptors

Board descriptors = lane bodies + the pipeline board sheet. After a skills release they can lag the templates: a lane that names no actor or trigger stalls the watch.

```bash
scripts/heal-descriptors.py <board>... [--skip LANE]...                  # dry run, writes nothing; ends `digest <hex>`
scripts/heal-descriptors.py <board>... [--skip LANE]... --apply --model M [--name N] [--session S] --expect <hex>
```

## Match

- Source = the template tables, read at run time: `lanework/templates/{pipeline,design-loop,datapoint}-lanes.md`, `discovery/templates/lanes.md`. The script holds no copy of the current text.
- Board's lane titles pick the set: ≥ 75% of a set's titles, one set clearly best. No match → data repairs only, nothing else.
- Every depth-1 folder with a title is a lane, `kind: lane` or not (depth defines it).
- Lanes outside the set (`Rejected`, `Deferred`) are never touched.

## Per lane

Actor/trigger sentence = the template body's second sentence (the tables: `lanework/references/board-kinds.md`).

| the board's body | change |
|---|---|
| empty | `fill-body`: the current template body |
| a predecessor template's, word for word | `replace-body`: the current body |
| the current template's | none |
| already carries the sentence, word for word | none |
| anything else (customised) | `insert-actor`: the sentence goes after its first sentence. Never a replacement |

- First paragraph not plain prose (opens with `#`, a list marker, `>`, a fence, `|`, `<` or `N.`) → the sentence goes in above it as its own paragraph. The owner's markup is never edited.
- A paraphrase does not count as carrying the sentence: the dry run shows the insert, and `--skip <lane title>` (repeatable) declines it.
- Predecessors = `OLD_BODIES` in the script: released history only, from `git log -p` of the template tables. **A released template body change adds the body it replaces there, same commit.** The grill-me predecessor board is not covered.
- **Accepted limitation**: a body that got an `insert-actor` sentence and later meets a changed template gets a second actor sentence. Predecessors are whole bodies; there is no memory of what was inserted.

## Pipeline board sheet

Missing the `Agent lanes` bullet → `insert-permission`: the template's line, naming only the agent lanes the board has, after the `Two human gates` bullet and its wrapped lines (else after the first bullet list under the first `##`). No `##` heading → `skip`, left to the owner. `--skip "board sheet"` declines it.

## Apply exactly what was shown

The dry run ends `digest <hex>`, a hash of the whole change list. `--apply --expect <hex>` recomputes it and refuses (exit 3, nothing written) when the boards changed since: dry-run again, show the user. `--skip` shapes the digest too, so pass the same ones.

## Stamping

- A descriptor edit restamps the edited file's `modified` whole with the running agent (`--model` required with `--apply`; without it exit 2, nothing written).
- Data repairs (`heal-board.py`) keep its no-restamp rule.
- Writes staged outside the board, then `mv`ed in. A file changed since it was read is skipped, not overwritten.

## Output

`<where>: <code> <what>`, then `N changes in M files`, then `digest <hex>`. `skip <where>: <why>` = left for the owner.
