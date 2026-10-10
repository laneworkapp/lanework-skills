---
name: heal
description: "Brings Lanework boards up to the current skills and guide: repairs board damage, then makes every lane body and the pipeline board sheet name who acts and what starts it. Run as /heal <board>..."
disable-model-invocation: true
---

# Heal

Brings each named board to currency, then reports. Runs only as `/heal <board> [<board>...]`: names or paths, resolved as `/watch` does (`watch/references/arming.md` § Boards).

Builds on `lanework` (authority, writes, healing). Read `lanework/references/authority.md` per board first.

## Flow

1. **Dry run, every board**: data repairs (`lanework/references/writes.md` § Healing), then descriptors (`references/descriptors.md`). Show one list per board: every change, every skip with its reason. Note the descriptor `digest`.
2. **The user's go, in this chat.** A user-invoked command confirming its own diff is not an open call on a card: no ask, no `waiting`.
3. **Apply** what was shown, nothing more: `heal-descriptors.py ... --apply --expect <digest>`, with any `--skip` the user chose. Exit 3 = the board changed since the dry run: dry-run again and show it. Both scripts are idempotent: a second run finds nothing.
4. **After**: validate each board (`lanework/references/writes.md` § Every write), one commit per board repo staging only the healed paths, push when the repo has a remote.
5. **Report per board**: what changed, what was skipped and why, what is left for the owner.

## Never

- Rewrite the guide or `.schema/` (the app's).
- Move a card, or edit a card body beyond the data repairs.
- Rewrite a customised lane body: the actor/trigger sentence is inserted, the owner's prose stays.
- Heal a board that matches no lane set past its data repairs.

## Topics

| topic | file |
|---|---|
| lane-set match, actor check, replace vs insert, stamping, the script | `references/descriptors.md` |
| the lane → actor tables the check reads | `lanework/references/board-kinds.md` |
| data repairs | `lanework/scripts/heal-board.py` |
