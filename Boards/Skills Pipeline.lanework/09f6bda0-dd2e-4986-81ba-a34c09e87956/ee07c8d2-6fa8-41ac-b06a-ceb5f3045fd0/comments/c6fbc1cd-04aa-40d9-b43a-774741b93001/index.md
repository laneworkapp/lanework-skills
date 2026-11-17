---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:25:47Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: an unclaimed agent-lane card with an unanswered owner comment is no longer taken as a work order at arming, which the merge-base watch did. Four notes.

- **Stance**: adversarial. Trigger: the branch removes a shipped skill, moves a script between skills and deletes 14 smoke cases.
- **Round**: 1
- **Card**: [ee07c8d2](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ee07c8d2-6fa8-41ac-b06a-ceb5f3045fd0)
- **Branch**: `retire-dispatch` at `16966142320c698b831b0cbc4d5e24692962bfee`

**Blocking**

1. `skills/watch/references/arming.md:25 @ 1696614` "Else answer it as a new owner comment (`responding.md`)", with `skills/watch/scripts/arm-pass.sh:13 @ 1696614` "Wins over arm on the same card.": the owner approves a card and leaves a note on it ("Please also cover Y.") while no watch runs. At arming the script prints only `comment` for that card, never `arm`. The new table answers the comment and stops, so the card in Approved (or Active) is never taken as a work order. The merge-base watch's model-read pass took every unclaimed agent-lane card as a work order. Dispatch carried the "answer, then arm" rule in `handler.md` (the `move`, `arm` row), deleted here. Measured on a fixture: Approved top card, unclaimed, one owner comment with no reply. Both the old and the moved script print `comment` only. Fix: in the `comment` row, after answering, go on as `arm` when the card sits unclaimed in an agent lane (Approved: its top card), because the script prints `comment` in place of `arm`. A grep case in smoke beside the new watch case would pin it.

**Questions for the lead**

1. The fix adds one clause to the `comment` row beyond the body's item 2. Is that within this card, or does it need a ruling on the card first?

**Notes**

1. `skills/watch/references/arming.md:21 @ 1696614` "passing the board's own agent lane titles when its bodies name lanes other than": titles on the command line replace the `board-kinds.md` rows (script header, smoke case "lane titles on the command line replace"). A reader could pass only the extra lanes and lose the defaults. Say "every agent lane title".
2. `skills/watch/references/arming.md:27 @ 1696614` "report only: lane, title, minutes quiet": no place says when the report goes out. `routing.md` step 5 put `stale` lines into § Tell the user, for the owner to free or leave. One clause in § Tell the user would keep that.
3. `CHANGELOG.md:3 @ 1696614` "the dispatch skill is retired. Use /lanework:watch instead": two sentences in one entry. The `app-changelog` format wants one, and entries 2 and 3 say bare `/watch`, not `/lanework:watch`. The text is the body's draft, verbatim, so this is the lead's call.
4. Release notes for 0.9.0 come from every CHANGELOG line added since `v0.8.0`, so they will also carry the guide v118 entries already under November. Expected, noted for whoever cuts the release.

**Checked**

- **Correctness vs done-when**:
  - `skills/dispatch/` gone, in git and on disk in the worktree. `plugin.json` names no `dispatch` (skills, keywords, description). Both manifests parse as JSON, and the smoke manifest case matches the skills list to the 7 folders.
  - Grep of the branch tree (`skills/`, `tests/`, `README.md`, `CLAUDE.md`, `.claude-plugin/`, `scripts/`, `.github/`) for `dispatch`, `classify-event`, `state.sh`, `handler`, `routing.md`: 11 hits. 7 are the plain verb or noun (`discovery/references/rounds.md`, `plan/references/sessions.md`, `watch/references/responding.md`, `work/references/companions.md`, `lead.md` twice, `team.md` twice), 4 are the smoke guard. `scripts/release.sh` and `.github/workflows/smoke.yml` name nothing removed.
  - `arm-pass.sh` output on this board, merge-base copy vs moved copy, read-only: 5 lines each, `diff` empty (minutes masked). On a fixture of 4 cards (Approved top with an owner note, Approved second, Active stale claim, Done question): identical, 2 lines each.
  - § Arming pass exists with the three line kinds: how to run (`<board>` plus agent lane titles), Done skipped, `stale` never released, the `in-reply-to` false alarm with read-the-card-first. The compaction bullet is in § Tell the user: authority chain re-read, in-flight work from the board and git, never the summary, path from `ls`.
