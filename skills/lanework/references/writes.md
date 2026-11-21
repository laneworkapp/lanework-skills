# Writes

The guide has the full rules. These hold on every board and cost most when missed.

## Every write

- **Stamp it**: shape = the guide's § Stamping your work; `by.name` = you or your role. **Missing `by` claims the owner wrote it.** Never sign `anyone`, `shortcuts`, `healer`, `board` or `tracker`: app-reserved (`anyone` is the mention that addresses every human). **Every stamp (`created`, `modified`, `waiting.since`) comes from the clock**, taken in the same command as the write: `now_utc` from `lanework/scripts/lib.sh`, or `date -u +%FT%TZ`. Never type, copy or bump one past another to stay "later" (2026-10-11, 2026-11-10: typed stamps up to 26 min ahead, threads sorted wrong). One deliberate offset: an ask goes 1s after its record (`work/references/writing.md`), as `now_utc 1`.
- **Stage outside the board, then `mv` in.** App reloads on every fs event and can read a half-written file. A temp left beside a card's `index.md` is relocated into its `attachments/`, not deleted (2026-09-08). After an aborted write, check `attachments/` for strays.
- **Double-quote every string value** (guide § Frontmatter: "Quote any `title` containing a colon", "Keep every scalar on one line"). A bare `: ` makes a nested mapping and the app refuses the whole card (2026-09-12). Also covers `#`, leading `*&![{`, bare `yes`/`no`/`null`.
- **Labels and priority**: all `labels` entries; shape, kinds and the built-in `text` kind = the guide's § Frontmatter (`labels`) and `.schema/card.json`. A root `priority:` key is reserved: never written. A root `component:` is no reserved key, just an unknown one: left as written. Write a label with `work/scripts/label-card.sh` (existing card) or `work/scripts/file-card.sh --label` (new card): `Text` or `Text:kind`. By hand, copy an entry's shape from the guide, never from another card (2026-10-02: three cards copied a custom kind's entry shape).
- **Lists and mappings: compact form** (guide § Frontmatter): one flow line up to 120 chars, strings quoted; longer → `key:` over a block, each entry one line where it fits, recursively. Stamps always one line. Other layouts read, but the heal rewrites them.
- **Validate before committing**: `python3 "$BOARD/.schema/bin/lanework-validate.py" <file or board>` → exit 0 **and** no `DEPRECATED` line. No `.schema/` yet: `founding.md` § Validate. Then `work/scripts/lint-stamps.sh <board>` → silent (no stamp over 60s ahead; restamp the named file from the clock).
- **Stamp lines: rewrite whole, never regex-patch.** Nested braces corrupt. Check `}}}` or an unbalanced brace on the stamp lines you wrote only, with `stamp_lines_ok` in `lanework/scripts/lib.sh`; valid copied lines end in `}}}`.
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
- Script: `work/scripts/move-card.sh`.
- **Same lane** = rewrite `order` only; leave `modified` alone.

## Placing

- Ladder: the guide's § Creating a card (1024 steps, midpoint between). Lanes use the same ladder; inserting changes no other file.
- Lane has `card-defaults` → union its `labels` into the new card's yourself, case-insensitively (guide § Frontmatter, lanes): a bare name = free label, a kinded entry = stamped from the board's current `config.labels`. Your own value of a `single` kind wins over the lane's; several lane values of one `single` kind → keep one (lowest `rank`, else the first). The app applies them only to cards it makes. `work/scripts/file-card.sh`, `file-ticket.sh`, `file-question.sh` and `file-record.sh` union them for you (`union_lane_defaults`, then `union_labels`, `lanework/scripts/lib.sh`); a card you write by hand, you union yourself.

## Comments

- Distinct `created.at` second per comment. Identical seconds scramble thread order.
- **Posting never restamps the card.**
- Answering a specific comment → `in-reply-to: <its uuid>`, whoever wrote it: a human's, another agent's, your own. Not only an answer to an ask.
- `cite-as` (a card's display name, unique by convention). **Mint**: scan every card on the board, `.trash/` flat and in trashed lanes included, count both `cite-as: <prefix><n>` and a legacy `<prefix><n>: ` title prefix, take the highest `n` plus one, as late as possible before staging (two sessions can still collide: the validator warns `duplicate-cite-as`, renumber by hand). Prefixes `Q`, `T`, `F`, `ADR`, `PDR`, a counter each; `Map`, `Topic` fixed. Scripts mint Q, T, ADR, PDR (`lib.sh` `next_cite`); a fact by hand. Only where `lib.sh` `cite_enabled` is true (older boards draw no `cite-as`): else keep the `<prefix><n>: ` title. Bare title when minted; never rewrite an existing title. Never carry one into a copy; a move keeps it. Pipeline boards: the board's sheet decides.
- A posted comment is fixed at most for a typo. Otherwise post a follow-up; never rewrite, remove, or move it into `comments/.trash`.
- Prose (record vs ask, handles, links): `work/references/writing.md`.

## Lease

A card's `claimed` key says one session is working it. Custom metadata (guide § Frontmatter: unknown keys): the app keeps it and draws nothing. Script: `scripts/lease.sh`, the only writer of `claimed`.

```yaml
claimed:
  by: {name: claude, kind: agent, model: <model>, session: "<CLAUDE_CODE_SESSION_ID>"}
  until: 2026-11-14T15:30:00Z
```

- **Holder** = the session: `by.session` from `CLAUDE_CODE_SESSION_ID`, never a flag, with no slash, backslash, quote, space, comma or closing brace in it (exit 2): a claim the script could not read back would strand. Only the session id is compared, never `by.name`, so a fixer under its lead's session passes. No session id → no lease. Subagents never stake. One machine; across machines a lease is a hint that lapses by its `until`.
- **Memory is per board folder path**: a copy of a board is another board (its cards never held). A board folder renamed or moved while a lease is live → the session no longer remembers holding the card; lapsed and taken by another session, its next write lands, no **Lease lost** record.
- **Layout**: the compact form (§ Every write). A real session id makes `by` pass 120 characters: the 3-line block above.
- **Length**: 30 min from stake or renewal. A detached timer, started by `stake` with the session's `CLAUDE_PID`, renews every 15 min of elapsed time (counted by waiting, never by `until`), reads the card each minute, and exits when the lease is released or lost, or `CLAUDE_PID` is gone. One memory file and one timer per card: a session may hold any number.
- **Stake**: write, wait 1 s, read back. Another session's `by` → back off. A lease this session already holds renews.
- **Clock guard**: `until` missing, unreadable or over 35 min ahead of now = no lease. Staking over one posts **Lease ignored**. A past `until` is lapsed, not guarded.
- **Takeover** of a lapsed lease this session never staked (one it staked is lost): post the notice, wait 2 min, read again. `until` or `by` changed → back off; unchanged → stake. A live holder's timer renews on a notice naming it. So `stake` over a lapsed lease **blocks 2 min**: give the call a timeout over that. Before working, read the thread's latest START or **Lease lost** record (`stake` prints its first line): it may point at work to keep.
- **Lapsed and still yours** (a sleep): renew and carry on.
- **Lost** (another session's `by`, or `claimed` gone, on a card this session staked): stop. One **Lease lost** record naming the work left in place (branch, directory, files touched at stake's directory), then never write that card again. The work stays; the new holder decides.
- **Check before every card write**: `lease.sh check` → `held` (a lapsed own lease renewed, a dead timer restarted), `lost`, or `never-held` (free, or another's, and never staked here: not blocked, nothing written).
- **Release** in the holder's closing write (done, at a gate, given up): `claimed` deleted, timer stopped. Another session's live claim: exit 1; `lease.sh list <board>` shows whether it lapsed (take a lapsed one with `stake`). `--force` only on the owner's word: posts **Lease released by force**.
- **Writes**: every stake, renewal and release restamps `modified` whole with the writer's `by`. A lease write lands only on the card as it read it, and otherwise reads again. That narrows the window against another writer and does not close it: no lock is shared with the app or other writers. A write across volumes stages a `.lease-write.*.lanework-tmp` at the board root, removed on every failure path and on TERM, INT or HUP; a killed write's file is swept by the next lease write on the board. A release that finds another session's claim exits 1, and the next lease call records the loss. Never committed alone: it rides with the holder's next board commit. A merge keeps the side with the later `modified`, as for any state.
- **Exit codes**: 0 ok (`check`: held); 1 refused (held by another, backed off, or nothing to renew); 2 usage, no model, no session id, no `CLAUDE_PID` (`stake`), a session id with a character above, or not one card with that uuid; 3 lost; 4 `check`: never held.

Records, fixed wording (match keys for the timer and lints; never an ask, no handle):

- `**Lease lost**: session <session> no longer holds this card; session <other> does. Work left in place: branch <b>, directory <d>, files touched: <list>. This session writes this card no more.` (`<other>` is `none` when `claimed` was removed; the opening is `lib.sh` `LEASE_LOST_PREFIX`)
- `**Takeover notice**: session <taker> takes this card from session <holder> at <time> unless the lease is renewed first. It lapsed at <until>.`
- `**Lease ignored**: until <x> was over 35 minutes ahead of <now>, so the card was staked as free.` (`<x>` is `none` when `until` is missing)
- `**Lease released by force** on the owner's word: session <s> held it until <until>.`

## Tracker keys

The board's `remote` (incl. `cadence`), a card's `remote`, a comment's `remote`, a lane's `remote-state`, a `labels` entry of kind `state`, `.tracker.nosync/`: left by builds that ran tracker sync. No build runs it now. **Never write, edit or copy one.** Keys a board already carries stay byte for byte. The board's `.gitignore` no longer lists `.tracker.nosync/`: never stage it.

## Healing

- **When**: the validator fails or prints `DEPRECATED` on files you didn't write; a guide-version move retired a spelling; a board worked without the app. Heal before fixing by hand.
- **Which copy**: the board's `.schema/bin/lanework-heal.py` when present (it wins: the app ships it), else `scripts/heal-board.py`. The skill's copy refuses to run where the board ships one.
- **Run**: `python3 scripts/heal-board.py <board>` → read the repair list (dry run, writes nothing) → `--apply --name <you> --model <model>` → validate. Commit the heal on its own.
- **Dry run lists `stale-label` or `single-kind`** (board heal H13 / H14: they re-apply the board's definitions to existing cards) → `--apply` only on the owner's ask. The app never re-stamps cards when a definition changes.
- **Repairs**: label stamps vs the board's `config.labels`, extra entries of a `single` kind, retired label and definition spellings, a reserved root `priority:` moved into `labels`, bare stamps, unquoted or multi-line titles, flat `icon`/`iconColor`, `modified-by`, non-compact layouts.
- **Whole board to currency** (lane bodies, pipeline sheet): the `heal` skill.
- **Writes**: no `modified` restamp: a heal is upkeep, like the app's. A repair that drops a fact posts a record on the card, signed as you, before the file changes. `skip` lines = left for you by hand. Never `.trash/`, a foreign entry or an unknown key. A missing `by` stays missing: it means the owner.

## Git

- Boards usually live in a repo, and the board body says how it's committed. Commit your own board writes, with plain messages.
- **Stage exact paths**: the card's `index.md`, the `comments/<uuid>` you wrote. Never a lane dir, a whole card dir (it drags in the owner's unposted `comments/.draft/`), `-A` or `.`.
- Board writes and code changes: separate commits. Shared repo: `git commit --only -- <paths>`, never amend or stash.
- Script: `work/scripts/commit-board.sh` (named paths only, under a lock; pushes only with `--push`).
- **Merge conflicts on a board**: never hand-edit the markers. The `merge` skill resolves them (`merge/references/rules.md`).
