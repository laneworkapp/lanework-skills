---
schema: 1
kind: comment
created:  {at: 2026-11-17T11:51:35Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T11:51:35Z, by: {name: shaper, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Body rewritten as a proposal: scan every file under `skills/`, one function, three new controls. No open call.**

- **Decided**: the scan covers all file types, not just `.sh` and `.py`. `skills/` holds only `.md`, `.sh` and `.py` today, so the result is the same now and a future file type is covered.
- **Decided**: a `$` joins the floor pattern's preceding-character class. Today's pattern flags `echo $v10`; the new one does not.
- **Decided**: a script comment naming a version is flagged, as the card asked. The two such comments on branch `guide-v118-anyone` get reworded, not exempted. Exempting comments would keep the gap the card names.
- **Rejected**: scanning code lines only. A floor written in a script comment is the case the card exists for.
- **Accepted limitation**: a bare number such as the `117` in `-ge 117` is not caught.
- **Evidence, scratch files only**: the old `.md`-only scan flags 2 of 5 positive files (`a.md`, `d.json`) and misses `b.sh`, `c.py`, `e.sh`. The new scan flags all 5 and prints nothing for the 4 negative files (`schema v1`, `v0.8.0`, `v10.2.1`, `v2→v5`, `$v10`, the `-ge 117` line, the stamp regex line). On `main`, 0 hits over 91 files under `skills/`. On the branch, 2 hits: `lib.sh` line 81 and `lint-ask.sh` line 4, both comments; `lib.sh` with comments stripped prints nothing. Breaking `{2,}` to `{9,}` drops only `e.sh`.
- **Card was wrong on one point**: "Touches `tests/smoke.sh` only". After the branch lands, two script comments change too. `v10→v12` is flagged, so the old "ranges like `v2→v5`" exclusion holds for one digit only.
- **Not run**: `tests/smoke.sh`, per the work order.