- **Project conduct**: one commit, plain message, explicit paths, no board writes and no `.DS_Store`. `plugin.json` version stays 0.8.0, and `release.sh` greps `^Version 0.9.0: `, which `CHANGELOG.md:3` matches. Three places of a removed skill: folder, `plugin.json`, README table and `ln -s` lines (7 left). The compaction rule lives only in `arming.md`.
- **Both paths**: the line kinds overlap on one card, and that overlap is Blocking 1. Lost-rule read of the deleted `SKILL.md`, `handler.md`, `routing.md` and both templates against `skills/watch/`: apart from Blocking 1 and Note 2, what goes is handler machinery (self-write registry, relays, escalation, `--only` commits under parallel handlers).
- **Fail-before**: FIXER RUN checked, plus OWN RUN, agreeing.
  - The `check-sizes` case: merge-base `check-sizes.sh` passes both ghost copies (rc 0, 57 rows, 0 wrong). The branch copy fails each naming `ghost` (rc 1) and passes the clean copy. A leftover `dispatch` summary row also fails, naming it.
  - The watch case: fails on the merge-base `skills/`, passes on the branch. Two mutants also fail it: the branch with the compaction bullet removed, and with `## Arming pass` turned back into a bold paragraph.
- **Test adequacy**: the 14 removed cases are all on `state.sh`, `classify-event.sh`, `handler.md` and the dispatch fixture board. None guarded `lib.sh`, the validator or `arm-pass.sh`, which keeps its own fixture board and validate case. The arm-pass block now defines `AP`, `NOWS`, `OLD` and `AGENT` itself. Nothing later in `smoke.sh` reads the removed names (`DS` at line 1049 is assigned there). The new cases sit beside their neighbours: the names loop and the `check-sizes` gate.
- **Blast radius**: 15 files, matching the body's list plus `CHANGELOG.md` and `check-sizes.sh`, both named in the body. Moved script: `git diff -M` at 92% similarity, header lines only. Mode stays `100755`, and `../../lanework/scripts/lib.sh` resolves at the same depth. `bash -n` clean. `tests/check-refs.sh`: 216 references, 0 missing.
- **Population**: own full run of `tests/smoke.sh` in the worktree at `1696614`: `smoke: 152 passed`, 152 `ok` lines. The merge-base has 164 `ok` calls, minus 14 removed, plus 2 added, gives 152. README § Sizes `watch`: `wc -w` 180 + 583 + 400 + 373 = 1,536, matching the row.

**Hypotheses**, written before reading the fixer's records (`c27bb177`, `d4cf9339`). 1 of 7 held.

1. A removed smoke block defines names that later cases still use, so smoke dies under `set -u`. Refuted: `NOWS`, `OLD` and `AGENT` moved into the arm-pass block, and the full run is green.
2. A removed case also guarded behaviour that survives. Refuted: all 14 are on dispatch-only files.
3. A dangling cite to a deleted dispatch file survives. Refuted: `check-refs.sh` reports 0 missing, and the grep found only plain verbs and the guard.
4. A dispatch rule that a plain watch needs lives nowhere else after the delete. Held: `handler.md`'s "answer, then arm" (Blocking 1). The stale reporting step is Note 2.
5. The new `check-sizes` case passes for the wrong reason, because the old checker already failed a ghost row. Refuted: the old checker passes both ghosts.
6. The move changed code, the exec bit or the `lib.sh` path. Refuted: header only, `100755`, same depth.
7. The changelog's version line or `plugin.json` trips `release.sh`. Refuted: the grep matches, the version is not bumped, and the release step bumps it.
