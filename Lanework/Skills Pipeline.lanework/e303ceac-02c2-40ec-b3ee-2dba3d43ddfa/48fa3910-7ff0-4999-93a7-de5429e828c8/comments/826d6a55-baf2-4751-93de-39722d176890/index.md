---
schema: 1
kind: comment
created:  {at: 2026-10-10T12:08:15Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T12:08:15Z, by: {name: reviewer, kind: agent, model: opus}}
---
**REQUEST-CHANGES at 0989f82: `--skills` works on a real skills folder, but on the per-skill symlink install (`~/.claude/skills/<name>` → repo) watch-file edits are never reported. Board events are unchanged byte for byte.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (watch-boards.sh is the watch's only event source)
ROUND:   1

CARD:   Active/48fa3910-7ff0-4999-93a7-de5429e828c8 "watch: re-read the skills when a release lands mid-watch"
BRANCH: watch-reread at 0989f82

BLOCKING: 1
  skills/watch/scripts/watch-boards.sh:36 @ 0989f82 "SKILLS=${SKILLS:A}" (+ :55 "find watch -name '*.md'", :70 fswatch on "$SKILLS";
  arming.md:29 "the folder holding the `watch` skill, resolved through symlinks"): an unflagged second path. The repo CLAUDE.md
  says users symlink each folder into ~/.claude/skills/<name>, and this machine does that. arming.md read literally gives
  --skills ~/.claude/skills. :A resolves the root, not the skill folders under it. BSD find skips a symlinked start
  point, so every watch/*.md drops out of the fingerprint. FSEvents on the root never sees edits inside the targets.
  MEASURED on a scratch root of symlinks (watch, work, lanework → a real copy): an edit to watch/references/arming.md gives
  0 SKILLS CHANGED, even after a later board burst. An edit to work/SKILL.md is reported only on the next board burst.
  The same edit with a real root gives 1. Passing <skills>/watch (the other misreading) gets fingerprint e3b0c442…,
  the hash of empty input, and is accepted silently. Fix direction: resolve each skill folder in the script
  (${SKILLS}/{watch,work,lanework}(:A)), fingerprint and fswatch those resolved folders, refuse a root with no watch/SKILL.md,
  and add a smoke case on a root of per-skill symlinks. The current smoke copies a real folder (smoke.sh:357 "cp -R "$SK" "$S2""),
  so it passes with this bug.

NOTES: 4
  watch-boards.sh:34,38 @ 0989f82 "${2:?$USAGE}": zsh doesn't expand the word, so a missing argument prints the literal "1: $USAGE"
    (measured). bca7ced printed the usage text. Inline the string, as the old line did.
  arming.md:29 @ 0989f82 "a plugin install into its cache" (card claim, REASONED): ~/.claude/plugins/cache/<mkt>/<plugin>/<version>/
    is a new folder per version. A release lands beside the armed root, never inside it, so a plugin-install watch never
    gets SKILLS CHANGED for a release. The card names that as its title case. See UNRESOLVED.
  watch-boards.sh @ 0989f82 skills_check: two watchers sharing one state path. Only the first to burst gets SKILLS CHANGED
    (measured: A 0, B 1). A shared state path is already unsupported for the snapshot, so this is not new.
  README.md:35 @ 0989f82 "Measured with `wc -w` on 2026-10-09": watch rows re-measured 2026-10-10, date line not bumped
    (the fixer flagged it). smoke ok 38's name, "no behavior change", is backed only by a missing .skills file. The
    pre-existing cases carry the behaviour.

CHECKED:
  correctness vs done-when: real root (spaces in path): live rule edit 1, restart after edit 1, second restart 0, template
    / lanework finding.md / lanework SKILL.md 0. Rule file add, rename, remove each 1. Atomic save (temp + rename, both
    a non-.md temp and an events.tmp.md temp) 1. Rule file and board file in one burst: both lines. Symlinked root
    (link → real dir), edits through either path: 1 each. Stored value empty: stores silently. Garbage, stale or
    multi-line: 1 at start, then overwritten. Not a folder: exit 2.
  project conduct:          plain commit, explicit paths, macOS zsh/BSD tools, no guide stamp under skills/. No "assume Y".
  both paths:               no --skills: OWN RUN, old (bca7ced) vs new side by side on identical scratch boards, .draft
    rename comment post + card move between lanes + 25-file BULK, 2 rounds, cmp identical (6 lines each), no .skills
    file. --skills: per-skill symlink layout broken (BLOCKING), plugin layout unhandled (NOTE). Neither flagged by the fixer.
  fail-before:              OWN RUN agreed: branch tests/smoke.sh in the scratch at bca7ced → rc 1 after ok 38, "no skills
    fingerprint stored:" / "not a board: …/skills-copy". Branch skills + tests in the scratch: smoke 84 passed, rc 0, 2/2.
    check-sizes 48 rows, 0 wrong. Scratch restored to bca7ced.
  test adequacy:            beside the other watch-boards cases in the fswatch block. Bounded polling (100×0.1s, probe ×8
    retries), no fixed sleeps. Live and restart cases discriminate, as the fixer's mutations showed. No case covers the
    symlink install.
  blast radius:             5 files: the 4 the card's Touches names plus README Sizes. No churn.
  population:               no --skills: 6/6 lines identical over 2 rounds. --skills real-root cases: 16 run, all as
    expected. Symlink-root cases: 2 run, both wrong.
  adversarial only:         written before the reports: H1 a symlinked install's root doesn't resolve the skill folders
    (HELD). H2 a plugin release lands in a new folder (HELD, reasoned). H3 a non-root path is accepted silently (HELD,
    inside the BLOCKING). H4 the no-flag path drifts (REFUTED, byte-identical). H5 "arming pass" in item 8 re-launches
    Monitor and loops (REFUTED: arming.md defines the arming pass as the agent-lane sweep). H6 item 8 contradicts
    "Skip your own writes" (REFUTED: item 8 is a non-board event and skips 1-7, so a self-merged skill change re-reads, which
    is right). H7 a mid-save state emits twice (REFUTED, 1 per save).

UNRESOLVED: plugin installs. Is "a release lands mid-watch" in scope for them? If yes, the root must follow the newest
  cache version, or the watch re-reads from a path it can't see. If no, scope the card and arming.md to symlinked
  installs and say plugin installs re-read at re-arm only.
```
