---
schema: 1
kind: comment
in-reply-to: 13b4ed1f-4b98-4fe7-b89e-b500a65c1675
created:  {at: 2026-11-23T19:05:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T19:05:41Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**In plain terms: the work on this card is finished and tested, but it improves a skill you have since decided to remove.**

- **What this card did.** In the `plan` skill, a ticket used to list what it depends on as text in its body. Now each dependency is a `depends-on` relation, the same kind the app shows. The branch has two commits and its full test run passed (414 cases). It is not on `main`.
- **What changed since.** On the compatibility spike you ruled: "lets remove plan for now, i'll bring it back (maybe) under a different name."
- **The question.** Merge finished work into a skill that is about to be removed, or not?
- **A, land it.** `main` gets the change now. When `plan` is removed, the improved version is what sits in git history, ready if it comes back. Cost: one review pass, about an hour of machine time, for a skill nobody can use after the removal.
- **B, park it.** The branch stays unmerged. Nothing is reviewed or released. If `plan` returns, someone rebases the branch then, which gets harder the longer it waits.
- **C, land the shared part only.** The first commit adds relation helpers to the shared library and makes `discovery` write its `supersedes` relations through them, with identical output. That part is useful without `plan`. The `plan` part stays on the branch.
- **Why I recommend A.** The work is done, and a returning `plan` should start from the relations version, not the body-list one.
