<!-- lanework-heal-catalog v2 — the board heal's rule catalog, written into .schema/ by the Lanework app. Don't edit it here: it is rewritten whenever the app ships a newer one. -->

# The heal catalog

Every repair a Lanework heal makes to a board's files, and nothing else. This
list is the specification. The app's own heal and `.schema/bin/lanework-heal.py`
are both written from it, and each repair in their code carries its rule id.
**A repair missing from this list doesn't exist**: neither heal makes it.

Each rule has a stable id, the documents it reads, what it does, a before and
after, and whether it **drops a fact**. A fact is something a person wrote
that no longer appears in the file afterwards.

## Running it

```
python3 .schema/bin/lanework-heal.py <board>                  # dry run: one line per repair, nothing written
python3 .schema/bin/lanework-heal.py <board> --apply --name <you> --model <model> [--session <s>]
```

A dry-run line reads `<file>: <rule id> <code> <what>`, and a `skip <file>: <why>`
line is something the heal leaves for you to fix by hand. Run the validator
afterwards (`python3 .schema/bin/lanework-validate.py <board>`): exit 0 with
no `DEPRECATED` line on what the heal touched is the finished state.

**The board's copy wins.** A copy of this script that ships with an agent
skill refuses to run against a board that carries its own
`.schema/bin/lanework-heal.py`, because the app keeps the board's copy current
with the board's format.

## Rules every repair keeps

- **No restamp.** A heal is upkeep, not an edit: no `modified` changes, on any
  file, for any rule. `created` is never touched.
- **A missing `by` stays missing.** It means the board's owner wrote the file,
  so no heal adds one.
- **A dropped fact gets a record first.** A rule marked *drops a fact* posts a
  comment on the card before the file is rewritten, quoting what went. It is
  signed by whoever runs the heal: `healer` when the app runs it, your own
  name when you run the script. Never sign `healer`, `shortcuts` or `tracker`
  yourself.
- **Unknown rides through.** A key or a subkey that no rule names is never
  removed, renamed or reordered. Inside a rewritten `labels` entry, unknown
  subkeys ride along at all three levels: on the entry, on its `kind`, and on
  its `icon`.
- **Foreign is left alone.** A label whose kind the board doesn't define, or a
  value a closed kind doesn't list, keeps every byte of its stamps (H13).
- **Never walked**: `.trash/`, `comments/.draft` and `comments/.trash`.
- **Only what needs repair.** A file no rule changes is never rewritten. A
  rewritten list or mapping comes back in the writer's compact form, and a
  comment on its key line stays on that line.
- **Idempotent.** A second `--apply` straight after the first finds nothing,
  and a run interrupted after its records and before its files posts no
  record twice when it is run again.

**Order.** In each document the rules run in id order, each on the previous
one's output. The definitions a card heals against come from the board's own
`config.labels` (after H05, H06 and H15), plus the built-in `text` kind.

**What the heal never does**: the app's writer folds some retired spellings
on its own next write of a file, and those aren't catalog rules: `author`
into `created.by`, a top-level `show-trash` into `config.show-trash`, a lane's
`group-by` into `group`, and a bare `group` scalar into the mapping. The
validator still names them as `DEPRECATED`. A rule for any of them starts
here, as a new entry with its fixtures.

---

## H01 · title-quote

- **Documents**: every document with a `title`.
- **Drops a fact**: no.

A `title` that YAML can't read as one line of text is rewritten as one
double-quoted line: a plain title carrying `: ` or ending in `:`, or starting
with `- `, `?`, `@`, `%`, a backtick, `!`, `&` or `*`; and a double-quoted
title whose escapes put a line break in it (the break becomes a space). A
plain title written over several lines folds onto one line with single spaces.
**A title that already reads as one line of text is left exactly as written**,
whatever its quoting: plain, single-quoted, or folded over lines.

