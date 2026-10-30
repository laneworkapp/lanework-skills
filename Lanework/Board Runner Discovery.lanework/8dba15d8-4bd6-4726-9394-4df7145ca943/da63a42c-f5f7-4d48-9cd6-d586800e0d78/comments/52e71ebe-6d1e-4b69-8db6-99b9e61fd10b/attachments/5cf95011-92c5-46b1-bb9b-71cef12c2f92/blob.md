# Repo facts for a board runner

Read 2026-10-30 in lanework-skills `main` (paths under `skills/`), and the Skills Pipeline board's guide (lanework-agent-guide v102).

## dispatch
- `/dispatch <board>...`, owner-only. The main session is a pure router: a script classes each event, a fresh handler subagent reads the card, acts, commits and returns a report of at most 10 lines (dispatch/SKILL.md:9, templates/handler-report.md:3).
- Classes (dispatch/scripts/classify-event.sh): comment, move, body, bulk, self, excluded. Owner = `by` absent or `kind: human`. A move stamp older than 120s counts as the owner's. Needs mikefarah `yq` v4.
- Routing (dispatch/references/routing.md:32-40): owner comment → handler; owner move into an `agent` lane → handler, else one line to the owner; body, agent comment, agent move, self, excluded → dropped; bulk → handler.
- State (dispatch/scripts/state.sh): in-flight set, per-card queues, self-writes registry (300s TTL), excluded lanes; mkdir lock.
- Tiers: sonnet for comments, rulings, bulk and moves into agent lanes other than Approved/Active; opus for a build lead and escalations.
- Handler: answers owner comments with no agent reply yet, folds rulings, acts on a move into an unclaimed agent lane's card, may lead a build; commits `git commit --only -- <paths>`, waits out `index.lock`.
- No file states why dispatch uses subagents and not `claude -p`. The dispatch card's problem: `/watch` context grows per event. Goal there: ≤2k tokens median growth per event.

## watch
- `watch/scripts/watch-boards.sh`: `fswatch -r -o -l 0.5` as a trigger only; changed paths come from a find/stat snapshot diff, because the app renames directories and raw fswatch paths drop comments and moves. Ignores non-`.md` files, `.trash/`, `comments/.draft/`. Emits `CHANGED <path>`, `BULK: <n> files` (>20), `SKILLS CHANGED`. Does not detect its own writes.
- `watch/references/events.md`: skip own writes and excluded lanes; only owner authorship gets a response; a bare move into an agent lane is a work order; a body edit or `waiting` cleared is context, not a reply.

## work
- Agent lanes (lanework/references/board-kinds.md § Pipeline): Shaping, Approved, Active. Holding: Ideas, Issues, Tasks. Gate: Proposed. None: Done.
- Build cycle (work/references/lead.md): lead makes a worktree + branch, fixer writes test → FAIL-BEFORE → fix, gate run in a granted slot, reviewer verdict (≤2 rounds), lead merges, closes with evidence. Heavy builds: one at a time, when free memory > ~55%.
- Claims: a START or plan comment is a claim (work/references/companions.md).
- Asks: record, then ask, set `waiting`; only the app clears it, when a human comment lands after `since`.
- No STOP word and no `by.kind: human` trust rule for Approved exist in the skills.

## Board guide (v102)
- No presence, heartbeat, lease or `.agents/` concept. Unknown frontmatter keys are preserved verbatim and invisible (`claimed-by:` is the guide's own example). Card key `assignees` is reserved.
- A bare folder move rewrites no file, so the card arrives unstamped = moved by the owner, unless its `index.md` is touched again.
- Reserved `by.name`s: `shortcuts` (owner automation), `healer`.
- `.trash/`, `.log/`, `.schema/`, `comments/.draft`, `comments/.trash` are the app's.

## Prior cards (Skills Pipeline)
- "Dispatch skill: a flat-context watch session", Active, f36f6a5d.
- "Dispatch arming: answer waiting owner comments in every lane, flag stale claims", Proposed, 4ada828e.
- No card about a runner, headless runs or launchd.
