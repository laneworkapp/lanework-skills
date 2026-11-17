---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:06:19Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** Blocking 1 is fixed: a record quoting `@anyone` in a code span or a URL now lints clean on a v117+ board, and a bare `@anyone` outside line 1 still fails. Two notes.

- **Stance**: adversarial, same trigger as round 1
- **Round**: 2
- **Card**: [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8)
- **Branch**: `guide-v118-anyone` at `d372ef5` (reviewed diff since `07143bc`: `9ebff9f`, `d372ef5`)

**Blocking**: none.

**Notes**

1. `skills/work/scripts/lint-ask.sh:21 @ d372ef5` "handle=$(printf": a board with no handle line, such as one holding only `AGENTS.md`, still uses this fallback. It takes the first `@token` from the raw body, so a record quoting `@anyone` in backticks is still refused there. 0.8.0 and `07143bc` behave the same. This is the same defect class as Blocking 1, on a rare board shape. A fix: run the line-20 strip here too, or read the handle from `AGENTS.md` in `owner_handle`.
2. `tests/smoke.sh:681 @ d372ef5` "We said @anyone should answer, then went on": this fixture is overwritten at line 683 before any use. Drop it.

**Checked**

- **Blocking 1, re-checked by its quoted text**: line 20 now runs line 28's code-span and URL strip before the `@anyone` test. Results on a scratch board carrying the real v118 guide:

  | input | `d372ef5` | `07143bc` |
  |---|---|---|
  | record quoting `@anyone` in a code span | passes | fails, "handle @anyone is not on the first line" |
  | record with `@anyone` in a link target and a bare URL | passes | fails |
  | record with a bare mid-sentence `@anyone` | fails | fails |
  | backticked `@anyone` plus a bare one | fails | fails |
  | clean `@anyone` ask with a code span and a `lanework://` link | passes | passes |
  | ask with `@anyone` late | fails | fails |

- **Lead-ruled notes**:
  - **Note 1 (smoke cuts)**: `sed -e '/^Provides:/,$d' -e '/^Plugin directory checks/,$d'` keeps both cuts.
  - **Note 3 (ask template)**: the skeleton line reads `[@anyone | @<handle>…]`.
  - **Note 4 (AGENTS.md fallback)**: `guide_version` reads `CLAUDE.md`, then `AGENTS.md`. Measured on the real v118 `AGENTS.md` alone: 118 and `anyone`. A non-guide `CLAUDE.md` beside the real `AGENTS.md` also gives 118. The `set -e` safety is unchanged.
- **Test adequacy**:
  - The new smoke case sits beside the v114 lint case and is worded like its neighbours.
  - Run against the `07143bc` lint, its `any-quoted.md` fails (rc 1).
  - In a mutant that strips the whole line before the `@anyone` test, `any-mid.md` passes (rc 0). So the case fails if the strip is missing or too broad.
  - The new `AGENTS.md` assertion fails without the fallback, because the old function read only `CLAUDE.md`.
- **Blast radius**: the only changes since `07143bc` are `lint-ask.sh`, `lib.sh`, `ask.md`, `smoke.sh` and the README sizes (work and `ask.md` +1 word each). Nothing outside the ruled items.
- **Smoke**: FIXER RUN, `smoke: 164 passed` at `d372ef5`: one case more than round 1, matching the one new `ok` line. Nothing in the diff gave me reason to re-run it. My own runs were the inputs and mutant above, on scratch boards.
