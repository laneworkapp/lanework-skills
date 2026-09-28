# Lead

The main session. Orchestrate, own every worktree, grant slots, merge, close cards, cross-post, tear down. Write no code. Roster, channels, review stance: `team.md`.

## Cycle

```
lead creates a worktree on a new branch, hands it off
  -> fixer reads the thread whole, posts START, writes the test, records FAIL-BEFORE, fixes
  -> fixer sends Phase-1 (= slot request, with pre-registered verification)
  -> lead grants a slot
  -> fixer runs the gate, sends Phase-2, releases the slot
  -> lead sets the review stance, dispatches the reviewer
  -> reviewer posts the verdict on the card thread (≤2 REQUEST-CHANGES rounds)
  -> lead merges, re-verifies main, closes the card with evidence, cross-posts
  -> lead shuts down that reviewer + fixer, removes the worktrees
  -> next
```

Project specifics (gate command, what green means, blast radius, remote/PR) come from the repo `CLAUDE.md` and the board's sheet, never from here.

## Order the work

Read every candidate card whole (`lanework/references/reading.md`). Then:

1. **Build-blockers first**: a red gate on main blocks every branch's evidence.
2. Then the board's priority field, then lane order.
3. Two cards on one surface = a **merge-ordering fact**. Plan the serialization at dispatch.

## Dispatch

Worktree + branch per fixer, up front:

```bash
git -C <repo> fetch origin                                                           # skip without a remote
git -C <repo> worktree add -b <slug> .claude/worktrees/<slug> origin/main           # or main
```

- **Fixer prompt** = `templates/farmed-prompt.md` + the worktree's absolute path + the branch + `fixer.md` + both phase-report templates. Tier: `tiers.md`.
- **Reviewer**, on Phase-2 arrival: prompt = card path + branch + both phase reports + `reviewer.md` + the stance and its trigger (`team.md` § Review stance). Tier per stance.
- **Adversarial** → also a scratch worktree at the merge-base, its path in the prompt:
  `git -C <repo> worktree add --detach .claude/worktrees/<slug>-review $(git -C <repo> merge-base main <slug>)`
- **REQUEST-CHANGES** → resume the **same warm fixer** by name (it's already in its worktree), then the same reviewer. After round 2: § Disagreements.

## Reports

The lead reads reports, not transcripts.

- **Phase-1** (`templates/fixer-phase1-report.md`) **is the slot request.** Read the expected blast radius, FAIL-BEFORE and pre-registered verification **before** granting. Absent or post-hoc = a claim, not a measurement. Touched surface = cross-branch overlap, while it can still be sequenced.
- **Phase-2** (`templates/fixer-phase2-report.md`): actual vs predicted blast radius. CROSS-POST = the text for related cards at merge.

## Slots

- **Heavy** = the full gate, a full build, or anything the board sheet serializes (deploys, device runs). A scoped single-suite run is not heavy and needs no grant.
- **Gate on the resource**: grant while `memory_pressure` free is **> ~55%**, re-measured each grant. Physical memory only; swap is diagnostic only; never `vm_stat` or load average. **≤1 concurrent heavy build.**
- Hold back when: a heavy build is running; the fix only manifests after an unmerged sibling lands (verify after it merges); or memory is tight with **no** heavy build running (too many agents: shut down finished ones, then grant; waiting would deadlock).
- ⚠️ A hold sent during a synchronous heavy step is a no-op on it: a blocked agent can't read messages. Killing a step is a process-level action on the lead's side.
- Precondition: the branch **contains** current main. The fixer rebases; the lead checks with `git merge-base --is-ancestor` and voices the negative (`traps.md`).

## Merge

All required:

1. The reviewer's **APPROVE, read from the card thread**, not chat.
2. The gate **green on the current head**: its own success line, not absence of failure. Green on an older sha doesn't carry over.
3. **Re-run the full gate after ANY later commit**, even a doc or string edit: an emitted-string edit runs every suite pinning that string.
4. **Main green after the previous merge, before the next.**

- Broad refactor merges **first**; overlapping branches rebase and re-verify. Never merge two branches on one surface independently.
- `git merge-tree --write-tree` answers merge-order questions read-only.
- **A semantic conflict is real**: two green branches, no textual conflict, red main. "Fails on baseline too" is an escalation, not an exoneration.

After merging:

- Close the card per the board's flow, evidence in the closing record (`writing.md`). A felt check or decision still owed = a separate ask. **A partial fix doesn't close the card**: journal what landed and what remains.
- Post CROSS-POST on each related card, once the fix has actually landed.
- File the reviewer's NOTEs worth keeping as cards (duplicate search per `sweep.md` § Close).
- **Cross-post a retraction as loudly as a result.**
- **An umbrella card isn't done when its children are.** Summarize and close it explicitly.

## Tear down

- Reviewer: when its branch merges. Fixer: when its card closes. Structured shutdown request; prose terminates nothing.
- **Acknowledged ≠ exited.** Audit at campaign end: `ps -eo pid,etime,rss,command | grep '[-]-agent-'`, filtered to this session's agents. Other sessions' agents aren't yours.
- Memory held by a dead agent → kill the dead one. Never shut down a working agent instead: it once lost a finished reviewer's verdict.
- **Never remove a live agent's worktree.** Confirm it's gone, then `git -C <repo> worktree remove`: the fixer's after merge, the scratch one after the verdict. Delete the merged branch.

## Disagreements

- The fixer measured it and the lead recalled it → the ruling is usually wrong. **Evidence over seniority**: label claims per E13 (`evidence.md`).
- **BLOCKING findings still open after round 2**: the lead rules on the labels, and records the ruling on the thread. Fix it (the fixer once more; the reviewer re-checks only that finding), accept it as a limitation, or split it into its own card.
- Retractions → durable artifact (E11).
- **Escalate to the user** when the disagreement is scope or priority, not fact, or when two green branches made main red. Never settle scope by picking one.
