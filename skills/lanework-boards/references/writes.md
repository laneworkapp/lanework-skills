# Writes

The guide has the full rules. These hold on every board and cost most when missed.

## Every write

- **Stamp it.** `created` / `modified` = `{at, by}`; `by: {name: <you or your role>, kind: agent, model: <model>[, session: "<name>"]}`. **Missing `by` claims the owner wrote it.** Move `at` + `by` together.
- **Stage outside the board, then `mv` in.** App reloads on every fs event and can read a half-written file. A temp left beside a card's `index.md` is relocated into its `attachments/`, not deleted (2026-09-08). After an aborted write, check `attachments/` for strays.
- **Double-quote every string value**: `title: "…"`. A bare `: ` makes a nested mapping and the app refuses the whole card (2026-09-12). Also covers `#`, leading `*&![{`, bare `yes`/`no`/`null`. After writing, parse back: `fm "$f" | yq -e . >/dev/null` (`reading.md`).
- **Stamp lines: rewrite whole, never regex-patch.** Nested braces corrupt. `grep '}}}'` every touched file after.
- **Icons**: `{glyph: <SF Symbol>}`. `color` only when the tint says what the glyph can't.

## Paths

- **Resolve a card's path fresh, in the same command as the write**: `ls "$BOARD"/*/<card-uuid>/index.md`. Cards move lanes between read and write; a stale path plants a **ghost card**.
- **Never `mkdir` a card dir.** If a write needs one, the path is wrong.
- **The Write tool is a ghost machine**: it creates parent dirs, so a stale path mints a duplicate card, and the app remints the stray under a fresh uuid. Prefer shell `mv` guarded by the existence check.
- **Never rename a uuid folder.**
- **Delete = `mv` to `<board>/.trash/`**, never `rm -r`.

## Placing

- Bottom of a lane: max `order` + 1024; top: min − 1024; between: midpoint. Empty lane: 1024.
- Lanes use the same 1024 ladder. Insert by midpoint; no other file changes.

## Comments

- Distinct `created.at` second per comment. Identical seconds scramble thread order.
- Prose (record vs ask, handles, links): `pitlane/references/writing.md`.

## Git

- Boards usually live in a repo, and the board body says how it's committed. Commit your own board writes, with plain messages.
- **Stage exact paths**: the card's `index.md`, the `comments/<uuid>` you wrote. Never a lane dir, a whole card dir (it drags in the owner's unposted `comments/.draft/`), `-A` or `.`.
- Board writes and code changes: separate commits. Shared repo: `git commit --only -- <paths>`, never amend or stash.
