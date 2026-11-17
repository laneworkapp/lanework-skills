---
schema: 1
kind: card
title: "Retire the dispatch skill and move its arming sweep and a compaction rule into watch"
order: 10240
labels: [{text: watch, kind: {type: skill, text: Skill}}, {text: dispatch, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-17T11:33:01Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-17T12:10:45Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Remove the `dispatch` skill, and give `watch` the two things that make a long watch safe without it: the scripted arming sweep, and a rule for what to do after the session's context is compacted.

## Why

- **Dispatch was only half trialed.** It shipped in 0.7.0 and its arming changes in 0.8.0. The arming half of the trial ran on 2026-11-16; an owner comment during the watch, `/clear` and a restart never ran ([Dispatch arming](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ada828e-56a0-4f1a-9b8b-094b330c71b7), newest record). Its flat-context claim is the design's, not a measurement ([Dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4)).
- **Watch with autocompact covers the same ground.** Watch re-reads the whole card and thread on every event (`watch/references/events.md` item 3), so the board is the memory. The Monitor survives a compaction as it survives `/clear`.
- **Two skills double the work.** The lease card and the move-receipt card each change `watch` and `dispatch` together.

## What moves into watch

1. **The arming sweep.** `skills/dispatch/scripts/arm-pass.sh` moves to `skills/watch/scripts/arm-pass.sh` (`git mv`). Its `../../lanework/scripts/lib.sh` and `../../lanework/references/board-kinds.md` paths resolve the same from there, so the code is unchanged. Only the header changes: line 2 ("so the router never opens a card") says the watch learns which cards to open, and lines 10-11 name the seven fields themselves instead of "the same seven fields classify-event.sh prints". Watch today has a model-read arming pass for unclaimed agent-lane cards (`watch/references/arming.md` line 19), but nothing for owner comments left unanswered or claims gone quiet.
2. **`skills/watch/references/arming.md`**: line 19's **Arming pass** paragraph becomes its own `## Arming pass` section after § Boards. Per board, run `scripts/arm-pass.sh <board>`, passing the board's own agent lane titles when its bodies name lanes other than `board-kinds.md`. Then, per line:
   - `comment` → read the card whole (`events.md` item 3). Already answered (a later agent record answers it, or its ruling is folded in the body) → no reply, one report line. Otherwise answer it as a new owner comment (`responding.md`). Older threads answered without `in-reply-to` print this line falsely; reading the card is what catches it.
   - `arm` → a work order only when the lane body agrees and the card waits on nobody (no `waiting`): `responding.md` § A move into an agent lane. Otherwise one report line.
   - `stale` → report only: lane, title, minutes quiet. Never released, never worked.
   - A lane whose body puts it out of scope: its lines are skipped.
3. **The compaction rule**, `arming.md` § Tell the user, a bullet after the `/clear` one: after a compaction, re-read each board's authority chain before acting, and re-derive work in flight (running builds, open claims, pending asks) from the board and git, never from the summary. A card path comes from `ls`, never from memory.
4. **`skills/watch/SKILL.md`**: line 11 (the pointer to `dispatch`) is deleted. The step table gains one row: `class every card at arming: owner comments to answer, cards to arm, stale claims` → `scripts/arm-pass.sh`.

`events.md` item 8 already re-runs the arming pass on `SKILLS CHANGED`, and `responding.md` needs no change.

## What goes

- `skills/dispatch/` whole: `SKILL.md`, `references/routing.md`, `references/handler.md`, `templates/handler-prompt.md`, `templates/handler-report.md`, `scripts/classify-event.sh`, `scripts/state.sh`.
- `.claude-plugin/plugin.json`: `./skills/dispatch` from `skills`, `dispatch` from `keywords`, and "a flat-context watch that hands each event to a fresh subagent" from `description`. `marketplace.json` never names dispatch.
- `README.md`: the skills-table row (line 12), `dispatch` in the on-demand list (line 18), the `/dispatch` bullet (line 24), the § Sizes summary row (line 36) and the `#### dispatch` table (lines 92-101), `dispatch` in the measured-on note (line 42), the `ln -s` line (line 172), "eight" to "seven" (lines 156 and 181), `dispatch` in the harness sentence (line 183) and in § Names (line 205). The `watch` row (line 11) gains its start-up catch-up, as a key feature. The `watch` rows in § Sizes are re-measured with `wc -w`.
- **Board write, separate commit**: `dispatch` leaves the label list in this board's body. The board's `skill` kind is open (no `values`), so there is no label value to remove from `config`. Cards labelled `dispatch` keep the label as history.

## Settled in shaping

Each item from the filed card, and what settled it (the evidence is in the thread record):

- **Model tiers**: watch keeps `work/references/tiers.md` as it is. The 2026-10-25 ruling on [Dispatch skill](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4) was tiers as-is. Dispatch's table only applied it to handlers, and watch has none: it handles comments in the main session and farms work per `tiers.md` (`responding.md` § Action-calling).
- **`arm-pass.sh` output**: kept as is, seven fields. Watch uses each field: the uuid to resolve the path, the comment path, the lane for its policy. Smoke pins the full lines, and [the lease card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233) adds a `held` line in the same shape.
- **`classify-event.sh`**: dropped with the folder. The owner ruled on Board Runner Discovery (Q3, 2026-10-30, ADR "The run skill owns its trigger rules") that the runner writes its own trigger rules and does not reuse dispatch's classifier. Git history keeps the script.
- **The false alarm** (folded rulings with no `in-reply-to`): the script stays strict, because the guide's § Comments makes `in-reply-to` the mark of an answer. Watch reads the card before replying (item 2 above).
- **Open cards that name dispatch** lose their dispatch half (§ Dependencies). The build lead posts a record on each. Their bodies change when each is next worked, since Proposed is the owner's gate.
- **Users on `/lanework:dispatch`**: the changelog tells them to use `/lanework:watch`, and tells a hand install to remove its `~/.claude/skills/dispatch` link.

## Open calls

- ~~**A. Order against the lease cards.**~~ **Ruled 2026-11-17: A1, this card first.** Both this card and [9c5ee0c7](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233) edit `arm-pass.sh` and `arming.md`. 
  - A1 (ruled): this card first. Watch takes today's START-based `stale`, and 9c5ee0c7 then edits `watch/scripts/arm-pass.sh` and drops its dispatch half. Nothing here waits on the lease chain.
  - A2: after 9c5ee0c7. The lease rewrite lands in `dispatch/` first, and this card moves the leased script. 9c5ee0c7's dispatch prose is built, then deleted.
- ~~**B. The two Active dispatch cards**~~ **Ruled 2026-11-17: B1, closed as withdrawn when this card lands.** ([f36f6a5d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/f36f6a5d-32a5-498e-8b4c-276b2e4e80d4), [4ada828e](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4ada828e-56a0-4f1a-9b8b-094b330c71b7)). 
  - B1 (ruled): closed as withdrawn when this card lands, each with a record naming this card. The `waiting` mark on f36f6a5d stays until the owner next comments there, since only the app clears it.
  - B2: closed as withdrawn now.
  - B3: kept, and the rest of the trial runs before dispatch goes.
- ~~**C. The version.**~~ **Ruled 2026-11-17: C2, 0.9.0.**
  - C1: 1.0.0, by this repo's rule (major for a removed skill).
  - C2 (ruled): 0.9.0, keeping 1.0.0 for a later milestone.

## Verified

- `bash -n` on the moved script.
- **Same output**: the moved `arm-pass.sh`, run read-only on this board, prints exactly what the old one printed before the move (`diff` of the two outputs empty, quoted in the closing comment).
- `tests/smoke.sh` green:
  - **Removed**: the dispatch block, lines 841-927: the 14 `ok` cases for `state.sh`, `classify-event.sh` and the dispatch fixture board.
  - **Kept, repointed**: the arm-pass block, lines 929-978 (3 cases), from `$DS/arm-pass.sh` to `$SK/watch/scripts/arm-pass.sh`. It uses `NOWS`, `OLD` and `AGENT`, which line 863-864 of the removed block defines, so those two lines move into it.
  - **Added**: `no skill folder or plugin.json entry is named pitlane, pitwall or dispatch` (`dispatch` joins the loop at line 48). `watch arming runs scripts/arm-pass.sh and carries the compaction rule` (a grep on `arming.md`). `check-sizes: a § Sizes row or table for a skill with no folder fails`, run on a scratch copy of the README.
- **`tests/check-sizes.sh`**: it walks only `skills/*/`, so a leftover `dispatch` row would pass unseen today. It gains a check that every § Sizes summary row and `####` table names an existing folder.
- `tests/check-refs.sh` passes once `watch/SKILL.md` line 11 is gone.
- The prose is read against this board's guide (v118 today; the repo stamp is v114, moved by [the guide card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8)).

## Done when

- `skills/dispatch/` is gone. `plugin.json` names no `dispatch`, and the plugin check in smoke passes.
- `grep -rn dispatch skills/ README.md .claude-plugin/` finds only the plain verb: `plan/references/sessions.md`, `discovery/references/rounds.md`, `work/references/companions.md`, `lead.md`, `team.md` and `watch/references/responding.md`.
- `skills/watch/scripts/arm-pass.sh` exists, and its output on this board matches the old script's.
- `arming.md` has § Arming pass, with the three line kinds, and the compaction bullet.
- `tests/smoke.sh` is green with the cases above, and README § Sizes matches `wc -w`.
- `CHANGELOG.md` has the entries under § Release, and this board's body no longer lists `dispatch`.

## Risks

- **A compaction mid-build** that the watch session leads. The compaction rule is the mitigation. It stays untested until a watch session has compacted mid-build and recovered from the board.
- **A long session's context.** Nothing has measured watch or dispatch over hours. Autocompact is what keeps watch going.
- **A heavier first arm.** Watch answers each `comment` line in the main session, where dispatch spawned a handler. On a board with many old questions the first arm is long. Done is never swept.
- **False lines on this board today.** Read-only, the script prints `comment` for two Proposed cards whose rulings were folded long ago ([d42328d4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7), [714177b9](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3)). It prints `arm` for both Active dispatch cards, which wait on the owner. Watch reads each and does nothing; B1 removes the second pair.
- **A dangling link** for hand installs, and an unknown `/lanework:dispatch` after the update. The changelog covers both.

## Dependencies and build order

- [9c5ee0c7, the session stakes a lease](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233): same files. Order is open call A. Under A1 it loses `routing.md`, `handler.md`, both templates and the dispatch `SKILL.md` row, and its `arm-pass.sh` and smoke edits point at `watch/`.
- [42019d3d, read a move receipt](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/42019d3d-d517-40da-956d-6962c771b9a2): loses `classify-event.sh` and its six smoke cases. What is left is `events.md` items 4 and 5. Built first, its classifier work is deleted here.
- [0f83a9dd, the lease script](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/0f83a9dd-3bee-4731-88c9-d29da3e4c0eb) and [eb4a1000, work lease checks](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/eb4a1000-fc45-4fba-b13b-d46e698635fa): no shared file. Their text names "the watch and dispatch arming pass" and `dispatch/scripts/arm-pass.sh`, which become `watch`.
- Text only, no shared file: [9e04cdec, guide v117](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) (its `classify-event.sh` item lapses), [36c5772c, lease trial](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/36c5772c-557e-437d-8a9e-d1818ce0f80b) (cites the script's old path), [4596a2cb, citable labels](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4596a2cb-ee8c-4227-a04a-4472ac9cae12) (its `handler-report.md` row lapses), [714177b9, clear waiting](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3) (its `dispatch` table row lapses).
- Order inside this card: move the script and its smoke block, then the watch prose, then delete `dispatch/`, the manifest and README, then the board body in its own commit.

## Release

A removed skill is a major bump by this repo's rule. The owner ruled 0.9.0 for this release (call C), keeping 1.0.0 for a later milestone. Draft entries for `CHANGELOG.md`, under the release month:

- `Version 0.9.0: the dispatch skill is retired. Use /lanework:watch instead, which now catches up when it starts.`
- `/watch now answers comments you left while no watch was running, in every lane except Done, and reports work claims that look abandoned.`
- `/watch now re-reads your boards after its conversation is compacted, instead of trusting its summary.`
- `If you installed the skills by hand, remove the old link with rm ~/.claude/skills/dispatch.`

## Recommendation

Build it under A1 and B1, before the lease chain, as one card with the board-body write in its own commit. Release it on its own as 0.9.0 (C2), so the changelog's retirement note is not buried among lease entries.
