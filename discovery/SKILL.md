---
name: discovery
description: "Discovery: a guided, question-by-question examination of a project's problem and domain space, run on a Lanework board. The agent explores every corner of the space (the problem, the people it serves, the domain language, scope and non-goals, constraints, architecture, integrations, risks, and what success looks like) in rounds until nothing is left silently assumed. It maps every decision as a discovery map and keeps the questions, the owner's rulings and the facts found along the way on a discovery board (a `<Topic> Discovery.lanework` folder the skill founds when none exists). The session produces a glossary and a set of decision records for the project: ADRs for architectural decisions and PDRs for product decisions. Every question is a card, every ruling is written into that card in the owner's words, and a later session resumes from the board. Use this skill whenever the user says 'discovery', 'run discovery on X', 'discovery session', 'let's do discovery for X', 'explore the problem space', 'map out the domain', 'grill me', 'interview me about', 'sharpen this plan', 'let's think through X properly', 'design session for X', or wants a project, plan or feature examined question by question before anything is built. Not for founding general boards (lanework-boards), sweeping a pipeline board (pitlane), or standing watch on one (pitwall)."
---

# Discovery

Discovery is a guided examination of a project's problem and domain space. The agent asks, the owner decides, and the session ends when every corner of the space has been looked into and nothing is left silently assumed. This skill runs that examination on a Lanework board so the questions, the answers and the facts outlive the chat that produced them. The project keeps two things from it: a shared understanding that the board records, and the decision records (ADRs and PDRs) and glossary that the codebase keeps from then on. The board is the discovery record and the chat is the conversation.

Two structures drive the session and are not optional. The **discovery map** is a tree: every decision branches into the decisions that hang off it. The **frontier** is the set of decisions whose prerequisites are settled, so they can be asked now without guessing at an answer the owner has not given yet. A round asks the whole frontier at once. On the board, each question is a card, each ruling is a sentence in the owner's words on that card, and the map itself is a card that is rewritten as it grows.

## The authority chain

This skill builds on **lanework-boards**, and everything there holds here. Before any write, read the board's app-maintained guide (`<board>.lanework/CLAUDE.md`), then the board's own `index.md` body, then each lane's body. The guide is the authority on frontmatter, stamping, comments, `waiting`, `in-reply-to`, labels and mentions, and nothing below restates it. Where anything here disagrees with a board's own files, the board's files win.

## The corners of the space

Discovery is thorough by design. Before the first round, check the map against each of these areas, and give each one at least one branch or an explicit line saying it is out of scope and why:

| corner | what it settles |
|---|---|
| Problem | what hurts today, for whom, and how anyone would know it stopped hurting |
| People | who uses it, who operates it, who pays for it or depends on it, and what each of them needs |
| Domain | the concepts, their names, their relationships, and the rules the domain imposes regardless of the software |
| Scope | what is in, what is explicitly out, and what is deferred |
| Behavior | what the product does, step by step, including failure and edge cases |
| Constraints | regulatory, contractual, budget, timeline, platform, and existing systems that cannot move |
| Architecture | the shape of the solution, its boundaries, and the technology choices with lock-in |
| Integrations | every system on the other side of a boundary, and who owns the contract |
| Data | what is stored, where it comes from, who may see it, and how long it lives |
| Risks | what could sink the project, what is unknown, and what would have to be true for it to succeed |
| Success | how the result is judged, and what counts as done |

The list is a floor, not a ceiling. A project with a corner of its own (a migration, a pricing model, a compliance regime) gets its own area on the map.

## The board

A discovery board has five lanes and three kinds of card. The full shape, with the literal file templates, is in `references/board.md`. The lanes:

| lane | order | what it holds |
|---|---|---|
| Brief | 1024 | the Topic card and the Discovery map card, the two standing references |
| Facts | 2048 | one card per fact found in the environment or the world, with its evidence attached |
| Asked | 3072 | one card per open question, waiting on the owner |
| Settled | 4096 | answered questions, with the ruling written into the body in the owner's words |
| Parked | 5120, collapsed | questions the owner deferred or declined, with the reason |

**Finding or founding it.** A discovery board is named `<Topic> Discovery.lanework` and lives where the project's boards live: `<repo root>/Pitlane/` by default, or `~/Pitlane/` when there is no project. Look for an existing board before founding one. The user may name a board, and a topic that had discovery before already has its board. A `<Topic> Grill.lanework` board from this skill's predecessor, `grill-me`, has the same lanes and cards: resume it as it is and do not rename it. Found a new board only when none fits, with `scripts/found-discovery-board.sh`. Then open it once in the app so the guide and schema are installed before the first question is filed. Never duplicate a board that already exists for the topic.

**A lighter discovery can run on an existing board's card** when the owner says so. That suits a small clarification, where a card per question would be too heavy: it is the plain interview, with the card's thread as the notebook. The full shape below is for a topic that deserves its own record.

## Running discovery

### 1. Frame

Read what exists before asking anything: the codebase, the design docs, `docs/adr/` and `docs/pdr/`, the glossary, any earlier card or note the owner wrote on the topic, and the board itself if it exists. Finding facts is the agent's job, never the owner's. When a round needs something from the environment, dispatch a subagent to find it. The result lands as a **Facts card** when it returns. Questions that depend on it wait for it, and the rest of the frontier is asked now.

Write two cards into Brief:

- The **Topic card**: the scope in one paragraph, and which corners of the space a shared understanding has to cover.
- The first **Discovery map card**: every decision you can already see, as an outline grouped by corner, with nothing settled yet.