```yaml
title: Fix: the drag ghost      # before (YAML reads this as a mapping)
title: "Fix: the drag ghost"    # after
title: Plain words here         # left alone: it reads
```

- **Skip**: a plain title carrying ` #` (YAML reads the rest as a comment), a
  title that reads as null (`~`, `null`, or a leading `#`), a title that isn't
  a scalar (`{`, `[`, `|`, `>`), and a double quote that never closes. Fix
  those by hand.

## H02 · bare-stamp

- **Documents**: every document.
- **Drops a fact**: no.

`created` or `modified` written as a bare timestamp becomes the mapping
`{at: …}`. A stamp whose `by` is a bare name gets `by: {name: …}`. Nothing
else in the stamp changes: no `by` is added, and `at` keeps its value.

```yaml
modified: 2026-09-01T10:00:00Z                       # before
modified: {at: 2026-09-01T10:00:00Z}                 # after
created:  {at: 2026-09-01T10:00:00Z, by: claude}     # before
created:  {at: 2026-09-01T10:00:00Z, by: {name: claude}}   # after
```

## H03 · bare-icon

- **Documents**: every document with a root `icon` or `iconColor`.
- **Drops a fact**: no. Where both say a colour, the mapping's is the one the
  app reads.

A flat `icon: <glyph>` becomes `icon: {glyph: …}`. The retired `iconColor` is
folded into `icon.color` when the mapping has no colour of its own, and then
removed. The mapping wins property by property.

```yaml
icon: star              # before
iconColor: amber
icon: {glyph: star, color: amber}   # after
```

## H04 · retired-key (`modified-by`)

- **Documents**: every document.
- **Drops a fact**: yes, in its third case.

The retired `modified-by: <name>` is removed:

1. folded into `modified.by` as `{name: …}` when `modified` has no `by`;
2. dropped when `modified.by.name` already names the same;
3. dropped with a record on the card when `modified.by` names someone else
   (the map wins).

- **Skip**: a `modified-by` with no string reading, and case 3 on a document
  that isn't on a card (a board root or lane has no thread to hold the record).

```yaml
modified: {at: 2026-09-01T10:00:00Z}     # before
modified-by: claude
modified: {at: 2026-09-01T10:00:00Z, by: {name: claude}}   # after
```

## H05 · definition

- **Documents**: the board's `index.md`, `config.labels`.
- **Drops a fact**: no.

Each definition entry in a retired spelling is rewritten in the current one:
`kind:` for `type:` (a string `kind` on an entry with no `type`); a bare
`glyph:` folded into `icon` (an `icon` mapping that names a glyph keeps its
own); the retired `default` type renamed `text`, with its display name
`Label` renamed `Text`. In a closed kind's `values`: a bare string becomes
`{text: …}`, `value:` becomes `text:` where there's no `text`, and a bare
`glyph:` folds into `icon`.

```yaml
config: {labels: [{kind: phase, glyph: flag, values: [Draft, {value: Done}]}]}           # before
config: {labels: [{type: "phase", icon: {glyph: "flag"}, values: [{text: "Draft"}, {text: "Done"}]}]}   # after
```

## H06 · added-definition

- **Documents**: the board's `index.md`, read against every card.
- **Drops a fact**: no.

When the board's cards use the `priority` or `component` kind (a reserved
root key, or a `labels` entry of that kind, in any spelling) and
`config.labels` doesn't define it, the board gains the definition, appended
after its own entries, as the suggested one:

```yaml
- {type: priority, text: Priority, icon: {glyph: flag}, single: true, values: [{text: Urgent, rank: 0, color: "#C8283C", icon: {glyph: exclamationmark.2}}, {text: High, rank: 1, color: "#E07A1F", icon: {glyph: exclamationmark}}, {text: Medium, rank: 2}, {text: Low, rank: 3, icon: {glyph: arrow.down}}]}
- {type: component, text: Component, color: aluminum, icon: {glyph: puzzlepiece}, single: true}
```

