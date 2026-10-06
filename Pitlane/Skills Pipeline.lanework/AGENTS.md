<!-- lanework-agent-guide v82 — created and kept up to date by the Lanework app. This guide is written at two names, CLAUDE.md and AGENTS.md, kept byte-identical. Don't edit either file: both are overwritten on upgrades. Board-specific instructions live in this board's own index.md body, below its first ## heading. -->

# This folder is a Lanework kanban board

Plain folders and Markdown, rendered live by the Lanework app. You can (and
should) manipulate the board by editing files directly — while the board is
open, the app picks up every filesystem change automatically. There is
nothing to sync and no API to call: the files are the board.

**Read this board's `index.md` body before doing anything else**: everything
below its first `##` heading is the owner's instruction sheet for agents on
this board; above it is the board's description. A body with no `##`
heading at all is entirely description.

**Ready-made skills.** Four agent skills for working boards are published at https://github.com/laneworkapp/lanework-skills: `lanework` (what a board is, reading one, founding a new one by hand), `pitlane` (sweeping a board and farming its work to subagents), `pitwall` (a standing watch on one or more boards) and `discovery` (a guided examination of a project's problem and domain space, run on its own board). Install by cloning the repo and linking each folder under its `skills/` into `~/.claude/skills/<name>`, or install the whole repo as the Claude Code plugin `lanework`. The skills are written against this guide's version line; wherever a skill and this guide disagree, this guide wins.

## Layout

```
<board>/                     this folder (the board)
├── index.md                 board title + settings; body = description, then agent instructions below its first ##
├── CLAUDE.md                this guide (app-maintained)
├── AGENTS.md                byte-identical twin of CLAUDE.md (app-maintained)
├── .trash/                  deleted cards and lanes (app-managed — see Deleting)
├── .log/                    the board's activity log, one file per UTC day (app-managed, read-only for you)
├── .schema/                 the board's JSON Schema, app-managed — see Frontmatter
│   └── bin/lanework-validate.py   validates a file or the board against it — see Frontmatter
├── <uuid>/                  a LANE
│   ├── index.md             lane title + order; body = lane notes/policy
│   ├── <uuid>/              a CARD
│   │   ├── index.md         card title + order; body = the card's content
│   │   ├── attachments/     the card's files, one uuid folder each
│   │   └── comments/        the card's comment thread (see Comments)
│   └── <uuid>/              another card
└── <uuid>/                  another lane
```

- Depth alone defines meaning: depth 1 = lane, depth 2 = card. There is no
  type field.
- Folder names are lowercase UUIDs and are the item's permanent identity.
  **Never rename a folder.** Titles live in frontmatter only.
- Every `index.md` is YAML frontmatter between `---` lines, then a Markdown
  body. Files are plain UTF-8, **no BOM**; keep each file's existing line
  endings, and end new files with LF.

## Reading the board

- Lanes run left→right by ascending `order`; cards top→bottom by ascending
  `order` within their lane. Ties break by folder name. An item with no
  `order` sorts after every item that has one — see Creating a card.
- Lane titles carry the workflow semantics (e.g. To Do → In Progress →
  Done). Read the board's and lanes' index.md bodies for descriptions and
  per-lane policy before deciding where a card belongs.
- `.trash/` holds deleted cards and lanes; everything else at board root that isn't a
  UUID-named folder is not part of the board's content.
- `.log/` is the board's **activity log** — app-managed, and **read-only for
  you**: never append to it, never edit it, never commit it. It is *off*
  unless `config.logging` (below) or this machine's own app-wide default
  turns it on, the app never writes one on a board in iCloud Drive (logs are
  local — a `.log/` that arrives with such a board is left exactly as found,
  never appended to and never deleted), and it holds one plain-text file per
  UTC day, `YYYY-MM-DD.log`. Grep it when
  you need to know what happened and when. Line 1 of each file is
  `# lanework-board-log v1`; every line after it reads
  `<UTC stamp> <level> <kind> <sentence>`, optionally followed by
  ` | k=v k=v` — `by=` is the changed item's stamp identity rendered
  `name/kind/model` (a missing stamp is the owner, so `by=owner`) and
  `via=` is `app` or `disk`. `<kind>` is a dotted token (`card.move`,
  `comment.post`, `board.open`), so `grep ' card.move '` is the usual way
  in. Any value carrying whitespace, `"`, `|` or `\` is double-quoted with
  `\"`, `\\` and `\n` as the only escapes, so a line is always exactly one
  line. Your own edits appear in it like anyone else's — attributed from
  the stamp you wrote — which is one more reason to stamp `by` properly.
- Refer to an item in prose as a markdown link,
  `[<its title>](lanework://<board-id>/<item-id>)` — the board's `id` from its
  `index.md`, then the card's or lane's folder name, then a comment's for a
  comment. Write the link syntax, not a bare uuid or a bare URL: the link form
  is what renders, survives every move and rename, and is clickable in
  terminals too. **Every card that prose names gets its link, every time** —
  in a comment or a card body, by title or by its short id (the uuid's first
  eight characters): a bare `572e3b41` is a search the reader has to run,
  `[572e3b41](lanework://…)` is a click.

## Frontmatter

**Everything below is stated machine-readably in `.schema/`, at the board
root.** Seven JSON Schema files (draft 2020-12), one per document — `board`,
`lane`, `card`, `comment`, `attachment`, this machine's own config document
— plus `common.json`, whose `$defs` hold the value families they all share
(a stamp, an identity, an icon, a label, a kind). They are generated from the
app's own reading code, so a key here and its entry there cannot drift.
The set is **lenient**: it describes what the app *reads*, retired spellings
included, and every retired branch carries `deprecated: true` — which is the
machine-readable "do not write this". Validating what you wrote and finding
nothing deprecated in it is the check this folder is for.
**The folder holds the validator too**: `python3 .schema/bin/lanework-validate.py <path>`
runs it with nothing installed that `git` did not already need — a path may
be one `index.md` (checked alone, against the schema its position picks) or
a whole board (walked, `.trash/` included and `comments/.draft` excluded).
A failing document prints one line naming the rule and the run exits 1; a
`DEPRECATED` line names the retired branch a value matched and the run
still exits 0; a clean file prints nothing, while a board walk always
ends with a population summary, and a `WARN` line (a dangling `hero` or
`in-reply-to`) prints and fails nothing. Exit 0 with no `DEPRECATED`
line is the check to make before committing a hand-written file.
`.schema/VERSION` is the set's own version marker, `lanework-schema vN` on
line 1 — the same shebang the guide's own first line carries, and its own
counter, unrelated to `schema: 1`. The script carries one of its own,
`# lanework-validate vN` on its line 2. **The folder is the app's**: the
set is rewritten whenever its marker is older than the app's, the script
alone whenever its own is, never edited by you, and — like this guide — it
belongs in git on a board that lives in a repository.

All levels: `schema` (always `1`; **required at the board's own `index.md`**,
optional below it — a lane or card without one is read as schema 1), `title`
(optional — an item without one renders as untitled, so give cards real
titles), `created` and `modified` (**mappings** — see Stamping your work
below), and `icon` (**a mapping** — the symbol and its tint; see Colors and
icons below). Lanes and cards may additionally set `background` (**a mapping**,
`{color: …}` — see Colors and icons below) — an edge
accent, a band along a lane's top and a stripe down a card's left side. **Not
the board's**: a `background` at the board root has no reading at all, so
writing one there paints nothing (one already in a file is left exactly as
written, like any key the app does not read). Lanes and cards may set `order`
(a number; floats are fine) — **optional, and the way to control position**:
an item without one goes last. Lanes may set `width` (integer ≥ 1, multiplier
of the standard lane width) and `collapsed` (`true` folds the lane to a slim
strip in the app; its cards are still there, just not drawn). **To expand a
lane, remove the `collapsed` key** rather than writing `collapsed: false` —
an absent key is the default, and the app removes it too. A lane's `width`
rides along untouched while it is folded.

