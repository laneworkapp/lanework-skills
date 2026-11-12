---
schema: 1
kind: card
title: "Shaping: assign a label from the kind the lane is grouped by"
order: 1024
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T00:35:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
waiting: {for: rzen, since: 2026-11-12T00:42:31Z, comment: 121d91c9-98a9-44ee-810a-93ba49e275d2}
modified: {at: 2026-11-12T00:42:31Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "board watch"}}
---
The owner asked on 2026-11-11 that when a card is shaped, the agent read what the Shaping lane is grouped by and try to give the card a fitting label of that kind. The card then lands in a real section, not the trailing "No <kind>" one.

## Proposal

**One rule, in one place**: a new bullet in `skills/lanework/references/writes.md` § Placing (line 34 is the sibling rule for `card-defaults`). It binds any lane an agent writes a card into, so shaping, filing and moving share it. Shaping is the case that prompted it; `skills/work/references/sweep.md` line 26 (the "Shaping to advance" row, the only place the flow names shaping) gets a pointer, not a copy. No other file restates it.

The bullet, in the skills' telegraphic style:

- **Grouped lane** (`group: {by: label, kind: K}`, or `by: priority`, or `kind: priority`; guide § Frontmatter, lanes): the lane sections on kind K, and a drop assigns it. A file write assigns nothing, so write it yourself.
  - Card already has an entry of K → leave it. Never overwrite the owner's value.
  - Else pick one value that fits the card: closed kind → one of its listed values in `config.labels`; open kind → a value already on a card in the board, never a new spelling.
  - Write it as a drop would: the flattened `labels` entry of K, stamped from the board's current `config.labels` (guide § Frontmatter, `labels`).
  - Unsure → leave it off and say so in the record. A wrong section is worse than the trailing one.
  - `by: modified` / `created`, no `group`, or `by: label` without `kind` → nothing to do. `by: due` → see open question 2.

**Scope**: a prose change to two files. No script writes labels for a shaped card (`grep card-defaults` finds only `writes.md`), so there is no code and no smoke case.

## Touches

- `skills/lanework/references/writes.md` § Placing: the bullet above (~90 words).
- `skills/work/references/sweep.md` line 26: append "; assign the lane's grouped label (`lanework/references/writes.md` § Placing)" to the Shaping row.
- `README.md` § Sizes: the word counts for those two files (`tests/check-sizes.sh` fails otherwise), and the summary totals.
- Not touched: `work/SKILL.md`, `board-kinds.md`, templates, scripts, `plugin.json`.

## Risks

- **An agent guesses a priority.** Priority is a judgment. Mitigated by "unsure → leave off, say so", but the owner may want `priority` carved out. Covered by open question 1's scope, not a second ask.
- **Collides with the owner's drop.** A shaped card keeps the owner's value (never overwrite), so no.
- **Skills Pipeline's Shaping lane has no `group` today**, so nothing here changes how this board runs until the owner sets one. The rule is for boards that do.
- **Version stamp**: the board's guide is v114, the repo stamps v101 (`CLAUDE.md`), and smoke fails when the board's guide is newer. That drift predates this card and is not fixed here.

## Verified when

Prose change, so verified = read through against the guide's `group` section (CLAUDE.md lines 178-235) and `lanework/references/writes.md`'s other bullets for contradiction, plus `tests/smoke.sh` green (its `check-refs.sh` and `check-sizes.sh` cover the new pointer and the README counts).

## Done when

1. `writes.md` § Placing has the Grouped lane bullet; it names the four outcomes (already set, assign, unsure, nothing to do) and the `due` ruling.
2. `sweep.md`'s Shaping row points at it; the rule text appears nowhere else under `skills/`.
3. `tests/smoke.sh` exits 0 and README § Sizes matches `wc -w`.
4. Changelog: a user-facing entry if the owner cuts 0.8.0 with it.

## Recommendation

Build it, scoped to every lane an agent writes a card into, `due` never assigned. It is trivial (two prose files, no script) but it is **not part of the 0.8.0 set** until the owner answers the two questions below, and it can ride 0.8.0 as a patch-sized wording change if answered in time. Deferred: a carve-out for `priority`, and any script that stamps the label (the work is prose, agents do the write by hand like every other label).

## Open questions (asked on the thread)

1. Scope: Shaping only, or every lane an agent writes a card into? Recommended: every lane.
2. Does it apply to `by: due`? Recommended: never (a date is the owner's call).
