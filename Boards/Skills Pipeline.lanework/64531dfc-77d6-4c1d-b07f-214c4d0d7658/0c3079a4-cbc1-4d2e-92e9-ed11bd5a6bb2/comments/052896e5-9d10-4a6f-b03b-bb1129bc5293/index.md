---
schema: 1
kind: comment
created:  {at: 2026-11-23T16:43:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T16:43:52Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Shaped: three slices in the body; one call is open, the scope that keeps a section out of another section's variables.**

Slices 1 (timers by pid) and 2 (named sections, `--list` and `--only`) need no ruling. Slice 3 rides on slice 2 whichever option is ruled. Behaviour below was checked on bash 3.2.57 in a throwaway folder.

- **A: each section a function run in its own subshell** (recommended)
  - Nothing a section assigns or defines can escape it. With `set -u` already on, a later read of an earlier section's name fails loudly.
  - Each section's exit trap runs when the section ends, which fixes the four `trap ... EXIT` lines that replace each other today.
  - Cost: the case counter moves to a file (about 4 lines). The boards shared on purpose (`D` read by 16 later sections, `P` by 5, `LB` by 3, `PL` by 2) each become a fixture function that founds the board fresh.
- **B: each section a function with `local`**
  - Only names declared `local` are kept in. About 740 names are assigned in the suite, so every section needs a list, and a missed name still leaks.
  - The counter keeps working. The exit traps still replace each other. The largest diff of the three.
- **C: a lint that fails on a name reused across sections**
  - Smallest runtime change. About 114 names are reused today, most of them scratch names (`rc`, `O`, `out`): passing needs about 100 renames or an allowlist, and an allowlist would have let `PL` through.
  - It reads assignments, so it misses `RE`, which the lease section only read. Catching that needs a read-side check too.
