---
schema: 1
kind: card
title: "Guide version: drop the runtime check, make the stamp a release gate"
order: 4096
labels: [{text: lanework, kind: {type: skill, text: Skill}}, {text: discovery, kind: {type: skill, text: Skill}}, {text: repo, kind: {type: skill, text: Skill}}]
created:  {at: 2026-09-28T00:41:31Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-06T22:37:01Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
The app and skills ship together, and the app never downgrades a board's guide, so an agent gains nothing from comparing the board's guide version with the skills' target at runtime. The stamp's real job is a check before each coordinated release.

**Owner, 2026-10-05**: "we need to find a way to coordinate app releases with udpates to skills as they are (although my preference is that they wouldnt) coordinate agent guide versions." So the aim is skills that need no coordination, and the gate covers what remains. [Pointing at the board's own guide and schema](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/43456b82-7956-4027-a435-e78fa9badbea) removes most of the coupling.

- **Keep the stamp and the gate? ruled 2026-10-06: A, keep both.** The stamp moves to v82 once [the pointer card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/43456b82-7956-4027-a435-e78fa9badbea) has read every skill against v82. It can be retired once the skills repeat nothing from the guide.
- **Touches**: `skills/lanework/references/authority.md` (§ Versions goes; one line added), `skills/lanework/SKILL.md:37` and `skills/discovery/SKILL.md:60` (the "Target versions" pointers go), repo `CLAUDE.md` (the stamp moves here), `tests/smoke.sh` (the stamp rule and a new gate), `README.md` § Versioning.
- **The one line**: a feature the board's guide doesn't describe may not exist there, so follow the guide. This covers the leftover temporary gaps with no version compare.
- **Gate**: smoke fails when the Skills Pipeline board's guide (line 1 of its `CLAUDE.md`) or schema (`.schema/VERSION`) is newer than the stamp.
- **Verify**: smoke passes as is. A scratch copy of the stamp set one version behind makes the gate fail, and a second stamp under `skills/` still fails.
- **Done when**: no file under `skills/` names a guide version, the stamp exists once in `CLAUDE.md`, and smoke enforces both rules.
