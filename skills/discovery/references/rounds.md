# Rounds

## Frontier

= decisions whose prerequisites are settled. Round = whole frontier at once.

- Depends on another question open this round → later round.
- Waits on a fact → hold it; dispatch the lookup, ask the rest now.

## Ask

Per question, one card in Asked: `scripts/file-question.sh`, or by hand from `templates/question-card.md` (`--depends` appends `## Depends on`).

- Always a recommendation: the owner can accept in one word.
- Two comments, 1s apart:
  1. **Founding record**: why it's on the frontier now, 2–3 lines, no handle.
  2. **Ask**: work's shape (`work/templates/ask.md`, lint with `work/scripts/lint-ask.sh`), ending `Context: body.` The card's `waiting.comment` = its uuid.

Then post the round in chat, each title linking its card:

```
❓ **Q7** - **Edition placement** [7c0e12a4](lanework://<board-id>/<card-id>): <question, options>

➡️ <recommendation>
```

## Answers

- **Chat** → record comment quoting the owner verbatim, in reply to the ask (`templates/ruling.md`).
- **Card** → app clears `waiting`. Re-read the whole thread.

A ruling that clears the bar: file its record first (`records.md` § Format). Then: ruling → body `## Ruling` (`templates/ruling.md`), card → bottom of Settled (`scripts/settle-question.sh`). Deferred or declined → Parked, reason = ruling.

**Challenge**: answer conflicts with a settled card, the glossary, an ADR/PDR, or the code → don't record it. Next round asks: "Q3 settled X; this implies Y. Which holds?"

## Close

When every Asked card of the round is Settled / Parked:

1. Rewrite the map card (`templates/map-card.md`) + a thread comment naming the round closed. A corner with no branches is a gap → next round.
2. Check every ruling that cleared the bar has its record card, and pinned terms are in `CONTEXT.md` (`records.md`).
3. Recompute the frontier → Ask.
