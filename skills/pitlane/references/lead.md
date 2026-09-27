# Lead

The main session. Orchestrate, own every worktree, grant slots, merge, close cards, cross-post, tear down. Write no code.

## Cycle

```
lead creates + hands off a coding worktree
  -> fixer reads the thread whole, posts START, codes (fix + one test)
  -> fixer sends Phase-1 (= slot request, with pre-registered verification)
  -> lead grants a slot
  -> fixer runs the gate, sends Phase-2, releases the slot
  -> reviewer reviews the branch, posts the verdict on the card thread
  -> lead merges, re-verifies main, closes the card with evidence, cross-posts
  -> lead shuts down that reviewer + fixer, removes the worktree
  -> next
```

Project specifics (gate command, what green means, blast radius, remote/PR) come from the repo `CLAUDE.md` and the board's sheet, never from here.

## Roles

| role | count | writes code | heavy builds | runs `git worktree` | stamps `by.name` |
|---|---|---|---|---|---|
| **lead** | 1, the main session | no | no | **yes, creates and removes all** | `claude` |
| **fixer** | 1 per card | yes | in a granted slot | no | `fixer` |
| **reviewer** | 1 per branch | no | no | no | `reviewer` |

## Order the work

Read every candidate card whole (`lanework-boards/references/reading.md`). Then:

1. **Build-blockers first**: a red gate on main blocks every branch's evidence.
2. Then the board's priority field, then lane order.
3. Two cards on one surface = a **merge-ordering fact**. Plan the serialization at dispatch.

## Dispatch

Worktree per fixer, up front:

```bash
git -C <repo> fetch origin                                                  # skip without a remote
git -C <repo> worktree add --detach .claude/worktrees/<slug> origin/main   # or main
```

- **Fixer prompt** = `templates/farmed-prompt.md` + the worktree's absolute path + `fixer.md` + both phase-report templates. Tier: `tiers.md`.
- **REQUEST-CHANGES** → resume the **same warm fixer** by name. It's already in its worktree.
- **Reviewer** on Phase-2 arrival: one per branch, read-only, no worktree, no slot. Hand it the card path + branch name + `reviewer.md`.

## Reports

The lead reads reports, not transcripts.

- **Phase-1** (`templates/fixer-phase1-report.md`) **is the slot request.** Read the expected blast radius and pre-registered verification **before** granting. Absent or post-hoc = a claim, not a measurement. Touched surface = cross-branch overlap, while it can still be sequenced.
- **Phase-2** (`templates/fixer-phase2-report.md`): actual vs predicted blast radius. CROSS-POST = the text for related cards at merge.

## Slots

- **Heavy** = the full gate, a full build, or anything the board sheet serializes (deploys, device runs). A scoped single-suite run is not heavy and needs no grant.
- **Gate on the resource**: grant while `memory_pressure` free is **> ~55%**, re-measured each grant. Physical memory only; swap is diagnostic only; never `vm_stat` or load average. **≤1 concurrent heavy build.**
- Hold back when: a heavy build is running; the fix only manifests after an unmerged sibling lands (verify after it merges); or memory is tight with **no** heavy build running (too many agents: shut down finished ones, then grant; waiting would deadlock).
- ⚠️ A hold sent during a synchronous heavy step is a no-op on it: a blocked agent can't read messages. Killing a step is a process-level action on the lead's side.
- Precondition: the branch **contains** current main.

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
- **Cross-post a retraction as loudly as a result.**
- **An umbrella card isn't done when its children are.** Summarize and close it explicitly.

## Tear down

- Reviewer: when its branch merges. Fixer: when its card closes. Structured shutdown request; prose terminates nothing.
- **Acknowledged ≠ exited.** Audit at campaign end: `ps -eo pid,etime,rss,command | grep '[-]-agent-'`, filtered to this session's agents. Other sessions' agents aren't yours.
- Never shed a working agent to reclaim memory a dead one holds (cost a finished reviewer's verdict).
- **Never remove a live fixer's worktree.** Confirm it's gone, then `git -C <repo> worktree remove`.

## Disagreements

- The fixer measured it and the lead recalled it → the ruling is usually wrong. **Evidence over seniority**: label claims per E13 (`evidence.md`).
- Retractions → durable artifact (E11).
- **Escalate to the user** when the disagreement is scope or priority, not fact, or when two green branches made main red. Never settle scope by picking one.
