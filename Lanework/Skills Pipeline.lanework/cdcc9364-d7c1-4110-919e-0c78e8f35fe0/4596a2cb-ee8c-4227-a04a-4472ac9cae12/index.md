---
schema: 1
kind: card
title: "Give numbered cards a citable label and cross-reference by it"
order: 2048
labels:
  - {text: discovery, kind: {type: skill, text: Skill}}
  - {text: plan, kind: {type: skill, text: Skill}}
  - {text: work, kind: {type: skill, text: Skill}}
  - {text: lanework, kind: {type: skill, text: Skill}}
created:  {at: 2026-11-14T14:20:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:23:45Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
waiting: {for: anyone, since: 2026-11-14T14:23:45Z, comment: 5156ff11-614c-4779-9117-b41a2393a5df}
---
The skills should give the cards they number a citable label (`Q15`, `T3`) that lives outside the title, and use it as the link text wherever a card is cross-referenced, so a card reads the same on its face, in search and in every link to it. The labeling is wanted; how the label is stored is not decided, and nothing is built until it is.

## Open call

- **How the citable label is stored: the `cite-as` key, or a special label kind.** The owner is testing the label kind in the app. Asked on this card; shaping waits on the ruling.

## The two candidates

- **A, the `cite-as` key.** A card key since the v117 guide (§ Frontmatter): a free one-line name, such as `cite-as: FR123`. The app draws it before the title on the card's face, finds it in search, and edits it in the card window's Details row. A name, never an identity: a link and a relation's `to` still carry the uuid. Unique per board by convention, with a validator warning `duplicate-cite-as`. Never carried into a copy.
- **B, a special label kind.** The citation is a `labels` entry of a kind made for it. Under test by the owner in the app; its shape, how it draws and its uniqueness rule are not known here.

## What the skills do today

- **The number lives in the title.** `discovery` titles a question `Q<n>: <title>` and `plan` titles a ticket `T<n>: <title>` (`templates/question-card.md`, `templates/ticket-card.md`).
- **Minting skips the trash.** `file-question.sh` and `file-ticket.sh` take the highest number across the lanes and prune dot-folders, so a trashed Q7 can be minted again.
- **Link text varies.** `[Q7](…)` in discovery's templates, `[T3: <title>](…)` in `plan/references/map.md`, and "short id or title" in `work/references/writing.md` § Card references.
- **`read-board.sh` prints title and short id**, no citation.
- **No skill writes or reads a citation**, in either form.

## Proposed, whichever candidate is ruled

- **Mint**: `file-question.sh` and `file-ticket.sh` write the label as `Q<n>` / `T<n>`, scanning every card on the board, `.trash/` included, for the highest number.
- **Title**: drop the `Q<n>:` / `T<n>:` prefix once the label carries it. With both, a face reads "Q15 Q15: Taking over a card…".
- **Link text**: the label when the card has one, else the short id or title. One rule in `work/references/writing.md` § Card references; the other skills point at it.
- **Lookup**: `/lanework:plan <board> T3`, `settle-question.sh`, `resolve-ticket.sh` and `frontier.sh` find a card by its label, falling back to the title prefix on boards filed before this.
- **Read**: `read-board.sh` prints the label beside the short id.

## Depends on the ruling

- **What is written**: a root key, or a `labels` entry with its kind, and for B the kind's row in each founding template's `config.labels`.
- **The copy rule.** Under A, one line in `lanework/references/writes.md`: never carry a `cite-as` into a copied card. [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) already plans that line. Under B the rule is whatever the kind's own is.
- **What the validator and the heal check.**

## For shaping to settle, after the ruling

- **Which cards get one.** Questions and tickets are clear. Facts, ADR and PDR records, and Topic and map cards are named by a title prefix today and are not numbered.
- **Pipeline boards.** Whether a pipeline card gets a label at filing (a board prefix and a number), which would replace the 8-hex short id in records, commits and chat.
- **Boards filed before this.** Leave their titles as they are, or have the `heal` skill move the prefix into the label.
- **Boards on an older app.** A build that does not know the chosen form draws nothing for it, so a card with no prefix in its title shows no number there.
- **Two sessions minting at once.** Scanning first narrows the window and does not close it.

## Touches, as far as found

| skill | files |
|---|---|
| `discovery` | `templates/question-card.md`, `scripts/file-question.sh`, `scripts/settle-question.sh`, `scripts/file-record.sh`, `references/board.md` § Order, and the link shapes in `templates/` |
| `plan` | `templates/ticket-card.md`, `scripts/file-ticket.sh`, `scripts/frontier.sh`, `scripts/resolve-ticket.sh`, `scripts/claim-ticket.sh`, `references/map.md`, `references/board.md` |
| `work` | `references/writing.md` § Card references |
| `lanework` | `scripts/read-board.sh`, `references/writes.md`, and under B `templates/label-kinds.md` |
| `dispatch` | `templates/handler-report.md` (the CARD line) |
| `merge` | to check: its rule when two sides set different labels |

Not yet read for this: `heal`, `watch`, and each script's title parsing.
