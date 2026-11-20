---
schema: 1
kind: comment
created:  {at: 2026-11-20T18:39:32Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**DONE, 2026-11-20: built, reviewed over two rounds, merged to `main` at `d96581d`. Smoke on main: 250 passed.**

- **What changed**: `work/references/writing.md` § When to ask has an **Owner action** bullet, and its Short form reads "A choice or an action only the human can make". `work/references/sweep.md` § 2 has the row **Owner action, no ask**. `README.md` word counts recounted. No script changed.
- **Review, round 1: changes requested.** As first worded, the rule also covered every card at a human gate, so a sweep would have posted an ask with `waiting` on each card awaiting review. Fixed with one clause: a gate lane's own step (the owner's review or move out) is not an owner action; it is surfaced as before.
- **Review, round 2: approved**, with two wording notes, both applied by the lead in `8dd2fd3`: the sweep row covers any lane but excludes the gate's own step, and the cite to `lanework/references/board-kinds.md` no longer names a heading that does not exist.
- **Done when**:
  - bullet and Short form present: met.
  - sweep row present, rule not restated elsewhere: met (reviewer grepped every `waiting` site under `skills/`).
  - the grep line: met in intent with `grep -n "Owner action"`, one hit per file (`writing.md:34`, `sweep.md:25`). The line as written in the body, lowercase, hits the "found later" cross-reference in `writing.md` instead of the definition.
  - smoke green, README recounted: met. `check-sizes: 57 rows, 0 wrong`; `check-refs: 242 references, 0 missing`.
- **Lint check from § Verified**: run by the reviewer on a throwaway board. A draft imperative ask with no options and the any-human handle on line 1 exits 0; three malformed drafts each exit 1.
- **Not verified**: no smoke case asserts this prose, as the body says. One smoke run during review aborted on a lease-timing case while five other smoke runs loaded the machine; the rerun and the run on main passed.
- **Known limit**: `lint-ask.sh` cannot see the miss itself (a record that says "stays with the owner" is a valid record). Only the sweep row catches it.
- **Bump**: patch; rides 0.9.0.
- **CHANGELOG sentence**: "Cards that wait on something only you can do, such as running a trial or cutting a release, now get a clear request to you and show as waiting, instead of sitting unmarked."