Lanes may set `group` — how the lane's cards are sectioned on screen —
as a mapping with two subkeys, always written together: `group: {by:
modified, direction: descending}`. `by` is `modified`, `created`,
`due`, `priority` or `component`. The first three read as day buckets
and draw newest section first (`due`'s undated cards fall into a
trailing "No due date" section). `priority` instead sections on the
stamped `rank` of the card's own `labels` entry of kind `priority`
(below the card-key paragraph), the lowest rank where a card carries
several — every rank-1 card in the topmost section, rank 2 next —
labelling each section with the `text` of its own first card's
priority. A priority with no readable rank has no section of its
own: it falls, with a card that has no priority at all, into a
trailing "No priority" section. No definition is consulted, so this
works on a board that defines no `priority` kind. `component`
sections by the card's `labels` entry of kind `component`
instead — freeform, so there is no roster to order by;
sections are the distinct component values that actually occur,
ordered **alphabetical case-insensitive**, labelled with the
**first-seen spelling** of each case-insensitive group (the first card,
in the lane's own order, to carry it); a componentless card falls into
a trailing "No component" section. `direction` is `ascending` or
`descending` (today's shipped, unlabeled default): for the three date
`by`s that is oldest/newest section first, and for `priority` it is
lowest/highest priority first — `descending` always means "the
reading a person would call *first*", whichever `by` is active, not
literally "biggest number first" (a lower `rank` is a higher
priority). For `component` there is no rank to invert:
`descending` draws A→Z and `ascending` flips to Z→A, the literal
dictionary reading, since a freeform value has no "prominence" for
the words to mean anything other than themselves. Under `modified`
and `created` this is presentation only — nothing about a card's
own file changes because a lane groups, and a drag only ever
changes a card's `order`, exactly as an ungrouped lane's does. Under
`priority`, `component` and `due` **a drop into a section assigns
that section's value to the card**: it writes the flattened `labels`
entry of that kind in place of any the card had, or the bare `due`
day, exactly as the card window's own rows do, and a drop under the
trailing no-value section removes the card's entries of that kind (or
its `due`); one undo puts the rank and the value back together. Direction only reorders sections
against each other; the rank order cards keep within one section
never changes, and the undated/no-priority/no-component tail stays
last either way. Full words are canonical for `direction`;
`asc`/`desc` read leniently as synonyms. Absent, `none`, or any `by`
this version doesn't recognize all read as no grouping, and an
unrecognized `by` or `direction` is left exactly as written rather
than corrected — a board that visits a later version's richer roster
keeps its own setting when it comes home. The lane menu's Group By
submenu writes this key — its own picker sets `by`, and the
Direction picker beneath it, shown once the lane actually groups,
sets `direction` alongside it — and **the two-subkey mapping is
the only shape to write**: a bare `group: modified` or a `by`-only
map is legal to write but not the canonical one.

Boards written before this key existed carry `group-by` instead — a
bare `group-by: modified`, or a `group-by: {by: …}` mapping with or
without `direction`. Both spellings still read (the bare scalar
coerces to `by`, the mapping's own `direction` if any), and the app
folds every legacy shape into the canonical `group: {by: …, direction:
…}` — direction made explicit — the next time it rewrites that lane's
own `index.md`, for any reason at all, dropping `group-by` on the way.
But **write `group`**: the retired spelling is kept readable for
convenience while boards in the wild catch up, not forever.

Lanes may set `filter` — a **list** of clause maps narrowing which of
the lane's cards show, `filter: [{by: modified, op: older, value: 1d},
{by: label, op: equal, value: done}]`. A card shows only if it matches
**every** clause (AND). Date clauses: `by` is `modified`, `created` or
`due`; `op` is `older` or `newer`; `value` is a duration `Nm`/`Nh`/
`Nd`/`Nw` (`30m`, `12h`, `1d`, `2w`). Day-and-up units (`Nd`, `Nw`)
anchor to local `startOfDay` — the same day buckets `group` draws:
`newer` than `Nd` means the card's day falls within the last N
day-buckets, today counting as the first; `older` is the exact
complement, and `Nw` is seven day-buckets. Sub-day units (`Nm`, `Nh`)
instead measure back from now as a rolling instant, unchanged.
`modified`/`created` compare their own stamp against whichever
threshold the unit picks; `due` compares its own local day the same
way, and an undated `due` matches neither `older` nor `newer`.
Label clauses: `by: label`, `op` is `equal` or `not-equal`, `value` is
a label name, matched case-insensitively; `not-equal` also matches a
card with no labels at all. Priority clauses: `by: priority`, the
identical `equal`/`not-equal` grammar, matching the card's `labels`
entry of kind `priority` (its lowest-ranked, where it carries
several). Component clauses: `by: component`, that grammar once more,
against its entry of kind `component`. **All three match the stamped
`text`** and consult no vocabulary at all: there is nothing for a
value to be "unrecognized" against, so `not-equal` matches any card
that carries no such value.
Waiting clauses: `by: waiting`, `op` is `equal` or `not-equal`,
`value` is `me` or a literal handle. `me` means this machine's own
human; `human`, `operator` and an absent `for` all count as that same
human too. `not-equal` matches a card carrying no `waiting` at all,
the same no-value rule as `label`'s restated for this one flag.
`author` is not yet a usable `by` — identity matching is
deferred, and the waiting clause above does not lift that: `waiting.for`
is one stamped string, `created.by`/`modified.by` a stamped identity
mapping, a different question this clause never touches. This is
presentation only, as `group` is under `modified` and `created`:
a filtered-out card is hidden, never touched, and it composes with
search as an intersection — visible means it survives both. **Lenient
per clause**: a clause this build cannot read — an unknown `by` or
`op`, a `value` with no reading — is simply skipped and the rest of the
list still applies; an empty or fully-malformed list filters nothing.
Unknown keys inside one clause are preserved and ignored. Two controls
touch this key today: the lane menu's Filter submenu writes one of its
four date presets onto it, and View ▸ Waiting on Me applies a transient
`by: waiting` clause across every lane without writing anything at all.
Every other clause shape, and a `waiting` clause you want saved on a
lane rather than toggled, remains hand- or agent-written.
A `by: label` clause reads a label entry's own `text` and never its
kind, so a clause cannot name the kind an entry belongs to: `{by:
label, value: High}` matches a card whose priority is High as well
as one carrying a free label spelled `High`. Use `by: priority` to
mean the priority alone.

Lanes may also set `card-defaults` — a mapping of what a fresh card born
into that lane starts with, one subkey today: `card-defaults: {labels:
[feature-idea]}`. Applied once, at the moment the card is created — never
on a move, a paste, or a duplicate, so removing a stamped-in label later
sticks and editing the lane's defaults never reaches back into a card
already born. The app's own card-making paths apply it for you; when you
file a card straight onto disk, stamp the lane's default labels into your
new card's own `labels` yourself, unioned in, case-insensitively, with
whatever else you write (`labels`'s own grammar, below). No control in the
app writes this key — writing it by hand or by agent is how a lane's
defaults get set.

The board's own `index.md` also carries `id` — a lowercase UUID that is the
board's identity, written by the app the first time it opens a board without
one. **Never change it**; write a fresh one when you create a board by hand,
and expect a duplicate the app makes to get its own.

The board's own `index.md` may set `config` — a mapping holding the
board's settings, `config: {show-card-body: 3, due-soon: 2, show-trash:
true}`. **Edit one subkey and leave the rest alone**: the app does exactly
that, so a setting you write by hand survives every change the user makes
to another one. Ten subkeys have a bullet below and **nine of them are
read**: `priorities` is retired and is no longer read anywhere. Any other
subkey in there is preserved and ignored like any key the app does not know.

This machine also has its own global config file, one level above every
board, at `/Users/rzen/Library/Containers/dev.rzen.indie.Lanework/Data/Library/Application Support/Lanework/Config/index.md` — its own `config:` block sets
an app-wide default some of these same subkeys fall back to (`due-soon`,
`priorities`, `thumb-sizes` and `logging` do, today — `logging` per subkey,
so a board can set only `level` and still inherit the machine's `retain`),
and its body documents the rest of what it holds.
The document's own `default-labels` key is the machine-wide
label-kind vocabulary a board's `config.labels` unions into rather
than replaces (see `labels` in the list below), and absent it is
just the one built-in kind, `text`; a `priority` or `component`
kind defined here reaches every board on this machine. Every definition at either level is a **write-time
palette** — what a writer picks from and stamps in full onto the
card — and never something a reader consults.

- `show-card-body` — how many lines of each card's body the app previews on
  the card's face, below its title. **`0` or `2` to `5`, and nothing else**:
  `0` is off, which is the default, and a value outside that set is read
  into it (`1` becomes `2`, anything above `5` becomes `5`). What previews
  is the body's **first paragraph, and only when it is plain prose** —
  collapsed to running text and truncated at the count. A body that opens
  with any block construct — a heading, a list, a blockquote, a code
  fence, a table, raw HTML — previews nothing, and that is your control
  over a card's face: start the body with a plain sentence to put it on
  the board, or with a heading to keep the face title-only.
- `due-soon` — how many days ahead a card's due date counts as *due soon*
  and wears the amber chip, **default `1`** (today and tomorrow). Today is
  day zero, so `due-soon: 0` means today alone. There is no control for this
  in the app — writing the subkey is how a board's horizon moves.
- `collapse-empty` — `true` auto-collapses a lane with no *visible* cards
  (search- and filter-narrowed) to the same slim strip an explicit
  `collapsed: true` draws. Presentation only — never written into that
  key, and an explicit `collapsed: true` still wins either way. Absent
  means off, which is the default. There is no control for this in the
  app — writing the subkey is how a board turns it on. Clicking an
  auto-folded lane's strip un-folds it for the rest of your session, even
  through a reload; only closing and reopening the board folds it again.
- `priorities` — this board's own priority roster, **retired twice
  over**: no build has ever written this key, and since 2026-09-07 no
  build reads it either — not at render, not as a fallback behind the
  `priority` kind, and no longer folded into `labels` when this board's
  `index.md` is next rewritten. A board still carrying it keeps its
  bytes exactly as they stand, unread and inert, until the one-time
  migration converts them; a roster you write here today changes
  nothing at all. Priorities are a label kind now: write a `priority`
  kind under `labels`, just below, and write each card's own value as
  a `labels` entry of that kind on the card itself (further down).
- `labels` — this board's own additions to the label-kind vocabulary,
  an array of kind entries (`labels: [{type: epic, text: Epic, color:
  tan, icon: {glyph: mountain.2}}, {type: status, text: Status, single:
  true, values: [{text: Open, rank: 1, color: fern}, {text: Closed,
  rank: 2}]}]`). **`type` is a kind's identity**, kebab-case and matched
  case-insensitively, and `text` is its optional display name; the
  `kind:` identity key older definitions carry migrates once and is not
  read. No `values` key names an *open* kind, whose values are free
  text; a `values` key — even an empty one — names a *closed* kind,
  whose values are exactly the ones listed, and each of those stamps its
  `rank`. `color` on a kind or on one of its values is a palette name or
  `#RRGGBB[AA]` hex, and `icon` is the `{glyph, color}` mapping (Colors
  and icons below); an unreadable colour never drops an entry, only its
  tint. `single: true` constrains **writers** and nothing else: a picker
  replaces rather than accumulates, no card entry ever stamps `single`,
  and a card that has somehow collected several values of a single kind
  draws every one of them until the on-command pass (Board ▸ Re-stamp
  Labels from Definitions, or its shortcut) reduces it to the first in
  file order and a comment signed `healer` records what was dropped
  (Stamping your work, below).
  **Unlike every other subkey here, this one unions rather than replaces**:
  the effective vocabulary is this machine's own `default-labels` (set
  on this machine, below) plus this board's own `labels`, a board kind
  naming one the global vocabulary already has overriding that kind's
  whole definition. **One kind is built in and always present** —
  `text` (`{type: text, text: Text, icon: {glyph: tag}}`), the open,
  multi-valued kind free labels belong to, stamped on every one of
  them like any other kind's and offered as the card menu's Labels ▸
  Text submenu on every board; it can be recoloured or given another
  icon or name by naming it here, and never removed.
  **`priority` and `component` are ordinary kinds**, present only
  where this board or this machine defines them — a board usually
  gets them from its template. The suggested definitions are
  `{type: priority, text: Priority, icon: {glyph: flag}, single: true,
  values: [{text: Urgent, rank: 0, color: "#C8283C", icon: {glyph:
  exclamationmark.2}}, {text: High, rank: 1, color: "#E07A1F", icon:
  {glyph: exclamationmark}}, {text: Medium, rank: 2}, {text: Low, rank:
  3, icon: {glyph: arrow.down}}]}` — Urgent and High carry a colour of
  their own, the other two none — and `{type: component, text:
  Component, color: aluminum, icon: {glyph: puzzlepiece}, single:
  true}`, an open kind. Reshaping the `priority` definition here is how
  a board changes its own priority scale.
  **A definition is a write-time palette, never a read-time authority**:
  it is what a writer picks from and stamps in full onto the card, and
  nothing that draws, sorts, filters or groups a card ever consults it,
  so recolouring a kind here changes new writes and leaves every card
  already written saying exactly what it says. There is no control for
  this in the app — writing the subkey is how a board's kinds get added.
