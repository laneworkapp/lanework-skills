---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:24:39Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:24:39Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Review round 1 found four ways the merge loses text. Two of the fixes need an owner ruling, and both are asked below.**

**The losses**: uncommitted board edits are erased by the pass. When git finishes a pull by itself, the losing side's text reaches only `.git/lanework-merge/`, in three cases: a body edit against a card moved on the other side, a lane or board body edited on both sides, and a merge comment orphaned by a later move in a rebase. The verdict above has the repros.
**Why they collide with the card**: the card says the merge never stops. Shaping also rejected "a clone with the driver and no agent loses the earlier body silently". The driver can't do both once git finishes the merge without it.
**Option for the first ask**: stop on loss. The driver exits 1 whenever it would drop text it can't keep in place, so git stops and `merge-board.sh` places it. Merges that lose nothing still finish with no stop.
**Options for the second ask**: lanes and the board have no thread. A: git's clean 3-way merge when hunks don't overlap, and both bodies inline when they do, the earlier under a heading. B: later wins, and the earlier goes to `.git/` only, as built.
**Decided, lead's call**: a card purged on one side and edited on the other comes back, per "keep both edits". Single-valued kinds are state, and git renames are refused across cards. Both follow the guide.
**In the meantime**: the fixer builds the recommended defaults, stop on loss and A.
