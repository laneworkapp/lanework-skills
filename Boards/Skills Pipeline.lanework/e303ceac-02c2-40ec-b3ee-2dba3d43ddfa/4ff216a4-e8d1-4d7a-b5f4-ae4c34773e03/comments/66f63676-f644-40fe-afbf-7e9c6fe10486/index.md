---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:02:44Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-10T02:02:44Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review, round 1: APPROVE. No blocking findings, five notes. Own fail-before agrees with the fixer's, and seven mutations show which checks would catch a wrong fix.**

```
VERDICT: APPROVE
STANCE:  ADVERSARIAL (diff changes four scripts that write board files, plus lib.sh that every script sources)
ROUND:   1

CARD:   Active/4ff216a4 "Discovery and founding scripts: escape titles, and stamp a real model"
BRANCH: script-stamps at 8628fa7 (read off the branch; merge-base 3fcec39)

BLOCKING: 0
  none

NOTES: 5
  lib.sh:16 @ 8628fa7 "MODEL=\"${MODEL:-${CLAUDE_MODEL:-}}\"": the CLAUDE_MODEL fallback has no smoke case. Replacing the line with ':' still gives "smoke: 45 passed". Checked by hand: CLAUDE_MODEL=envmodel stamps model: envmodel, and --model flag wins over it. Add one env-only call to the model case.
  found-board.sh:39,49 @ 8628fa7 "\"$(title_str \"$TITLE\")\"": the board and lane title path has no hostile-title case. Reverting both lines to yaml_str still passes smoke (the only difference is LF handling). Checked by hand: 15 hostile board titles render and validate (list under CHECKED).
  found-board.sh:12 @ 8628fa7 "[--model m] [--name n]}": the ${1:?} usage string still shows --model as optional, while line 27 says it is required. The smoke ok-line also says "four scripts" but runs five.
  lib.sh:8 @ 8628fa7 "yaml_str() {": nothing under skills/ calls it any more. Remove it, or keep it as the helper for non-title strings and say so in a comment.
  templates/board.md:11, pipeline-index.md:11, index.md:11 "# {{title}}": the body heading gets the raw title, so an LF in a board title splits the heading over two lines. This is body text only and the board still validates.

CHECKED:
  correctness vs done-when: grep -rn 'CLAUDE_MODEL:-unknown\|model: unknown' over skills/ at 8628fa7 finds nothing. Every title any script writes goes through title_str: file-question:76, file-record:43, found-board:39,49 (grep of yaml_str|title_str; templates render title only through those values). Both new smoke cases pass.
  project conduct: macOS bash/BSD tools only. Tests use throwaway boards under TMPDIR. Diff covers skills/ and tests/ only, no board writes. No "assume Y" shapes.
  both paths: flag vs env vs neither, all handled in require_model (measured, env path by hand). found-discovery-board passes "$@" through to found-board, so it is refused by found-board before any mkdir. Measured: no board folder exists after the refusal, and --model "" exits 1 on ${2:?}.
  fail-before: OWN RUN agreed. Scratch at 3fcec39 with the branch's tests/smoke.sh and merge-case.sh: 'question title not escaped: title: "Q5: C:\path \"x\"'. With that assertion bypassed in a copy: 'file-question: want exit 2 with usage, got 0'. The fixer ran at ffea864, an ancestor of 3fcec39 with no skills/ or tests/ changes between them, so same result.
  test adequacy: both cases sit beside the discovery cases and are shaped like their neighbours (ok lines, validate, sum checksum). Mutations, each on an archive copy of 8628fa7 under TMPDIR, run with CLAUDE_MODEL unset:
    require_model in found-board moved after mkdir -> rc=1 "a refused call wrote something"
    settle-question check removed -> rc=1 "want exit 2 with usage, got 0"
    file-record check removed -> rc=1, same
    title_str LF handling removed -> rc=1 (existing file-record title case)
    file-question check moved after its staging mkdir -> rc=0 (harmless: the staging dir is outside the board and removed by the trap)
    CLAUDE_MODEL fallback removed -> rc=0 (note 1)
    found-board back to yaml_str -> rc=0 (note 2)
  blast radius: Phase-1 named 11 files and the diff touches exactly those 11 (70+/36-). No churn outside them.
  population: head smoke "smoke: 45 passed", rc=0, under /bin/bash 3.2.57 with CLAUDE_MODEL unset. Hostile titles: 16 inputs, each through found-discovery-board (board title), file-question and file-record. Inputs: backslash+quote, trailing backslash, lone backslash, lone quote, CR+LF, {{n}} {{title}} {{stamp}}, leading #, leading [, {a: b}, & $HOME backtick $(id), apostrophe, leading "- ", leading ": ", literal \n, tab, and empty. The first 15 validate with failures 0, and a PyYAML 6.0.3 safe_load round-trip of every title matched (CR/LF -> space). Empty is refused by ${2:?} with exit 1. Lane titles come from the shipped templates and go through the same helper.
  adversarial only: hypotheses written before reading the reports.
    H1 render mangles \ or & in values: refuted (perl s///ge, values used as literals)
    H2 {{x}} in a title is re-substituted: refuted (single pass, measured)
    H3 found-discovery-board writes before the check: refuted (exec only, measured)
    H4 a caller omits --model: refuted (git grep over skills, tests, README, references, templates: every invocation passes it, and prose mentions defer to the SKILL.md tables)
    H5 bash 3.2 $'\n' inside ${//} misbehaves: refuted (/bin/bash 3.2.57 run)
    H6 the refused case passes for the wrong reason: refuted (other args valid, each mutation caught)
    H7 a template puts raw {{title}} in frontmatter: refuted (frontmatter only uses title_yaml or the title_str value; held only for the body heading, note 5)

UNRESOLVED: none
```
