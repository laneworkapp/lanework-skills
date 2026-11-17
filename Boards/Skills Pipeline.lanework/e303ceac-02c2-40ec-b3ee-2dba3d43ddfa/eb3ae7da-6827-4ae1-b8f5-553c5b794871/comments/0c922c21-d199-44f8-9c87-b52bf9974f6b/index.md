---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:19:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T23:19:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Merged to main as `7a27938`. The skills are `work` and `watch`, and this machine's `~/.claude/skills` links are renamed to match.**

**Evidence**: `bash tests/smoke.sh; echo $?` on main at `7a27938` printed `smoke: 30 passed` and exit 0. The adversarial review approved in round 1. Three of its notes were applied in `1a3333e`: smoke now fails on a missing lint script, the `work` word count is corrected, and the headings are capitalised. The lead checked that diff.
**Decided, lead's call**: no "Pitlane" trigger alias on `work`. The rename ruling drops the racing words, and the boards folder loses the name in the same release.
**Links**: `~/.claude/skills/pitlane` and `pitwall` are replaced with `work` and `watch`, which point at the renamed folders. They aren't tracked in the dotfiles repo.
**Next**: the merge-skill branch rebases over this. It conflicts only in `plugin.json` and `README.md`.
