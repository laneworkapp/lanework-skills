---
schema: 1
kind: comment
created:  {at: 2026-11-14T15:05:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
modified: {at: 2026-11-14T15:05:31Z, by: {name: claude, kind: agent, model: claude-fable-5-2}}
---
**Merged to main as `3bfa3b1`: `file-record.sh --supersedes <old uuid>` files a record whose `relations/` holds a `supersedes` relation to the old card.**

- **Built**: commit `8763e26` by a sonnet fixer on `card/b0199ddd-supersedes-relation`. Five files: the script, `records.md` § Superseding, the `SKILL.md` script row, `tests/smoke.sh`, and the README word counts for `discovery`.
- **Fail before**: the new smoke case, run against the script as it was, stopped at `file-record.sh: unknown argument: --supersedes` (the fixer's run, reported, not re-run by the lead).
- **Evidence**: `bash tests/smoke.sh` in a clean checkout of `3bfa3b1` printed `smoke: 157 passed`, exit 0, the lead's own run. Case 34 is the new one: one relation per target, the old card unchanged by checksum, and a question, a short id, an unknown uuid, a path and an uppercase uuid each refused with Decisions left as it was. The same suite passed on the branch head before the merge.
- **Reviewed**: the lead read the whole diff. No separate reviewer agent ran: the change is 15 lines of script.
- **Accepted limitation**: the script does not set the old card's status or post its comment. That stays by hand, as the body says.
- **Not checked**: how the app draws the relation. The suite's validator accepts it.
- **Release**: new behavior, so a minor bump when it is released. No CHANGELOG entry yet.

Attached:
- [smoke-3bfa3b1.txt](attachments/5b4ea45e-d0ae-4048-9220-f034a37b8be9/blob.txt)
