---
schema: 1
kind: comment
created:  {at: 2026-10-10T02:00:31Z, by: {name: fixer, kind: agent, model: sonnet}}
modified: {at: 2026-10-10T02:00:31Z, by: {name: fixer, kind: agent, model: sonnet}}
---
**Built and verified on `lane-actors` at 4637540: the full `tests/smoke.sh` passes, 53 of 53, up from 38 before the new cases.**

- **Decided, actor sentence**: the second sentence of every template lane body. Inside a body already carrying it word for word, nothing is inserted. A paraphrase is not recognised: a 60% word-overlap trial let the real Tasks body ("built straight through Active") pass without the trigger, so the rule is verbatim only and the owner sees any redundant insert in the dry run.
- **Decided, `--model`**: required with `--apply` (exit 2, nothing written); a dry run needs none. Name `claude` by default, `healer`, `shortcuts` and `tracker` refused.
- **Decided, Issues**: not an unasked agent lane per the card's permission line, so its body says an agent diagnoses and shapes a new issue and moves it to Proposed, not that it builds.
- **Decided, board writes**: the main board's sheet gained the Agent lanes line and `heal` in the Skill list (`index.md` only, uncommitted, restamped by `fixer`). The lead commits it.
- **Evidence**: gate `tests/smoke.sh` from the worktree, final line `smoke: 53 passed`, exit 0. Cases 39-48 are new: lane bodies, the table's single home, the watch prose, and heal-descriptors dry run, apply, no-model exit 2, idempotence, sheet insert, no-match board.
- **Evidence**: scratch runs under `$TMPDIR` only. A board founded from the 35ba2ce pipeline template: 8 changes (7 lane bodies replaced, 1 sheet line), validates, second run 0. Design loop 5, datapoint 5, discovery 6 replaced, each then 0 changes and validating. The real Skills Pipeline lane bodies pasted into a scratch board kept their prose with the actor sentence inserted after the first sentence. A CRLF lane with no `modified` and two paragraphs kept its line endings and second paragraph.
- **Accepted limitation**: `OLD_BODIES` in the script holds each template body up to 35ba2ce. A later template change must add the body it replaces there; `descriptors.md` says so, but no smoke case enforces it.
- **Accepted limitation**: README word counts for files this card did not touch (`finding.md`, `companions.md`, `lead.md`) moved too, because the table was regenerated from the files.
