# Lanework agent skills

Skills that let Claude agents work Lanework boards: plain folders of Markdown that the Lanework app renders live.

## Language

**Runner**:
A resident process, owned by the `run` skill, that watches one board and starts a fresh headless Claude job for each change the board's lanes call for. No Claude session sits in its loop.
_Avoid_: daemon, worker, agent loop

**Job**:
One headless `claude -p` run that a runner starts on one card, doing its work through the `work` skill and then exiting.
_Avoid_: task, handler (a handler is dispatch's subagent)

**Lease**:
The `claimed: {by, until}` key in a card's frontmatter that marks the card as taken until the time it names, honored by runner jobs and interactive sessions alike.
_Avoid_: lock, claim comment (a START comment is a record, not a lease)
