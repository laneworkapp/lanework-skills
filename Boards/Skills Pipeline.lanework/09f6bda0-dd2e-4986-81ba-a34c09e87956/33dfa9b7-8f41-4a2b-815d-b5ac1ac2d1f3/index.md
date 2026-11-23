---
schema: 1
kind: card
title: "Plan: record ticket dependencies as depends-on relations"
order: 4096
labels: [{text: "plan", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-23T16:34:08Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Scratch"}}
modified: {at: 2026-11-23T17:35:10Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}}
claimed:
  by: {name: claude, kind: agent, model: claude-fable-5-2, session: "8a1a40af-9f60-4879-984b-68b4c8585042"}
  until: 2026-11-23T18:05:10Z
---
Plan tickets record their dependencies as a `## Depends on` list in the body, which the app treats as plain links, while the guide has a typed `depends-on` relation for exactly this. This card makes `file-ticket.sh` write one relation per dependency and makes `frontier.sh` and `resolve-ticket.sh` read relations, so a dependency shows on both tickets in the app and one the owner adds or removes there is obeyed.

## Evidence

- **Writer**: `skills/plan/scripts/file-ticket.sh:54-68` checks each `--depends` (this board's full link, card exists, not Out of scope) and `:99-101` appends `## Depends on` with `- [<ref>](<link>)` lines. Header `:7-11` documents it. `grep -rni relation skills/plan` finds nothing.
- **Readers**: `frontier.sh:32-35` and `resolve-ticket.sh:53-56` hold the same `deps_of`, which reads links under `## Depends on` only. `card_of` (`frontier.sh:19`, `resolve-ticket.sh:51`) matches a full uuid only.
- **Run, throwaway board**: a Blocked ticket whose only dependency is a hand-written `depends-on` relation gets `drift: T2: Two is Blocked but names no dependency` from `frontier.sh`. Resolving its dependency leaves it in Blocked, because `resolve-ticket.sh:118` skips a ticket with no body links. So a dependency the owner adds in the app is invisible to plan today. The app has relation add, edit and trash in the inspector (lanework-app `LaneworkTests/RelationEditingTests.swift`).
- **Prose and templates**: `plan/references/tickets.md:20-24` § Depends on names the body section as the record. `templates/ticket-card.md:13-15` shows it. `templates/lanes.md:9` (the Blocked lane body) says "listed under Depends on". `references/tickets.md:50` (§ Editing) says to edit the section by hand.
- **Guide** (`Boards/Skills Pipeline.lanework/CLAUDE.md:1112-1155`): one document per relation at `<card>/relations/<uuid>/index.md`, on the card making the statement. `schema`, `kind`, `rel` and `to` are required, with no `title` or `order`. `rel` is free text. `to` is the full link, though a short prefix link is legal and resolves by prefix (`:1136-1138`, `:99`). Delete = move into `relations/.trash/` (`:1147`). No inverse is ever stored (`:1150`). `suspect: {since, by, cause}` is set and removed by agents (`:1142-1146`).
- **App reads it on both sides**: lanework-app `LaneworkTests/CardInspectorRelationsTests.swift` lists own relations grouped by `rel`, incoming relations from the same board, and the `suspect` mark. It treats `traces-to` and `Traces_To` as one type (`:100`, `:380`). That last point means an owner can write `Depends_On` or `depends on`.
- **Prior art**: `discovery/scripts/file-record.sh:76-79` writes `supersedes` relations with an inline `printf` (`schema`, `kind`, `created`, `rel`, `to`, no body), staged with the card and moved in one `mv`. Smoke `tests/smoke.sh:612-637` pins that shape.
- **Guide version**: Relations entered the guide at v111 (lanework-app `4eb952ce8`, `AgentGuide.version` 110 to 111). A board's `.schema/` from before then has no `relation.json`, and the validator fails at any `relations/` document (`.schema/bin/lanework-validate.py:80-83`, `:1372-1375`). **Run**: the same board validates clean with the current set and has 1 failure with `relation.json` removed. `heal-board.py` finds 0 repairs on the relation, including one carrying `suspect`.
- **Plan boards in the wild**: `lanework-aup/Boards/AUP Skills Plan.lanework` has 15 tickets, 9 of them with `## Depends on` and none with `relations/`. Its guide is **v109** and its `.schema/` has no `relation.json`. A relation written there fails its own validator until the app upgrades the board.
- **No trigger for `suspect` in plan**: a Resolved ticket never leaves its lane (`plan/references/board.md:36`) and is never edited (`tickets.md:51`). A change of mind is a new ticket linking the old one. The idea's "reopened or re-ruled dependency" cannot happen under plan's own rules.

## Proposal

**`skills/lanework/scripts/lib.sh`**
- `relations_enabled <board>`: guide v111 or later, the same shape as `cite_enabled` (`:101`). No readable stamp counts as false.
- `relation_file <dir> <rel> <to> <at> <by>`: writes `<dir>/relations/<uuid>/index.md` in the guide's shape, identical to `file-record.sh:78` today, and prints the uuid.
- `relation_targets <card dir> <rel>`: prints the `to` of each live relation whose `rel` matches. The match ignores case and reads `_` and spaces as `-`. It strips quotes and skips `relations/.trash` and every dot folder.

**`skills/discovery/scripts/file-record.sh`**: `:76-79` calls `relation_file`. Same bytes out, so there is one writer for the relation shape. No behavior change.

**`skills/plan/scripts/deps.sh`** (new, sourced by the two readers): one `deps_of <board> <card dir>` and one `card_of` in place of today's two copies.
- `deps_of` returns the card uuids from `relation_targets … depends-on` and nothing else. A `## Depends on` body section is not read.
- `card_of` resolves a full or short link: the board segment must be this board's id or a prefix of it, and the card segment a unique prefix.
- A target on another board, or one naming no card, comes back as missing.

**`skills/plan/scripts/file-ticket.sh`**
- The `--depends` checks at `:54-68` stay as they are, refusals included.
- On a `relations_enabled` board it writes one `depends-on` relation per `--depends` with `relation_file`, inside the staged card (`$C`), so the card and its relations land in the one `mv` at `:106`.
- Below v111, or with no guide stamp, `--depends` is refused (exit 1, nothing written), with a message to open the board in the app so it upgrades. A ticket with no dependency files as before.
- Nothing is ever written on the target ticket. The header (`:5-15`) is updated.

**`skills/plan/scripts/frontier.sh`, `resolve-ticket.sh`**: source `deps.sh` and drop their own `deps_of` and `card_of`. The output lines (`waits on …`, `unblocked T<n>`) and drift warnings stay as they are. A Blocked ticket that still carries a `## Depends on` body section and no relation gets the existing "names no dependency" warning, with a hint to re-enter its dependencies as relations. The drift warnings now cover relations: a missing target, a target on another board, an Out of scope target, a Blocked ticket with no dependency, a Frontier ticket with one open. Headers `frontier.sh:5-9` and `resolve-ticket.sh:7-9` are updated.

**`skills/plan/references/tickets.md` § Depends on** (the heading is kept because `sessions.md:13` cites it):
- A dependency = one `depends-on` relation on the dependent ticket (shape: guide § Relations), written by `file-ticket.sh --depends`. Never on the target.
- Add one later by hand in the same shape. Drop one by moving its folder into `relations/.trash/`. Then run `scripts/frontier.sh` and fix the drift it names.
- § Editing `:50` changes to match.

**`skills/plan/templates/ticket-card.md`**: replace the `## Depends on` block with one line saying dependencies are relations, not body text, written by `file-ticket.sh` (guide § Relations).

**`skills/plan/templates/lanes.md:9`** (owner-facing prose): "Specified tickets waiting on another ticket that is not resolved yet (each one a depends-on link on the ticket)." The rest of the body is unchanged. Heal does not read plan's lane table (`heal/references/descriptors.md:12`), so no `OLD_BODIES` entry is needed.

**`tests/smoke.sh`**: cases below. **`README.md`** § Sizes for `plan` (`tickets.md`, `ticket-card.md`, `lanes.md`). **`CHANGELOG.md`**: one user-facing entry at release.

## Decisions in this proposal

- **Gate at guide v111**, from the board's guide stamp as `cite_enabled` does it. This is the version that brought relations and `relation.json`. Writing them below it fails the board's own validator.
- **The target is never touched.** No inverse, no comment, no restamp, as the guide says and as `file-record.sh` already does.
- **Readers follow the app's leniency**: short links, quoted values and `rel` in any case or with `_` or spaces all read. `file-ticket.sh` still accepts and writes only the full link.
- **One relation writer.** `file-record.sh` moves onto `relation_file` in this card, because two copies of the shape would drift.
- **Relations are the only record** (owner ruled A, 2026-11-23). A ticket filed on a v111+ board carries no `## Depends on` body section.
- **Old body lists are ignored** (owner ruled, 2026-11-23: "ignore old relations. we'll have test users migrate relevant relations to new scheme."). No reader for the old shape and no migration script. My reading of what follows from it: `--depends` is refused below v111, since a relation there fails the board's own validator and a body list would be ignored.
- **`suspect` is not in scope.** Plan has no event that changes a dependency after it resolves (Evidence, last bullet). A follow-on card is filed only if the owner wants an overturning ticket to flag the tickets that relied on the old one.

## Out of scope

- `suspect`, as above.
- `discovery`'s question cards, which keep their own `## Depends on` (`discovery/scripts/file-question.sh:106`, `templates/question-card.md:23`). They are a separate card if wanted, with the same open calls.
- Gating `file-record.sh --supersedes` at v111. It has the same gap on an old board but is discovery's behavior. A follow-on card.
- A script to add or drop a dependency on an existing ticket. Hand edits per the guide, checked by `frontier.sh`.
- `read-board.sh` listing relations.

## Risks

- **Tickets already filed stop counting their body lists.** On the AUP board (v109, 9 tickets with a body list) every Blocked ticket shows as drift until someone re-enters its dependencies as relations, and `resolve-ticket.sh` unblocks nothing from a body list. The owner accepted this: test users migrate by hand. No script does it.
- **A board below v111 cannot file a dependent ticket** until the app opens it and upgrades the guide and schema.
- **Short-link resolution** can match two cards. `card_of` treats an ambiguous prefix as missing and warns, and never guesses.
- **The relation lands with the card.** It is staged inside `$C` before the `mv`, so a crash leaves both or neither, never a ticket in Blocked with no dependency.
- **Owner-facing wording** in existing boards' Blocked lane still says "listed under Depends on". That stays true for their old tickets. Accepted.
- **Smoke churn**: the current plan board `$PL` has no guide, so it sits below the gate and its `--depends` cases would now be refused. The plan board gets a guide stamp (`mkguide`, `tests/smoke.sh:1068`) or the dependency cases move to a stamped board, and the drift case that appends a body link at `:768` becomes the legacy case.

## Verification

Smoke, on throwaway boards only:

1. **Write, v120 board**: `--depends` twice gives two `relations/<uuid>/index.md` on the dependent ticket only. Each has exactly `schema: 1`, `kind: relation`, a one-line `created` from `by_of`, `rel: depends-on` and `to: lanework://<board>/<uuid>`. The targets have no `relations/`. The ticket lands in Blocked. The board validates and heal finds 0 repairs.
2. **Gate**: on boards at v110 and with no stamp, `--depends` exits 1 and leaves the board checksum unchanged; the same call without `--depends` files the ticket. A loop like `:3161-3170`.
3. **Refusals**: the existing bad-dependency loop (`:727-733`) on the v120 board still leaves the board checksum unchanged, `relations/` included.
4. **Read**: `frontier.sh` prints `waits on` from relations. `resolve-ticket.sh` unblocks a relation-only ticket when its last dependency resolves, and a two-dependency ticket only after both.
5. **Owner-written shapes**: quoted `rel`/`to`, a short `to` link, and `rel: Depends_On` all read as dependencies. A relation in `relations/.trash/` and a `rel: traces-to` one are ignored, so a ticket with only those gets "names no dependency".
6. **Drift**: a relation to a missing card, to another board's card, and to an Out of scope card are each warned. `frontier.sh` still exits 0.
7. **Legacy**: a Blocked ticket with only a `## Depends on` body section is warned as naming no dependency, with the hint, and resolving the ticket it links does not unblock it.
8. `file-record.sh --supersedes` output unchanged: the `:612-637` assertions pass unedited.
9. `check-refs.sh`, `check-sizes.sh` and `bash -n` pass.

## Done when

- [ ] `file-ticket.sh --depends` writes `depends-on` relations on a v111+ board, and nothing on the target.
- [ ] `frontier.sh` and `resolve-ticket.sh` read relations through one shared `deps_of`, with no second copy.
- [ ] Below v111, `file-ticket.sh --depends` refuses and writes nothing, and a smoke case pins it.
- [ ] `file-record.sh` writes through `relation_file`, with byte-identical output.
- [ ] `tickets.md`, `ticket-card.md` and `lanes.md` name the relation, not a body section. `grep -rn "Depends on" skills/plan` finds only the § heading and the drift hint.
- [ ] Smoke cases 1-8 pass. `tests/smoke.sh` is green. README sizes are updated.
- [ ] Nothing under `skills/` names a guide version.

## Release

Minor: new behavior in three scripts. One CHANGELOG entry.
