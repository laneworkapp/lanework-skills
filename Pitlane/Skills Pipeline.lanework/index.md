---
schema: 1
kind: board
title: Skills Pipeline
id: 04b8692e-adef-4b77-959d-ca3e08eb7776
icon: {glyph: arrowshape.forward.fill}
config: {show-card-body: 3, labels: [{type: skill, text: Skill}]}
created:  {at: 2026-09-27T20:39:07Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-01T10:38:36Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
# Skills Pipeline

Where work on the Lanework agent skills goes from a raw idea to something shipped, one card per piece of work: a new skill, a change to an existing one, or a fix. Lanes are stages of commitment, so a card's lane says who acts next.

## How this board works

- **Flow**: Ideas to Shaping to Proposed to Approved to Active to Done, with Issues as the side entrance for something broken in a shipped skill, and Tasks as the owner's side entrance for chores that need no shaping.
- **Two human gates**: triage out of Ideas, and review out of Proposed. Agents surface what sits at a gate and never move a card through one. A chore the owner files in Tasks has passed both.
- **Every card names its skill** with a `Skill` label: `lanework`, `pitlane`, `pitwall`, `discovery`, or `repo` for work on the repository itself. A card that spans two skills carries both labels.
- **A card is ready to build** when its body names the files under `skills/` it touches, how it will be verified, and a done-when a reader could check without asking.
- **Verified means**: every changed script passes `bash -n` and a real run against a throwaway board outside the repo, with the output quoted in the closing comment. A prose change is read through against the `lanework-agent-guide` version the skills target.
- **Never test on this board.** Scripts under test run against a scratch board, never against this one.
- **The body is the spec, the thread is the journal.** Edit the body when scope or done-when change, and put everything else in comments.
- **Git**: this board lives in the skills repo. Commit your own board writes with a plain message, stage only your own paths, and keep board writes and skill changes in separate commits.
