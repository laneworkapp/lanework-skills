---
schema: 1
kind: comment
created:  {at: 2026-11-27T16:48:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-27T16:48:40Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: APPROVE.** Every done-when line holds on my own runs, both fail-before runs agree with the fixer's, and nothing blocks; 6 notes.

- **Stance**: adversarial, because the fixer ran at opus and the diff changes how persisted comment files merge
- **Round**: 1
- **Card**: [Guide moved to v122: read the skills against it and bump the stamp](lanework://Skills%20Pipeline/cf9fd707-01a4-41e4-82f4-d8616f723f86)
- **Branch**: `guide-v122` at `6d8ed0ba` (read off the branch), on `a490089e`

**Blocking**: none.

**Notes**

1. `README.md:41 @ 6d8ed0ba` "`lanework`, `work` and `watch` on 2026-11-22, `merge` and `plan` on 2026-11-23": the counts for `lanework`, `watch` and `merge` were re-measured in this branch, but their dates were not moved. Earlier count changes moved the date too (`45acb355` set `merge` to 2026-11-23). `check-sizes.sh` does not read the dates, so it passes.
2. `skills/merge/scripts/lanework-merge.py:412 @ 6d8ed0ba` "{keyf(x): x for x in l}": identical entries that carry no emoji collapse into one when both sides changed `reactions`. Base `[👍, {emoji: ""}, {emoji: ""}]`, each side adding one reaction, gives a single `{emoji: ""}`. The guide says such an entry "is kept untouched". The app never writes this shape, so it is a hand-edit edge only.
3. `skills/merge/scripts/lanework-merge.py:545 @ 6d8ed0ba` "pick = lt if win == 'theirs' else lo": when one side holds a scalar or mapping and the other added a reaction, the tie goes to ours with no merge comment. With ours `reactions: lol` and theirs adding 👀, the 👀 is dropped silently. `rules.md` documents "Not a list on a side → later wins", and it matches every other later-wins key, so this is a note only.
4. `skills/lanework/scripts/lib.sh:198 @ 6d8ed0ba` "l=$(printf '%s' "$1" | tr 'A-Z' 'a-z')": the name is not trimmed, so `--name ' board'` is accepted and writes `name: " board"`. `heal-board.py`'s `canon` strips before it compares, so the two guards disagree on padded names.
5. Script headers: none of the 13 `stamp_args_ok` callers lists reserved names among its exit-2 causes. `writes.md` says "Each script header lists its own", but the earlier control-character refusal from the same function is not listed in any header either, and only `claim-ticket.sh` lists "an empty --name". So the repo's habit does not require it today. If the lead wants headers complete, one pass should add both causes together.
6. `skills/lanework/references/reading.md:25` and `skills/watch/references/events.md:11 @ 6d8ed0ba`: both now say what a move receipt is, and `moved.by` is explained in `reading.md` and in `events.md` item 5. The card's Scope asked for both lines, so this is not scope creep. Under one topic, one file, `events.md` could link `reading.md` instead.

**Checked**

- **Context**: the card body and all 15 comments, including the C ruling, its withdrawal and the A ruling (`7f055c3d`, `b1f4a736`), the START record and the fixer evidence `661ccb5a`. The reactions text follows A: agents never react, and a reaction is never an answer.
- **Correctness vs done-when**:
  - Reactions: I ran `tests/merge-case.sh <scratch> reactions` from the worktree. It exited 0, and the both-add case kept 👍 🎉 👀, while remove-and-add kept 🎉 👀 and the 👍 stayed removed. It validated, with no merge comment.
  - Ad hoc cases called `merge_doc` directly on scratch documents. Both add the same reaction: one entry. Both add different ones: all three. One removes while the other adds: the removal holds and the addition is kept. Both remove: gone. Removed on one side and re-stamped (`at` changed) on the other: the changed entry is kept. Base has no key: both additions kept. One side deletes the whole key while the other adds: only the addition survives. Scalar or mapping on a side: later wins, ties ours. Entry with no emoji: kept. Owner 👍 and bob's 👍: two entries. Block form against flow form: merged. A bare `by: alice` keys the same as `{name: alice}`.
  - Order of the result: ours' order first, then theirs-only entries appended, which is first appearance within the merged list.
  - Other keys: `in-reply-to` and the body are untouched. A one-sided body edit merges with a one-sided reaction and leaves no merge comment.
  - A real `modified` conflict on the same comment still keeps the later body and posts "The comment: kept the later edit (2026-01-06T00:00:00Z, owner)", and its reactions are unioned.
  - `reactions` on a card (not a comment) still falls to later wins, and the guide says no other level carries the key.
  - Reserved names: `anyone`, `ANYONE`, `BoArD`, `Healer`, `SHORTCUTS` and `Tracker` exit 2 from `post-comment.sh`, with "<name> is a reserved name; sign as yourself; nothing written". `boarder`, `claude`, `Claude` and `Boards` pass. `lease.sh check --name board` exits 2, which is a 13th caller the fixer did not list and smoke does not test. `found-discovery-board.sh` and `found-plan-board.sh` with `--name Board` exit 2 with no folder written, because they pass the name through to `found-board.sh`.
  - Stamp: `CLAUDE.md:28` reads `lanework-agent-guide v122` on the same line, in the same place. `grep -rn 'agent-guide v' skills` finds only the parser comment in `lib.sh`.
- **Project conduct**:
  - The two commits keep the skill change and the stamp apart, and neither commit carries a board write.
  - No reserved signer appears in `skills/` or `tests/`, apart from the existing heal refusal tests and two hand-written fixtures that imitate app and Shortcuts writes (`smoke.sh` 1690, 2087).
  - The reference lines are telegraphic.
  - The `rules.md` row is the only merge rule for reactions.
  - The `RESERVED_NAMES` set in `lib.sh` matches `heal-board.py` and `heal-descriptors.py`. The v122 guide names four reserved names; `tracker` is the skills' own fifth, as the card's Scope asks.
- **Both paths**: the flow and block YAML forms are both handled. Missing, empty and non-list values are handled. The direct writers and the three founding wrappers, plus `lease.sh`, are covered.
- **Fail-before**: OWN RUN agreed. I used `git archive a490089e` into scratch with the branch's `tests/merge-case.sh` overlaid. The run printed "merge-case (reactions): reactions, both add: 👀 lost" and exited 1. At the base, `file-card.sh --name board` and `post-comment.sh --name board` both exit 0.
- **Test adequacy**: the new merge case sits beside its neighbours in `merge-case.sh`, and the header lists the new mode. The reserved-name loop sits next to the control-character loop in the braces section and asserts exit 2, the stderr line and an unchanged board for 12 scripts. `lease.sh` is not in that loop.
- **Blast radius**: 10 files. Eight are the card's Scope rows. `README.md` counts and the `writes.md` `stamp_args_ok` clause are the two extras the fixer named. `tests/smoke.sh` holds the reserved-name case the Scope asks for.
- **Gates (worktree)**: `bash -n` passed on `lib.sh`, `merge-case.sh` and `smoke.sh`. `py_compile` passed on the driver. `check-refs: 259 references, 0 missing`. `check-sizes: 59 rows, 0 wrong`. `smoke.sh --only braces,merge` printed `smoke: 34 passed (sections: braces, merge)`, exit 0, and the worktree was clean afterwards. My first run failed with "interrupt: the harness wrote __pycache__". The cause was my own ad hoc `python3 -I` import of the driver, which left a cache in the worktree at 10:16:56. `-I` ignores `PYTHONDONTWRITEBYTECODE`. I removed it and re-ran on the clean tree. The branch's own scripts write no cache, so this guard works.
- **Population**: 13 `stamp_args_ok` callers, from `grep -rn 'stamp_args_ok "$NAME"' skills`. 12 are in smoke, and `lease.sh` I ran by hand. 18 ad hoc merge cases, plus 3 compound ones.

**Hypotheses**, written on reading the diff, before my runs. 2 of 5 held, as notes only.

1. Reactions changed alongside a later `modified` edit would lose the earlier side's reactions. Refuted: the union runs whatever side wins.
2. Rewriting the list would change the bytes of entries nobody touched. It holds but is harmless: `at` and the names are quoted, the validator accepts that, and labels merge the same way.
3. Duplicate or invalid entries would be altered. Held for identical entries with no emoji (Note 2).
4. Some writer would bypass `stamp_args_ok`. Refuted: all 15 scripts that write a stamp either call it or delegate to `found-board.sh`.
5. Case folding would miss mixed case or catch real names. Refuted. Padding is the one gap (Note 4).
