---
schema: 1
kind: comment
in-reply-to: febe07f7-e4ed-46ef-909f-8a86506ad16a
created:  {at: 2026-11-17T22:22:29Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T22:22:29Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The diff is the body's three edits and nothing else, the ruled sentence lands word for word, the heal replaces the v0.8.0 body and nothing else changes behavior, and each new check catches the mutation it guards; 2 notes.

- **Stance**: standard (three files, +10/-5: one template sentence, one table entry, smoke cases)
- **Round**: 1
- **Card**: [Active lane text still says a card is claimed with a comment](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/84bb7548-cb2d-4c8f-a052-3d1f6a170598)
- **Branch**: `active-lane-sentence` at `168bc45`

**Blocking**: none.

**Notes**

1. `tests/smoke.sh:1088 @ 168bc45` "--exclude-dir=__pycache__": the exclusion is honest. Smoke itself writes no bytecode: its in-process imports set `sys.dont_write_bytecode = True` or run `python3 -B`, and `lib.sh` runs `heal-board.py` with `-B`. The stray `.pyc` most likely came from the `python3 -m py_compile` the body's Verified list names, which writes `__pycache__` beside the script (reasoned). No `__pycache__` is tracked or left in the worktree. A source file carrying the phrase is still caught. For later cards, check syntax without leaving bytecode, e.g. `python3 -B -c 'import ast,sys; ast.parse(open(sys.argv[1]).read())'`.
2. This board's own Active lane, as the body expects: a heal dry run on a scratch copy proposes `lane Active: insert-actor customised` with the new sentence after "The build lane.", so the old "claiming it with a comment that names the session and the branch" text would stay beside it. The owner's hand edit is still the fix. Not this card's done-when.

**Checked**

- **Correctness vs done-when**: all four met, measured.
  - `pipeline-lanes.md:13 @ 168bc45`: "Work in progress." is kept, then the ruled sentence word for word. No `|` in the body, and every row splits into 7 fields.
  - A board founded under `mktemp -d` with the branch's `found-board.sh` has an Active body byte-equal to the template's and validates with `failures 0 over 0 of 9 documents`. The heal finds `0 changes` on it.
  - `OLD_BODIES["pipeline"]["Active"][1]` equals the Active body in `git show v0.8.0:skills/lanework/templates/pipeline-lanes.md` byte for byte. The earlier predecessor is kept at `[0]`. Parsed with `ast`, the branch table differs from the merge-base's at `pipeline/Active` only.
  - Fixture with the v0.8.0 body: the dry run prints `lane Active: replace-body` and `1 changes in 1 files`, and `--apply` gives the template body, restamped with `reviewer`/`test`. A second `--apply` prints `0 changes`, and the board validates. The earlier predecessor body also gets `replace-body`.
  - Positive control: the merge-base heal on the same fixture prints `0 changes`, because there the v0.8.0 body is the current one.
  - Design-loop, datapoint, discovery and plan boards founded from the branch give the same heal output from the branch and from main. Plan matches no lane set, as before.
  - The comment's "up to the v0.8.0 release (released history only)" is true at every tag: every lane body of the four tables at each tag is either the current one or in `OLD_BODIES`. Unreleased intermediate commits aren't covered, which is what the comment says.
- **Project conduct**: the board write (`6da75f9`) and the skill change (`168bc45`) are separate commits. Paths were staged explicitly. No `CHANGELOG.md`, `plugin.json` or `README.md` change, as the body says. `tests/check-sizes.sh` prints `57 rows, 0 wrong`. No "assume Y" shapes.
- **Both paths**: three kinds of founded board, each measured on a scratch copy. A body that matches word for word is replaced, a customised one gets the actor sentence inserted, and one already on the new body is left alone.
  - Elsewhere under `skills/`, grepping "claim" and "START" finds nothing that contradicts the sentence. `board-kinds.md:22` has no claim clause. `companions.md:5` says "The lease is the claim". `watch/scripts/arm-pass.sh:15` says "A START comment is no claim: only a lease is."
  - Plan's "claimed by a session" (`plan/templates/lanes.md`) is a different claim. The body leaves it to the plan card.
- **Fail-before**: FIXER RUN checked. Before the fix, the dry run printed `0 changes in 0 files` and the gate found 2 hits. That agrees with my merge-base control above.
  - OWN RUN, mutations: I ran the gate, the founded-board check and the heal cases on mutated copies of `skills/`, using the smoke lines as written. A clean copy passes all 5.
  - Template sentence put back: the gate fails, naming `pipeline-lanes.md`.
  - Option B wording (no lease clause): the founded-board check fails.
  - The new `OLD_BODIES` entry dropped: the dry run gives `lane Active: insert-actor`, so the `replace-body` case fails.
  - The phrase added to `watch/references/arming.md`: the gate fails, naming that file.
- **Test adequacy**: the heal cases were extended in place beside Approved, Tasks and Shaping. The new gate sits after the lane-to-actor table check, as the body places it. The founded-board check greps for the lease clause rather than comparing the whole body. That is enough here, because the `--apply` case already compares `Active` to `TPL Active` exactly.
- **Blast radius**: 3 files expected, 3 changed. `main` has moved only by the board commit `6da75f9` since the merge-base `f7fbe0b`, and `git merge-tree` merges the branch into main cleanly.
- **Population**: one full `tests/smoke.sh` in the fixer's worktree at `168bc45` printed `smoke: 241 passed` and exited 0. That matches the fixer's count. Cases 118, 122 and 124 are the new and changed ones. `git status --short` was clean afterwards, there was no `__pycache__`, and `pgrep -fl lease.sh` printed nothing.
