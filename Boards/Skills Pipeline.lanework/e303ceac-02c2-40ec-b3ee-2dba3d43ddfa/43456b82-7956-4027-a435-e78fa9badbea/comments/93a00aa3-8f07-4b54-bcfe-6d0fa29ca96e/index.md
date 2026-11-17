---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:45:21Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T22:45:21Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review of `pointer-audit` at 264b6ca: REQUEST-CHANGES, one blocking finding in the new smoke check; the skill text itself is right against guide v82.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none": regex heuristic, guide sections cited by name)
ROUND:   1

CARD:   Active/43456b82 "Skills point at the board's own guide and schema for specifics, starting with priority and component"
BRANCH: pointer-audit at 264b6ca

BLOCKING: 1
  tests/smoke.sh:84 @ 264b6ca "\b(priority|component): *[^ `]|(priority|component)[^.]*root keys?": the guard misses its own target in this repo's house style (keys in code spans). OWN RUN of the regex against mutants: "Write `priority:` as a top-level key", "Priority and component live at the card root", "Set the root key `priority`" all pass step 19, so a reworded root-key prescription re-ships green. The card's Touches asks for "no skill file names `priority:` or `component:` as a key". Fix direction: drop the "[^ `]" value requirement and widen the root clause to either order and "top-level", e.g. '\b(priority|component):|(priority|component)[^.]*(root|top-level)|(root|top-level)[^.]*(priority|component)', still excluding "reserved" lines. Measured: zero hits on the 264b6ca skills tree, all three mutants caught.

NOTES: 4
  skills/lanework/references/writes.md:21-26 @ 264b6ca "Delete = `mv` to `<board>/.trash/`" / "Another lane = `mv` one card folder by name": Paths (delete) and Moving restate the guide's § Editing and deleting and § Moving and reordering with no § pointer, and the audit table (0d86322f) has no row for them. Only the file-level "The guide has the full rules" points. Not wrong vs v82; a § pointer per bullet would close done-when literally.
  skills/lanework/references/writes.md:9 @ 264b6ca "(guide § Frontmatter: quoting)": the dropped "Every scalar on one line; a title never carries a line break" is in the guide's § Frontmatter, so it's covered by the pointer, but "quoting" is not a heading there; the pointer works only by reading the whole section.
  skills/lanework/references/founding.md:19 @ 264b6ca "Founding needs only `schema: 1` on the board": the board template also writes `kind: board` and `id`, which the guide asks for by hand; "only" reads as a rule. Suggest "the script writes the board's required keys".
  tests/smoke.sh:84 @ 264b6ca "\b(priority|component): *[^ `]": false-positives on plain prose like "Priority: rank the cards first." No such line today; worth knowing before widening.

CHECKED:
  correctness vs done-when: every § cited (Frontmatter, Stamping your work, Creating a card, Mentions, Colors and icons) is a real v82 heading; .schema/card.json, board.json, lane.json exist. writes.md:10 now matches the guide's labels section ("priority and component are labels entries, never root keys", every entry stamps its kind, built-in kind `text`). Grep of skills/ for priority/component: only lead.md:27 (fixed), lead.md:93 (scope priority, not a key), writes.md:10 (reserved), board-kinds.md:26 (group by component, valid in v82). Templates: discovery question-card's Round label stamps its kind; no `default` kind, no scalar background anywhere.
  project conduct:          telegraphic, entries replaced not appended, one topic one file; authority.md stamp still v78 (step 20 ok); board writes not in the code commit.
  both paths:               n/a (wording only); the second "path" is the smoke guard, see BLOCKING.
  fail-before:              OWN RUN agreed: scratch at 3908fde + branch smoke.sh exits at step 19 citing writes.md:10. Branch skills+tests in scratch: steps 1-20 ok; the plugin-validate step is the known pre-existing red (4cd77231).
  test adequacy:            placed beside check-refs and the version check, named like them; too narrow (BLOCKING).
  blast radius:             Phase-2 matches Phase-1: six skill files + one smoke step; no scripts, plugin.json, README or authority.md churn.
  population:               audit table lists 9 converted rows; Moving/Paths rows missing from the denominator (NOTE 1).
  adversarial only:         hypotheses before reports: (1) a cited § missing in v82: did not hold; (2) the replacement wrong vs v82 (kind stamping, text kind, group by component): did not hold; (3) dropped rules lost (at+by together, one-line scalars, empty-lane 1024): covered by the guide via the pointers; (4) smoke guard passes a reworded fix: HELD; (5) leftover unpointed restatements: partly held (NOTE 1).

UNRESOLVED: none
```
