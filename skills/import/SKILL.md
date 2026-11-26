---
name: import
description: "Converts another tool's board into Lanework CSV, the one format the Lanework app imports (File > Import Board...). Two scripts: a Trello JSON export, and an Obsidian Kanban plugin Markdown board. Use when the user wants to bring a Trello board or an Obsidian Kanban board into Lanework, 'import my Trello board', 'convert this Kanban note'. Writes a new folder; the person opens it in the app. Never touches an existing board."
---

# Import

The app reads one format: Lanework CSV (`board.csv`, plus `assets/`). Other tools come across by a script here. Output goes to a NEW folder; the person runs **File > Import Board...** on it. Never write into a `.lanework` board.

**Base**: `lanework` (what a board is). Format contract: the Lanework docs, reference/csv.

## Flow

1. Pick the script by input:

| input | script |
|---|---|
| Trello JSON (board menu > Print, export and share > Export as JSON) | `scripts/trello-to-lanework-csv.py` |
| Obsidian Kanban plugin `.md` file (+ its vault folder if known) | `scripts/obsidian-kanban-to-lanework-csv.py` |
| Trello CSV, other tools | none: say so, never improvise a converter |

2. Pick a fresh `--out` folder (not existing, or empty). Non-empty → exit 2, nothing written.
3. Run with `python3`. Add flags only when the person wants them (table below).
4. Relay the summary: counts carried, what was left out and why, what could not be fetched.
5. Tell the person: open the app, **File > Import Board...**, choose the folder. Fix reported faults in the CSV or rerun; never hand-edit around a fault silently.

## Usage

```
python3 scripts/trello-to-lanework-csv.py <export.json> --out <folder> [--include-archived] [--attachments] [--max-attachment-bytes N]
python3 scripts/obsidian-kanban-to-lanework-csv.py <board.md> --out <folder> [--vault <vault folder>] [--include-archive] [--max-asset-bytes N]
```

| flag | when |
|---|---|
| `--include-archived` / `--include-archive` | person wants archived lists/cards, or the Archive section |
| `--attachments` (Trello) | person wants uploaded files fetched. Public URLs only, no login sent; ones needing a login stay links in the card and are listed. Ask first: it makes network requests |
| `--vault` (Obsidian) | linked notes become card bodies, embedded pictures become attachments. Give it whenever the vault is known. Nothing outside the vault is read |

Exit: 0 ok, 2 bad input or usage (read the message), 1 failure.

## Topics

| topic | file |
|---|---|
| field mapping, what is carried, what is left out, ids, limits | `references/mapping.md` |
