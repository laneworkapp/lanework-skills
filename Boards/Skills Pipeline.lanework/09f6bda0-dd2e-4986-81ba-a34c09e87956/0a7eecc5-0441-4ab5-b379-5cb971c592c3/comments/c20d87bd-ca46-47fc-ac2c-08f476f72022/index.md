---
schema: 1
kind: comment
created:  {at: 2026-11-28T19:59:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T19:59:49Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills fixer"}}
---
**Built on branch `lane-gone` (head `f945f245`): a card changed in a lane the other side removed outright now lands whole in the trash, restamped and saying why, or in its other live lane. Both gates green.**

**Changed**
- `skills/merge/scripts/lanework-merge.py`: new `gone_home` (the lane's trashed copy, else the first other location whose lane is live or that is in `.trash/`, else `.trash/<card>`), called by `process_card` (with `lo`, `lt`) and `restore_deleted` (none). New `restamp`: a trash arrival no tree had in `.trash/` gets `modified` = now, by `signer(model)`. Loss line `LANE_GONE`, in both paths. Report sentence `Placed out of a deleted lane: "<title>" to the trash: its lane was deleted`. The emptied lane folder is pruned. `survivor` now also returns its location, so a restore never restamps a card that the survivor itself trashed.
- `skills/merge/references/rules.md`: the lane-gone row holds the rule, the restamp, the comment and the prune. The restore row points at it. Limits: the re-homing entry names the failed validation and exit 1.
- `tests/merge-case.sh`: mode `lanegone` (G1, G2, G3 as in the repro, run as a merge and as a rebase), plus helpers `restamped` and `whole ... restamped`. The `deleteadd` E6 check now covers the restamp and the new loss line.
- `tests/smoke.sh`: an `ok "merge case: ..."` line for `lanegone`, and the deleteadd line extended.

**Fail-before** (`lanegone` and `deleteadd` at `1a38a044`, the tests only, source unchanged):
```sh
merge-case (lanegone): merge: G1 is not in .trash/ (./<Approved lane>/<G1>)
merge-case (deleteadd): merge E6: not restamped by the pass: modified: {at: 2026-01-01T00:00:00Z, by: {name: owner, kind: human}}
```
After the change, both exit 0.

**Evidence**
- `tests/merge-case.sh`: all 13 modes (merge, rebase, nodriver, clean, rebasemove, dirty, appside, delete, deleteadd, stamps, interrupt, reactions, lanegone) exit 0 on the committed head.
- `lanegone`, per phase: G1 and G2 are whole in `.trash/<card>`, every non-index base file byte for byte, the edit kept, `modified.at` later than every side's, one merge comment with the loss line, and the report line. G3 is in Ideas with the later body; its earlier body is in the merge comment and it is not restamped (the control). No folder is left for Approved, Active or Done. No lane uuid prefix appears in the report. The validator shows `index-less identity folders 0,`.
- Gate `tests/smoke.sh --only merge`: `smoke: 16 passed (sections: merge)`, exit 0.
- Gate `tests/smoke.sh --only static,headers,usage_guard,plugin,versions,cite_as,release_gate,braces`: `smoke: 47 passed (sections: static, braces, versions, headers, release_gate, cite_as, usage_guard, plugin)`, exit 0.

**Done differently**
- The loss line is the card's text, word for word. It does not name the lane's title.
- For a card with two locations, the report's lane-gone placement is its own sentence, not part of "Placed by the later stamp", because the later stamp did not decide it.
- The restore path also carries the loss line, so both paths say the same thing.

**Not checked**: the full `tests/smoke.sh`, beyond the two gate runs. The app's trash sort order was not opened in the app; it is inferred from `modified.at`. Raw logs stay in the fixer's scratch and are not attached (`post-comment.sh` has no attachment flag).

**Changelog draft**: A card edited in a lane someone else deleted now moves to the trash, on top and with a note saying why, instead of vanishing from the board.