- `thumb-sizes` — the square sizes this board offers when you embed one of
  a card's images, a list of positive whole numbers (`thumb-sizes: [200,
  400]`). Each number names a square an image is **fitted into**, never
  upscaled past, and each one is a **real file** beside the attachment's
  blob — `attachments/<uuid>/thumb.<N>.png`, written the first time a body
  references it — so `![](attachments/<uuid>/thumb.400.png)` renders at
  that size in any Markdown reader, not just in Lanework. The full-size
  `blob.<ext>` is always available beside them and is what a reader zooms
  to. A bare number reads as a one-item list; an entry that is not a
  positive number is dropped and the rest of the list still applies.
  Absent falls back to the app-wide default set on this machine (below),
  and both absent falls back to the built-in `[200, 400]`; an explicit
  `thumb-sizes: []` is not absent — it offers no sizes at all, full
  resolution only. Removing a size never deletes files already written,
  because prose may still point at them. There is no control for this in
  the app — writing the subkey is how a board's sizes change.
- `logging` — the board's own activity log (`.log/`, above), **off unless
  this key or the app-wide default turns it on**. Canonically a mapping,
  `logging: {level: info, retain: 30}`. `level` is `off`, `error`,
  `warning`, `info` or `debug`, low to high, and it is a *threshold*: a
  level writes its own lines and everything more severe, so
  `level: warning` writes errors and warnings and suppresses info and
  debug. `retain` is how many days of day-files to keep, **default 30**;
  `retain: 0` means keep everything forever and only ever means that when
  it is written out explicitly. A bare scalar reads leniently —
  `logging: info` is `{level: info}`, `logging: true` is `{level: info}`,
  `logging: false` is `{level: off}` — and a level name this version does
  not know is left as written and reads as `info`. The two subkeys
  **cascade independently**: each one falls back to the app-wide default
  set on this machine (below), then to the built-in (`off`, and 30 days),
  so a board setting only `level` still inherits the machine's `retain`.
  A board in iCloud Drive never logs whatever this says. **The whole of this
  key is read once, when the board opens**: changing it — here or in the
  machine's own config — takes effect the next time the board is opened, not
  on the next reload, so a board you are looking at keeps the level and the
  retention it opened with. There is no control for this in the app — writing
  the subkey is how a board's logging changes.
- `show-statusbar` — `true` puts a status bar along the bottom edge of
  the board's window: a breadcrumb saying where the current selection
  lives — the board's place on disk, then the selected card's title or a
  selected lane's card count. Absent means hidden, which is the default;
  the control in the app is View ▸ Show Status Bar.
- `show-trash` — `true` puts the `.trash/` column on screen as the
  board's last lane. Absent means hidden, which is the default; the
  control in the app is View ▸ Show Trash.
- `perspective` — which perspective the board window presents. Read but
  **dormant**: `kanban` is the only case this build draws, so absent, a
  hand-written `kanban`, and anything else all render the same lane strip
  you already see. Not worth writing by hand today — it exists so a
  board's setting survives a trip through a future version that adds a
  second perspective and comes home unmolested.

Same remove-at-default rule throughout: **to turn a setting off, remove
its subkey** rather than writing `show-card-body: 0` or `show-trash:
false`, and when the last subkey goes the app removes `config` itself. A
board with no `config` block is a board taking every default, not a board
that lost its settings.

Boards written before 2026-08-24 carry `show-trash` as a **top-level**
key rather than a `config` subkey. It still reads — the mapping wins
where both exist — and the app folds it into `config.show-trash` the
next time it rewrites that board's own `index.md`, for any reason at
all, dropping the top-level key on the way. But **write the subkey**:
the top-level spelling is kept readable for convenience while boards in
the wild catch up, not forever.

Cards may set `hero` — **the uuid of one of that card's own attachments**
(`hero: 3f2a8c14-…`), which the app draws as a banner across the top of the
card's face. **An identity, never a path**: the value is the name of a folder
inside that card's `attachments/` (Attachments below), so `hero:
attachments/3f2a8c14-…` and any other value containing a `/` name nothing and
draw nothing. A uuid that names no attachment, or one whose file is missing or
is not an image, draws no banner and is otherwise harmless — so a hero set
before the file arrives simply starts working when it does. There is one
control for this in the app: the attachment row's Set as Hero / Remove Hero.

**Quote any `title` containing a colon** — `title: Fix: the thing` is
invalid YAML; write `title: "Fix: the thing"`. The same goes for any value
containing `: ` or starting with `#`, `[`, `{`, or a quote — when in doubt,
double-quote.

