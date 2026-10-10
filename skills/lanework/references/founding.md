# Founding

## Warranted?

Usually not: a program card with child cards on an existing board carries weeks of work, and every extra board costs readers a "which board?". Found one only when it has its own **lane semantics**, its own **instruction sheet**, or its own **audience**. Unsure → ask the owner in one sentence.

## Found

Path: `<repo root>/<folder>/<Name>.lanework` (machine-level: `~/<folder>/`), folder per `finding.md` (new board).

```bash
scripts/found-board.sh "<path>/<Name>.lanework" --index <template> --lanes <lanes> [--var key=value]... [--labels <kind>,...] --model <your model>
```

- Pipeline: `--index templates/pipeline-index.md --var project=<Project> --var verified="<gate command>" --lanes templates/pipeline-lanes.md`.
- Other kinds: `templates/design-loop-lanes.md` or `templates/datapoint-lanes.md`, plus an index filled in from `templates/index.md`. Custom lanes: same table format. Kinds: `board-kinds.md`.
- **Label kinds**: offer the lane set's default (`board-kinds.md`) and the rest of the catalog in one line (priority, component, type, size, platform, release, epic), then pass `--labels <kinds>`. Rows: `templates/label-kinds.md`. Unknown kind → exit 2, nothing written. None wanted → omit the flag.
- **Lane bodies** (custom lanes too): 2nd sentence = who acts + what starts it (tables: `board-kinds.md`). A body forbidding agents an action also says what they may do.
- Mints the board `id` (host of every `lanework://` link; never changes), stamps, quotes titles, and stages every write outside the board.

Index body: description above the first `##`; instruction sheet below it. The sheet holds whatever an agent would otherwise get wrong: gates and who holds them, the card bar, what verified means, blast radius, repo conduct. Nothing the guide says. Per-board process lives there, never in a file of its own.

Keys and value shapes (board, lane, `config`, `icon`, `background`, `group`, `filter`): the guide's § Frontmatter and `.schema/board.json`, `.schema/lane.json`; none restated here. The script writes the board's required keys.

## Don't write

The app heals these in on every open. Never write them, never copy them from another board (a copied `.schema/` carries a wrong version marker; a copied board duplicates the `id`):

`CLAUDE.md`, `AGENTS.md`, `.schema/`, `.gitignore` (your own exclusions go above the board folder), `.log/`, `.trash/`.

## Validate

No `.schema/` yet → borrow another board's:

```bash
python3 "<other>.lanework/.schema/bin/lanework-validate.py" "<new>.lanework"
```

Pass = exit 0 **and** no `DEPRECATED` line (deprecated still exits 0). `FAIL` → exit 1. Exit 2 = usage error or zero documents, never a pass. No other board on the machine → check the YAML parses (`reading.md`) and let the first open report.

## Commit, open, commit

1. `git add "<board>"`, read `git status --short -- "<board>"`, then commit "Found the <Name> board".
2. Open once in the app (Finder double-click, or File → Open). Lanes appear in order, empty.
3. Commit what the open healed in: guide, `.schema/`, `.gitignore` (and the `id` if you left it out). `.log/` stays ignored.

File the first cards per `writes.md`, each with a founding comment saying why it exists.
