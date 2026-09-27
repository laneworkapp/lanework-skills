# Format

Spec = the board's own guide (`authority.md`). This page: orientation only.

- Board = folder `<Name>.lanework` of plain dirs + UTF-8 Markdown, rendered live by the Lanework macOS app. No API, nothing to sync: **the files are the board**. Edit them; the app picks up every change.
- **Depth = type**: depth 1 lane, depth 2 card. No type field.
- Folder names = lowercase uuids = permanent identity. Titles live in frontmatter only.
- Every item = folder + `index.md` (YAML frontmatter between `---`, then Markdown body). Cards also hold `attachments/` and `comments/<uuid>/index.md`.
- Board body: above the first `##` = description; below = owner's instruction sheet for agents.
- **App-owned** at board root, never written by you: `CLAUDE.md` + byte-identical `AGENTS.md` (the guide), `.schema/` (schema set + validator), `.gitignore` (seeded), `.log/` (read-only), `.trash/`.