### 2. Ask a round

Compute the frontier. File one card into Asked for each question on it, with `scripts/file-question.sh` or by hand to the same template:

- the question in the body, above the first `##`
- the options under `## Options`
- your recommendation under `## Recommended`
- the settled cards it hangs off under `## Depends on`, each as a `lanework://` link

Questions are numbered globally in the order they are asked (`Q1`, `Q2`, … across every round), so the chat and the board agree. The round is a label.

Each card arrives with two comments. The first is a founding record saying why the question is on the frontier now. The second is the **ask**: it carries the owner's handle and restates the question, its options and the recommendation in under 80 words, so the owner can answer from the thread without opening the body. The card's `waiting` key points at the ask, so the lane header counts what the owner owes.

Then post the same round in chat, because the owner may be at the terminal. Use the interview format, with each question's title linking its card:

```
❓ **Q7** - **Edition placement** [7c0e12a4](lanework://<board-id>/<card-id>): <question, options>

➡️ <your recommended answer>
```

A question whose answer depends on another question still open in this round belongs to a later round. Every question gets a recommended answer, so the owner can accept it with one word.

### 3. Take the answers

Answers arrive two ways and are recorded the same way:

- **In chat.** Post a record comment on the card that quotes the owner's answer verbatim, in reply to the ask. Then write the ruling into the body.
- **On the card.** The owner comments in the app, and the app clears `waiting`. Re-read the whole thread, then write the ruling into the body.

The ruling goes in the body under `## Ruling`: dated, in the owner's words, one or two sentences. The recommendation stays above it, so a reader sees what was proposed and what was decided. Then move the card to the bottom of Settled. An answer that defers or declines the question moves the card to Parked, with the reason as its ruling.

**Challenge as you go.** Do not record an answer that conflicts with a settled card, the glossary, an existing ADR or PDR, or what the code does, and move on. Put the conflict back to the owner in the next round, as a new question that names it: "You settled Q3 as X; this answer implies Y. Which holds?"

### 4. Close the round

A round closes when every Asked card in it is Settled or Parked. Then:

1. **Rewrite the Discovery map card.** Settled decisions get their card links and one-line rulings. Open ones get their card links. Ones not yet askable stay as plain outline lines. A corner that has no branches yet is itself a gap, and the next round covers it.
2. **Write the documents.** The round's rulings feed documents outside the board, and they are written now, not batched to the end of the session:
   - the **glossary** (`CONTEXT.md` at the repo root), for every term the round pinned
   - an **ADR** (`docs/adr/NNNN-slug.md`), for each ruling that settles how the system is built
   - a **PDR** (`docs/pdr/NNNN-slug.md`), for each ruling that settles what the product does and for whom

   Both kinds of record have to clear the same bar, and a ruling that settles both a how and a what gets one of each. `references/docs.md` has the formats, the bar and the ADR/PDR split. A Settled card whose ruling produced a record links it under the ruling.
3. **Recompute the frontier** and go back to step 2.

### 5. Finish

The session is done when the frontier is empty and every corner of the map is either settled or explicitly ruled out of scope. Post a closing record on the Topic card with:

- the number of settled and parked questions
- the ADRs, PDRs and glossary terms written, each linked
- one paragraph on the shape of what was agreed

Then ask the owner, in one ask, whether this is a shared understanding. **Do not build anything, and do not turn the board into work cards, until the owner says so.**

## Resuming

A discovery session that stopped partway resumes from the board, not from memory:

1. Read the board in one pass, with the lanework-boards recipe.
2. Read the Discovery map card (on a board from `grill-me`, the Design tree card).
3. Read every Asked card's thread. A thread with an owner comment newer than the card's `waiting.since` holds an answer that is not recorded yet, and recording it comes first.
4. Continue from step 4.

If the owner wants to answer on the board while the session waits, use the **pitwall** skill's watch. Arm it on the discovery board, and every owner comment on an Asked card becomes an event to record and move.

## Writing conduct

The pitlane skill's `references/writing.md` governs every comment here. These rules are specific to a discovery board:

- **The body holds the question in full; the ask comment is where it is answered.** The owner reads and replies in the thread, so every question card carries exactly one ask: the last comment when the card is filed, with the handle on its first line. No other comment on the card mentions the handle. The owner ruled this on the first board of this kind (the `grill-me` predecessor, 2026-09-22): a question that lives only in the body has nowhere to be answered.
- **A ruling is the owner's words.** It is not a paraphrase, and not the recommendation restated as if it were accepted. When the owner said "yes", the ruling is the recommendation, marked as accepted as recommended.
- **One question per card, one decision per question.** A question with two decisions in it is two cards.
- **Facts are cited, never asserted.** A Facts card names its source and attaches the report. A question that leans on it links it.
- **Records are written from rulings, never ahead of them.** An ADR or PDR states what the owner decided, not what the agent recommended, and it is written only after the card is Settled.
- **Follow the guide's write rules.** Stamp every write with your own identity. Write atomically from a temp path outside the board. Never rename a uuid folder. Delete by moving to `.trash/`. Resolve a card's path immediately before every write to it. The guide has the rest.

## Versioning

Written against `lanework-agent-guide v70` and `lanework-schema v1`. Each marker is on line 1 of its own file, `CLAUDE.md` and `.schema/VERSION`, at the root of any board. If a board's guide reads a later version, the guide is right and this skill is out of date.
