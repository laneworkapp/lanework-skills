---
schema: 1
kind: card
title: "Fix the merge script dropping a kept card's unedited files"
order: 104448
labels: [{text: "merge", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-22T22:20:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
modified: {at: 2026-11-23T04:03:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
When one side deletes a card for good and the other edits it, the board merge pass brings the card back with only the files the surviving side changed, so its unedited comments, attachments and relations are gone, and the merge comment still says "the edited card is kept". The same pass also aborts on a stamp with no timezone, leaves a comment in a folder with no `index.md` when the edit was to a comment alone, and deletes a card's files before it rewrites them, so an interruption between the two loses local edits. All four reproduce, and the board validator passes on every broken result.

## Evidence

Each case was run on a throwaway repo under `mktemp -d`: a board founded with `found-board.sh`, the driver installed, and one card holding `index.md`, a comment, an attachment (`index.md` and `blob.png`) and a relation, committed as the base. Branch `side` and `main` then diverge, `git merge side` runs, then `merge-board.sh <repo> --model test`. Scripts were read at `skills/merge/scripts/lanework-merge.py` as of `6e04933`.

- **Main claim, reproduced both ways.** `main` runs `git rm -r` on the card, `side` restamps `modified` and edits the body; then the mirror. Git reports `CONFLICT (modify/delete)` on `index.md` only. The pass exits 0 with "Merge comments on 1 card: "K base" (The other side deleted this card for good; the edited card is kept.). Acme.lanework validates (11 documents)." The card folder afterwards holds `index.md` and the new merge comment only. In the mirror, git had already staged the deletion of the comment, the attachment and the relation, and the pass did not restore them.
- **Cause.** Lines 944 to 953: the deleting side's file map is empty, so every unedited file has `vt == vb` (or `vo == vb`) with the deleting side's value `None`, the pick is `None`, and nothing is written. Only files the survivor changed reach line 955. The merge comment is line 917, not 916.
- **(a) Mixed timezones, reproduced.** Both sides edit the body; `main` stamps `2026-01-02T00:00:00Z`, `side` stamps `2026-01-03T00:00:00`. The driver prints "can't compare offset-naive and offset-aware datetimes" and keeps ours. The pass then dies at line 904 with `TypeError` in `later()`, line 384, exits 1, and leaves the path unmerged. The schema's `timestamp` pattern allows a stamp with no zone. Probing `stamp_at()` directly, a date alone, a space separator (`2026-01-03 00:00:00Z`) and a lowercase `t` raise the same error, because the regex on line 362 stops at the space or the `t` and parses a bare date. A one-digit month (`2026-1-3T00:00:00Z`) parses as no stamp, so ours wins silently. With both stamps zoned the same case resolves, exit 0.
- **(b) Delete against a comment-only edit, reproduced both ways.** `side` edits only the comment. The pass exits 0, says "the edited card is kept", and adds "Not re-homed: c0000000 (git and the disk disagree on where the card is: commit the move first)". The folder holds the edited comment and the merge comment, with no `index.md`, and the board still "validates (11 documents)". Same cause as the main claim: `index.md` is unedited, so it is dropped.
- **(c) Remove before rewrite, reproduced by simulation.** Both sides edit the body; the comment holds an uncommitted edit. A harness imports the script, replaces `write_atomic` with a function that raises `KeyboardInterrupt`, and calls `cmd_resolve`. That is an interruption after `remove_paths` (line 1001) and before the first write (line 1015). Afterwards the card folder has no files, and git status shows all five card paths as `D`. The uncommitted text is in no file and not in the index. It survives only as an unreachable blob that `git merge` happened to hash, which an edit made after git stopped would not have.
- Read, not run: the smoke idiom. `tests/merge-case.sh` builds two clones and runs one mode per call; `tests/smoke.sh` lines 1711 to 1715 call each mode. The full case's D1 row (deleted against edited) has only `index.md`, which is why smoke passes.

## Proposal

- **Kept card, whole tree** (`process_card`). When one side has no card and `L` is set, the content loop uses the base map in place of the deleting side's empty map: a whole-card delete reads as "left every file as it was". The `vt == vb` and `vo == vb` branches then pick the survivor for every file. The survivor's own deletions stay deleted and its additions stay. This fixes (b) too: `index.md` comes back with the edited comment. The uncommitted-edit loop (line 974) keeps the real maps.
- **Stamps** (`stamp_at`). Parse with the schema's `timestamp` pattern, so a space, a lowercase `t`, one-digit fields and a date alone all read. A stamp with no zone reads as UTC, as YAML 1.1 defines it. `later()` then never compares naive with aware.
- **Write before remove** (`process_card`). Write every final file and extra first (`write_atomic` already replaces in place), then remove only the tracked paths not rewritten, then `git add`. An interruption then leaves at worst a second copy and the unmerged entries, and a rerun of the pass resolves it.
- `skills/merge/references/rules.md`: the "deleted for good" row says the whole surviving card is kept; a line under Content says a stamp with no zone reads as UTC; How it runs says the pass writes before it removes.
- `tests/merge-case.sh`: new modes `delete`, `stamps` and `interrupt`. The `interrupt` harness imports the script with bytecode writing off, so it leaves no `__pycache__` in the repo. `tests/smoke.sh`: one `ok` line each beside lines 1711 to 1715.
- `CHANGELOG.md`: one user-facing entry for the release.

## Risks

- Substituting the base map must apply only to a whole-card delete. A file deleted inside a card that both sides kept must still follow the 3-way rule.
- Writing in place before removal touches files git holds as unmerged. The final `git add` must still clear every stage, and a moved card must not leave its old folder behind.
- Reading a zone-less stamp as UTC can flip a winner that used to go to ours by error. That is the fix, but the merge comment wording stays the same.

## Verification

Each new case fails on the current script, using the reproductions above.

- `delete`: deleted on ours, body edited on theirs, then the mirror. Every base file of the card is back byte for byte; the merge comment names the delete.
- `delete`: the survivor also removes one comment and adds another. The removed one stays gone; the added one is kept.
- `delete`: deleted against a comment-only edit, both ways. The card has its `index.md` and the edited comment, and no "Not re-homed" line.
- `delete` control: deleted against no change. The card stays gone (passes before and after).
- `stamps`: ours zoned, theirs zone-less and later. Pass exits 0 and theirs wins. Plus direct `stamp_at()` asserts for a date alone, a space, a lowercase `t`, a one-digit month and `+02`.
- `interrupt`: the harness above. The uncommitted comment text is still on disk after the interruption, and a second pass exits 0 with the text carried.
- The existing modes (`merge`, `rebase`, `nodriver`, `clean`, `rebasemove`, `dirty`, `appside`) still pass.

## Done when

- [ ] A card kept against a delete keeps the whole surviving side's tree, both ways, and the survivor's own removals hold.
- [ ] (a) fixed: a zone-less or loosely written stamp never aborts the pass, and reads as UTC.
- [ ] (b) fixed: a delete against a comment-only edit keeps the whole card.
- [ ] (c) fixed: the pass writes before it removes, and the `interrupt` case proves an edit survives.
- [ ] `delete`, `stamps` and `interrupt` are in `tests/merge-case.sh`, called from `tests/smoke.sh`, and `tests/smoke.sh` passes.
- [ ] `rules.md` matches the new behavior.
- [ ] The fix ships as a plugin release.

## Decision in this proposal

A comment-only edit, or an added comment or attachment, brings back a card the other side deleted, whole. `rules.md` already says an edit is kept against a delete, the pass already says "the edited card is kept" in this case, and there is nowhere else to hold the comment. The alternative honors the delete and loses the comment.

## Outside this card

The board validator said "validates" on every broken result, a card folder with no `index.md` among them. The validator is the app's file in each board's `.schema`, not part of this repo, so the new cases assert on the files directly.

## Release

Patch: fixes only. This is data loss in a shipped skill, so it is worth a release of its own.

## Open calls

None.