**Keep every scalar on one line.** A double-quoted scalar may legally
continue on the following line (`title: "Long title` then `  the rest"`),
and some tools emit that shape for long titles — but it is the most common
way frontmatter gets broken by hand: the continuation reads as a line of
its own, so an edit or a copy that takes only the first one leaves the
quote unclosed, and an unclosed quote runs on to swallow every key below
it. The whole file then fails to parse, not just the title. Titles have no
length limit — write a long one as one long line, and when you copy a card
between boards, copy its frontmatter block whole.

**A title never carries a line break**, at any level and in every kind
that has the key — a board, a lane, a card, an attachment. That is a
rule about the value's own text, not about the physical line the
paragraph above warns you off: `title: "one\ntwo"` is a single legal
YAML line and still not a title. It is enforced rather than trusted —
every title the app writes is flattened first, each `\r\n`, `\n` and
`\r` becoming one space, and a title already on disk with a break in
it is **drawn** flattened everywhere at once and healed for real on
the next write that touches its file. `.schema/` states the same rule,
so a title you write by hand is caught by validating it rather than by
reading this line.

**A collection is the one value that may open out, and the app writes
both spellings.** A mapping or a list goes on one line while that line
stays short — `icon: {glyph: hammer.fill, color: fern}` — and as an
indented block once the `key: value` line would run past about 120
characters: two spaces in, `subkey: value` lines under a map, `- ` items
under a list, the map inside a list item opening on its own dash line.
The two forms are the same value and **both read, always**, so write
whichever suits you; one you wrote by hand is left exactly as written
until the app itself next writes that key, and then it comes back in
whichever form the length rule picks. **The two stamps are exempt and are
always one line**, however many subkeys `by` grows — `created` and
`modified` stay greppable.

Cards may set `labels` — a list of label maps, drawn as chips along the
bottom of the card's face and editable in the app.
**An entry carries its own full value**, so a card copied between boards
as a file keeps its meaning with no config present at either end: every
property an entry is drawn, sorted, filtered or grouped by is in the
entry itself, and nothing reading a card consults a definition to find
one. An entry is `{text, rank?, color?, icon?, kind}`:

- `text` — **the identity within its kind**, compared
  case-insensitively, display spelling preserved. A map with no
  readable `text` is no entry at all.
- `rank` — the number a ranked kind sorts by, and the exact key its
  sections group on. Absent on an open kind's value.
- `color` — the value's own colour, a palette name or `#RRGGBB[AA]`
  hex (Colors and icons below).
- `icon` — the value's own `{glyph, color}` mapping. **No `icon`
  means no glyph at all** — a label never falls back to a default
  symbol the way a board, lane or card does — and an `icon` carrying
  no `color` of its own takes the value's `color`.
- `kind` — **the kind object, stamped whole and inline**: `{type,
  text?, color?, icon?}`, repeated on every entry of that kind. The
  redundancy is deliberate and is what makes each entry readable and
  removable on its own. **Every entry stamps its kind**, the built-in
  `text` kind — free labels — included: `{text: bug, kind: {type:
  text, text: Text, icon: {glyph: tag}}}`, and `priority` and
  `component` like any other.

**A card's priority and component are `labels` entries, never root
keys.** A priority is an entry of kind `priority`, stamping its kind
like any other: `labels: [{text: High, rank: 1, color: "#E07A1F",
icon: {glyph: exclamationmark}, kind: {type: priority, text: Priority,
icon: {glyph: flag}}}]`, and a component one of kind `component`.
**`priority:` and `component:` at a card's root are reserved**: never
write either. One still found there is not read; the one-time
migration moves it into `labels`, and an entry already in the list
wins over it.

