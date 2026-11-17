---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:05:00Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:05:00Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Built and verified on `work-helpers` at `f8ce9f7`: `tests/smoke.sh` prints `smoke: 167 passed`, 152 before plus 15 new cases.**

- **Scripts**: `file-card.sh`, `move-card.sh`, `post-ask.sh`, `commit-board.sh` in `skills/work/scripts/`, executable, `bash -n` clean (smoke case 1).
- **Defect to case**: D1 153, 155. D2 153. D3 156. D4 154. D5 158. D6 157. D7 157. D8 158. D9 159, 160. D10 159. D11 162. D12 161. D13 164. D14 150.
- **Real run**, scratch board in a temp repo with a bare origin: `file-card.sh` into an empty Approved gave `order: 1024`; `move-card.sh <prefix> Active --comment` moved it and posted the record; `post-ask.sh --for anyone` set `waiting` to the ask's uuid and second; validator `failures 0 over 0 of 12 documents`, `lint-stamps.sh` clean; `commit-board.sh --push --trailer` committed 3 files, origin equal to HEAD, trailer once.
- **Decided beyond the body**: `post-ask.sh` lints the body twice (with the board and without), because the board lint passes an ask to a person who is not the guide's handle untouched; it also refuses when `@<for>` is not on line 1. `commit-board.sh` also refuses a glob and an owner's `comments/.draft/`, and skips a named path neither on disk nor in HEAD (a card's old lane path when it was filed since HEAD). `writes.md` § Placing names `file-card.sh` beside the other filing scripts.
- **Accepted limitation**: `--push` carries earlier unpushed commits on the branch, as Pitwall's did. The lock's `kill -0` test misreads a reused pid.
- **Not reachable**: the body's file-card case "the caller's own value of a `single` kind wins" needs a label flag the body rules out; covered instead by a lane with two values of one `single` kind keeping the lowest rank.
