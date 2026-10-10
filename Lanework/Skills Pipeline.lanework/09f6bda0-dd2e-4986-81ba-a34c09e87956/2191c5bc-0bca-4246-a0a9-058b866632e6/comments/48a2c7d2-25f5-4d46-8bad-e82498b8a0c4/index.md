---
schema: 1
kind: comment
created:  {at: 2026-10-10T03:03:47Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T03:03:47Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review, round 1: REQUEST-CHANGES on `label-kinds` at 1e8a8e0. Two BLOCKING findings: `--labels` is silently dropped in two places. Everything else holds, including a heal run on 334 real boards with no change from main.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (found-board.sh writes board config; heal-board.py rewrites label stamps on users' boards, which is persisted data)
ROUND:   1

CARD:   Proposed/2191c5bc "lanework: a catalog of common label kinds for founding boards"
BRANCH: label-kinds at 1e8a8e0

BLOCKING: 2
  skills/lanework/scripts/found-board.sh:57 @ 1e8a8e0 "labels "$LABELS_YAML" label_entries "$LABEL_ENTRIES"": if the index template has neither
    slot (a custom index, or any template written before this branch), --labels does nothing and the script still exits 0.
    Repro: a template with 'config: {show-card-body: 3}' + --labels priority -> "founded", rc=0, config has no labels.
    The agent reports kinds that were never written. Same rule as an unknown kind: --labels given and neither
    {{labels}} nor {{label_entries}} in --index -> exit 2, nothing written.
  skills/discovery/scripts/found-discovery-board.sh:16 @ 1e8a8e0 "--labels round --var topic=... "$@"": a caller's own --labels comes
    later in "$@" and replaces round, because found-board.sh keeps the last --labels. Repro: found-discovery-board.sh <b> --model x
    --labels priority -> config.labels = priority, record, status, and no round. founding.md tells agents to offer kinds and pass
    --labels, and board-kinds.md lists round as discovery's default, so this path is reachable. At the merge-base round was
    hard-coded and could not be lost. The same gap: found-board.sh --index discovery/templates/board.md without --labels
    also founds without round. Fix: found-discovery-board.sh merges round into a caller's --labels (or rejects a caller's
    --labels). Optionally the discovery template could require a non-empty label_entries.

NOTES: 4
  tests/smoke.sh:507 @ 1e8a8e0 "for bad in "type,nonsense" "nonsense" "type,,size" """: duplicates ("type,type") exit 2 (checked by hand) but no smoke case covers it.
  skills/lanework/scripts/found-board.sh:57 @ 1e8a8e0 "${VARS[@]+"${VARS[@]}"}": the --var pairs come after labels/label_entries, so
    --var labels=", foo: 1" overwrites the slot and writes 'config: {show-card-body: 3, foo: 1}'. Reserved slot names are not guarded,
    the same as title/id before this branch.
  skills/lanework/scripts/heal-board.py:247 @ 1e8a8e0 "SUGGESTED = load_suggested()": a priority or component row that won't parse
    makes heal exit at import, --help included. The message is loud and names the row, and smoke 67 catches it in CI. Fine as is.
  skills/lanework/references/founding.md:17 @ 1e8a8e0 "Rows: `templates/label-kinds.md`": agents are pointed at the catalog, yet the README
    Sizes table treats it as script-only and leaves out its 249 words. Pick one.

CHECKED:
  correctness vs done-when: catalog has 8 kinds; the priority/component rows are verbatim substrings of the v83 guide's suggested text
    (whitespace-normalised). Discovery template takes round via {{label_entries}}. Any subset founds in the given order
    (8 kinds and size,priority both validate). Each lane set names defaults. heal reads the catalog, and the embedded copy equals
    it both as dicts and as key-ordered JSON. Unknown, empty, blank, trailing-comma, " size" (space), "Type" (case) and duplicate
    kinds all exit 2 with no board written. No value can produce 'labels: []' or a dangling comma: an empty list exits 2.
  project conduct:          plain commits, skills-only (no board writes mixed in); scripts are bash/BSD and Perl render (no
    gsub & hazard); no "assume Y" shapes. Telegraphic prose OK.
  both paths:               two unflagged gaps, the BLOCKING above (slotless index; discovery --labels override). Heal: the
    skill-tree copy reads the catalog; a lone copy falls back to the embedded one (smoke 68). The app's .schema/bin copy has no
    ../templates, so it takes the embedded path.
  fail-before:              OWN RUN agreed. At 3f68046 with the branch's tests/: case 24 fails first ('round ... single: true' missing).
    With that line reverted locally, case 61 (golden) passes and case 62 dies with 'found-board.sh: unknown argument: --labels',
    matching FIXER RUN. Base discovery founding diffs from the golden only in title/topic, so the goldens really are pre-change output.
  test adequacy:            cases 61-68 sit as one block before check-refs, the same style as their neighbours; goldens in tests/fixtures/.
    Smoke 73/73 green on the branch in the scratch worktree.
  blast radius:             15 files, matching the card's Touches plus discovery's 2 files (round, added by the owner) and fixtures.
    No unexplained churn.
  population:               heal dry run on rsync copies of all 334 *.lanework under ~/Indie (worktrees excluded, fixtures included),
    main vs branch vs lone branch copy, --ignore-board-copy: 334/334 identical output, 0 diffs. All 8 existing discovery/grill
    boards: stale-label 0. On a freshly founded discovery board with a filed Q1 ("Round 1" entry), heal dry run and --apply
    both made 0 repairs: single is never stamped.
  adversarial only:         hypotheses written first: render substitution hazards (no, Perl, safe); slotless template silently
    drops --labels (HELD, blocking); discovery passthrough loses round (HELD, blocking); --var collides with slot (HELD, note);
    duplicate/case/blank kinds (no, all exit 2); heal catalog vs embedded key order (no); stale-label on round (no);
    real-board heal regressions (no); guide verbatim mismatch (no); discovery golden not truly pre-change (no).

UNRESOLVED: none
```
