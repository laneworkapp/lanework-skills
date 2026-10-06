---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:47:05Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-06T22:47:05Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Round 1 fixed on `pointer-audit` (06e17f2, rebased onto main da61093): the smoke guard now catches all three mutants, and smoke passes end to end.**

**BLOCKING (smoke step 19)**: regex is now `\b(priority|component):|(priority|component)[^.]*(root|top-level)|(root|top-level)[^.]*(priority|component)`, case-insensitive, skipping lines that say "reserved". Own run on mutants: "Write `priority:` as a top-level key", "Priority and component live at the card root", "Set the root key `priority`" all CAUGHT; "root `priority:` keys are reserved" passes. Zero hits on the branch's skills tree.
**NOTE 4**: plain prose "Priority: rank the cards first." is also CAUGHT, on purpose: no such line exists, and one that appears must be reworded.
**NOTE 1**: writes.md delete bullet cites guide § Editing and deleting; Moving cites § Moving and reordering. Audit rows: writes.md delete bullet, pointer (§ Editing and deleting); writes.md Moving bullets, pointer (§ Moving and reordering).
**NOTE 2**: quoting pointer now names the guide's two sentences ("Quote any `title` containing a colon", "Keep every scalar on one line"). **NOTE 3**: founding.md now says "The script writes the board's required keys."
**Gate**: `tests/smoke.sh`, exit status read directly: rc=0, `smoke: 21 passed` (step 21, plugin validate, green on main's fix).
