---
schema: 1
kind: card
title: "Work skill: ship move-card, post-ask and commit-board helpers"
order: 9216
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T17:55:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
modified: {at: 2026-11-12T17:55:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
---
Requested by the Lanework Pitwall session (it watches the Lanework Pipeline board), at the owner's ask, 2026-11-12. Every coordinator session working a pipeline board writes its own one-off board-write scripts in a scratchpad, and they repeat the same stamp, order and staging mistakes. The work skill ships `lint-ask.sh`, `lint-stamps.sh` and `post-comment.sh`; moving a card, posting an ask and committing a board are still done by hand.

## Three helpers

**1. `move-card.sh <board> <card-id-or-prefix> <target-lane> --model m [--comment <bodyfile>] [--top|--bottom] [--clear-waiting]`**

Defects seen in a hand-rolled version (`land-done.sh`):

| defect | effect |
|---|---|
| source lane hardcoded to Active | a card closed from Approved or Issues isn't found; moved by hand |
| closing comment's `by` hardcoded | a sonnet fixer's record went out signed as the opus lead |
| only `modified.at` rewritten, old `by` kept | on a card the human filed, `modified` has no `by`, so the agent's move reads as the owner's |
| `order` not set | the card lands at an arbitrary place in the target lane |
| `waiting` left on a card moved to Done | a stale ask |
| prefix not checked | zero or two matches make a bad move |

Wanted: find the card in any lane, exactly one match or refuse; stamp `modified` with `at` from the clock and the caller's `by`; set `order` (lane max + 1024, or the top); drop `waiting` when asked; post the optional comment with the same `by`; validate what it touched. No commit.

**2. `post-ask.sh <board> <card> --model m --for <handle> <askfile>`**

`post-comment.sh` already writes the comment from the clock and runs `lint-ask.sh`. Still by hand, and still slipping: `waiting.comment` not equal to the ask's uuid, `waiting` left unset, the ask in the same second as its record. Wanted, in one step: lint, wait until at least 1 s after the card's newest comment, write the ask, set `waiting: {for, since: <ask time>, comment: <ask uuid>}`, stamp `modified`. To settle in shaping: a new script, or a `--ask --for` mode of `post-comment.sh`. Depends on the v117 card (9e04cdec) for what `--for` defaults to.

**3. `commit-board.sh "<msg>" <paths...>`**

The owner's app writes into the same board folder all day (lane layout, reordering, `.schema` updates, comment trash). `git add -A` or `git commit -a` sweeps those into the agent's commit, and `pull --rebase --autostash` makes stashes. Pattern that worked (`succ-commit.sh`):

- holds a lock directory, so concurrent agents serialise
- fetch + `merge --ff-only`; stops if the branch diverged
- commits through a private `GIT_INDEX_FILE` built from HEAD plus only the named paths, so nothing else is staged
- pushes; on rejection un-commits (ref only, files stay on disk) and retries
- never stashes; warns if the stash count changed

Avoid: appending a session trailer itself (callers that add one get it twice). Make it a parameter or leave it to the caller. To settle in shaping: whether pushing belongs in a shipped script or behind a flag, since a board's push policy is a project fact; and whether this lives in `work` or `lanework`.

## Also

A line for `work/references/traps.md`: a waiter written as `while pgrep -f <pattern>; do sleep; done` matches its own command line and never ends. Watch a pid with `kill -0`, or keep the pattern out of pgrep's sight. `kill -0` also succeeds on a zombie, so a finished child of a stopped parent still looks alive.

## Not in scope

Build queue, build-slot and timing locks, gate wrappers: specific to the Lanework app repo.

## Evidence

The scripts described are in the Lanework Pitwall session's scratchpad, in no repo. That session offered to send their full text.
