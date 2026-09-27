# Build team

Who's on a coding campaign, how they talk, and how hard the reviewer pushes. When to field one: `sweep.md` § Farm. Each role's procedure: `lead.md`, `fixer.md`, `reviewer.md`.

## Roster

| role | count | spawned by | lives until | writes code | heavy builds | worktree | stamps `by.name` | tier |
|---|---|---|---|---|---|---|---|---|
| **lead** | 1, the main session | the user | campaign end | no | no | **creates and removes all** | `claude` | the session's |
| **fixer** | 1 per card | lead, at dispatch | its card closes | yes | in a granted slot | works in its own | `fixer` | `tiers.md`, sonnet default |
| **reviewer** | 1 per branch, kept across rounds | lead, on Phase-2 | its branch merges | no | no | none; adversarial: a scratch one at the merge-base | `reviewer` | § Review stance |
| **proposal reviewer** | not defined yet | | | | | | | |

Only the lead runs `git worktree`, grants slots, merges, moves cards and mentions the human.

## Channels

| what | where | why |
|---|---|---|
| Phase-1, Phase-2, slot grant / hold, shutdown | SendMessage, fixer ↔ lead | coordination; dies at teardown |
| START, decisions, FAIL-BEFORE run, gate evidence, verdict | card thread, as records | durable: the next agent resumes from it |
| a question only the owner can settle | → lead → an ask (`writing.md`) | one voice rings the bell |

## Review stance

Set by the lead at reviewer dispatch, automatically. **Adversarial** when any holds, else **standard**:

- the fixer ran at opus
- Phase-1 UNCERTAINTY isn't "none"
- Phase-2 blast radius differs from Phase-1's expected
- the diff touches concurrency, a migration or persisted data, deletion, or auth / security
- the card body or board sheet asks for it

The reviewer prompt names the stance and the trigger that set it.

| | standard | adversarial |
|---|---|---|
| posture | confirm the diff meets done-when | try to break it |
| read order | reports, then diff | card + diff first, own failure hypotheses written down, **then** the reports |
| fail-before | check the fixer's FAIL-BEFORE run | that, **plus** its own run in the scratch worktree. The two disagree → BLOCKING |
| also | | attack the verification: would it pass if the fix were wrong (E2)? The defect class inside the fix (E12)? |
| tier | ≥ the fixer's | one above the fixer's, capped at opus |

## Bounding review

- **BLOCKING needs a failure scenario**: a concrete input or state → wrong output, crash or lost data. Or a checklist failure: done-when unmet, an unflagged second path, no fail-before evidence. Everything else is a **NOTE**.
- NOTEs never block. The lead files the ones worth keeping as cards at merge.
- **Re-review is scoped**: the open BLOCKING findings, plus the diff since the last reviewed sha. Anything new on unchanged code = a NOTE.
- **Two REQUEST-CHANGES rounds, then the lead rules** (`lead.md` § Disagreements). No third round.
