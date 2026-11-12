---
schema: 1
kind: card
title: "Shaping: assign a label from the kind the lane is grouped by"
order: 5120
labels: [{text: work, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-12T00:35:26Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-11-12T00:54:48Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
The owner asked on 2026-11-11 that when a card is shaped, the agent read what the Shaping lane is grouped by and try to give the card a fitting label of that kind. The card then lands in a real section, not the trailing "No <kind>" one.

## Proposal

**One rule, in one place, for shaping only** (owner ruling, 2026-11-12): a new bullet in `skills/work/references/sweep.md`, under the workload table whose "Shaping to advance" row (line 26) is the only place the flow names shaping; the row gets a pointer to it. It binds an agent shaping a card in a Shaping lane, and nothing else: filing and moving into other lanes are unchanged. No other file restates it.

The bullet, in the skills' telegraphic style:

- **Shaping in a grouped lane** (the Shaping lane's `group: {by: label, kind: K}`, K not `priority`; guide § Frontmatter, lanes): the lane sections on kind K, and a drop assigns it. A file write assigns nothing, so write it yourself.
  - Card already has an entry of K → leave it. Never overwrite the owner's value.
  - Else pick one value that fits the card: closed kind → one of its listed values in `config.labels`; open kind → a value already on a card in the board, never a new spelling.
  - Write it as a drop would: the flattened `labels` entry of K, stamped from the board's current `config.labels` (guide § Frontmatter, `labels`).
  - Unsure → leave it off and say so in the record. A wrong section is worse than the trailing one.
  - `by: modified` / `created`, no `group`, or `by: label` without `kind` → nothing to do. `by: priority` or `kind: priority` → never assign a priority: off limits, the owner's call (owner ruling, 2026-11-12). `by: due` → never assign a date: a date is the owner's call (owner ruling, 2026-11-12).

**Scope**: a prose change to one skill file. No script writes labels for a shaped card (`grep card-defaults` finds only `writes.md`), so there is no code and no smoke case.

## Touches

- `skills/work/references/sweep.md`: the bullet above (~90 words) under the workload table, and a pointer to it in the Shaping row (line 26).
- `README.md` § Sizes: the word count for that file (`tests/check-sizes.sh` fails otherwise), and the summary totals.
- Not touched: `lanework/references/writes.md`, `work/SKILL.md`, `board-kinds.md`, templates, scripts, `plugin.json`.

## Risks

- **An agent guesses a priority.** Ruled out: priority is never assigned.
- **Collides with the owner's drop.** A shaped card keeps the owner's value (never overwrite), so no.
- **Skills Pipeline's Shaping lane has no `group` today**, so nothing here changes how this board runs until the owner sets one. The rule is for boards that do.
- **Version stamp**: the board's guide is v114, the repo stamps v101 (`CLAUDE.md`), and smoke fails when the board's guide is newer. That drift predates this card and is not fixed here.

## Verified when

Prose change, so verified = read through against the guide's `group` section (CLAUDE.md lines 178-235) and `lanework/references/writes.md`'s other bullets for contradiction, plus `tests/smoke.sh` green (its `check-refs.sh` and `check-sizes.sh` cover the new pointer and the README counts).

## Done when

1. `sweep.md` has the grouped-lane shaping bullet; it names the four outcomes (already set, assign, unsure, nothing to do) and the `due` ruling.
2. The Shaping row points at it; the rule text appears nowhere else under `skills/`.
3. `tests/smoke.sh` exits 0 and README § Sizes matches `wc -w`.
4. Changelog: a user-facing entry if the owner cuts 0.8.0 with it.

## Recommendation

Build it as ruled: Shaping only, `due` and `priority` never assigned. It is trivial (one prose file plus the README counts, no script), so it can ride 0.8.0 if approved in time. Deferred: any script that stamps the label.

## Rulings

- **Scope**: Shaping only (owner, 2026-11-12, comment 7d30bca0).
- **Due grouping**: an agent never assigns a due date (owner, 2026-11-12, comment 2bbea8c7).
- **Priority grouping**: off limits, an agent never assigns a priority (owner, 2026-11-12, comment f088fd85).
