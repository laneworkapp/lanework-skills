---
schema: 1
title: "Spike: i'd like to test a few third party skills to have them found and output into lanework board"
order: 2048
created: {at: 2026-11-23T17:27:43Z}
modified: {at: 2026-11-23T17:35:07Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
kind: card
---
## Question

Run third-party skills unchanged in a repo that has a Lanework board. Does each one find the board on its own and land its output there as cards and comments instead of loose files? If not, what is the smallest change (to our skills, the in-board guide, or a wrapper) that makes it land? The owner has ruled the set: the installed `mattpocock-skills` 1.3.1.

## What the set does

27 skills are active in the manifest. 4 under `misc/` and 7 under `in-progress/` are not shipped, so they are out. The facts that shape the test:

- **Most output skills are user-invoked only** (`disable-model-invocation: true`): `to-spec`, `to-tickets`, `triage`, `wayfinder`, `grill-with-docs`, `grill-me`, `handoff`, `implement`, `implement-spec`, `retro`, `to-questionnaire`, `improve-codebase-architecture`, `setup-matt-pocock-skills`. "Unprompted trigger" is moot for them. The question is what they read once typed.
- **The tracker skills never look at the repo for a tracker.** They expect `/setup-matt-pocock-skills` to have run and say "tell the user to run it" otherwise. Setup writes `docs/agents/issue-tracker.md` and a `## Agent skills` block into the root `CLAUDE.md` (else `AGENTS.md`, else asks which to create). Its "Other" tracker answer takes a one-paragraph workflow description, recorded as prose. That is the natural wrapper: a board described as the tracker.
- **The skills do read the repo for `GLOSSARY.md`, `docs/adr/`, `docs/agents/`, `.scratch/`, `CODING_STANDARDS.md`.** Nothing in them looks for `*.lanework`, and a board's guide sits inside the `.lanework` folder, not at the root.
- Model-invoked: `research`, `domain-modeling`, `diagnosing-bugs`, `tdd`, `prototype`, `codebase-design`, `code-review`, `pr`, `wizard`, `grilling`, `writing-for-agents`.

## Candidates

| skill | outputs, and where | interactive | Lanework equivalent | finds the board unprompted? |
|---|---|---|---|---|
| `setup-matt-pocock-skills` (user) | `docs/agents/{issue-tracker,domain,triage-labels}.md` + `## Agent skills` block in root `CLAUDE.md`/`AGENTS.md` | yes: tracker, labels, layout, confirm draft | the bridge itself: a root pointer plus a tracker doc describing the board | No. Its explore step lists `.scratch/`, `docs/`, root files, not `*.lanework`. Offers GitHub, GitLab, local markdown, "Other" |
| `to-tickets` (user) | one file per ticket in `.scratch/<feature>/issues/NN-slug.md`, with `Blocked by:`, `Status: ready-for-agent`, acceptance checkboxes; or one tracker issue per ticket | yes: quizzes the breakdown | one card per ticket in Ideas (agents file there; Approved is the owner's move). Blockers become relations. Checkboxes stay in the body | No. Baseline stops: "run setup". After setup it follows `docs/agents/issue-tracker.md` |
| `to-spec` (user) | `.scratch/<feature>/spec.md`, or one tracker issue labelled `ready-for-agent` | one confirm (test seams) | one card in Shaping or Proposed, body = spec | No, same as `to-tickets` |
| `research` (model) | one Markdown file with cited claims, "where the repo keeps such notes, else somewhere sensible" | no. Runs a background agent | a card in Ideas or Shaping with the answer in the body, or an attachment on the asking card. Sources in the body | Maybe. "Match the existing convention" reads the repo for notes. Boards are not recognised as a notes place. Expect a loose `docs/research/*.md` |
| `grill-with-docs` = `grilling` + `domain-modeling` | chat rounds; `GLOSSARY.md` edited inline; `docs/adr/NNNN-*.md` | yes: rounds of numbered questions | discovery board: question cards, glossary card, ADR card in the Decisions lane (`discovery/references/records.md`) | No. It knows only `GLOSSARY.md` and `docs/adr/`. Closest overlap with our `discovery`, and the two will compete |
| `diagnosing-bugs` (model) | chat, a repro loop script, a regression test, redacted artifacts | light: shows ranked hypotheses, asks if stuck | a card in Issues; hypotheses and evidence as records; fix commit linked in a comment | No. It reads `GLOSSARY.md` and ADRs only. Output is chat plus code, so there is no file to redirect, which makes it the "nothing but chat" control |
| `triage` (user) | state machine over tracker issues: labels, disclaimer-prefixed comments, `.out-of-scope/*.md` | yes: grills if needed | lanes are the states (Ideas, Issues to Shaping to Approved); comments = records; `.out-of-scope` = a Rejected lane card | No. Needs a tracker. Reserve |
| `wayfinder` (user) | a map issue plus child "decision tickets"; locally `.scratch/<effort>/map.md` and `issues/NN-*.md` with `Status: claimed/resolved` | yes | map card plus child cards; `Blocked by` = relations; claim = our card lease (`lease.sh`) | No. Reserve. 2,075 words, heavy |
| `code-review` (model) | chat, two sub-agent reports; spec found under `docs/`, `specs/`, `.scratch/` | asks where the spec is | a comment on the card being reviewed. The spec is the card body | Maybe. It searches for a spec in three named folders, not boards. Reserve |
| `to-questionnaire` (user) | `to-questionnaire-<slug>.md` in cwd | yes: who, what back | an ask comment, or a card with the file attached | No. Reserve, cheap |
| `handoff`, `improve-codebase-architecture`, `teach`, `retro`, `pr`, `prototype`, `tdd`, `codebase-design`, `wizard`, `writing-for-agents`, `implement*`, `ask-matt`, `grill-me` | handoff and the architecture HTML go to `$TMPDIR`; `teach` writes a workspace of HTML and Markdown; `pr` is a PR body; the rest are code or chat; `implement*` read the tracker | mixed | none worth testing, or covered by a row above | not tested |

**Test first (5):** `setup-matt-pocock-skills`, `to-tickets`, `research`, `grill-with-docs`, `diagnosing-bugs`.

| why | covers |
|---|---|
| `setup` | the only skill that could make all the others land; tests the wrapper idea directly |
| `to-tickets` | many cards, blocking edges to relations, the Approved-lane gate clash |
| `research` | model-invoked, one file, "match the repo's convention" |
| `grill-with-docs` | glossary and ADR records, and the overlap with our `discovery` |
| `diagnosing-bugs` | the nothing-but-chat control: does a skill with no file output still land a comment? |

**Changed from the five named in the scoping ask** (`research`, `domain-modeling`, `grilling`, `diagnosing-bugs`, `prototype`): `prototype` is dropped because it outputs code and chat only. `domain-modeling` and `grilling` run together as `grill-with-docs`, the skill that wraps both. `setup-matt-pocock-skills` and `to-tickets` are added because they are the ones that file work items.

**Cost:** about 16 to 20 fresh Claude sessions on this machine, at the sonnet tier, on the owner's account. The scratch repo is deleted afterwards.

Reserves, in order: `triage`, `wayfinder`, `code-review`, `to-questionnaire`. Skipped: anything needing a GitHub PR or a UI, and the rest of the last row.

## Setup

| piece | how |
|---|---|
| Scratch repo | `mktemp -d` under `/tmp`, **not** under `~/Indie`. Parent folders' `CLAUDE.md` files load into every session, and the Lanework project map and the user's global rules would contaminate it. `git init`, no remote |
| Code sample | a small Python `invoice` package: line items, totals, a discount function with a rounding bug, one failing `pytest`, a README. It gives `diagnosing-bugs` a bug, `to-spec` and `to-tickets` a feature (discount codes), `research` a question (currency rounding in the stdlib docs), and `grill-with-docs` real vocabulary |
| Board | `skills/lanework/scripts/found-board.sh "<repo>/Boards/Invoice Pipeline.lanework" --index skills/lanework/templates/pipeline-index.md --lanes skills/lanework/templates/pipeline-lanes.md --var project=Invoice --var verified="pytest passes" --model <m>`, as `tests/merge-case.sh` does. Seed an Issues card and an Ideas card with `file-card.sh`. A second board, `Invoice Discovery.lanework`, from `found-discovery-board.sh`, for the `grill-with-docs` runs only |
| In-board guide | the app writes it on first open, so stand in: copy `CLAUDE.md`, `AGENTS.md`, `.schema/` and `.gitignore` from `Boards/Skills Pipeline.lanework` into each founded board. Record the guide line (`v120`) in the results |
| Plugins | `lanework` installed from the marketplace as a user has it, plus `mattpocock-skills` 1.3.1. Nothing is edited |
| Baseline commit | commit the repo once, then rebuild or `git reset --hard && git clean -fdx` before every run, so each run starts identical |

## Runs

**Step 0, before anything (an hour at most):**

| check | why it decides the method |
|---|---|
| Can a subagent call the `Skill` tool on a plugin skill? | If not, runs are `claude -p` headless sessions, not subagents |
| Does `claude -p "/mattpocock-skills:to-tickets"` run a `disable-model-invocation` skill? | Those skills only run when the user types them |
| In the scratch dir, which plugins and which `CLAUDE.md` files load? Expect user-global rules and both plugins, and nothing from the Lanework tree | Confirms isolation. Capture with `--output-format stream-json` |
| Does `--resume <session> -p "<answer>"` carry a multi-round skill? | Decides how interactive skills are driven |

**Conditions** (each run is a fresh session; one skill, one condition, one run):

| id | repo state | prompt |
|---|---|---|
| A baseline | board present, no mention of it anywhere | the skill's fixed prompt, no word about the board |
| B pointer | A plus one line in a root `CLAUDE.md`: "Work is tracked on the board at `Boards/Invoice Pipeline.lanework`; read its `CLAUDE.md` before writing there." | same prompt as A |
| C named | A, no root file | the same prompt plus "Track it on the Invoice Pipeline board" |

For `to-spec`, `to-tickets` and the like, A also covers whether setup was needed. `setup-matt-pocock-skills` itself gets A and C: in C, the answer to Section A is "Other: the Lanework board at `Boards/Invoice Pipeline.lanework`", and whether the board reads as an issue tracker is the test. Its output (the `## Agent skills` block and `docs/agents/issue-tracker.md`) is then diffed against the hand-written B line. Setup's output also becomes condition D for `to-tickets`: the repo as setup left it.

**Fixed prompts** (kept verbatim in the results file):

| skill | prompt |
|---|---|
| `setup` | `/setup-matt-pocock-skills` |
| `to-tickets` | `/to-tickets` plus "Add discount codes to invoices: percent or fixed, one per invoice, expiry date." |
| `research` | "Research how Python's `decimal` module should round currency totals, and write it up." |
| `grill-with-docs` | `/grill-with-docs` plus "Grill me on how invoice discounts should work." |
| `diagnosing-bugs` | "The discount total is off by a cent on some invoices. Diagnose it." |

**Driving the interactive skills:** a scripted answers file per skill, fed one round per `--resume` call. Accept-the-recommendation by default ("yes"); a fixed answer for each choice question; "I don't know, you decide" if it asks something unscripted. The same script is used in A, B and C, so only the board varies. A run ends when the skill reports done or after a fixed turn cap.

**Recorded per run:**

| field | how |
|---|---|
| found the board (y/n, and when) | from the stream-json transcript: first read or grep touching `.lanework` |
| output location | board (cards, comments, attachments) vs repo file vs chat only |
| files written outside the board | `git status --porcelain` in the repo, plus new files under `$TMPDIR` since the run began |
| board validates | `python3 "<board>/.schema/bin/lanework-validate.py" "<board>"`, exit status and first lines |
| stamps | `skills/work/scripts/lint-stamps.sh "<board>"` clean or the lines |
| anything overwritten | `git diff` on the board against the baseline commit: guide, `.schema`, existing cards, lane bodies |
| smallest change that lands it | one line, filled after the run |

**What a headless or subagent run cannot show:** a real user session has the board open in the app, so the live view and the app's own file watching are absent. The user may paste or `@` the board. Skill triggering by description depends on the whole prompt, which a fixed prompt does not vary. One run per cell shows a possibility, not a rate. Run twice where a result is surprising.

## Result shape

Matrix, 5 skills by conditions A, B, C (plus D for `to-tickets`). Each cell: found y/n, output on board y/n/partial, validates y/n.

| skill | A | B | C |
|---|---|---|---|
| `setup` | | n/a | |
| `to-tickets` | | | |
| `research` | | | |
| `grill-with-docs` | | | |
| `diagnosing-bugs` | | | |

Findings, each mapped to a possible follow-on card:

| expected finding | follow-on card |
|---|---|
| `research`, `diagnosing-bugs` and the other model-invoked skills never reach the board without a pointer | a one-line root pointer that the app or `found-board.sh` writes, or says to add (the app writes the guide, not a root file) |
| tracker skills stop at "run setup" | a "bridge" reference in `lanework`: the text to answer setup's "Other" tracker question with, so `to-tickets` and `triage` file cards |
| the cards they file break board rules (no stamps, no lane gate, ready-for-agent vs the owner's Approved gate) | a bridge reference: the ticket-to-card mapping, relations for blockers, Ideas for agent-filed work |
| `grill-with-docs` writes `GLOSSARY.md` and `docs/adr` beside our discovery cards | a decision on which wins when both exist; our `discovery` skill description or its `records.md` |
| our `work` and `lanework` descriptions never fire when the prompt says nothing about a board | description wording that catches "tracker", "tickets", "ADR", "backlog" in a repo with a `.lanework` folder |

## Out of scope

- Changing any third-party skill or the in-board guide in this spike. Findings only.
- Skills outside the 5 and the 4 reserves; the app; other agents' harnesses (the neighbouring spike).
- Fixing what the findings point at.

## Risks

- **Third-party skill text is untrusted input.** Read each skill in full before its first run (done once for this plan, from the installed copy). Run only in the scratch repo.
- **No network writes.** The scratch repo has no remote. Put a failing `gh` and `glab` stub first on `PATH`: `to-spec`, `to-tickets`, `triage`, `pr` and setup's label step otherwise call `gh issue create` or `gh label create`. No pushes.
- **Writes outside the repo:** `handoff`, `improve-codebase-architecture` and `teach` use `$TMPDIR` or a workspace. Set `TMPDIR` to a scratch folder for the runs so they stay recorded.
- **Never a real board.** Never run against `Skills Pipeline` or any board under `~/Indie`.
- `research` spawns a background agent and reads public sources. Reads only.
- Results are tied to `mattpocock-skills` 1.3.1 and guide v120. Record both.

## Done when

- Step 0 is answered and the method (headless session or subagent) is written down.
- The 5 skills have run under A, B and C, with `to-tickets` also under D, and every cell holds the seven recorded fields.
- The matrix and the findings list are on this card, each finding naming its follow-on card.
- No file under `~/Indie`, no remote, and no real board was touched; the scratch repo is deleted or its path noted.
