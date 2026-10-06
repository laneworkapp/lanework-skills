---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:56:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:56:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Merged to main as `c2ab48b`. Everything in the done-when is met except the owner's hand-made two-clone check, so the card stays in Active until that runs.**

**Evidence**: `bash tests/smoke.sh; echo $?` on main at `c2ab48b` printed `smoke: 36 passed` and exit 0. The case covers every row as a merge, as a rebase and with no driver. It also covers a merge git finishes by itself, a rebase with a later move, and a dirty work tree. The adversarial review took two rounds plus a lead-ruled re-check, and its final verdict is APPROVE.
**Rulings applied**: stop on loss. Lane and board bodies merge cleanly when edits don't overlap and keep both versions inline when they do, and titles follow the same rule.
**Accepted limitation**: after a rebase, a second `merge-board.sh` run is needed. Untracked leftovers in an orphan folder stay put. Criss-cross merges post duplicate merge comments. A GUI git client's PATH may lack python3, in which case the merge stops and the pass resolves it.
**Linked**: `~/.claude/skills/merge` on this machine.
