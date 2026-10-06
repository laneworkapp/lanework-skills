# Writes

The guide has the full rules. These hold on every board and cost most when missed.

## Every write

- **Stamp it**: shape = the guide's § Stamping your work; `by.name` = you or your role. **Missing `by` claims the owner wrote it.** Never sign `shortcuts`, `healer` or `tracker`: app-reserved.
- **Stage outside the board, then `mv` in.** App reloads on every fs event and can read a half-written file. A temp left beside a card's `index.md` is relocated into its `attachments/`, not deleted (2026-09-08). After an aborted write, check `attachments/` for strays.
- **Double-quote every string value** (guide § Frontmatter: "Quote any `title` containing a colon", "Keep every scalar on one line"). A bare `: ` makes a nested mapping and the app refuses the whole card (2026-09-12). Also covers `#`, leading `*&![{`, bare `yes`/`no`/`null`.
- **Labels, priority and component**: all `labels` entries; shape, kinds and the built-in `text` kind = the guide's § Frontmatter (`labels`) and `.schema/card.json`. A root `priority:` / `component:` key is reserved: never written. Copy an entry's shape from the guide, never from another card (2026-10-02: three cards copied a custom kind's entry shape).
- **Validate before committing**: `python3 "$BOARD/.schema/bin/lanework-validate.py" <file or board>` → exit 0 **and** no `DEPRECATED` line. No `.schema/` yet: `founding.md` § Validate.
- **Stamp lines: rewrite whole, never regex-patch.** Nested braces corrupt. `grep '}}}'` every touched file after.
- **Icons, colors**: the guide's § Colors and icons. `color` only when the tint says what the glyph can't.

## Paths

- **Resolve a card's path fresh, in the same command as the write**: `ls "$BOARD"/*/<card-uuid>/index.md`. Cards move lanes between read and write; a stale path plants a **ghost card**.
- **Never `mkdir` into an existing card's path.** If a write needs one, the path is wrong. A new card = the whole folder staged outside, then one `mv` in.
- **The Write tool is a ghost machine**: it creates parent dirs, so a stale path mints a duplicate card, and the app remints the stray under a fresh uuid. Prefer shell `mv` guarded by the existence check.
- **Never rename a uuid folder.**
- **Delete = `mv` to `<board>/.trash/`**, never `rm -r` (guide § Editing and deleting). Restamp `modified` whole (the trash sorts by it); leave `order` for the restore.

## Moving

Guide § Moving and reordering has the full rules.

- **Another lane** = `mv` one card folder by name (never a glob: it takes the lane's own `index.md`), a fresh `order`, and `modified` rewritten whole. **A bare `mv` reads as the owner's move.**
- **Same lane** = rewrite `order` only; leave `modified` alone.

## Placing

- Ladder: the guide's § Creating a card (1024 steps, midpoint between). Lanes use the same ladder; inserting changes no other file.
- Lane has `card-defaults` → union its labels into the new card's `labels` yourself (guide § Frontmatter, lanes). The app applies them only to cards it makes.

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

## Healing

- **When**: the validator fails or prints `DEPRECATED` on files you didn't write; a guide-version move retired a spelling; a board worked without the app. Heal before fixing by hand.
- **Which copy**: the board's `.schema/bin/lanework-heal.py` when present (it wins: the app ships it), else `scripts/heal-board.py`. The skill's copy refuses to run where the board ships one.
- **Run**: `python3 scripts/heal-board.py <board>` → read the repair list (dry run, writes nothing) → `--apply --name <you> --model <model>` → validate. Commit the heal on its own.
- **Repairs**: label stamps vs the board's `config.labels`, extra entries of a `single` kind, retired label and definition spellings, reserved root `priority:`/`component:` keys moved into `labels`, bare stamps, unquoted or multi-line titles, flat `icon`/`iconColor`, `modified-by`. Machine-level `default-labels` only via `--global <config index.md>`.
- **Writes**: no `modified` restamp: a heal is upkeep, like the app's. A repair that drops a fact posts a record on the card, signed as you, before the file changes. `skip` lines = left for you by hand. Never `.trash/`, a foreign entry or an unknown key. A missing `by` stays missing: it means the owner.

## Git

- Boards usually live in a repo, and the board body says how it's committed. Commit your own board writes, with plain messages.
- **Stage exact paths**: the card's `index.md`, the `comments/<uuid>` you wrote. Never a lane dir, a whole card dir (it drags in the owner's unposted `comments/.draft/`), `-A` or `.`.
- Board writes and code changes: separate commits. Shared repo: `git commit --only -- <paths>`, never amend or stash.
