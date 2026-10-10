---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:34:13Z, by: {name: reviewer, kind: agent, model: opus}}
in-reply-to: 826d6a55-baf2-4751-93de-39722d176890
modified: {at: 2026-10-10T12:34:13Z, by: {name: reviewer, kind: agent, model: opus}}
---
**APPROVE at 0153b71: the per-skill symlink finding is fixed, the root is checked before use, and board events without `--skills` are still byte-identical to bca7ced.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (watch-boards.sh is the watch's only event source)
ROUND:   2

CARD:   Active/48fa3910-7ff0-4999-93a7-de5429e828c8 "watch: re-read the skills when a release lands mid-watch"
BRANCH: watch-reread at 0153b71 (rebased; 751069c = reviewed 0989f82, range-diff differs only in the README Sizes hunk)

BLOCKING: 0
  round-1 per-skill symlink finding: CLOSED. watch-boards.sh:59 @ 0153b71 "SKDIRS+=(${d:A})" + :83
  fswatch "${SKDIRS[@]}" + skills_fp cd into each skill. MEASURED on a root of per-skill symlinks (watch and work into one
  copy, lanework into another place, spaces in every path), each edit through the real path, no board burst:
  watch/references/arming.md 1, work/SKILL.md 1, lanework/references/authority.md 1. An edit through the link path also
  gives 1. A template or lanework finding.md gives 0. Was 0 / burst-only / 0 at 0989f82.

NOTES: 3
  watch-boards.sh:59 @ 0153b71 "for n in watch work lanework; do d=$SKILLS/$n": the skill folders are resolved once, at start.
    A skill symlink re-pointed mid-watch (rm + ln -s to a new target that has an edit) gave 0 SKILLS CHANGED live
    (measured). The old target is still the one watched, and the root isn't. Reported on the next board burst, or at
    re-arm. Re-linking is rare. Fixing it means adding the root back to fswatch.
  watch-boards.sh:40 @ 0153b71 "STATE=${1:-}; [[ -n $STATE ]] || { echo \"$USAGE\" >&2; exit 2 }": with no arguments, the exit is now 2
    (it was 1 at bca7ced). It matches the other refusals, and nothing reads that rc.
  watch-boards.sh @ 0153b71 skills_check: unchanged code. Two watchers sharing one state path still split one
    SKILLS CHANGED between them (round 1 NOTE). A shared state path is already unsupported.

CHECKED:
  correctness vs done-when: per-skill symlink root as above. Real root: a rule file and a board file in one burst give
    both lines. Atomic save (events.tmp.md + rename) 1. Rule file added, renamed, removed: 1 each. watch/scripts/notes.md 1
    (watch/** by design). Symlinked root (link to a real dir), edit via the link: 1. Stored value empty: stored silently.
    Garbage or stale: 1 at start. Refused with rc 2 and no state file: <root>/watch, a missing path, a file, a parent
    folder. --skills with no value: rc 2, prints the usage text. A root with only watch/: accepted, fingerprints it.
  project conduct:          plain commit message, explicit paths, zsh/BSD only. arming.md narrowed per the lead ruling.
  both paths:               no --skills: OWN RUN, bca7ced vs 0153b71 side by side on identical scratch boards, .draft
    rename comment post + card move between lanes + 25-file BULK, 2 rounds, cmp identical (6 event lines each), no
    .skills file. --skills: real root, symlinked root, per-skill symlinks. Plugin installs: out of scope per the lead
    ruling, and arming.md:29 says so.
  fail-before:              OWN RUN (round 1) holds for 41-43. 44-46 are covered by the fixer's mutations, and my 0989f82 repro
    of the same layout gave 0.
  test adequacy:            ok 44-46 sit beside 41-43 in the fswatch block. 44 waits for the live line before any probe,
    so it fails if fswatch watches only the root. 46 is a bounded 50×0.1s liveness wait, then rc + no state file + usage
    text. No fixed sleeps.
  blast radius:             751069c..0153b71 touches watch-boards.sh, arming.md, smoke.sh and README Sizes, as the fixer
    reported. README watch rows 1,369 / arming 400; check-sizes 48 rows, 0 wrong.
  population:               gate OWN RUN at 0153b71 in the scratch: smoke 92 passed rc 0, 2 of 2 runs. Hostile --skills
    cases 15 live + 3 state + 6 arg, all as expected except the re-point NOTE.
  adversarial only:         round 2: the new arg parsing breaks the no-flag path (REFUTED, byte-identical). Resolving at
    start misses a link re-pointed mid-watch (HELD, NOTE). Per-skill cd breaks path prefixes (REFUTED: watch-only,
    work-only and lanework-only edits each change the fingerprint).

UNRESOLVED: none (plugin scope is with the owner as an ask)
```
