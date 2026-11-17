---
schema: 1
kind: card
title: "Let an agent clear waiting when it records an owner ruling given off the board"
order: 6144
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-06T00:08:54Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "board runner discovery"}}
modified: {at: 2026-11-17T11:40:29Z}
---
The skills let an agent clear a card's `waiting` mark itself when it records an owner ruling given off the board, as a trial the owner started, with a small script that shows what comes of it.

~~**Open call: which route?** Recommended: keep the rule.~~ **ruled 2026-11-14: "Yes, skills first, as a trial."** The skills go ahead of the guide on this one rule. The earlier routes (keep the rule, guide first, drop the card) are overruled.

## The rule

In `skills/work/references/writing.md` § The ask, today: "**Only the app clears it**, once a human comment lands after `since` or replies to the ask by `in-reply-to`; an agent's reply never clears it. Never remove it yourself. Cleared before the reply you needed → set it again." It becomes:

- The app still clears it on a human comment after `since` or a human reply by `in-reply-to`. An agent's reply never does.
- **One exception, the owner's, a trial**: an agent clears `waiting` only when it records an owner ruling given off the board (chat, a call, a note), in the same pass, and only if the card's `waiting.comment` is the ask that ruling answers. A newer or different ask stays marked.
- The record, `in-reply-to` that ask, no handle: line 1 `**Owner ruled off the board.**`, then the owner's words verbatim as a `>` quote line, then `**Given**: <where>, <date>`.
- The write: read the card's `index.md` fresh, delete the `waiting` key whole (block lines too), restamp `modified`, change nothing else. If a human comment already sits on the card after `since`, leave it to the app.
- Not a ruling, so the mark stays: a lean ("inclined"), a `Recap:` click, an answer to a different question, an agent's own summary with no owner words.
- Nothing else lets an agent clear it. "Cleared before the reply you needed → set it again" stays.
- The wording says this is the owner's standing exception to the guide (see Conflict), with no guide version number.

## Who else says who clears `waiting` (grep of `skills/`)

| file | says | change |
|---|---|---|
| `work/references/writing.md` § The ask | "Only the app clears it ... Never remove it yourself" | **rewritten** as above; the "Owner in a live chat" bullet in § When to ask gains one clause pointing at it; line 58 "(the app clears it on any human comment)" is about a click on the Recap button, stays |
| `work/references/writing.md` short form (line 9) | the set-it rule only, no clear rule | none, on purpose: farmed prompts get the short form, and a farmed agent that never sees the exception cannot use it |
| `watch/references/events.md` item 6 | "the app clearing `waiting` after the owner replied" | **one clause**: or an agent, with a ruling record. Still context, not a reply |
| `discovery/references/rounds.md` § Answers | chat answer = record quoting the owner verbatim, in reply to the ask; card answer = "app clears `waiting`" | none. It is already this shape, and the card line is about the app |
| `discovery/scripts/settle-question.sh` | drops `waiting` when it records a ruling | none. It already clears with a quoting record; this card makes the same act legal for a card that is not a question card |
| `plan/scripts/resolve-ticket.sh`, `plan/references/sessions.md` line 22 | resolve drops `waiting`; an owner comment newer than `waiting.since` is the answer | none |
| `work/references/sweep.md` § Unanswered question | reads `waiting` as present or absent | none. A card an agent cleared stops showing here by design; the lint script is where it shows |
| `merge/references/rules.md`, `plan/scripts/frontier.sh`, `heal`, `dispatch` | read or merge `waiting` as a key | none. `dispatch` states no rule on who clears it |
| `work/SKILL.md` | names `lint-ask.sh` and `lint-stamps.sh` | **one clause** naming the new script |

## Conflict, stated plainly

Guide v117 § Mentions says "Only the app clears it" and "do not remove it yourself when the reply lands". Repo `CLAUDE.md` says the in-board guide wins. The owner ruled on 2026-11-14 that the skills go first here, as a trial. So the page says this one rule is the owner's standing exception to the guide, ruled on this card. It writes no guide version number: smoke fails on one under `skills/`, and the stamp lives only in `CLAUDE.md`. The exception ends one of two ways: the guide takes the rule in, and the exception wording is dropped, or the trial fails and the rule is struck (see The trial).

## The trial: how "what falls out" is seen

New `skills/work/scripts/lint-waiting-clears.sh <board>`, read-only, modeled on `lint-stamps.sh` (same `lib.sh` source, silent when there is nothing to report, usage and exit-2 handling). It finds every card whose latest ask has been cleared by an agent:

- the card's newest ask (a comment by an agent whose body starts with `@`) with **no** later human comment (no `by`, or `kind: human`) and none in reply to it, and the card has **no** `waiting`;
- one line per such card: `QUOTED <card> <ask uuid>` when an agent comment `in-reply-to` that ask has a `>` line and a `**Given**` line, else `NO-QUOTE <card> <ask uuid>`;
- a last line with the two counts; exit 1 when any `NO-QUOTE`, else 0; exit 2 on a bad path or flag.

It cannot tell an agent clear from an ask that never got a mark (the gap in [02bf00c2](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/02bf00c2-ec9e-427b-8e9a-4b49fb56837f)); both show as `NO-QUOTE`, which is the right thing to look at either way. Skips `.trash`, `.log`, `.schema` and attachments, as `lint-stamps.sh` does.

