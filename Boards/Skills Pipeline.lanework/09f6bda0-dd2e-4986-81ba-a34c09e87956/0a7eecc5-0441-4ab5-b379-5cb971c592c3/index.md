---
schema: 1
kind: card
title: "Merge: a conflicted card whose lane was removed outright still lands in a lane with no index.md"
order: 1024
labels: [{text: "merge", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-23T18:46:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-28T20:02:25Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-28T20:32:25Z
---
When one side removes a whole lane with `git rm -r` and the other side changes a card in it, the merge pass keeps the card inside the removed lane's folder, which now has no `index.md`, so the app skips the card, the validator and the heal both pass over it, and the report says "validates".

## What happens

Reproduced on a throwaway repo, not on any board in the repo. The harness is a copy of the first 122 lines of `tests/merge-case.sh` (the base board, two clones A and B, `mclone`), with `ROOT` pinned to the repo and one new mode, `lanegone`, appended. It was run on a directory from `mktemp -d`. Ours is A, theirs is B, as in every `merge-case.sh` mode.

Three variants, all at code `7aee58f7`:

| card | ours (A) | theirs (B) |
|---|---|---|
| G1, in Approved | `git rm -rq` the Approved lane | edits G1's body |
| G2, in Active | edits G2's body | `git rm -rq` the Active lane |
| G3, in Ideas at the base | moves G3 into Done and edits it | `git rm -rq` the Done lane (empty at the base), edits G3's body in Ideas |

`git merge` stops on all three (two `CONFLICT (modify/delete)` lines and one `CONFLICT (content)` from the driver). Then `merge-board.sh` prints, and exits 0:

```
Board merge (merge): 3 unmerged board paths resolved. Placed by the later stamp: "G3 base" to b62677c1. Merge comments on 3 cards: "G2 base" (The other side deleted this card for good; the edited card is kept.); "G3 base" (The body: kept the later edit (2026-01-04T00:00:00Z, alice); the earlier (2026-01-03T00:00:00Z, bob) is below.); "G1 base" (The other side deleted this card for good; the edited card is kept.). Acme Pipeline.lanework validates (39 documents). Nothing is committed: commit the merge.
exit 0
```

"to b62677c1" is the lane title falling back to the first eight characters of the folder name (`lane_title` in `skills/merge/scripts/lanework-merge.py`), because the lane has no `index.md` to read a title from. On disk all three lanes are folders with no `index.md`, each holding the whole card:

```
Approved (f8d5cea4-0e6f-441a-a653-b8a3be6b0a06): index.md MISSING
   ./a13e386b-8c1f-457d-b9bc-5516177ebaf9/index.md   (plus its comments, attachment and relation)
Active (5f2f8b36-d9e5-439c-b728-4ba3ebe6a7ce): index.md MISSING
   ./528caa7a-ba0c-4e2f-a9fb-796191b2cb5d/index.md   (plus its comments, attachment and relation)
Done (b62677c1-4892-42aa-bfad-efe9b8fd578e): index.md MISSING
   ./9ec63456-88a3-42f1-9343-5a34485a62b2/index.md   (plus the merge comment)
== .trash
(none)
```

The board validator, `Boards/Skills Pipeline.lanework/.schema/bin/lanework-validate.py --schema <that .schema> <throwaway board>`, passes with exit 0 and only counts the lanes:

```
skipped     strays 0, index-less identity folders 3, symlinks 0, retired flat attachments 0
failures    0 over 0 of 39 documents
```

The board's own heal (`.schema/bin/lanework-heal.py <board>`, dry run) reports one unrelated repair (`H17 compact-collection`) and nothing about the three lanes: its `documents()` walks only uuid folders that hold an `index.md` (`uuid_dirs`).

The app skips such a lane and everything in it. `lanework-app/Lanework/Storage/BoardLoader.swift` guards each lane with `guard hasIndex(laneURL) else { return .skipped(.missingIndex(path: laneName)) }` and the warning reads "`<lane>: folder has no index.md, skipped`". So the owner sees no card at all, only a load warning naming a uuid, while the merge comment on the hidden card says "the edited card is kept". The edit is not deleted from disk, but nobody can see it in the app.

### Why it falls through

The placement decision is in `process_card`, `skills/merge/scripts/lanework-merge.py` lines 931 to 956. After the placement table picks `L`, one fallback handles a gone lane:

```python
if lane_gone(repo, board, L):
    L = trashed_lane(repo, board, L) or lo or lt
```

- `lane_gone` (line 909) is true when the card's lane folder has no `index.md` on disk. Git has already removed the lane's `index.md` cleanly, because one side deleted it and the other left it alone, so it is never an unmerged path and the pass never sees it.
- `trashed_lane` (line 914) only finds a lane moved into `.trash/<lane>/`. A lane removed with `git rm -r` has no trashed copy, so it returns `None`.
- `lo or lt` is then the fallback. For G1 and G2 one side deleted the card with its lane, so that side's location is `None` and the other location is the gone lane itself. For G3 both locations exist, but `lo` (ours, in the removed Done lane) is tried first and is truthy, so the live location `lt` (Ideas) is never reached.

`rules.md` documents exactly this ("card's lane gone on the winning side | the lane's trashed copy, else ours' location"). The restore path already does better: `restore_deleted` (line 1187) sends a card whose lane is gone to `trashed_lane(...) or ('.trash', card)`, and `tests/merge-case.sh` mode `deleteadd` (card E6) checks that. The two paths follow different rules.

The two other findings on this card, read from the code and not reproduced here:

- A card the pass places in `.trash/` keeps its old `modified` stamp. `restore_deleted` writes the survivor's blobs byte for byte (lines 1197 to 1204), and `process_card` writes the merged `index.md` with the merged stamp. The in-board guide says a move into `.trash/` restamps and that "The trash sorts by `modified.at`, newest first", so such a card sorts low in the trash.
- An untracked file left in a card folder the pass moved away from keeps that folder alive, and the validator registers the folder as a second identity next to the card's new home, so the board fails validation and the pass exits 1. `rules.md` Limits already has the entry "Re-homing moves tracked files only. An untracked file left in an orphan folder (an unposted draft) stays there." but does not say what that does.

## Decided here, not asked

The card's own Done when already chose the trash. The research below confirms it; no call is left for the owner.

| option | files touched | data-loss risk | what the owner sees |
|---|---|---|---|
| (a) restore the removed lane's `index.md` from the side that kept it | `lanework-merge.py` (`process_card` writes `<lane>/index.md` from the base or survivor tree, outside the card loop), `rules.md`, `merge-case.sh` | none for the card. It undoes a deliberate permanent delete, and the lane comes back holding only the cards the other side changed, because its unchanged cards stay deleted | a half-empty lane reappears. If it is an agent lane (Approved, Active), the `watch` skill can arm the card and an agent starts work nobody asked for. A lane has no thread, so nothing on the lane explains why it is back |
| (b1) move the card to the board's first lane | `lanework-merge.py`, `rules.md`, `merge-case.sh` | none | the card turns up in a lane it was never in. On a board whose first lane is an agent lane, the same hazard as (a) |
| (b2) move it to the lane the remover moved the lane's other cards to | as (b1), plus a base-to-remover diff to find that lane | none | right when it is detectable. In practice a lane is removed with its cards, as in this repro, so the heuristic usually finds nothing and needs a fallback anyway |
| (b3) move it to `.trash/<card>`, restamped, with a merge comment saying why | as (b1), plus the restamp in `restore_deleted` | none: every file kept, restorable from the trash | the card at the top of the trash, with a merge comment naming the deleted lane, and a report sentence saying it went to the trash. It never lands in a lane it was not in, and never in an agent lane |
| (c) leave it and only report | `lanework-merge.py` (a report line), `rules.md` | the files stay on disk, but the app never shows them, and the heal ignores them | nothing on the board, and a load warning naming a uuid |

Decided: (b3), with one refinement taken from the G3 variant. Where the card has another location on a live lane (or in the trash), it goes there, since only its destination lane was deleted and the card itself never was. The rule becomes: the lane's trashed copy, else the other side's location when its lane is live or it is in the trash, else `.trash/<card>`. This is the rule `restore_deleted` already follows, so both paths share one rule and one row in `rules.md`.

Also decided:
- **Restamp on a trash arrival the pass makes.** When the pass puts a card into `.trash/` and it was not in `.trash/` at the base or on either side, `modified` becomes now with the merge signer (`signer(model)`), in `process_card` and in `restore_deleted`. This is the guide's stamp rule for a container change, and it puts the card on top of the trash. A card a person trashed keeps the stamp the merge picked.
- **The merge comment and the report say why.** One loss line, "Its lane was deleted on the other side, so the card is in the trash.", and the report's placement sentence names "the trash: its lane was deleted", as the restore path does, in place of a uuid prefix.
- **Limits gets the untracked-file consequence** by extending the existing re-homing entry, not by adding a new one.

## Scope

| file | change |
|---|---|
| `skills/merge/scripts/lanework-merge.py` | `process_card`: replace `L = trashed_lane(repo, board, L) or lo or lt` with the trashed copy, else the first of `lo`, `lt` that is not `L` and not `lane_gone`, else `('.trash', card)`. Restamp `index.md` when the final location is in `.trash/` and no tree had it there. Add the loss line and the report wording. `restore_deleted`: the same restamp. Keep one helper for "where does a card whose lane is gone go" so both paths call it |
| `skills/merge/references/rules.md` | Placement row "card's lane gone on the winning side": the new rule, the restamp and the merge comment. The restore row's "Its lane gone" clause points at that row. Limits: extend the re-homing entry with "the folder stays as a second identity, so the board fails validation and the pass exits 1" |
| `tests/merge-case.sh` | new mode `lanegone` with G1, G2 and G3 as in the repro, run as a merge and as a rebase: G1 and G2 whole in `.trash/<card>` with a later `modified.at` than either side and one merge comment naming the lane; G3 in Ideas; no folder left for Approved, Active or Done; the report says "the trash: its lane was deleted"; the board validates with `index-less identity folders 0`. The `deleteadd` E6 check adds the restamp |
| `tests/smoke.sh` | one `ok "merge case: ..."` line for `lanegone`, beside the other merge-case lines (around line 2243) |

## Risks

- **Overlap with the `guide-v122` worktree** (card cf9fd707, in Active). Its diff touches `tests/merge-case.sh` (the header comment, the mode list on lines 16 and 17, and a new `reactions)` case just before `esac`) and `tests/smoke.sh` near the merge-case lines. This card edits the same lines, so whichever lands second has a small textual conflict to resolve. Its `lanework-merge.py` change is for comment reactions (content merging), and this card touches `process_card` and `restore_deleted`, not the content merge, so no logic overlap is expected. Land after it, or rebase onto it.
- **The restamp changes state ties.** A card the pass restamps into the trash now carries a later stamp than either side, so a later merge of an older branch that edits it sees the trash as the later state. That is what a trash move by hand already does.
- **A side that trashed the card itself** (a `.trash/<card>` location on that side) must keep its own stamp. The check "no tree had it in `.trash/`" covers this; the `merge` mode rows TR1, TR2 and TT must still pass.
- **The rebase direction flips ours and theirs.** The new rule picks by liveness, not by side, so the rebase phase should land the same way; the test runs both to prove it.

## Verified by

- The new `lanegone` mode fails first against `7aee58f7` (G1 not in `.trash/`), then passes.
- `tests/merge-case.sh <dir> <mode>` passes for every existing mode, `deleteadd` with its added restamp check included.
- `tests/smoke.sh` passing in full, which runs `bash -n`, the schema validator, `check-refs.sh` and `check-sizes.sh`.

## Done when

- A conflicted card whose lane was removed outright, and that has no other live location, lands whole in `.trash/<card>`, both when ours removed the lane and when theirs did.
- A card with another live location (G3) lands there, not in the removed lane.
- `process_card` and `restore_deleted` call one shared rule for a card whose lane is gone.
- A card the pass puts in the trash, which no side had in the trash, is restamped with the merge signer and sorts on top of the trash.
- The card's merge comment and the pass's report say the card went to the trash because its lane was deleted; no lane is named by a uuid prefix.
- After the merge, the validator reports `index-less identity folders 0` and no removed lane's folder is left on disk.
- `rules.md` has the new placement rule in one row, and its Limits entry on re-homing names the failed validation an untracked file causes.
- `tests/merge-case.sh` has a `lanegone` mode, run as a merge and as a rebase, listed in `tests/smoke.sh`, and smoke passes.
- The closing record carries the changelog sentence.
