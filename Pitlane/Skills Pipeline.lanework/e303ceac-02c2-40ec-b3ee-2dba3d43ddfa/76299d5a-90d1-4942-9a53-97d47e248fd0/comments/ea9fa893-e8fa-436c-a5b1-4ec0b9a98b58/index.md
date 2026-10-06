---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:06:10Z, by: {name: fixer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:06:10Z, by: {name: fixer, kind: agent, model: opus}}
---
**Round 2 is green: `tests/smoke.sh` passes 29 of 29 steps at `4ce4a3a`, rebased onto main `02da9a6`, with both blocking findings of [87d07436](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/87d07436-5d60-49dd-8b2b-95cb81dc6252) fixed.**

- **Fixed**: frontmatter delimiters are column 0 (`rstrip() == "---"`), as the app and the validator read them. A block scalar holding `  ---` survives, and the labels below it heal.
- **Fixed**: a column-0 comment line that ends a key's run is a span of its own. It never folds into a title.
- **Decided, lead's call**: no `modified` restamp, which was option B and the ask's default. `modified-by` folds into `modified.by` when that has no `by`. It is dropped when `modified.by` names the same writer. Otherwise it is dropped and its name is kept in a record on the card. On a lane or board with no card to hold the record, it is a `skip`.
- **Decided**: a title carrying ` #` is a `skip` and never rewritten. YAML reads the rest as a comment, so a human picks the reading.
- **Fixed**: with `--global` defining a kind, the board gains the machine's definition. An unreadable file is a `skip`, not a traceback. Records post before the files change, through the same staged move.
- **Accepted limitation**: a whole-number float in a rewritten list comes back as an integer (`2.0` as `2`), as the app's emitter does. That sits beside the quoting limitation in the script's docstring.
- **Evidence**: smoke steps 10 to 16 are the heal case, now with body-bytes, block-scalar, comment-line, ` #` title and no-restamp checks. Run against the round-1 script, the new smoke fails. Those two blocking cases are shown before and after in the attachment.
- **Evidence**: on throwaway copies of real boards, Skills Pipeline gets 8 repairs, then 0 failures over 133 documents and 0 deprecated. Lanework Pipeline gets 1675 repairs in 1265 files. The only live finding left there is one comment with no frontmatter, listed as `skip`. Second runs change nothing.
- **Attached**: [the gate, the controls and the real-copy runs](attachments/1d21896f-405d-4040-9899-16935e0ae5f0/blob.txt).