**Flatten as you write.** Resolve each property against the effective
definitions (`config.labels`, above) and stamp the answer: the value's
own colour where the definition states one, else its kind's; the value's
own icon, else **none**, because a value never inherits its kind's
glyph. Write the keys in the order `text`, `rank`, `color`, `icon`,
`kind` — `{text: bug, kind: {type: text, text: Text, icon: {glyph:
tag}}}` is a free label on a board that configures nothing, `{text:
Open, rank: 1, color: fern, kind: {type: status, text: Status}}` a
value of a board-defined kind — and re-stamp the whole list on the
card's next labels write, never on a read. Two entries are the
same label when their kind and their text match case-insensitively — a
card carries `Bug` or `bug`, never both — and a list with nothing left
in it should have the key removed rather than written as `labels: []`.

**These spellings are not read at all any more**, and migrate once
rather than living on as a tolerance: a bare string entry, a bare
scalar at `labels:`, a `value:` key standing in for `text`, a bare
`kind: epic` string where the kind object belongs, a bare `glyph:`
on a label or a kind where the `icon` mapping does, a root
`priority:` or `component:` key where a `labels` entry belongs, and
an entry with no `kind` at all — a free label written before
2026-10-05, when `text` replaced `default` as the built-in kind.
Nothing is refused
for carrying one: a value with no reading is **preserved and
invisible**, which is this format's posture for every value it cannot
read.

Cards may set `due` — a due date, most naturally a bare date
(`due: 2026-08-25`), which the app draws as a "Due: Aug 25" chip beside the
labels. **A bare date means that day wherever the reader is** — write one
unless you actually mean a moment, in which case a full timestamp
(`due: 2026-08-25T17:00:00Z`) works and is read as the day it falls on
locally. A value that isn't a date draws no chip and is otherwise harmless.
The chip turns amber as the day approaches and red once it has passed.
The card window's Due row writes it, and so does a drop under a day
section in a lane grouped by `due` (`group`, above).