- **Skip**: a `config` that isn't a mapping, or `config.labels` that isn't a
  list.

## H07 · bare-labels

- **Documents**: a card's `labels`.
- **Drops a fact**: no.

`labels: <scalar>` becomes a one-entry list. A bare string entry becomes a
label map, and the `value:` alias on an entry becomes `text:`. The entry then
takes its kind (H08, H09) and the stamps of its definition, as a written label
would.

```yaml
labels: bug                                   # before
labels: [{text: "bug", kind: {type: "text", text: "Text", icon: {glyph: "tag"}}}]   # after
```

## H08 · string-kind

- **Documents**: a card's `labels`.
- **Drops a fact**: no.

An entry's `kind: <name>` becomes the kind object `{type: <name>}`, then
takes the stamps of that kind's definition. `priority` and `component` are
written lowercase, and the retired `default` becomes `text`.

```yaml
labels: [{text: High, kind: Priority}]     # before
labels: [{text: "High", rank: 1, color: "#E07A1F", icon: {glyph: "exclamationmark"}, kind: {type: "priority", text: "Priority", icon: {glyph: "flag"}}}]   # after
```

## H09 · text-kind

- **Documents**: a card's `labels`.
- **Drops a fact**: no.

A label with a `text` and no `kind` is a free label from before the `text`
kind. It's stamped `kind: {type: text, text: Text, icon: {glyph: tag}}`, or
with the board's own `text` definition where it has one. A `kind` naming the
retired `default` type is renamed `text`.

## H10 · bare-glyph

- **Documents**: a card's `labels`.
- **Drops a fact**: no.

A bare `glyph:` on a `labels` entry, or on its `kind`, folds into `icon`. An
`icon` mapping that already names a glyph keeps its own.

## H11 · root-key

- **Documents**: a card.
- **Drops a fact**: no.

A reserved root `priority:` or `component:` key moves into `labels` as an
entry of that kind, appended, and the key is removed. A scalar resolves
through the definition, the way a picker's write would. A mapping keeps its
own `text`, `rank`, `color` and `icon` (with `value:` read as `text:` and a
bare `glyph:` folded), and takes the definition's kind, or `{type: …}` alone
where nothing defines it.

```yaml
priority: High              # before
labels: [{text: "High", rank: 1, color: "#E07A1F", icon: {glyph: "exclamationmark"}, kind: {type: "priority", text: "Priority", icon: {glyph: "flag"}}}]   # after
```

- **Skip**: a key with no reading (a list, or a mapping with no `text`), and a
  `labels` that isn't a list. A `null` root key (`priority:` or `component:`)
  is left as written. A `labels` that is bare, `~` or `null`, `[]`, or only a
  comment under it is no list, not a skip: the entry starts one. `labels: ""`,
  a number, or a mapping is still skipped (a text scalar is H07's one-entry
  list).

## H12 · root-key-dropped

- **Documents**: a card.
- **Drops a fact**: yes.

H11's key, when `labels` already carries an entry of that kind: the entry
wins, the key is removed, and the record quotes it.

## H13 · stale-label

- **Documents**: a card's `labels`.
- **Drops a fact**: no.

A recognised entry whose stamps differ from what its definition says now is
re-stamped. Recognised means the board defines the entry's kind (the built-in
`text` always counts) and, for a closed kind, lists its text,
case-insensitively. The re-stamp sets:

- `text`: the definition's casing;
- `rank`: the listed value's rank (a closed kind; the value's 1-based
  position where it states none), or none at all (an open kind);
