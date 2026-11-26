# Import mapping

Both scripts: Python 3 standard library, no prompts, write only the columns used, row order is card order (no `order`). Ids: Trello ids kept as `uuid`; Obsidian gets `b1`, `l1`, `c1`, `a1`. The app mints real ids.

## Trello

| Trello | Lanework |
|---|---|
| board name | board `title` |
| list, by `pos` | lane |
| card, by `pos` | card; `desc` → body |
| label | `labels`, plain text label of its name, colour when unnamed; `;` → `,`, `:` → ` - ` |
| `due`, `start` | `due`, `start` (UTC timestamp) |
| `commentCard` actions, oldest first | comment rows; body first line `**Name**`; `created` = its date |
| checklists | task list at the end of the body, checked items checked |
| attachment that is a link | `**Links**` list in the body |
| uploaded attachment | with `--attachments`: file in `assets/`, attachment row; else (or on failure) a link in the body |

Left out, counted in the summary: archived lists (and their cards) and archived cards unless `--include-archived`; members, votes, stickers, covers, custom fields, Power-Up data, activity other than comments.

`--attachments`: one HTTPS GET per uploaded attachment URL already in the export, no credentials, 20 s timeout, size cap (`--max-attachment-bytes`, 25 MiB), redirects must stay https, file names reduced to one safe segment inside `assets/`. Trello's own upload URLs usually need a login: expect them in the "could not be fetched" list.

## Obsidian Kanban

| Kanban file | Lanework |
|---|---|
| file name | board `title` |
| `## ` heading | lane |
| `- [ ]` / `- [x]` item | card; first line = title (tags, dates removed), indented lines = body |
| `#tag` anywhere in the card | `labels`, plain text |
| `@{YYYY-MM-DD}` (first real date) | `due`; an unreal date stays text, counted |
| `[[Note]]` alone as the title, with `--vault` | body = that note's text (frontmatter dropped), title = note name or alias |
| `![[shot.png]]`, with `--vault` | file copied to `assets/`, attachment row on the card, embed removed from the text |

Left out, counted: items after `***` / under the plugin's `## Archive` unless `--include-archive`; the `%% kanban:settings` block; frontmatter; the checked state (a checked card keeps its place). Other plugins' syntax stays as written in the card text.

Note resolution: search the vault for a unique `Note.md` (path suffix allowed, exact case first). Missing or ambiguous → link stays text, counted. Without `--vault`, links and embeds stay text, counted.

Confinement: every vault path goes through `realpath` and must lie inside the vault's realpath. A symlink that leaves the vault, a `..` or absolute target → refused, counted, never read. Hidden folders (`.obsidian`, `.trash`) are not searched.
