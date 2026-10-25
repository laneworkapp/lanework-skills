# Routing

The main session routes and never handles. Per event: one classify call, one state call, at most one spawn, one line to the user.

## Never in the main session

- `Read`, `cat` or `yq` of a card, thread, lane body, board body or guide.
- The BULK diagnosis (`git status`, `find`, `.log` greps).
- A board write, a ruling fold, a commit, a build lead, an evidence review.
- An answer to an owner comment, on the card or in chat.

`watch/references/events.md` items 1–7 and all of `watch/references/responding.md` run in a handler (`handler.md`). The router writes nothing on a board, so the authority chain binds handlers only.

## Arm

Once. `<state>` = `<scratchpad>/dispatch`. Read this file, `templates/handler-prompt.md`, `work/references/tiers.md` and the lane-actor tables in `lanework/references/board-kinds.md`.

1. **Boards**: each argument per `watch/references/arming.md` § Boards (resolution only: the per-board reading there is the handlers').
2. `scripts/state.sh <state> init <board>...`
3. **Arming pass**: `lanework/scripts/read-board.sh <board>`. Each card under a lane whose title is an `agent` row → one event line, `arm<TAB><Board>.lanework<TAB><card uuid><TAB><lane title><TAB><card title><TAB>-<TAB>-`, routed as a handler event (§ Route). The handler checks the claim and the lane body.
4. **Monitor**: `watch/references/arming.md` § Monitor as written, state file `<state>/board-snapshot.txt`.
5. **Tell the user**: `watch/references/arming.md` § Tell the user, with `/dispatch` for `/watch`.

## Route

A Monitor notification carries one or more lines.

1. `SKILLS CHANGED` → re-read this file and `templates/handler-prompt.md`, one line to the user. The fingerprint covers `watch`, `work` and `lanework`, not `dispatch`: a live dispatch edit takes a new `/dispatch`.
2. Per board the lines name: `scripts/classify-event.sh --state <state> <board> <lines verbatim>`.
3. Each output line:

| kind | author | route |
|---|---|---|
| `self`, `excluded` | any | drop, silently |
| `comment` | owner | handler |
| `comment` | agent | drop: another session's work (`work/references/companions.md`) |
| `body` | any | drop: context, not a reply (`watch/references/events.md` item 6) |
| `move` | owner | lane title an `agent` row → handler. Else one line to the user, no handler |
| `move` | agent | drop |
| `bulk` | - | handler, which runs the diagnosis |

4. Handler event → `scripts/state.sh <state> claim <key> '<the line>'`. Key = card uuid, or `bulk:<Board>.lanework`.
   - `spawn` → § Spawn.
   - `queued` → nothing. The follow-up handler gets it.
   - `relay <agent-id>` → SendMessage the line to that build lead. It owns the card.
5. `scripts/state.sh <state> prune`, once per notification.

## Spawn

- `Agent`, fresh (never `fork`), in the background. Prompt = `templates/handler-prompt.md` filled, nothing added: every byte lands in this context.
- Tier, per `work/references/tiers.md` (owner ruling 2026-10-25):

| event | tier |
|---|---|
| owner comment, ruling, bulk, `arm` or move into any agent lane but these two | sonnet |
| `arm` or move into Approved or Active: the handler leads a build | opus |
| a report's `ACTION: escalate` | opus, same events |

  Never haiku: every handler may write owner-facing prose. Never inherit.
- Then `scripts/state.sh <state> tag <key> <agent-id>`, adding `lead` for an opus build.

## On completion

The notification carries the report (`templates/handler-report.md`). Never re-read the card to check it.

1. `scripts/state.sh <state> self <each WROTE path>`.
2. `LANE: <uuid> out-of-scope` → `scripts/state.sh <state> exclude <board> <uuid>`.
3. `ACTION: escalate` → spawn again at opus with the same events, and `tag`. Skip 4.
4. `scripts/state.sh <state> finish <key>`. Lines printed = events queued meanwhile → one follow-up handler for all of them, at the highest tier any needs, then `tag`.
5. One line to the user: `<board> · <card title> · <ACTION> · <COMMIT> · <GATE>`. A no-op with no gate: no line.

A report off the template → one line to the user naming the card and quoting `ACTION`. Never repair it here.

## Chat

The owner talks to this session as usual. Answer from the reports already here. A question that needs a card read → a handler, event `chat<TAB><Board>.lanework<TAB><card uuid or -><TAB>-<TAB>-<TAB>owner<TAB><the question>`, sonnet, spawned with no `claim` and no `finish`. Relay its `ANSWER`.

## After `/clear`

The Monitor survives (`watch/references/arming.md` § Tell the user). On the next notification: re-read this file and `templates/handler-prompt.md`, then `scripts/state.sh <state> show`. `<state>` = the folder of the Monitor's snapshot file. No board re-read. Handlers still running report as usual.

The Monitor dies with the session: a resumed session runs `/dispatch` again, on a fresh `<state>`.
