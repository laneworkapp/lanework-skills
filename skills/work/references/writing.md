# Writing cards and comments

Two readers: the owner, who decides, and the next agent, who resumes cold. Both read a card-width column, often on a phone. Authority: the guide's "Use the thread". This page: procedure + checks.

## Short form

Pasted verbatim into every farmed prompt (`templates/farmed-prompt.md`):

> A comment is a **record** or an **ask**, never both. A record carries context and evidence and never mentions the human. An ask is one request for the human: `@anyone` (or a person's handle) on the first line, under 80 words, the shape in `work/templates/ask.md`, linted with `work/scripts/lint-ask.sh <file> <board>` before the `mv`, posted one second after the record it depends on, with the card's `waiting` set in the same pass. A choice or an action only the human can make is always an ask: never left in the body or a record alone. In a lead/fixer cycle, the question goes to the lead instead.

## Record vs ask

| kind | carries | mentions human | shape |
|---|---|---|---|
| **record** | reasoning, decisions, routes not taken, evidence, attachments | never | conclusion first, then labeled one-liners |
| **ask** | one request the human must act on | always, line 1 | `templates/ask.md` |

- Belong together → two comments, the ask 1s after, so it's last in the thread and the bell opens on it.
- **The handle is a bell, not a cc.** Only in an ask: never a founding comment, START, closing report, or felt check inside a landing note. Measured: 167 of 618 agent comments mentioned the owner, typically 250–700 words with the request last, and the bell stopped meaning anything.
- A record ending in a question for the human renders without option buttons (the app draws them only on a real ask, 2026-09-26). Split it.

## When to ask

A call only the owner can make (between options, taste, scope, anything a done-when hangs on) = an **open call**. It is ruled only on the card:

1. Body: the options under an open-call line, the recommendation marked.
2. Record laying out the options, then the ask 1s later: options as buttons, recommendation in the default line, `waiting` set.
3. The ruling edits the open-call line in place (§ Card bodies).

- **Approval rules nothing.** Approving a card moves it; its open calls stay open (`lanework/references/board-kinds.md`). No build until each one has a ruling comment.
- **Owner in a live chat**: the ask still goes on the card, where the ruling is recorded. The chat only links to it ("asked on [<short id>](lanework://…)"). Never ask in chat instead. A chat ruling is recorded on the card and may clear `waiting`: § The ask. Before sending a reply, scan it for questions on a card's options, scope or next step: each is an ask on that card first. A question with no card yet → file the card, then ask on it.
- **Filing a card with an open call** → its asks go out in the same pass as the founding record. An open-call list in a fresh body with no asks under it is the miss.
- Open call or owner action found later (in Approved, Active, a review) → post the ask then, and stop work that depends on it.
- **Owner action**: something only the owner can do that the card's next step waits on (run a trial, cut a release, run commands on their machine). A gate lane's own step (owner's review or move out) is not one: surface it (`lanework/references/board-kinds.md`, Lane actors). Not a choice: no options, no open-call line in the body, no ruling edit. One imperative ask: `@anyone` on line 1, the action, the card linked, "reply here when done" (clearing: § The ask), `If no answer: blocked`, `waiting` set in the same pass. A record alone ("stays with the owner") is the miss.

## The ask

Fill `templates/ask.md`. Hard budget:

- **address `@anyone`, `for: anyone`** (`lanework/scripts/lib.sh` `ask_handle` decides: older boards draw no buttons for it, so there the guide's handle). A person's handle only for a question that is theirs alone, a gate the board's sheet names. Never take it from the guide's "answers to" line (that says whose machine ran, not who is asked). Agents never act on `@anyone`
- every handle on line 1, ask in that sentence: a question mark or an imperative
- one ask per comment; two asks = two comments
- under 80 words; one clause per sentence (no em-dash, no semicolon)
- no hashes, counts, log names or paths; those live in the record the ask points at
- every card named is a link
- no hedging ("worth a try", "a note on whether" → imperative)
- the default and when it applies, or "blocked"
- blank line after every list: Markdown folds the next line into the last item (2026-09-14)

Post it with `scripts/post-ask.sh <board> <card> --body F --model m --for <anyone|handle>`: `--for` required, `@<handle>` on line 1. One step: lint (`lint-ask.sh`, fails on each mechanical item), a wait until one second past the card's newest comment, the ask stamped from the clock, then the card's `waiting` (shape: the guide's § Mentions; `comment` = the ask's uuid) and `modified` restamped. It refuses a second already on the card, a check not a lock: concurrent posters can collide.

Several people → `for: [a, b]`, by hand (`post-comment.sh --ahead 1`, then `waiting`), each `@`-named on line 1; only where the board's guide § Mentions allows a list (older builds never clear one). Any one answer clears it. It marks the card and counts it in the lane header for that human. **The app clears it**, once a human comment lands after `since` or replies to the ask by `in-reply-to`; an agent's reply never does.

**The owner's exception, a trial.** This one rule is the owner's standing exception to the in-board guide, ruled on the card "Let an agent clear waiting when it records an owner ruling given off the board". Until the guide takes it in or the trial fails, clear `waiting` only when you record an owner ruling given off the board (chat, a call, a note), in the same pass, and only if `waiting.comment` is the ask that ruling answers. A newer or different ask stays marked. `scripts/lint-waiting-clears.sh <board>` lists every agent clear. The trial ends when `lint-waiting-clears.sh <board> --since <0.9.0 release time>` shows ten `QUOTED` and no `NO-QUOTE` (release time: the commit date of the `v0.9.0` tag, in UTC; filled in when 0.9.0 is cut).

- Record, `in-reply-to` that ask, no handle: line 1 `**Owner ruled off the board.**`, then the owner's words verbatim as a `>` quote line, then `**Given**: <where>, <date>`.
- Write: read the card's `index.md` fresh, delete the `waiting` key whole (block lines too), restamp `modified`, change nothing else. A human comment already after `since` → leave it to the app.
- Not a ruling, the mark stays: a lean ("inclined"), a `Recap:` click, an answer to another question, your own summary with no owner words.
- Nothing else lets you clear it, `move-card.sh --clear-waiting` included. Cleared before the reply you needed → set it again.

Options become buttons. A click posts `<label>: <option text>` as the human's comment.

**The standing option.** An ask with options ends them with `- Recap: Explain this in plain terms first`; `lint-ask.sh` requires it and leaves it out of the 80 words. An ask with no options gets none. A click on it (`Recap: Explain this in plain terms first`) is a request, not a ruling. Same pass:

1. Record, `in-reply-to` the click: the decision in everyday words (what is decided, why now, what each option does). No new options, no handle.
2. One second later, re-post the same ask as a new comment, standing line included.
3. Set `waiting` to the new ask (the app clears it on any human comment).
4. Change nothing else: no body edit, no lane exit.

A second click gets a second recap.

## The record

- Line 1: the conclusion, bold, one sentence.
- Then labeled one-liners, dropping empty ones: **Decided**, **Rejected** (route + why), **Accepted limitation**, **Evidence** (what ran, what it showed, population beside every zero), **Attached**.
- Raw output → attachments, never inline. Name paths; don't quote files.
- A code fence carries its language (`sh`, `yaml`, `json`, `diff`, `swift`): the app colours those.
- Cut: restating body or thread; narrating tool use; candor self-narration; ceremonial tags ("as ruled", "is not owed"); a bold headline chaining four clauses with dashes.
- A long thought trace = its own "more context" comment, before the conclusion.

## START

The record a session posts when it starts working a card, after staking it. It says what. Who and until when = the lease (`lanework/references/writes.md` § Lease).

```markdown
**START: <the plan in one line>**

- **Scope**: <what changes>
- **Verify**: <the check that proves it>
- **Where**: <branch and worktree, or the lanes it passes>
```

- About 40 words. Drop a label that has nothing; add none.
- Opens with `START:` (bold or not): a scan for two on one thread keys on it. A shaping start reads `**START: shaping: <plan>**` (the plan line opens with `shaping`): the scan skips it as a handoff, not a second builder.
- A choice made while planning → its own record (§ The record), never inside START.
- **One per start**: the session that starts the card posts it (`scripts/start-card.sh`, with the lease and the move). A worker under that lease (fixer, subagent) posts its plan as a record (§ The record), never a second START: one from another `--session` label reads as a second builder.

## Card references

Every card named, anywhere (comment, body, commit, report), is `[<link text>](lanework://<board-id>/<card-id>)`. **Link text**: the card's `cite-as` alone (`[Q7](…)`, `[T3](…)`), else its short id or title (`lanework/scripts/lib.sh` `card_ref`); the title follows in running text where it helps. Written link text is never rewritten. A bare id is a search; a link is a click. A link may arrive short (each segment 8+ hex digits): read it by prefix, write the full form.

```bash
bid=$(awk '/^id:/{print $2}' "$BOARD/index.md"); cid=$(basename "$CARD")
printf '[%s](lanework://%s/%s)\n' "${cid:0:8}" "$bid" "$cid"
```

## Card bodies

- Body = the spec, not a journal. Sections = what the board's instruction sheet asks for, one short paragraph or list each.
- **Open with one plain sentence**: with `show-card-body` on, the card's face previews the first paragraph only when it's prose. A heading first = a title-only face.
- Title: imperative, lane-glance short, double-quoted (`lanework/references/writes.md`).
- **A ruling edits the body in place**: `~~<the open call>~~ **ruled <YYYY-MM-DD>: <ruling>**`, plus a record comment. A retraction: same.
- How the card got here → thread, never the body.
- Founding comment on every filed card: the why, not a restatement. Filing and starting in one sitting: one comment does both, reasoning then plan. None for a mechanical card (a moved duplicate, a sweep artifact).

## Before posting

Would a cold reader need anything missing? Skip anything present? For an ask: can the owner answer in one line without opening anything else?
