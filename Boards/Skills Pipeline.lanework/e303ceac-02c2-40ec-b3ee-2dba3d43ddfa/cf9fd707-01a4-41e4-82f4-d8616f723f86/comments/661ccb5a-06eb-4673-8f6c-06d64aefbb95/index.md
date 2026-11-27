---
schema: 1
kind: comment
created:  {at: 2026-11-27T15:11:37Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-27T15:11:37Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Fixer evidence: the v122 card is built on `guide-v122` (39901277, 6d8ed0ba), and full smoke passes with no drift note.**

- **Reactions failed before the fix (measured)**: `tests/merge-case.sh <scratch> reactions` against the unchanged driver. When both sides added a reaction, bob's was dropped and git finished with exit 0: `merge-case (reactions): reactions, both add: 👀 lost`. When one side removed a reaction and the other added one, only `🎉` survived, so the other side's `👀` was lost.
- **Reserved names failed before the fix (measured)**: `tests/smoke.sh --only braces` printed `post-comment --name anyone: exit 0 (want 2), or no message, or the board changed`.
- **Reactions after the fix (measured)**: in the both-add case the merged comment keeps 👍, 🎉 and 👀. In the remove-and-add case it keeps 🎉 and 👀, and 👍 stays removed. Git finishes on its own with no merge comment, and the board validates.
- **Reserved names after the fix (measured)**: `anyone`, `board`, `healer`, `shortcuts`, `tracker` and `Board` exit 2 and write nothing, from post-comment, file-card, post-ask, label-card, move-card, file-question, settle-question, file-record, file-ticket, claim-ticket, resolve-ticket and found-board. Post-comment and file-card print `<script>.sh: <name> is a reserved name; sign as yourself; nothing written`. The name `boarder` is still accepted.
- **Gate (measured)**: `--only braces,merge` printed `smoke: 34 passed (sections: braces, merge)`. The one full run printed `smoke: 422 passed` and exited 0, with no guide drift note. That is 420 cases before this change plus the 2 new ones.
- **Callers (measured)**: no script under `skills/` or `tests/` signs as a reserved name. The only `--name` uses of one are the existing heal refusal tests.
- **Also changed**: `README.md` word counts for the four reference files and their totals, because `check-sizes.sh` failed without them. `writes.md`'s line on `stamp_args_ok` now names reserved names too.
- **Not changed**: the script headers still list their exit-2 causes without reserved names.
