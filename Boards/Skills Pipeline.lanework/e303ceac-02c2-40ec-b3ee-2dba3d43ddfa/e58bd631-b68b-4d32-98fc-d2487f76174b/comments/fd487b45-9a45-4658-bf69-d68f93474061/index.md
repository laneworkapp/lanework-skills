---
schema: 1
kind: comment
created:  {at: 2026-11-28T13:20:20Z, by: {name: claude, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills fixer"}}
modified: {at: 2026-11-28T13:20:20Z, by: {name: claude, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills fixer"}}
---
Done: heal-descriptors.py --apply now refuses a padded --name (exit 64, nothing written); found-board.sh header trimmed; smoke case added. Gate green.

- Commits on branch padded-name: e2827547 (scripts), f98f134a (smoke).
- Changed: heal-descriptors.py refuses name != name.strip() before the reserved-name test, stderr "heal-descriptors: ' board' has leading or trailing whitespace; sign as yourself; nothing written"; header exit text names "padded". found-board.sh header line 13 drops the shared cause. Dry run untouched.
- Smoke: new case after the "--name board" case (section label_kinds): ' board', 'board ', ' claude' each exit 64, board checksum unchanged; dry run with ' claude' matches the plain dry run (output and exit).
- Fail-before (old script, section label_kinds): "heal-descriptors --apply --name ' board': rc=0".
- Gate: smoke --only static,headers,usage_guard,plugin,versions,cite_as,release_gate,heal_descriptors,lane_actors,label_kinds, exit 0: "smoke: 77 passed (sections: static, lane_actors, label_kinds, versions, headers, release_gate, cite_as, heal_descriptors, usage_guard, plugin)". check-refs: 262 references, 0 missing. check-sizes: 59 rows, 0 wrong. bash -n and ast.parse clean.
- Measured: all of the above. Reasoned: no guide shows a padded call.
- Differences from card: the case sits in label_kinds, not heal_descriptors; the card's --only list lacked that section. Not run: braces and full suite (lead's gate).
- Changelog draft: The heal descriptors tool now refuses a signer name with leading or trailing spaces, like every other board writer.
