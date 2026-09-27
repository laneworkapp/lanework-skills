# Writing cards and comments

Two readers: the owner, who decides, and the next agent, who resumes cold. Both read a card-width column, often on a phone. Authority: the guide's "Use the thread". This page: procedure + checks.

## Short form

Pasted verbatim into every farmed prompt (`templates/farmed-prompt.md`):

> A comment is a **record** or an **ask**, never both. A record carries context and evidence and never mentions the human. An ask is one request for the human: their handle on the first line, under 80 words, the shape in `pitlane/templates/ask.md`, linted with `pitlane/scripts/lint-ask.sh <file> <board>` before the `mv`, posted one second after the record it depends on, with the card's `waiting` set in the same pass. In a lead/fixer cycle, the question goes to the lead instead.

## Record vs ask

| kind | carries | mentions human | shape |
|---|---|---|---|
| **record** | reasoning, decisions, routes not taken, evidence, attachments | never | conclusion first, then labeled one-liners |
| **ask** | one request the human must act on | always, line 1 | `templates/ask.md` |

- Belong together → two comments, the ask 1s after, so it's last in the thread and the bell opens on it.
- **The handle is a bell, not a cc.** Only in an ask: never a founding comment, START, closing report, or felt check inside a landing note. Measured: 167 of 618 agent comments mentioned the owner, typically 250–700 words with the request last, and the bell stopped meaning anything.
- A record ending in a question for the human renders without option buttons (the app draws them only on a real ask, 2026-09-26). Split it.

## The ask

Fill `templates/ask.md`. Hard budget:

- handle on line 1, ask in that sentence: a question mark or an imperative
- one ask per comment; two asks = two comments
- under 80 words; one clause per sentence (no em-dash, no semicolon)
- no hashes, counts, log names or paths; those live in the record the ask points at
- every card named is a link
- no hedging ("worth a try", "a note on whether" → imperative)
- the default and when it applies, or "blocked"
- blank line after every list: Markdown folds the next line into the last item (2026-09-14)

Lint before the `mv`: `scripts/lint-ask.sh <file> <board>` fails on each mechanical item, silent on a record.

Same pass: set the card's `waiting: {for: <handle>, since: <now>, comment: <ask uuid>}`, restamping `modified`. It marks the card and counts it in the lane header for that human. **Only the app clears it**, once a human comment lands after `since`; never remove it yourself. Cleared before the reply you needed → set it again.

Options become buttons. A click posts `<label>: <option text>` as the human's comment.

## The record

- Line 1: the conclusion, bold, one sentence.
- Then labeled one-liners, dropping empty ones: **Decided**, **Rejected** (route + why), **Accepted limitation**, **Evidence** (what ran, what it showed, population beside every zero), **Attached**.
- Raw output → attachments, never inline. Name paths; don't quote files.
- A code fence carries its language (`sh`, `yaml`, `json`, `diff`, `swift`): the app colours those.
- Cut: restating body or thread; narrating tool use; candor self-narration; ceremonial tags ("as ruled", "is not owed"); a bold headline chaining four clauses with dashes.
- A long thought trace = its own "more context" comment, before the conclusion.

## Card references

Every card named, anywhere (comment, body, commit, report), is `[<short id or title>](lanework://<board-id>/<card-id>)`. A bare id is a search; a link is a click.

```bash
bid=$(awk '/^id:/{print $2}' "$BOARD/index.md"); cid=$(basename "$CARD")
printf '[%s](lanework://%s/%s)\n' "${cid:0:8}" "$bid" "$cid"
```

## Card bodies

- Body = the spec, not a journal. Sections = what the board's instruction sheet asks for, one short paragraph or list each.
- **Open with one plain sentence**: with `show-card-body` on, the card's face previews the first paragraph only when it's prose. A heading first = a title-only face.
- Title: imperative, lane-glance short, double-quoted (`lanework-boards/references/writes.md`).
- **A ruling edits the body in place**: `~~<the open call>~~ **ruled <YYYY-MM-DD>: <ruling>**`, plus a record comment. A retraction: same.
- How the card got here → thread, never the body.
- Founding comment on every filed card: the why, not a restatement. Filing and starting in one sitting: one comment does both, reasoning then plan. None for a mechanical card (a moved duplicate, a sweep artifact).

## Before posting

Would a cold reader need anything missing? Skip anything present? For an ask: can the owner answer in one line without opening anything else?