A card's **priority** is its `labels` entry of kind `priority` —
write the flattened value, resolved against the effective `priority`
kind exactly as any entry is, and give a card one: a picker replaces
the kind's entry rather than adding one, and a card carrying several
is read by its lowest rank. On a card's face a priority with a
stamped `color` draws as a tinted capsule, Urgent and High alone in
the suggested scale; one with no colour draws as a bare mark, its own
glyph beside its text (Low's arrow); and the suggested Medium draws
nothing. It sits at a fixed place beside the other labels rather
than among them, and in a lane grouped by `priority` it is hidden,
because the section header already says it. The card window draws
every value as the two-segment capsule, the kind's glyph leading.
**Grouping sections on the exact `rank`** — every rank-1 card in the
topmost section, rank 2 next, each section labelled with the priority
`text` of its own first card — and filtering matches the stamped
`text`, case-insensitively; a scale this board never heard of sorts
and draws exactly as one it defines, because nothing at read asks a
definition anything, and both work on a board that defines no
`priority` kind at all. In the suggested scale a colour on this chip
means "this one interrupts" rather than "this one has a priority"; a
lower rank is a higher priority, which is why Urgent sits at 0. A
board reshapes the scale by writing a `priority` kind under
`config.labels`, which changes what a *writer* stamps and never what
an already-written card says. Where the board's vocabulary defines
the kind, the card window has a Priority row for it and the card
menu's Labels ▸ a Priority submenu, both in the vocabulary's own
order; Create Card refuses a priority on a board that defines none.

A card's **component** is its `labels` entry of kind `component`,
`priority`'s rules for the other kind. The suggested kind is **open**,
so a flattened value normally carries its own `text` plus the kind's
colour and no `rank`, and a board that gives `component` a `values`
list closes it, after which its values stamp `rank` like priority's.
It draws the same two-segment capsule as priority, sitting adjacent
to it and sharing its exact chrome — but always **untinted**: "no
color semantics" is this kind's own standing ruling, so the stamped
`color` travels with the value and the chip draws it in the ordinary
ink regardless, on a card's face and in the card window alike. In a
lane grouped by `component` the chip is hidden. Grouping and
filtering both work off the stamped `text` alone, case-insensitively.
The card window's Component row and the card menu's Labels ▸ write
it where the board's vocabulary defines the kind.

**This build runs no tracker engine.** Lanework's tracker sync is
built but switched off in this release, so nothing is pulled from
a tracker, pushed to one or posted to one. The names it uses stay
reserved, and all of them are the engine's alone: a board's
`remote` and the `cadence` inside it, a card's `remote`, a
comment's `remote`, a lane's `remote-state`, a `labels` entry of
kind `state`, and the `.tracker.nosync/` folder at the board root.
**Never write, edit or copy any of them**, and don't add a `remote`
to bind a board: nothing in this build would act on it. A board
that already carries them, from a build that runs the engine,
keeps them untouched: the app preserves every one byte for byte
on every rewrite and draws nothing from them.

Unknown keys are preserved verbatim by the app and invisible in its UI —
custom metadata (`project:`, `tags:`, `claimed-by:` …) is safe to add and
survives every app rewrite. Reserved for Lanework's upcoming tracker
sync — preserved but not rendered, don't repurpose it: the card key
`assignees`. `comments/` is **not** on this list — it's a shipped
feature with its own section below, not a reserved name.

**`author` is reserved too, and unlike those it is not preserved.** It's a
retired spelling of `created.by` (Stamping below), and the app migrates it
**on sight, at every level** — a board, a lane, a card, a comment: the next
time the board is opened, an `author: <name>` becomes
`created: {by: {name: <name>}}` and the key is gone, or is simply dropped
where `created.by` already says something. So don't write it, and don't use
the name for anything of your own — a key you put there will not be there
next time you look.

## Stamping your work: `created` and `modified`

Both stamps are **mappings**, not bare timestamps:

```yaml
created:  {at: 2026-07-24T18:00:00Z, by: {name: claude, kind: agent, model: opus-5}}
modified: {at: 2026-07-25T09:12:04Z, by: {name: claude, kind: agent, model: opus-5}}
```

- `at` — an ISO-8601 timestamp with timezone (`date -u +%FT%TZ`).
- `by` — **who**, as a map. `name` is the display name (the only subkey the
  app draws today); `kind` is `human` or `agent`; `model` is your model
  name or level; `roster-ref` is the GUID of your card on the Agent HQ
  roster board when you have one — **a bare UUID, never a path**, because
  the roster is a document that can move and the identity in this file
  should not go stale with it. **Any other subkey you want is preserved
  verbatim** — a session id, a tool name — so put what makes your work
  traceable in there.

**Write the whole map.** A bare timestamp (`modified: 2026-07-24T18:00:00Z`)
is read as `{at: …}` and a bare name (`by: claude`) as `{name: claude}` —
those coercions exist for a human typing frontmatter by hand, and files
written before this schema still read exactly as they did. You can write
four subkeys, so write four.

**Stamp `by` on every write, and after every move.** **A missing `by` means
the board's owner** — that is a claim about who wrote the file, not a blank:
the app clears `by` on its own writes precisely because those writes are the
owner's, so leaving yours off does not say "unattributed", it says the owner
did it. A card you touched yesterday reads as the owner's today unless you
re-stamp it. A bare folder move rewrites no file, so a moved card arrives
unstamped — meaning the owner moved it — unless you touch its `index.md`
again.

**`at` and `by` travel together.** Never move one without the other: a
`modified.at` from your write with a `by` from somebody else's is a file
that lies about who changed it. Set both in the same edit, every time.

`created` is set once, when you file the item, and never updated —
`created.by` is therefore a permanent record of who filed it. On a comment
it is also the attribution the app renders (see Comments below).

**You are not the only agent here.** A stamp reading `by: {name: shortcuts,
kind: agent}` is the owner's own automation writing through Lanework's
Shortcuts actions — a time-triggered card, a comment posted when something
else finished — and it may carry a name of the shortcut's own instead of
`shortcuts`. Read it as a hand like yours, not as the app: the app's own
writes carry no `by` at all, which is the rule above. There is nothing for
you to do differently, and nothing here for you to write: this is a name
the app reserves for that one writer.

**A second name the app reserves: `healer`.** A comment signed `by: {name:
healer, kind: agent}` is the app's own repair writing down what it changed
and why — today, a card that had collected several values of a kind the
board defines as `single`, reduced to the first, with the original list
quoted in the comment. The next repair that destroys a fact a person
wrote, on a card or lane, on a command somebody ran, signs `healer`
too and posts the same record; a repair that only re-spells, adds,
or runs at board open never does.
It is a record, not a request: nothing is owed in
reply, and the card's own `modified` is deliberately untouched, because a
heal is upkeep rather than an edit. Like `shortcuts`, this is a name for
you to read and never to write.

**A third name the app reserves: `tracker`.** It signs the writes
of Lanework's tracker sync, which this build does not run, so
nothing here writes it; a card or comment already signed `by:
{name: tracker, kind: agent}` came from a build that does. It is
a record, not a request. Like `shortcuts` and `healer`,
this is a name for you to read and never to write.

On a board that lives in a git repository of the user's own, committing
your changes yourself (see Git below) records exact authorship as well.

## Creating a card

1. Pick the lane folder.
2. Create a folder named a fresh lowercase UUID:
   `id=$(uuidgen | tr 'A-Z' 'a-z')`.
3. Write `<lane>/$id/index.md` (timestamp: `date -u +%FT%TZ`):

```markdown
---
schema: 1
kind: card
title: "Short imperative card title"
order: 3072
created:  {at: 2026-07-24T18:00:00Z, by: {name: claude, kind: agent, model: opus-5}}
modified: {at: 2026-07-24T18:00:00Z, by: {name: claude, kind: agent, model: opus-5}}
---
The card's content — any Markdown.
```

**Tag a fenced code block with its language** — `swift`, `sh`, `yaml`,
`json` or `diff` — **and Preview colours it by syntax**, in a card body
and in a comment alike; any other tag, or none, stays plain monospaced
text exactly as it does today.

**`order` is what places the card, and computing it means reading the
lane**: bottom of the lane = max existing card `order` + 1024; top =
min − 1024; between two cards = their midpoint. (Empty lane: any number,
conventionally 1024.) Write it whenever the position matters.

**You can also file a card without reading the lane at all.** The minimum
legal card is a `mkdir` and one `index.md` containing nothing but a title —
no `order`, no `schema`:

```markdown
---
title: "Short imperative card title"
---
The card's content.
```

**Quoted for the reason Frontmatter states above**: a bare `: ` inside a
value opens a YAML mapping and the card will not load.

It lands at the bottom of the lane (an item with no `order` sorts after
every item that has one; two such items sort by folder name), and the app
writes a real `order` into it the next time it rewrites that file. Prefer
the full frontmatter above — `kind` and the two stamps with your identity in
them are all worth having — but when you are filing into a 200-card lane and
the position doesn't matter, the short form costs one write and no reads.

Creating a lane is the same one level up (body optional; `kind: lane`;
`order` ranks lanes left→right, and is optional in the same way).

**Always write `kind`** at creation — `kind: card`, `kind: lane`,
`kind: board` at board root. Depth already says what an item is on the
board, but `.trash/` is flat, and there the value is the only thing that
tells a trashed lane from a card. Omitting it is healable, never fatal: the
app fills a missing `kind` in the next time it rewrites that file.

**File it, then found it.** A card you file should, with rare exceptions,
arrive with a founding comment — a first comment (see Comments below)
explaining the reasoning behind the card, not a restatement of the body. The
body is the spec; the founding comment is why the card exists. The exception
is a trivially mechanical card — a moved duplicate, a sweep artifact —
which needs none.

## Moving and reordering

- **The stamp rule**: a move that changes an item's container — another
  lane, another board, or into/out of `.trash/` — stamps `modified.at` and
  re-stamps `modified.by`, the same as any content edit. A reorder that
  keeps an item in the same container (a card among its lane's cards, a
  lane among the board's) rewrites only `order`; leave `modified` alone
  entirely. The trash move isn't an exception to this — it stamps because
  every container change stamps.
- Move to another lane: `mv <laneA>/<card-uuid> <laneB>/` — the folder move
  IS the move. Then set the card's `order` to place it among the
  destination's cards and rewrite `modified` whole — `at` and `by`
  together.
- Move folders **one at a time, by name** — never `mv <laneA>/* <laneB>/`.
  A lane folder holds its own `index.md` beside its cards, so a glob
  sweeps the lane's identity file along with them and overwrites the
  destination lane's.
- Reorder within a lane: rewrite only that card's `order` — don't touch
  `modified`.

## Editing and deleting

- Edit bodies freely; update `modified` on every write. Preserve frontmatter
  keys you don't recognize and don't reformat content you didn't change.
- **Delete a card or a lane = move its folder into `<board>/.trash/`**:
  `mv <lane>/<card-uuid> <board>/.trash/`, or `mv <lane-uuid>
  <board>/.trash/` for a whole lane (create `.trash/` if missing). A lane
  travels with its cards inside it. It's a container change like any other
  move (Moving and reordering above): rewrite `modified` whole, `at` and
  `by` — and here the stamp is also the position. **The trash sorts by
  `modified.at`, newest first**, so a restamped arrival lands on top;
  there is no rank to mint, and you should leave `order` exactly as it is —
  it rides along for the restore. Restore is the same move in reverse — a
  card into a lane, a lane back to board root, with a fresh `order`,
  stamped the same way.
- **Stamp `kind: lane` when you trash a lane that lacks it.** `.trash/` is
  flat, so an empty lane folder looks exactly like a card folder; the `kind`
  value is what tells them apart in there.
- Never write a `deleted:` key — that convention is retired; the app
  migrates any it finds.
- Remove a folder outright (`rm -r`) only when you mean permanent,
  unrecoverable deletion — the trash is the recoverable path for both
  cards and lanes.

## Attachments

A card's files live in `attachments/` inside the card folder, and **each one
is a folder of its own**, named a fresh lowercase UUID:

```
<card>/attachments/<uuid>/
├── blob.png                 the file itself
└── index.md                 its metadata
```

The file is always called `blob`, plus `.` and its extension where it has one.
The name a person reads lives in the metadata instead, which is what makes an
attachment renameable without breaking a single reference to it.

- **`index.md` carries exactly four things**: `kind: attachment`, `title` (the
  original filename **without** its extension), `extension` (bare, no leading
  dot), and the `created`/`modified` stamps. `schema: 1` as everywhere.
  Unknown keys are preserved like anywhere else, but do not invent any — the
  key set is deliberately closed for now. Surfaces recompose
  `<title>.<extension>` for display, so a `title` of `sketch.png` would render
  as `sketch.png.png`.
- **The `extension` key and the blob's name must agree.** The key is the
  promise that a reader can construct `blob.<extension>` without listing the
  directory, so a folder holding `blob.jpg` under `extension: png` is reported
  broken rather than quietly healed. Absent key means the file is named
  exactly `blob`.
- **To attach a file**: create `attachments/` if missing, then
  `attachments/$(uuidgen | tr 'A-Z' 'a-z')/`, copy the file in as
  `blob.<extension>`, and write its `index.md`. Nothing can collide, so
  nothing is ever overwritten and no rename ladder is needed.
- **Reference attachments from the body by relative path**:
  `![](attachments/<uuid>/blob.png)` — plain Markdown, resolved against the
  owning document, so it renders in any viewer. A comment's references resolve
  against the comment's own folder.
- **Put files in `attachments/`, never beside `index.md`** — the app relocates
  loose files into it and tells the user it did.
  The name `attachments` itself belongs to that folder — never create a
  *file* called `attachments` in a card; the app treats one as a defect
  and displaces it on sight.
- A folder under `attachments/` that is **not** uuid-named is tolerated and
  never listed as an attachment. A uuid folder with no `index.md` is repaired
  only when it holds exactly a file named `blob`; anything else is left
  completely alone, because it may be a sync still in flight.
- Flat files sitting directly in `attachments/` are the **retired** layout.
  They are shown as needing migration, and the app will not open, move or
  delete one — `scripts/migrate-attachments.swift` in the Lanework repository
  folds them into the shape above and rewrites the references that name them.

## Comments

Every card has a comment thread at `comments/` inside the card folder —
a lightweight, chronological log beside the card itself. The card body
is the spec; the thread is where work on it gets journaled (see Use the
thread below).

- **Resolve the card's directory by locating its `index.md` immediately
  before you write, every time — never construct the path from which
  lane the card is supposed to be in, and never reuse a path you read
  earlier.** A card can move lanes in the window between your read and
  your write, and a comment written against the stale path's
  `comments/` silently `mkdir -p`s a **ghost**: a card-shaped directory
  holding a `comments/` but no `index.md`, sitting wherever the stale
  path pointed. **Never create a card directory yourself** — only the
  app, or a deliberate whole-directory `mv`, does that; if writing a
  comment would have to create the card folder first, your path is
  wrong, not the card's.
- A comment is `comments/<lowercase-uuid>/index.md`: frontmatter
  `schema: 1`, `kind: comment`, `created`, `modified`. **No `title`, no
  `order`** — the common schema minus two, plus the one optional key
  below. A comment may carry its own `attachments/`, one level down
  from the card's — the same rules as Attachments above apply there
  too.

```markdown
---
schema: 1
kind: comment
created:  {at: 2026-07-24T18:00:00Z, by: {name: claude, kind: agent, model: opus-5}}
modified: {at: 2026-07-24T18:00:00Z, by: {name: claude, kind: agent, model: opus-5}}
---
What you have to say.
```

- **Chronology is the ordering**: the thread sorts by `created.at`
  ascending, so the stamp *is* the position. Write real current UTC
  (`date -u +%FT%TZ`); give a burst of several comments distinct
  seconds — ties fall back to folder-name order.
- **`created.by` is the attribution** — it is what the app draws above
  the comment, and it is the one identity the app never clears (every
  other stamp it writes has no `by` at all, which means the board's
  owner). Write yours: a comment with none is the owner's by that same
  rule, and the app draws no name over it, so an unsigned comment of
  yours reads as theirs.
- **`comments/.draft` and `comments/.trash` are the app's** — the
  unposted composer draft and the undo backing store. Never write into
  either, and never "delete" a comment by moving it there yourself:
  content no live undo step owns is swept as residue at the next
  window open. To retract a comment, post a follow-up saying so — never
  rewrite or remove an existing one.
- **`in-reply-to` names one sibling comment of the same card** — a bare
  uuid, nothing else. The app draws a ↩ context line above the comment
  naming it, and clicking that line jumps to and briefly highlights
  the target. A uuid naming no sibling is legal — the target may be
  deleted, or a sync still in flight — and draws a quiet hint rather
  than an error. An answer to an ask is an ordinary comment carrying
  this key, pointing at the question it answers.
- A comment counts as **edited** when `modified.at` differs from
  `created.at` — that's the whole rule, no separate flag, and
  `modified.by` is then who edited it. Fixing a typo is fine; once the
  conversation has moved past something you wrote, post a follow-up
  instead of rewriting it.

## Mentions

Typing `@handle` in a comment's body targets somebody. It is ordinary
Markdown text, parsed when the app **reads** the comment — nothing about
it is a schema key, and nothing round-trips that a plain-text viewer
wouldn't already show you. Handles are matched case-insensitively and by
whole token: `@rzen`, `@Rzen` and `@RZEN` all name the same person, but a
handle stitched into a longer word (`foo@bar`) or an email address
(`user@example.com`) is not a mention at all — the `@` has to sit at a
word boundary, not glued to the character before it.

**This board's human answers to `@rzen` right now** —
the handle is per-machine and configurable, so a comment synced to
another human's computer notifies *them* by *their* own handle, never
this one. There is no reserved `@owner`-style handle: it is an ordinary
handle like any agent's, and this line is simply this app's own current
answer, refreshed every time it rewrites this guide.

**Agent handles are whatever `created.by.name` you write** (Stamping
above) — sign your comments and your own name becomes mentionable the
moment somebody on this board types it. An `@token` matching nobody
known to the board renders as plain text and notifies nobody; that is
not an error, it is just an unusually short sentence.

**A card that is blocked on a human's reply says so in its frontmatter:
`waiting: {for: rzen, since: 2026-09-13T01:29:48Z, comment: 973cda84-…}`.**
Write it in the same pass as the ask it points at — `for` is the handle
you addressed, or the word `human` (or `operator`) for any human, and
an absent `for` means any human too; `since` is when you set it, in the
stamps' own timestamp grammar; `comment` is the ask's own comment uuid,
bare, never a path. A mapping is the only shape. **Only the app clears
it**: once a human's comment lands on the card later than `since`, the
app removes the key on its next load, and nothing else on the card
moves; without a readable `since` nothing ever clears it. Until then the card
face wears the mark and the lane header counts the card, for the human
whose handle it names — a card waiting on somebody else's handle wears
nothing on this machine. If the app cleared it before the reply you
needed, set it again; do not remove it yourself when the reply lands,
the app already has.

## Hard rules (the app fails loudly on violations)

- Frontmatter must parse as YAML. The board's own `index.md` must carry
  `schema: 1`; everywhere else `schema` and `order` are optional and a
  missing one is read, never refused. Never write a `schema` other than
  `1`. The classic violations are an unquoted colon in a title and a
  quoted value left unclosed across a line break (see Frontmatter above).
- Files must be UTF-8 without BOM.
- Never create a card folder without an `index.md`.
- Never rename UUID folders.
- Prefer atomic writes (write a temp file, then rename over the target) —
  the app reloads on every filesystem event and can catch half-written
  files.

## Colors and icons

`background` is a **mapping** too, on a lane or a card, never the board:

```yaml
background: {color: coral}
```

`color` is its one subkey — a palette name from the background list
(preferred) or `#RRGGBB[AA]` hex. A bare `background: coral` is not a
reading: it fails validation and paints nothing.

`icon` is a **mapping**, at every level:

```yaml
icon: {glyph: hammer.fill, color: fern}
```

- `glyph` — any SF Symbol name. A name this Mac doesn't have draws the
  level's default symbol and is otherwise harmless.
- `color` — a palette name (preferred) or `#RRGGBB[AA]` hex, tinting the
  glyph.

**Tint is the exception, not the default.** Leave `color` off unless the tint
says something the glyph cannot; a lane of multi-colored icons reads loud, and
the level's own ink already reads as one system (owner, 2026-09-13). The key
stays legal: this is conduct, not format.

Both subkeys are optional and either stands alone; an absent one means the
level's default. **Edit one subkey and leave the rest alone** — the app does
exactly that, any other subkey you put in there is preserved and ignored,
and when the last subkey goes the app removes `icon` itself. Same shape and
same rules as `config`, one key over.

A label and a label kind carry this same mapping (`labels` above), with
one difference worth knowing before you write one: there is **no
per-level default** to fall back on, so an absent `glyph` draws no
symbol at all rather than a stand-in, and an absent `color` takes the
holder's own `color` rather than the level's.

Boards written before this shape existed carry two flat keys instead — a
bare `icon: hammer.fill` and a separate `iconColor: fern`. Both still read
(a bare scalar counts as the `glyph`), and the app folds them into the
mapping the next time it writes that item's icon — but **write the
mapping**: the flat spellings are kept for convenience while the schema
settles, not forever.

- Icon tint palette: `obsidian`, `aluminum`, `soapstone`, `chalk`,
  `carnation`, `rich-grapefruit`, `smokey-tangerine`, `rich-lime`,
  `fern`, `light-jade`, `light-teal`, `deep-sky-blue`, `rich-indigo`,
  `pale-violet`, `rich-magenta`, `deep-cool-granite`.
- Background palette: `shale`, `fog`, `coral`, `salmon`, `apricot`,
  `straw`, `pear`, `clover`, `seafoam`, `mint`, `aqua`, `cornflower`,
  `periwinkle`, `lavender`, `orchid`, `slate`.

**The lists are fixed.** Every name carries one value for light mode and
one for dark mode, and the app draws whichever fits; a hex draws exactly
as written in both, and nothing on this machine redefines or extends
either list. A name from either list works in either field. Names are
matched **exactly**, and a name nobody has defined draws nothing at all —
the bytes stay as written. Older boards may
carry a retired background name — `light-cayenne` (now `coral`),
`light-mocha` (`salmon`), `smokey-mocha` (`apricot`), `smokey-lime`
(`pear`), `smokey-fern` (`clover`), `dark-jade` (`seafoam`), `dark-teal`
(`aqua`), `smokey-ocean` (`cornflower`), `smokey-indigo` (`periwinkle`),
`smokey-rich-eggplant` (`lavender`), `smokey-magenta` (`orchid`),
`intense-cool-shale` (`slate`). It still draws, as the colour in
brackets; leave it as written, and write the new name when you set a
colour yourself.

## Git

Lanework itself never runs git: the app manages no repository, makes no
commits, and never reads `.git`. But the format is deliberately
git-friendly — one file per card, stable UUID folder names, byte-faithful
rewrites — and a board may live inside a repository of the user's own.
When it does:

- **Stage only your own paths** — never `git add -A` or `git add .`: a
  sweep would commit the user's not-yet-committed changes under your name.
- **Commit your own changes, with clear messages** — nothing else will
  commit them for you, and a semantic message ("Move card 'Fix login' to
  Doing") is the history the user will actually read.
- **Leave the app-maintained files to the app** — this guide (both
  `CLAUDE.md` and its `AGENTS.md` twin) and the seeded `.gitignore` are
  rewritten by Lanework when they need to be; don't edit or delete
  them, and don't commit changes to the user's other files that you
  didn't make.
- **The seeded `.gitignore` is the app's** — line 1 is
  `# lanework-gitignore vN`, and the app rewrites the file to its current
  seed at every open, marked or not: every file inside a board folder is
  Lanework's, so a rule you add here is gone at the next open. A board is
  never a repository root — put your own exclusions in a `.gitignore`
  **above** the board's folder, where nothing rewrites them.

## Use the thread: journal your work

The card's body is the spec; its comment thread (see Comments above)
is the journal. Edit the body when scope, constraints, or done-when
change. Everything else — progress, in-the-moment thinking, questions —
belongs in the thread.

**Exhaustive over *what*, concise over *how*.** Every decision, rejected
route, and accepted limitation gets a line — and one line each. Spend
sentences by reader cost: each one must change what the reader does or
record a decision, or it is cut. Conclusion first, then short blocks
a cold reader can scan — a list, once the items pass two. The classic
padding to cut on sight: restating the body or the earlier thread,
quoting whole files instead of naming paths, narrating tool use,
hedging boilerplate. A longer thought trace is welcome as its own
separate "more context" comment — one a reader can skip now and
revisit later — never inline in the comment that carries the
conclusion. Before posting, ask both ways: would a cold reader need
anything not here, and would they skip anything that is?

- **Founding a card you filed**: your first comment on it should be
  the founding comment — the reasoning behind the card, not a
  restatement of the body. Skip it only for a trivially mechanical
  card — a moved duplicate, a sweep artifact — there's no reasoning
  to record. Filing and starting work in the same sitting, one
  comment may serve as both — the reasoning first, then the plan.
- **Starting work on a card**: post a comment with your plan and the
  decisions already settled, routes not taken included — one line each,
  written for a reader with none of your context: the user checking in
  later, another agent, or your own future session picking the card
  back up cold.
- **While working**: record decisions as you make them, not
  reconstructed afterward. Outcomes live elsewhere — commits, diffs —
  so the thread's job is the *why*, the routes you didn't take, and
  any limitation you knowingly accepted.
- **Questions**: post them as comments. The app narrates arrivals by
  path shape ("Comment on '⟨card⟩'"), so a posted question genuinely
  reaches the user live. **A comment is a record or an ask, never
  both.** A record carries context — reasoning, decisions, evidence,
  attachments. An ask carries one request for the human and nothing
  else, in this shape:

  ```markdown
  @rzen <the ask in one sentence: a question, or an imperative>

  Options, only when choosing:
  - A: <one line>
  - B: <one line>

  Why now: <one line>
  If no answer: <the default and when it applies, or "blocked">
  Context: <the comment above, or a section of the body>. Nothing restated.
  ```

  The blank line after the options is not optional: Markdown folds the
  line after a list item into that item, so without it `Why now:`
  renders as the tail of option B. Every list — in a comment or a
  body — ends with a blank line before the paragraph that follows.

  An option's label is whatever sits before the colon — `A`, `A2`,
  `A1 plus the well` — a short run that starts with a letter. The app
  draws each option as a button, and a click writes the answer as an
  ordinary comment reading `<label>: <the option's text>`.

  Under about eighty words. Short sentences of one clause — no dash-
  or semicolon-chained thoughts, no hashes, counts, or log names, no
  hedging ("worth trying", "a note on whether"): say what you need.
  Two asks are two comments, so each can be answered and settled on
  its own. When a record and an ask both belong on a card, post the
  record first and the ask a second later, so the ask closes the
  thread. **The handle is an ask, not a cc**: mention
  `@rzen` only in an ask — the card
  is blocked on the human, or a gate is theirs — never in a record,
  a founding comment, or a closing report. Answers come back as later
  comments — **re-read the whole thread before resuming any card**,
  not just the last entry.
- **Finishing**: close with verification evidence — what you ran, what
  it showed — and name anything you did differently from what the
  card asked.
- **Comments never stamp the card**: posting one leaves the card's own
  `modified` alone, the same as the app's own posts.

Per-board process — lane cadence, commit conventions, anything specific
to this board — belongs in the board's `index.md` body, under a `##`
heading, not here — and not in a file of its own at board root.
