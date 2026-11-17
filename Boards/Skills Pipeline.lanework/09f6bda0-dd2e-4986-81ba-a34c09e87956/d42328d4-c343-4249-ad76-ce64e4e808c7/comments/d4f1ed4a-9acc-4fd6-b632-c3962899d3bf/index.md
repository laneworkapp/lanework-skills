---
schema: 1
kind: comment
created:  {at: 2026-11-17T13:40:34Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T13:40:34Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: APPROVE.** The diff is the body's three edits and nothing else, nothing left in the repo reads the deleted file, and the plugin block still fails on a skills mismatch; 2 notes.

- **Stance**: standard (three files, +3/-25; deletes a file `stable` users of the old catalog read)
- **Round**: 1
- **Card**: [Remove this repo's own marketplace.json](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7)
- **Branch**: `drop-marketplace-json` at `225a835`

**Blocking**: none.

**Notes**

1. Release consequence, for whoever cuts 0.9.0: both catalogs are named `lanework`, so a user who never followed the 0.8.0 notice still has a `lanework` marketplace pointing at this repo, and their next `/plugin marketplace update lanework` fails once `stable` lacks the file. That is the risk the body accepts, and the 0.8.0 notice (`CHANGELOG.md:5 @ v0.8.0` "Existing plugin users: Lanework now installs from a central marketplace") covers it. The thread's condition stands: move the owner's install ([Move the owner's install](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/702953a4-79a8-463e-8887-13113c1118fc)) before 0.9.0 is cut, then re-run `lanework-marketplace/scripts/check.sh` against the new `stable`.
2. `tests/smoke.sh:1708 @ 225a835` "plugin manifests match the skills folders and validate": the comment above the block was made singular but the `ok` label still says "manifests". It is cosmetic, and renaming it would change the case name the fixer cited. Leave it or fix it in passing.

**Checked**

- **Correctness vs done-when**: the diff from merge-base `17fb6c1` touches exactly `.claude-plugin/marketplace.json` (deleted), `CLAUDE.md` and `tests/smoke.sh`, as the Files list says. No `skills/` change, no `CHANGELOG.md` entry, and `plugin.json` stays at `0.8.0`.
  - `git grep -n marketplace.json drop-marketplace-json`, excluding `Boards/`, `Lanework/` and `notes/`, finds nothing.
  - The "`stable` has no file" part of done-when is met only by a release, which is the owner's call.
- **Project conduct**: the `CLAUDE.md` row edit is in scope, since the body says "say the plugin is listed in `laneworkapp/lanework-marketplace`". Its claim "tracks the `stable` branch" matches the central catalog's `"ref": "stable"`. § Releasing (`CLAUDE.md:32` "`stable` is what plugin users get") still reads true. The smoke comment rewording is in scope as part of the plugin block edit. No "assume Y" shapes.
- **Both paths**: these other readers do not read the deleted file: `scripts/release.sh` reads `plugin.json` only (`M=.claude-plugin/plugin.json`); `.github/workflows/smoke.yml` only mentions branches; `tests/check-refs.sh` and `tests/check-sizes.sh` never mention it; `README.md:145`/`:149` name the central marketplace.
  - The central catalog lists the plugin by `{source: url, url, ref: stable}`, and its `scripts/check.sh` only runs `git ls-remote` for the ref, so neither it nor plugin install needs a `marketplace.json` in this repo.
- **Fail-before**: FIXER RUN checked. The body adds no assertion, and the fixer's grep at the merge-base (3 hits) is the before-state.
  - OWN RUN, plugin block only: the block, run on a `git archive` copy of the branch in scratch, passes clean and exits 1 with `plugin.json skills [...] != folders [...]` when one skill is dropped from `plugin.json`.
  - OWN RUN: `claude plugin validate` on that copy, which has no `marketplace.json`, prints `Validation passed with warnings`, and the only warning above the directory checks is the known CLAUDE.md-at-root one that smoke allows.
- **Test adequacy**: no new case. The skills-vs-folders assert and `claude plugin validate` stay in the same case, as the body asks.
- **Blast radius**: 3 files expected, 3 changed. Since the merge-base, `main` has moved only under `Boards/`. The lead's START names `e53a5f0` as the cut point, but the fixer's `17fb6c1` is the real merge-base, a board-only descendant of it, so it is harmless.
- **Population**: smoke is `168 passed` from the fixer's run at `225a835`, the same count as main. I relied on that run and did not do my own full run.
