---
schema: 1
kind: card
title: "Give numbered cards a citable label and cross-reference by it"
order: 9216
labels:
  - {text: discovery, kind: {type: skill, text: Skill}}
  - {text: plan, kind: {type: skill, text: Skill}}
  - {text: work, kind: {type: skill, text: Skill}}
  - {text: lanework, kind: {type: skill, text: Skill}}
created:  {at: 2026-11-14T14:20:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T14:59:25Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
The skills should give the cards they number a citable label (`Q15`, `T3`, `ADR2`) in the card's `cite-as` key, leave it out of the title, and use it as the link text wherever a card is cross-referenced, so a card reads the same on its face, in search and in every link to it.

## Ruled

- ~~How the citable label is stored: the `cite-as` key, or a special label kind.~~ **ruled 2026-11-14: the `cite-as` key.**

## What cite-as is

- **A card key since the v117 guide** (§ Frontmatter): a free one-line name, such as `cite-as: FR123`. The app draws it before the title on the card's face, finds it in search, and edits it in the card window's Details row.
- **A name, never an identity.** A link still carries the uuid: `[FR123](lanework://<board>/<card-uuid>)`. A relation's `to` does too (§ Relations).
- **Unique per board by convention.** To mint the next number for a prefix, scan every card on the board, `.trash/` included, and take the highest trailing number plus one. Nothing refuses a duplicate; the validator warns `duplicate-cite-as`.
- **Never carried into a copy.** A move keeps it.

## What the skills do today (read from the files)

- **The number lives in the title.** `discovery/templates/question-card.md` titles `Q{{n}}: {{title}}`, `plan/templates/ticket-card.md` `T{{n}}: {{title}}`, `discovery/templates/record.md` `{{kind}}: {{title}}` (no number), `discovery/templates/fact-card.md` `Fact: <…>` (no number).
- **Minting skips the trash.** `file-question.sh` and `file-ticket.sh` scan `*/*/index.md` and prune dot-folders, so a trashed Q7 can be minted again.
- **Two scripts depend on the title prefix.** `resolve-ticket.sh` prints `unblocked ${t%%:*}` (the text before the first colon of the title), and both `file` scripts and `frontier.sh` build link text and messages from the whole title. Dropping the prefix without changing these makes `unblocked` print the whole title.
- **Link text varies.** `[Q<n>](…)` in discovery's templates, `[T<n>: <title>](…)` in `plan/references/map.md`, `plan/templates/*` and `file-ticket.sh`'s `## Depends on` lines, `[Q<n>: <title>](…)` in `discovery/templates/record.md` and `file-record.sh`, "short id or title" in `work/references/writing.md` § Card references.
- **`read-board.sh` prints order, title and short id**, no citation.
- **No skill writes or reads `cite-as`** (grep of `skills/` and `tests/`: zero matches).

## What the worked example shows

[Card Lease Discovery](lanework://33527992-d72c-417b-85a2-1b62bea96794/d304d742-37e8-42d8-aac8-514f525e4b53) (commit e39d824) cited every card by hand: questions `Q1`..`Q22`, facts `F1`..`F5`, records `ADR1`..`ADR13` and `PDR1`..`PDR2` (counted per prefix), the Brief cards `Map` and `Topic`. Every title lost its prefix (`Q12: What a lease write restamps…` became `What a lease write restamps…`, `Fact: …` and `ADR: …` likewise). Its older card links still read `[Q2: One machine or several](…)` and `[ADR: A takeover posts…](…)`: nothing rewrote link text, and the links still work because they carry the uuid.

## Settled by reading the evidence

- **Which cards get one.** Everything the skills number or name by prefix: questions `Q<n>`, tickets `T<n>`, facts `F<n>`, ADRs `ADR<n>`, PDRs `PDR<n>` (each prefix has its own counter), as the example does. The discovery map card gets the fixed `Map` and the topic card `Topic`: one per board, so no number and no scan. The plan board's map card is titled `Map` already and gets none. Scripts mint for Q, T, ADR and PDR; no script files a fact, so `templates/fact-card.md` carries `cite-as: F<n>` and points at the scan rule in `writes.md`.
- **Pipeline boards: no.** No skill files a pipeline card (the `work` skill has `post-comment.sh`, `lint-ask.sh`, `lint-stamps.sh`, nothing that mints a card), so there is nothing to mint at. The prefix a pipeline would use is that board's own choice, which belongs in its instruction sheet (CLAUDE.md: project facts never move into a skill). The link rule below reads any card's `cite-as`, so a pipeline board that numbers its cards by hand is picked up with no further change. The guide's `short-id` setting remains the app's own affair.
- **Boards filed before this: leave them.** A `Q7:` title prefix is not a retired spelling and no damage, so `heal` has no rule for it (its catalog is retired spellings and label damage), and a title is the owner's text. Skills never rewrite an existing title. Lookup falls back to the title prefix by display (`read-board.sh` prints the title as it is), and minting counts both the highest `cite-as` and the highest `<prefix><n>: ` title prefix, so a mixed board never reissues a number. Migrating one is a board commit by hand, as e39d824 was.
- **Boards on an older app: gate on the board's guide line.** A build before v117 keeps the key and draws nothing, so a bare title with its number only in `cite-as` would show no number there. The scripts write `cite-as` and a bare title only on a board whose guide line reads v117 or later (`guide_version`, which [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8) adds to `lib.sh`); below it, or with no readable stamp, they behave as today: prefixed title, no `cite-as`. The guide stamp is written by the app that opened the board, so it names what that board's app draws.
- **Two sessions minting at once: accepted.** The scan runs as late as possible, immediately before the card is staged, and the script prints the citation it minted. It narrows the window and does not close it; no lock is added (a lease is its own card, not this one). The validator's `duplicate-cite-as` warning is the backstop, and a duplicate is renumbered by hand.
- **Link text: the citation alone, else the short id.** `[Q7](lanework://…)`, as discovery's templates already write it, and `[T3](…)` in plan; the title follows in running text where it helps (the map's description column already does). A card with no citation keeps today's rule (short id or title). The rule lives once, in `work/references/writing.md` § Card references; other files link to it.
- **merge: no change.** `cite-as` falls under `merge/references/rules.md` "any other key: later `modified` wins". Two sessions minting the same citation on two different cards is not a file conflict: both cards survive and the validator warns. Differing citations on one card means two edits of one name, and the later one is right.
- **`dispatch`: link text only.** `templates/handler-report.md` CARD line names the citation when there is one.

## Change

| file | change |
|---|---|
| `skills/lanework/scripts/lib.sh` | add `cite_of <index.md>` (the `cite-as` value, quotes stripped), `card_ref <index.md>` (citation, else title, escaped as link text) and `next_cite <board> <prefix>` (highest trailing number over every card incl. `.trash/` flat and in trashed lanes, taking both `cite-as: <prefix><n>` and a `<prefix><n>: ` title prefix, plus one) |
| `skills/lanework/scripts/read-board.sh` | print the citation before the title when a card has one |
| `skills/lanework/references/writes.md` | one entry: scan before minting, count `.trash/`, never carry a `cite-as` into a copy. The only home of the mint rule |
| `skills/lanework/references/reading.md` | the `read-board.sh` line says it prints citations |
| `skills/work/references/writing.md` | § Card references: the link text rule above |
| `skills/discovery/scripts/file-question.sh` | on a v117+ board mint `Q<n>` with `next_cite`, write `cite-as`, bare title; print the citation; older boards unchanged |
| `skills/discovery/scripts/file-record.sh` | mint `ADR<n>` / `PDR<n>`, write `cite-as`, bare title, `Question: [<citation>](…)`; older boards unchanged |
| `skills/discovery/scripts/settle-question.sh` | none: reads no title (checked) |
| `skills/discovery/templates/question-card.md`, `record.md`, `fact-card.md`, `topic-card.md`, `map-card.md` | `cite-as` line (`Q{{n}}`, `{{cite}}`, `F<n>`, `Topic`, `Map`), bare title, link shapes `[Q<n>](…)` |
| `skills/discovery/references/board.md`, `records.md`, `rounds.md` | the Q-number line points at `writes.md`; the record title rule drops `ADR: `; the round message's link text is the citation |
| `skills/plan/scripts/file-ticket.sh` | mint `T<n>`, write `cite-as`, bare title; `## Depends on` lines and the Out-of-scope message use `card_ref`; older boards unchanged |
| `skills/plan/scripts/frontier.sh` | print the citation before the title; messages name the citation |
| `skills/plan/scripts/resolve-ticket.sh` | `unblocked` names the citation (or, on an unprefixed card, the title) instead of `${t%%:*}` |
| `skills/plan/scripts/claim-ticket.sh` | none: reads only lane titles (checked) |
| `skills/plan/templates/ticket-card.md`, `resolution.md`, `map-card.md`; `references/map.md`, `references/board.md`; `SKILL.md` | `cite-as: T{{n}}`, bare title, link text the citation alone; the `T<n>` mint line points at `writes.md`; "Never a bare `T3`" becomes "link text is the citation" |
| `skills/dispatch/templates/handler-report.md` | CARD line: citation when present |
| `tests/smoke.sh` | the cases below |
| `README.md` | § Sizes only, if a word count moves (`tests/check-sizes.sh`) |

Not touched: `heal`, `merge`, `watch` (no title parsing, no citation rule: grep for `cite`, `prefix` and the Q and T patterns finds nothing in them). `tests/check-refs.sh` needs no edit.

## Verified by

New cases in `tests/smoke.sh`, each on a throwaway board whose `CLAUDE.md` first line the test writes (`v117` or `v114`):

- **`cite v117 mint`**: two questions filed, `cite-as: Q1` and `Q2`, titles bare, the board validates with no `duplicate-cite-as`; two tickets `T1`, `T2`; a PDR and two ADRs mint `PDR1`, `ADR1`, `ADR2` independently.
- **`cite trash and legacy scan`**: Q2 moved to `.trash/` (flat) and one inside a trashed lane: the next question is still Q3; a card titled `Q7: old` with no `cite-as` makes the next one `Q8`.
- **`cite v114 and unreadable stamp`**: the same filings keep the prefixed title and write no `cite-as`. The existing assertions on `Q2: Engine: placement` and `Q5: C:\path` stay as they are: `found-board.sh` writes no `CLAUDE.md` (the app installs it on first open), so a founded throwaway board has no stamp and reads as old.
- **`cite links`**: `Depends on` lines are `- [T1](lanework://…)`; a record's first line is `Question: [Q1](…)`; `frontier.sh` and `read-board.sh` print `T1` / `Q1` before the title.
- **`cite resolve unblocked`**: resolving a ticket with a bare title prints `unblocked T3`, not the title.
- Each new case fails against the scripts as they are today. `tests/check-refs.sh` and `tests/check-sizes.sh` pass. A prose change is read through against `lanework-agent-guide v117` § Frontmatter and § Relations.

## Done when

- On a v117 throwaway board, `file-question.sh`, `file-record.sh` and `file-ticket.sh` write `cite-as` (`Q<n>`, `ADR<n>` / `PDR<n>`, `T<n>`), a title with no prefix, and the board validates clean.
- A citation is never reissued: a trashed card's, or one only in a legacy title prefix, still counts.
- On a v114 board, or with no stamp, the scripts write what they write today.
- `resolve-ticket.sh` prints `unblocked T<n>` for a bare title; `frontier.sh` and `read-board.sh` show the citation.
- Every link template, `writing.md` § Card references and the `plan` and `discovery` references agree on one link-text rule, stated once.
- `tests/smoke.sh` passes whole in a clean worktree.

## Risks

- **Depends on the guide-version reader.** The gate needs `guide_version` from [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8), which also edits `lib.sh` and `writes.md`. Build after it lands; if this builds first it adds that one function and 9e04cdec reuses it.
- **Same script as the supersedes card.** [b0199ddd](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b0199ddd-9102-452e-9ba6-4dd9b4307cc0) (Active) adds `--supersedes` to `file-record.sh` and edits `records.md` § Superseding. Different sections, same files: build after it, not beside it.
- **Mixed-version boards.** The gate exists for them; a board whose stamp cannot be read is treated as old, so a board founded by script and not yet opened in the app (`found-board.sh` writes no `CLAUDE.md`) gets prefixed titles until the app installs its guide.
- **Stale link text on older boards.** Existing `[Q2: One machine…]` text stays as written, as the example shows. Harmless, since the uuid carries identity.
- **A bare title loses the number in tools that ignore `cite-as`** (a plain `ls`, the commit log, an old app). The gate limits it to boards whose app draws the key; `read-board.sh` prints it.
- **Release**: new behavior for the scripts, so a minor bump, the owner's release call.

## Depends on

- [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8): `guide_version` in `lib.sh`, and the `cite-as` line in `writes.md` this card extends.
- [b0199ddd](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b0199ddd-9102-452e-9ba6-4dd9b4307cc0): also edits `file-record.sh` and `records.md`.

## Recommendation

Build it, after 9e04cdec and b0199ddd land: one change in the order `lib.sh`, the three filing scripts, `resolve-ticket.sh` and `frontier.sh`, the templates and prose, then smoke. Medium size, `sonnet` can build it, reviewed against the v117 guide. Nothing here needs the owner: every point above is settled from the guide and the example.
