---
schema: 1
kind: comment
created:  {at: 2026-11-14T22:04:39Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
in-reply-to: c4fc6d82-2dd2-4784-b837-3096ceff8ae8
---
**The v117 guide keys exactly two rules to a guide version. Everything else that moved between versions is a one-time change the skills took up at a catch-up.**

**Rules the guide itself ties to a version** (an agent must read the board's guide line before writing):

| feature | floor | below the floor |
|---|---|---|
| `waiting.for` as a list, `for: [a, b]` | v105 | an older build reads a list as no one and never clears it |
| `@anyone` on an ask and `for: anyone` | v117 | an older build reads `anyone` as a handle nobody has and draws no buttons, so keep `for: human` and the handle |

**Features that arrived at a version and changed the skills** (from the catch-up cards):

| version | feature | what changed in the skills |
|---|---|---|
| v93 | `waiting` clears on a reply `in-reply-to` the ask; tracker engine and its reserved names removed; the board ships its own heal | one prose line; the skill's heal steps aside |
| v101 | compact form is the only written form; lane `card-defaults.labels` takes kinded entries; `.gitignore` seed v5 | every writer script, the heal and the merge driver |
| v105 | `waiting.for` list | prose |
| v107 | short `lanework://` links read by prefix | prose; scripts still match full ids |
| v108 to v114 | `relations/` under a card; reserved name `board` and move receipts; `component` retired as a built-in; lane `background` unread | the heal's reserved names and its walk; prose |
| v117 | `@anyone`, reserved name `anyone`, `cite-as` | `lib.sh`, `lint-ask.sh`, three reserved-name lists, ask templates (card [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8)) |

- **Checked**: grep of the working-tree guide for a version number finds three lines: the stamp on line 1, line 1071 (v117) and line 1092 (v105). "Older build" appears only on those two rules.
- **Not version-specific**: the rest of the guide leans on "unknown keys are preserved and ignored", so a newer key on an older board does no harm and needs no floor.
- **What this means for the gate**: only the two floors change what a script must do on a given board, and both are read from the board at run time, not from the stamp. The stamp guards the second table: changes that need a read of the skills once. That fits a check at release.
- **Not known**: features between the listed versions that needed no skill change (v83, v84 and others) were not itemized on their cards.