- `color`: the listed value's, else the kind's, else the entry's own;
- `icon`: the listed value's glyph and colour, else the entry's own (never the
  kind's);
- `kind`: the definition's `type`, `text`, `color` and `icon`.

Unknown subkeys ride along on the entry, on its `kind` and on its `icon`; a
definition's own unknown subkeys are never stamped onto a card. A foreign entry
is never touched.

```yaml
labels: [{text: high, rank: 9, note: "from triage", kind: {type: priority}}]     # before
labels: [{text: "High", rank: 1, color: "#E07A1F", icon: {glyph: "exclamationmark"}, kind: {type: "priority", text: "Priority", icon: {glyph: "flag"}}, note: "from triage"}]   # after
```

## H14 · single-kind

- **Documents**: a card's `labels`.
- **Drops a fact**: yes.

A card carrying several entries of a kind the board defines as `single`
keeps one: **the value readers show**. A `rank` written as a string counts
only when it is a plain decimal number (`"20"` does, `"1_0"` and `" 2"` don't),
as the app reads it. That's the lowest `rank` (a ranked
entry before an unranked one), with a repeated value counting once, as first
written, and the first in the file where ranks tie or none is ranked. Every
other entry of that kind goes, repeats included, and the record quotes the
original `labels` lines. A kind no definition names, and a kind not defined
`single`, are never reduced. A list left empty loses its `labels` key.

```yaml
labels: [{text: "Low", rank: 3, kind: {type: "priority"}}, {text: "High", rank: 1, kind: {type: "priority"}}]   # before
labels: [{text: "High", rank: 1, kind: {type: "priority"}}]                                                       # after
```

## H15 · config-priorities

- **Documents**: the board's `index.md`.
- **Drops a fact**: no.

The retired roster `config.priorities` is converted into a `priority`
definition in `config.labels` when the list defines none. Each level
`{name, value, color}` becomes a value `{text, rank, color}`, and a bare
string level is ranked by its position. Where the list already defines
`priority`, its definition wins and the roster is simply removed. Either way
the key goes, and `config` itself goes if it was the last subkey. The roster
is read as the board's `priority` definition while its cards heal.

```yaml
config: {priorities: [{name: High, value: 1, color: red}, Low]}      # before
config: {labels: [{type: "priority", text: "Priority", icon: {glyph: "flag"}, single: true, values: [{text: "High", rank: 1, color: "red"}, {text: "Low", rank: 2}]}]}   # after
```

## H16 · config-collapse-empty

- **Documents**: the board's `index.md`.
- **Drops a fact**: no. No build reads the key.

The retired `config.collapse-empty` is removed, whatever its value, and
`config` goes with it if it was the last subkey.

```yaml
config: {collapse-empty: true, show-statusbar: true}    # before
config: {show-statusbar: true}                          # after
```

## H17 · compact-collection

- **Documents**: every document, every top-level key whose value is a
  non-empty list or mapping, the two stamps included.
- **Drops a fact**: no. Only the layout changes; every value reads the same.

A collection stored in a layout other than the writer's compact form is
rewritten in it. The compact form is what the app writes: `key: <flow>` while
that line is at most 120 characters, else `key:` over an indented block in
which each nested entry stays on one line when its own line fits, the same
rule again one level down. The two stamps are always one line. A key needs
the rule when its stored lines, not counting blank or comment lines, number
differently from the compact form's: more lines is a hand-expanded
(verbose) collection, and one line where the compact form has several is a
flow line past 120 characters. Quoting and spacing never fire it.

Every string comes back double-quoted, as the app writes it, except a
timestamp written plain in the app's own form (`2026-09-13T01:29:48Z`), which
stays plain. A stamp keeps its words plain, as H02 writes it. A comment on the
key's line stays on the first line written.

```yaml
labels:                                              # before
  - text: "Low"
    rank: 3
    kind:
      type: "priority"
labels: [{text: "Low", rank: 3, kind: {type: "priority"}}]   # after
```

- **Left alone**: a key written twice; a key with a comment line inside its
  value; and a key whose value holds a block scalar (`|`, `>`), an anchor, an
  alias or a tag (`&`, `*`, `!`). Rewriting any of these could lose or
  misread what was written.
