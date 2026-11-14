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
modified: {at: 2026-11-14T14:43:35Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
The skills should give the cards they number a citable label (`Q15`, `T3`) that lives outside the title, and use it as the link text wherever a card is cross-referenced, so a card reads the same on its face, in search and in every link to it. The label is the card's `cite-as`.

## Open call

- ~~How the citable label is stored: the `cite-as` key, or a special label kind.~~ **ruled 2026-11-14: the `cite-as` key.**

## What cite-as is

- **A card key since the v117 guide** (§ Frontmatter): a free one-line name, such as `cite-as: FR123`. The app draws it before the title on the card's face, finds it in search, and edits it in the card window's Details row.
- **A name, never an identity.** A link still carries the uuid: `[FR123](lanework://<board>/<card-uuid>)`. A relation's `to` does too.
- **Unique per board by convention.** To mint the next number for a prefix, scan every card on the board, `.trash/` included, and take the highest trailing number plus one. Nothing refuses a duplicate; the validator warns `duplicate-cite-as`.
- **Never carried into a copy.** A move keeps it.

## What the skills do today

- **The number lives in the title.** `discovery` titles a question `Q<n>: <title>` and `plan` titles a ticket `T<n>: <title>` (`templates/question-card.md`, `templates/ticket-card.md`).
- **Minting skips the trash.** `file-question.sh` and `file-ticket.sh` take the highest number across the lanes and prune dot-folders, so a trashed Q7 can be minted again.
- **Link text varies.** `[Q7](…)` in discovery's templates, `[T3: <title>](…)` in `plan/references/map.md`, and "short id or title" in `work/references/writing.md` § Card references.
- **`read-board.sh` prints title and short id**, no citation.
- **No skill writes or reads `cite-as`.**

## Proposed

- **Mint**: `file-question.sh` and `file-ticket.sh` write `cite-as: Q<n>` / `T<n>`, minted by the guide's rule.
- **Title**: drop the `Q<n>:` / `T<n>:` prefix once the citation carries it. With both, a face reads "Q15 Q15: Taking over a card…".
- **Link text**: the citation when the card has one, else the short id or title. One rule in `work/references/writing.md` § Card references; the other skills point at it.
- **Lookup**: `/lanework:plan <board> T3`, `settle-question.sh`, `resolve-ticket.sh` and `frontier.sh` find a card by its citation, falling back to the title prefix on boards filed before this.
- **Read**: `read-board.sh` prints the citation beside the short id.
- **Copy rule**: one line in `lanework/references/writes.md`: never carry a `cite-as` into a copied card, scan before minting. [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) already plans that line, on the finding that no script mints a citation. This card changes that finding.

## For shaping to settle

- **Which cards get one.** Questions and tickets are clear. Facts, ADR and PDR records, and Topic and map cards are named by a title prefix today and are not numbered.
- **Pipeline boards.** Whether a pipeline card gets a citation at filing (a board prefix and a number), which would replace the 8-hex short id in records, commits and chat.
- **Boards filed before this.** Leave their titles as they are, or have the `heal` skill move the prefix into `cite-as`.
- **Boards on an older app.** A build before the v117 guide keeps the key and draws nothing, so a card with no prefix in its title shows no number there.
- **Two sessions minting at once.** Scanning first narrows the window and does not close it. The validator's warning is the backstop.

## Touches, as far as found

| skill | files |
|---|---|
| `discovery` | `templates/question-card.md`, `scripts/file-question.sh`, `scripts/settle-question.sh`, `scripts/file-record.sh`, `references/board.md` § Order, and the link shapes in `templates/` |
| `plan` | `templates/ticket-card.md`, `scripts/file-ticket.sh`, `scripts/frontier.sh`, `scripts/resolve-ticket.sh`, `scripts/claim-ticket.sh`, `references/map.md`, `references/board.md` |
| `work` | `references/writing.md` § Card references |
| `lanework` | `scripts/read-board.sh`, `references/writes.md` |
| `dispatch` | `templates/handler-report.md` (the CARD line) |
| `merge` | to check: its rule when two sides set different citations |

Not yet read for this: `heal`, `watch`, and each script's title parsing.
