---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:35:33Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T22:35:33Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
---
**Filed from the owner's early-user feedback: the pit lane and pit wall metaphors weren't landing with an IT audience.**

- **Decided**: plain verbs, chosen in chat on 2026-10-06. `watch` is settled. `work` is the owner's pick with a stated willingness to rename again during beta.
- **Rejected**: `shift` + `oncall` (on-call vocabulary, accurate but a theme to learn), `foreman` + `nightwatch` (maps the lead/fixer/reviewer cycle well but back to decoding), `run` (collides with a built-in skill).
- **Accepted limitation**: `watch` and `work` are generic. The plugin install namespaces them as `lanework:watch` and `lanework:work`; the symlink install does not, so a clash with another skill of the same name would be silent.
- **Deferred**: the `Pitlane/` boards folder keeps the racing word in daily view. The owner wants to settle the skill names first and take the folder up separately.
