---
schema: 1
kind: card
title: "Move the guide-version gate out of smoke and into the release"
order: 1024
labels: [{text: repo, kind: {type: skill, text: Skill}}, {text: lanework, kind: {type: skill, text: Skill}}]
created:  {at: 2026-11-14T03:56:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T03:56:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
waiting: {for: anyone, since: 2026-11-14T03:56:59Z, comment: 77ca5db1-b234-4514-9a87-8dd1f261451b}
---
The guide-version stamp finds real drift, but the smoke gate built on it turns main red whenever the app upgrades this board's guide, so this card proposes checking the stamp only at release and keeping it out of everyday smoke.

## What the stamp does today

- **The stamp**: one line in the repo's `CLAUDE.md`, `lanework-agent-guide v114` and `lanework-schema v1`. It records which guide the skills were last read against.
- **Nothing shipped carries it.** Smoke fails when any file under `skills/` names a guide version (`tests/smoke.sh:1305`). The runtime compare of board against target went on 2026-10-06 (`3bda3ed`).
- **Its one job is the gate** at `tests/smoke.sh:1444`: smoke fails when this board's guide (line 1 of its `CLAUDE.md`) or `.schema/VERSION` is newer than the stamp. That forces a read of every skill against the new guide before anything else goes green.
- **Ruled once already**, on 2026-10-06, on [4a97bc2b](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4a97bc2b-2950-4522-9a1b-03e64511ac77): keep the stamp and the gate, and retire them "once the skills repeat nothing from the guide".

## What it has caught

The guide went from v82 to v117 between 2026-10-06 and 2026-11-12. The gate tripped six times.

| catch-up | card | what the skills needed |
|---|---|---|
| v83 | [8cb716fa](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/8cb716fa-d396-4661-b148-33838f76f150) | nothing: a one-line stamp bump (`fa797dd`) |
| v84 | [1a63eb6b](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/1a63eb6b-52b3-44b9-8b0a-a1aec41d4dcd) | nothing: a one-line stamp bump (`42107c6`) |
| v93 | [ef174605](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ef174605-8c92-449a-b4bd-1c2bb4879409) | 5 files, 13 lines added and 20 removed (`cb6ebb9`) |
| v101 | [3d4b9109](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/3d4b9109-8eeb-413d-9db0-fb602754b19f) | 4 files, 11 added and 10 removed (`110d18f`), plus the compact-form change (`246abc1`) |
| v114 | [2c29a34f](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2c29a34f-fde2-4a44-8a3b-94157a320609) | 23 files under `skills/` and `tests/`, 182 added and 168 removed (merge `2dc7b75`) |
| v117 | [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8), open | about ten files, by its own drift table |

- **Four of six trips found real drift.** The gate earns its keep as a reminder.
- **The retirement condition will not be met.** The scripts write board files, so they encode what the guide specifies however little the prose restates. Pointing the prose at the guide ([43456b82](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/43456b82-7956-4027-a435-e78fa9badbea)) did not end the drift: v93, v101, v114 and v117 all came after it.

## What it costs

The costs come from where the gate sits, not from the number.

- **It reads the working tree.** The app rewrites this board's guide when it upgrades, so smoke on main goes red with no commit involved. It is red now: the working-tree guide reads v117, the stamp v114.
- **Local and CI disagree.** A clean checkout sees the committed v114 guide and passes. The main checkout sees v117 and fails.
- **It blocks unrelated work.** [7655176d](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/7655176d-d184-4955-bf9f-5f338a62be0f) (the board helper scripts) records that its build waits on the v117 card only because of the gate.
- **The number is a coarse trigger.** Any guide edit trips it. Two of six trips needed no skill change, and each still cost an issue card, a stamp commit and board commits.
- **Every catch-up is a full cycle**: a card, a shaping pass, a build, a review. Six in five weeks.

## Options

1. **Gate at release, not in smoke.** `scripts/release.sh` refuses to cut a release while the stamp is behind the committed guide (`git show HEAD:` of this board's `CLAUDE.md` and `.schema/VERSION`). Smoke prints one note when the working-tree guide is ahead and stays green. A release still cannot ship unread against the current guide. An app upgrade no longer reddens main, splits local from CI, or blocks other cards.
2. **Let the catch-up card be the tracker.** The watch already files a "Skills target agent guide vN" card when line 1 of the guide changes. Under option 1 the stamp is just the line that card bumps. No new mechanism.
3. **Drop the stamp and the gate.** Script drift would still show through the validator and `tests/fixtures/app-writes/`. Prose drift (who an ask addresses, which names are reserved) would go unseen until an agent follows a stale rule. Most of the v114 catch-up was that kind.
4. **Keep both in smoke, as today.** The costs above continue at about one trip a week.
5. **Cheaper catch-ups from the app side.** A short "what changed for agents" note per guide version would let a no-op bump like v83 or v84 be dismissed in seconds. Outside this repo. Independent of the choice above.

## Open call

- **Which way the stamp goes: option 1 with 2 (recommended), option 3, or option 4.** Asked on this card.

## Recommendation

Options 1 and 2. They remove every cost listed and keep the reminder that found drift four times. Dropping the stamp (option 3) is not safe while the guide moves about seven versions a week and the skills still carry prose that restates it.

## Touches, under the recommendation

| file | change |
|---|---|
| `tests/smoke.sh` (the release-gate block at line 1444) | compare, print a note when the working-tree guide or schema is ahead, do not fail. The one-stamp and no-version-under-`skills/` checks stay. |
| `scripts/release.sh` | new check before anything is tagged or pushed: stamp not behind the committed guide and schema, in `--dry-run` too |
| repo `CLAUDE.md` (the guide bullet, § Releasing) | "smoke also gates the stamp" becomes "the release gates the stamp" |
| `README.md` § Versioning | same wording change |
| `.github/workflows/smoke.yml` | none: CI already sees only the committed guide |

No file under `skills/` changes.

## Verified by

- `tests/smoke.sh` green in the main checkout while the working-tree guide is ahead of the stamp, with the note printed. A scratch copy with the stamp set one version behind the committed guide: smoke still green, `scripts/release.sh X.Y.Z --dry-run` exits non-zero and names both versions.
- A second stamp under `skills/` still fails smoke.
- `release.sh --dry-run` on a tree whose stamp matches the committed guide passes the new check.

## Done when

- Smoke never fails because of the guide version on this board, in the working tree or committed.
- `scripts/release.sh` cannot cut a release while the committed guide or schema is newer than the stamp, and says why.
- `CLAUDE.md` and `README.md` describe the gate as a release check.

## Note for the v117 card

Separate from the call above, for whoever builds [9e04cdec](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9e04cdec-c118-4dd1-89b7-8ec4cb9602f8):

- It adds `guide_version` and `ask_handle` to `lanework/scripts/lib.sh`, keyed to "v117 or later". That is a version-keyed rule for older boards, the kind [4a97bc2b](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/4a97bc2b-2950-4522-9a1b-03e64511ac77) rejected on 2026-09-28. The v117 guide now tells agents to do exactly this (§ Mentions: "Only write `anyone` on a board whose guide line reads v117 or later"), so the design follows the guide.
- An alternative with no number: test whether the board's guide mentions `for: anyone`. The committed v114 guide has zero matches, the v117 guide ten. It breaks if the guide rewords, so the version read is the safer of the two.
- Its drift table plans prose such as "v114-and-older boards keep the handle" in `work/references/writing.md`. A version written in a skill's prose fails smoke's no-version check. Keep the number in `lib.sh` alone and have the prose say "an older board".

## Risks

- **A late surprise at release.** Drift is found when a release is cut instead of the day the guide moves. The watch-filed card and the smoke note cover the gap.
- **The note gets ignored.** A printed note is weaker than a red suite. The release check is the backstop.
- **Committed against working tree.** The release check reads the committed guide, so a guide the app has rewritten but nobody has committed does not block. That is the same view CI has today.
