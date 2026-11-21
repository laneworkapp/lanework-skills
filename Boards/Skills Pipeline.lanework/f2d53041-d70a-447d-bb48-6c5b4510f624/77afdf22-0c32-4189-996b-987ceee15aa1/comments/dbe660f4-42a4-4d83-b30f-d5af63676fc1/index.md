---
schema: 1
kind: comment
created:  {at: 2026-11-21T18:45:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-21T18:45:26Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Filed from a documentation pass that read all 28 scripts against their code.**

- **Why**: the skills send agents to script headers for usage and exit codes, so a header that omits or misstates one becomes a wrong assumption at run time.
- **Evidence**: four readers, one group of skills each, listed every header claim the code contradicts or leaves out. A handful were spot-checked against the source (the two heal scripts' exit 64, the `lint-ask.sh` word test, the `lease.sh` exit codes).
- **Not checked**: the rest, line by line. Shaping re-checks each item before the card moves on.
- **Left alone**: no header or script is changed.
