---
schema: 1
kind: card
title: "Work skill: ship move-card, post-ask and commit-board helpers"
order: 2048
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T17:55:12Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
modified: {at: 2026-11-12T18:56:42Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5}}
---
Ship three board-write helpers in the `work` skill (`move-card.sh`, `post-ask.sh`, `commit-board.sh`) so coordinator sessions stop hand-rolling scripts that mis-stamp, mis-order and over-stage.

Requested by the Lanework Pitwall session at the owner's ask, 2026-11-12. Its hand-rolled `land-done.sh`, `post.sh`, `move.sh` and `succ-commit.sh` are in the evidence comment (reference, not code to copy).

## Files touched

| file | change |
|---|---|
| `skills/work/scripts/move-card.sh` | new |
| `skills/work/scripts/post-ask.sh` | new |
| `skills/work/scripts/commit-board.sh` | new |
| `skills/work/SKILL.md` | one line naming the three beside `lint-ask.sh`, `lint-stamps.sh`, `post-comment.sh` |
| `skills/work/references/writing.md` | § The ask: post with `post-ask.sh` |
| `skills/work/references/traps.md` | Shell row: `while pgrep -f <pat>` matches itself; use `kill -0 <pid>` (true on a zombie too) |
| `skills/lanework/references/writes.md` | § Moving and § Git cite `work/scripts/move-card.sh` and `commit-board.sh` (one line each, no restated rules) |
| `skills/lanework/scripts/lib.sh` | only if a helper is shared (card lookup across lanes, `waiting` rewrite); reuse `lane_by_title`, `next_order`, `by_of`, `now_utc` first |
| `tests/smoke.sh` | new cases below |
| `CHANGELOG.md` | one user-facing entry in the release commit |

No new skill, so `plugin.json` and the README skills table stay. README word counts re-checked by `check-sizes.sh`.

## Design

**`move-card.sh <board> <card-uuid-or-prefix> <lane-title> --model m [--name n] [--session s] [--comment F] [--top|--bottom] [--clear-waiting]`**

- Finds the card in any lane; exactly one match or exit 2, nothing written.
- Stamps `modified` whole: `at` from the clock, `by` from the caller (`by_of`), replacing any old `by` (a card the owner filed has none).
- Sets `order`: lane max + 1024, or half the lane's lowest with `--top`.
- `--clear-waiting` drops `waiting`. Default keeps it.
- `--comment F` posts through `post-comment.sh` with the same `by`.
- `mv` of the one folder, then runs `lanework-validate.py` on the card. No git, no commit.

**`post-ask.sh <board> <card-uuid> --body F --model m --for <handle|anyone> [--name n] [--session s] [--in-reply-to u]`**

- A new script wrapping `post-comment.sh` (which already lints and refuses a same-second comment), not a mode of it: `post-comment.sh` stays a pure comment writer.
- Waits until the clock is at least 1 s past the card's newest comment, lints, writes the ask, then sets `waiting: {for, since: <ask time>, comment: <ask uuid>}` and restamps `modified`, in one step.
- `--for` is required, with no default. What the default becomes under guide v117 belongs to the v117 card (9e04cdec); this script then gains the default there.

**`commit-board.sh [--push] [--trailer T] "<msg>" <paths...>`**

- Lives in `work`, beside the other board-write helpers; scripts reach siblings by relative path, so no reason to split it into `lanework`.
- Keeps Pitwall's pattern: lock directory, `fetch` + `merge --ff-only` (the stop message names the overlapping file), private `GIT_INDEX_FILE` from HEAD plus only the named paths, never stashes and warns if the stash count changed. Closing `git reset -q -- paths` syncs only those paths (stated in the header).
- Push is **off unless `--push`**: a board's push policy is a project fact. On a rejected push it un-commits (ref only) and retries, as in the original; that is safe only under the lock.
- The trailer is **only what `--trailer` passes**; the script never appends one.
- Refuses a path outside the work tree; refuses `.DS_Store`; never `-A`.

## Verification

`tests/smoke.sh`, new cases on throwaway copies (never this board):

- move-card: move from Approved and from Issues; zero and two prefix matches exit 2 with nothing written; owner-filed card (no `modified.by`) comes out stamped by the caller; `order` is lane max + 1024 and `--top` is lowest minus; `--clear-waiting` drops it and default keeps it; `--comment` carries the caller's `by`; validator exit 0 and no `DEPRECATED`; `lint-stamps.sh` clean; every other file byte-identical.
- post-ask: `waiting.comment` equals the new comment's uuid; `since` equals the ask's `created.at`; ask lands at least 1 s after the newest comment; a body failing `lint-ask.sh` writes nothing and leaves `waiting` unset; `modified` restamped; missing `--for` exits 2.
- commit-board: in a temp repo with a bare origin: a dirty unrelated file is not committed; no push without `--push`; with it, origin has the commit; a rejected push retries; a diverged branch stops and names the overlap; stash count unchanged; no trailer unless `--trailer`; second invocation waits on the lock.
- Each script passes `bash -n` and a real run against a scratch board outside the repo, output quoted in the closing comment.

## Done when

1. The three scripts exist under `skills/work/scripts/`, executable, `bash -n` clean.
2. The smoke cases above exist and `tests/smoke.sh` passes (`check-refs.sh` and `check-sizes.sh` included).
3. `skills/work/SKILL.md`, `writing.md`, `traps.md` and `lanework/references/writes.md` cite them as described, and no rule is stated twice.
4. Every defect in the card's table has a failing-then-passing smoke case.

## Risks

- Smoke currently fails at the stamp gate (board guide v117 vs repo stamp v114). Building waits on, or lands after, the v117 card (9e04cdec); "verified" needs smoke green.
- `commit-board.sh` is the only script that touches git state: the lock and un-commit retry are subtle (concurrent agents, abandoned lock after a kill). Mitigation: lock holds a pid and is reclaimed when `kill -0` fails; smoke covers it.
- `post-ask.sh` sleeps up to 1 s; acceptable.
- macOS bash and BSD tools only (`date -v`, `uuidgen`).

## Not in scope

Build queue, build-slot and timing locks, gate wrappers: specific to the Lanework app repo.

## Recommendation

Build as designed: three scripts in `work`, push off by default, `--for` required until the v117 card lands. Minor bump (new behavior). No open calls.
