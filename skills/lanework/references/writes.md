# Writes

The guide has the full rules. These hold on every board and cost most when missed.

## Every write

- **Stamp it.** `created` / `modified` = `{at, by}`; `by: {name: <you or your role>, kind: agent, model: <model>[, session: "<name>"]}`. **Missing `by` claims the owner wrote it.** Move `at` + `by` together. Never sign `shortcuts`, `healer` or `tracker`: app-reserved.
- **Stage outside the board, then `mv` in.** App reloads on every fs event and can read a half-written file. A temp left beside a card's `index.md` is relocated into its `attachments/`, not deleted (2026-09-08). After an aborted write, check `attachments/` for strays.
- **Double-quote every string value**: `title: "…"`. A bare `: ` makes a nested mapping and the app refuses the whole card (2026-09-12). Also covers `#`, leading `*&![{`, bare `yes`/`no`/`null`. Every scalar on one line; a title never carries a line break.
- **Priority, component = root keys, never `labels` entries**: `priority: {text: "Medium", rank: 2}`. A `labels` entry of kind `priority`/`component` is not read: drawn as a stray chip, skipped by grouping and filters. A built-in kind is never stamped in `labels` (2026-10-02: three cards copied a custom kind's entry shape).
- **Validate before committing**: `python3 "$BOARD/.schema/bin/lanework-validate.py" <file or board>` → exit 0 **and** no `DEPRECATED` line. No `.schema/` yet: `founding.md` § Validate.
- **Stamp lines: rewrite whole, never regex-patch.** Nested braces corrupt. `grep '}}}'` every touched file after.
- **Icons**: `{glyph: <SF Symbol>}`. `color` only when the tint says what the glyph can't.

## Paths

- **Resolve a card's path fresh, in the same command as the write**: `ls "$BOARD"/*/<card-uuid>/index.md`. Cards move lanes between read and write; a stale path plants a **ghost card**.
- **Never `mkdir` into an existing card's path.** If a write needs one, the path is wrong. A new card = the whole folder staged outside, then one `mv` in.
- **The Write tool is a ghost machine**: it creates parent dirs, so a stale path mints a duplicate card, and the app remints the stray under a fresh uuid. Prefer shell `mv` guarded by the existence check.
- **Never rename a uuid folder.**
- **Delete = `mv` to `<board>/.trash/`**, never `rm -r`. Restamp `modified` whole (the trash sorts by it); leave `order` for the restore.

## Moving

- **Another lane** = `mv` one card folder by name (never a glob: it takes the lane's own `index.md`), a fresh `order`, and `modified` rewritten whole. **A bare `mv` reads as the owner's move.**
- **Same lane** = rewrite `order` only; leave `modified` alone.

## Placing

- Bottom of a lane: max `order` + 1024; top: min − 1024; between: midpoint. Empty lane: 1024.
- Lanes use the same 1024 ladder. Insert by midpoint; no other file changes.
- Lane has `card-defaults` → union its labels into the new card's `labels` yourself. The app applies them only to cards it makes.

## Comments

- Distinct `created.at` second per comment. Identical seconds scramble thread order.
- **Posting never restamps the card.**
- Answering a specific comment → `in-reply-to: <its uuid>`.
- A posted comment is fixed at most for a typo. Otherwise post a follow-up; never rewrite, remove, or move it into `comments/.trash`.
- Prose (record vs ask, handles, links): `pitlane/references/writing.md`.

## Tracker boards

Tracker keys: the board's `remote` (incl. `cadence`), a card's `remote`, a comment's `remote`, a lane's `remote-state`, a `labels` entry of kind `state`, `.tracker.nosync/`. Whether an engine runs: the board's guide says.

- **Engine off** (guide: "This build runs no tracker engine", the release build): every tracker key is reserved. **Never write, edit or copy one**; don't add a `remote` to bind a board. Keys a board already carries stay byte for byte.
- **Engine on** (guide describes two-way sync): the engine's alone, never written, edited or copied: a card's `remote`, its `state` label, any comment's `remote`, `.tracker.nosync/`. Absent card `remote` = unpublished: hand-writing or copying one claims a ticket that isn't the card's. Yours to hand-write: the board's `remote` and a lane's `remote-state`.
  - **Your writes push, like anyone's.** Filing a card publishes an issue. A move into a lane with a `remote-state`, or trash, changes the issue's state. A body or title edit edits the issue.
  - **Every comment on a published card is posted to the issue verbatim, as the token's user, and emails the repo's watchers.** `@handle` mentions that tracker user. Deleting it here leaves it there. Write each one as public.

## Git

- Boards usually live in a repo, and the board body says how it's committed. Commit your own board writes, with plain messages.
- **Stage exact paths**: the card's `index.md`, the `comments/<uuid>` you wrote. Never a lane dir, a whole card dir (it drags in the owner's unposted `comments/.draft/`), `-A` or `.`.
- Board writes and code changes: separate commits. Shared repo: `git commit --only -- <paths>`, never amend or stash.