**The trial ends well** when, ten agent clears (`QUOTED`) have been listed on the owner's boards, none is `NO-QUOTE`, and the owner names none as wrong. **It ends badly** when any `NO-QUOTE` stays unfixed by a quoting record, or the owner calls any one clear wrong: the rule is struck from `writing.md` and the card reopened. Checked by running the script on each board and counting `QUOTED` lines; the owner's say-so covers "wrong".

**No clearing helper in this card.** [7655176d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f) ships `move-card.sh`, `post-ask.sh` and `commit-board.sh`; its `post-ask.sh` sets `waiting`, and its `move-card.sh --clear-waiting` drops it on a move. The clear here is one deleted key plus a restamp, done in the same pass as a record the agent writes anyway, so a hand edit is enough for a trial. If the lint shows hand edits going wrong, a `clear-waiting.sh` that checks `waiting.comment` against the ask and refuses without a quoting record is the follow-up card. One note for that card: `--clear-waiting` is a clear too, so it falls under this rule and must not be used outside it.

## Files

| file | change |
|---|---|
| `skills/work/references/writing.md` | § The ask: the rule above replaces "Only the app clears it ... Never remove it yourself"; § When to ask, "Owner in a live chat" bullet: one clause linking it |
| `skills/watch/references/events.md` | item 6, one clause |
| `skills/work/SKILL.md` | one clause naming `scripts/lint-waiting-clears.sh <board>` |
| `skills/work/scripts/lint-waiting-clears.sh` | new, executable, `bash -n` clean, macOS bash and BSD tools |
| `tests/smoke.sh` | new case, below |
| `CHANGELOG.md` | one user-facing entry in the release commit, not in this card's build |

No new skill, so `plugin.json` and the README skills table stay. `tests/check-refs.sh` covers the new `<skill>/<dir>/<file>` citations; `tests/check-sizes.sh` runs only if README word counts move (they should not).

## Verified by

New smoke case in `tests/smoke.sh`, "work: lint-waiting-clears", on a throwaway copy of the discovery board (never the Skills Pipeline board), the way the `lint-stamps` case is built:

- a card with an agent ask, no `waiting`, and a quoting record (`in-reply-to` the ask, `>` line, `**Given**` line): one `QUOTED` line, exit 0;
- the same with no record: `NO-QUOTE`, exit 1; with a record lacking the `>` line: `NO-QUOTE`;
- an ask with `waiting` present: silent; an ask followed by a human comment, `waiting` absent (the app's clear): silent; an ask followed by a human reply `in-reply-to` it: silent;
- two asks, the newer unanswered and unmarked with no record: names the newer ask's uuid only;
- a block-form `waiting` still reads as present;
- a missing path exits 2;
- the new script and every changed script pass `bash -n`; `tests/smoke.sh` passes. The prose is read through against the board's guide § Mentions: the one place it disagrees is the stated exception.

## Done when

1. `grep -n "clear" skills/work/references/writing.md` shows the rule once, naming the owner's exception, the record shape and the matching-ask condition; no file under `skills/` carries a guide version number it did not before.
2. `skills/work/scripts/lint-waiting-clears.sh` exists and the smoke case above passes, so `tests/smoke.sh` exits 0 (given the stamp gate; see Depends on).
3. `watch/references/events.md` item 6 and `work/SKILL.md` carry their one clause each; no other file under `skills/` restates the rule.
4. The closing comment names the trial's ending line (ten `QUOTED`, no `NO-QUOTE`) and where the lint result will be read.

## Risks

The five from the thread's risks record, with what the rule does to each:

- **A pending ask disappears.** Stands in part: the mark goes, by design. Limited by the rule: the clear needs a record on the card in the same pass, so the card shows the ruling, and the lint lists every clear, so none is silent.
- **The ruling may not be a ruling.** Limited: the record quotes the owner's words, where and when, so the owner can see on the card what the agent took as a ruling; leans, Recap clicks and answers to other questions are named as not rulings. The agent still judges; the quote makes a wrong call visible, not impossible.
- **The wrong ask gets cleared.** Limited: the clear only happens when `waiting.comment` is the ask the ruling answers, the record is `in-reply-to` it, and a newer or different ask stays. The lint checks the `in-reply-to` link.
- **Two writers on one key.** Stands: a skill cannot lock a file the app also rewrites. Reduced: read the card fresh before the write, touch only `waiting` and `modified`, and leave the card alone if a human comment already landed (the app clears it, same end). The worst case left is a lost write, seen as a mark that comes back, which the existing "set it again" line covers.
- **The skills contradict the guide.** Stands, accepted: the owner ruled it, the page names it as the owner's exception and the trial's ending decides whether the guide takes the rule or the rule goes. Until then a reader holding only the guide may think a skill is wrong.
- **Not on the list, noted**: an agent that clears and a later watch session see no mark, so `sweep.md` will not list the card; the lint script is the only place those cards are counted.

## Depends on

- [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) (stamp to v117): smoke fails at the stamp gate until it lands; this card's "verified" waits on it. Both touch `work/references/writing.md` § The ask, so build this one after it.
- [7655176d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f) (work helpers): also edits `work/SKILL.md` and `writing.md`; this card goes last in the lane, so it rebases on that one. No code shared.
- Related: [02bf00c2](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/02bf00c2-ec9e-427b-8e9a-4b49fb56837f), cards parked on an owner action with no mark: the same cards show up as `NO-QUOTE` in the lint until that fix lands.

## Recommendation

Build as written: the rule in `writing.md`, the two one-clause edits, the lint script with its smoke case, no clearing helper. Minor bump (new behaviour in the skills). The trial's result, not this card, decides whether the guide changes. No open calls.
