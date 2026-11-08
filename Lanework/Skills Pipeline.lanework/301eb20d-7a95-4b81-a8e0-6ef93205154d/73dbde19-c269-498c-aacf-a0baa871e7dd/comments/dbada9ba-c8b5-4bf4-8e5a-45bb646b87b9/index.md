---
schema: 1
kind: comment
created:  {at: 2026-11-08T00:02:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-11-08T00:02:34Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
*Sample, not a real verdict: the screenshot's verdict from [65ff6238](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01), with every line kept and only the formatting changed. No fence, no hard line breaks, links instead of bare ids.*

**Verdict: APPROVE.** The diff meets the done-when. My own fail-before run agrees with the fixer's. I found no failure scenario, and there are 3 notes.

- **Stance**: adversarial, because the diff touches trash and delete paths and removes partial trees on disk.
- **Round**: 1
- **Card**: [Check a cut deleted mid-copy cannot paste a hollow card](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01)
- **Branch**: `card/65ff6238-staging-partial` at `89a78ecb4`. The card commit is `ad0da6cfe`. The merge of origin/main changes none of the card's 4 files: `git diff ad0da6cfe 89a78ecb4` on them is empty, and the diff from merge-base `8b759d7b4` is exactly those 4 files.

**Blocking**: none.

**Notes**

1. `ClipboardStore.swift:917 @ ad0da6c` "the sweep removes whole": true only for a copy the pasteboard no longer names. Suppose a crash mid-copy leaves `.partial-<id>` in the copy the pasteboard still names (the system pasteboard outlives the app). Then the launch sweep keeps that folder, partial included, until the next copy or a foreground return that finds another owner. That costs disk only. A paste still refuses, because the final path is absent, and the base already left the whole half-tree there in the same case. `theSweepReclaimsALeftoverPartial` (`PasteWriteTests.swift:1042`) plants the partial only in a copy that is no longer kept. A doc-comment wording fix at most.
2. The open question is now settled, by an experiment. `FileManager.copyItem` on a card whose folder is renamed into a sibling `.trash/` mid-copy (150 × 4 MB attachments, rename after 5/20/60/150 ms) throws NSCocoaErrorDomain 4 "The file 'f56.bin' doesn't exist." It leaves `index.md` plus a partial `attachments/` (46/150 and 140/150 files) at the destination. The 60 ms and 150 ms runs finished before the rename and were whole. So the base really pasted hollow. The injected copier (`PasteWriteTests.swift:987` "copyThatDiesAfterIndex") models the real failure faithfully, and the fix's reliance on the copy throwing holds. The CHANGELOG line's "instead of arriving without its attachments" is accurate. Script: `scratchpad/65ff6238-reviewer/exp/copyrace.swift` (reviewer session).
3. Lane copies use the same `stage()` loop, and only a card is pinned. It is one code path, so this is not a gap.

**Checked**

- **Correctness vs done-when**: the final path exists only after `copyFolder` and the strip both ran and `moveItem` (a same-directory rename) succeeded. Any throw removes the partial (`ClipboardStore.swift:927-936`). The preflight is unchanged, so the paste refuses with "Couldn't paste 'First' — the copied content is gone" and writes nothing. Matches the Shape's fail-before example.
- **Project conduct**: no repo CLAUDE.md. The global bars: CHANGELOG is one end-user sentence under November 2026 (app-changelog form), and README key features don't apply (not a feature). The seam is a defaulted init parameter that no app caller passes, as the Shape decided. No "assume Y" shapes.
- **Both paths**: card and lane copies share `stage()`. The armed-cut move path doesn't stage, so it is out of scope. With N jobs where one fails, the others land, and the preflight refuses the whole paste on the missing entry.
- **Fail-before**: own run, agreed. Scratch worktree at `5151535fd`, with the branch's `ClipboardTests.swift` and `PasteWriteTests.swift` checked out. On `ClipboardStore.swift`: the branch's `copyFolder` typealias, init parameter and stored property, with the base stage body calling `try? copyFolder(job.source, job.destination)` straight to the destination.
  - `StagingPartialTests`: 3 tests, 5 issues, all in `aFailedCopyRefusesThePaste` (lines 1008, 1012, 1017, 1018, 1019: the half tree is at the final path, the paste wrote a card, no banner).
  - `aSuccessfulCopyIsWholeWithNoPartial` and `theSweepReclaimsALeftoverPartial` passed.
  - Same as the fixer's [ab31b4b2](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01/ab31b4b2-ee4a-40ad-ae0f-c293b3280c3e). That tree is also the Shape's mutation, so the mutation is red too.
- **Test adequacy**: new suite `StagingPartialTests` in `PasteWriteTests.swift` beside the preflight's neighbours, using `makeClipboardHarness` and `makeDestination` like them. Pin 1 is red under the mutation. Pin 2 is red if the rename were dropped (the tree would stay under `.partial`). Pin 3 is a characterization pin, green on base by design, as stated.
- **Blast radius**: Phase-2 actual (`ClipboardStore.swift`, the `ClipboardTests.swift` harness passthrough, `PasteWriteTests.swift`, `CHANGELOG.md`) = the Shape's scope plus the CHANGELOG line. No churn.
- **Population**: gate ([fadfb119](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01/fadfb119-d7ea-4bdc-af1f-f9292a3aeda9)): 8306 tests in 1316 suites passed, 3 known issues, on head `89a78ecb4`, the current head. Own run: 3 of 3 tests ran.

**Hypotheses**, written before reading [1167b2ee](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01/1167b2ee-9d01-4a31-9735-08fe8e8f6a50), [ab31b4b2](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01/ab31b4b2-ee4a-40ad-ae0f-c293b3280c3e) and [fadfb119](lanework://6c887de3-eb25-4b83-8750-31f1b8743f05/65ff6238-1b4b-4586-ad3d-09a1fbbc8a01/fadfb119-d7ea-4bdc-af1f-f9292a3aeda9). None of them held as a defect.

1. A pre-existing destination at `moveItem`: cannot occur (a fresh UUID copy dir per write, and subjects are a set). If it did, `moveItem` throws and the partial is removed, so the paste refuses. Fail-safe.
2. A `.partial` name collision: per job inside a fresh copy dir. A clash makes `copyItem` throw, which is fail-safe.
3. The sweep, `stagedCopyIDs` and dot names: prune lists the root skipping hidden names and claims whole copy folders, so the partial goes with its folder. `stagedCopyIDs` filters dot names at the root only, which is where it is used. The kept-copy case is note 1.
4. `stripCommentTrash` depends on the folder name: refuted. It walks `[folder] + identityDescendants` and takes the root regardless of its name.
5. Cancellation or quit: the chain is never cancelled, and a quit is the crash case. Final path absent, so the paste refuses.
6. `hasUnsettledStaging`: `stagedGeneration` still bumps once per `stage()`. Unchanged.
7. The pin passes with a wrong fix: refuted by the mutation run above.
8. `copyItem` completes silently without throwing: refuted experimentally (note 2).
9. The lane path is untested: same code (note 3).
10. The CHANGELOG claims a prior behaviour that wasn't established: established by note 2, so the line is accurate.

**Unresolved**: none.
