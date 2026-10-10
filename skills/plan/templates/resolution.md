# Resolution shapes

The `--resolution` file for `scripts/resolve-ticket.sh`, which writes the `## Resolution` heading above it. Conclusion first. Record, glossary and asset lines only when written.

## Grilling, Prototype (HITL)

```markdown
**<YYYY-MM-DD>**: The engine runs in the app, as recommended. "<owner's words>"
ADR: [ADR: Engine lives in the app](lanework://<board>/<card>)
PDR: [PDR: Sync is free](lanework://<board>/<card>)
Glossary: **Tracker**, **Remote** in CONTEXT.md
Assets: `outline.md`, attached to the comment above
```

## Research, Task (AFK)

```markdown
**<YYYY-MM-DD>**: GitHub allows 5000 requests an hour per token. Source: <url>, read <YYYY-MM-DD>; report attached.
**<YYYY-MM-DD>**: Done: test org created. Facts: token in the keychain as `gh-sync-test`, 3 repos seeded.
```

A Task handed to the owner as a checklist: their words, as HITL.

## Moot, out of scope

```markdown
**<YYYY-MM-DD>**: Moot: no server, so nothing to host. Decided by [T1: Where the engine runs](lanework://<board>/<card>).
**<YYYY-MM-DD>**: Out of scope: past the destination, which covers cloud trackers only. "<owner's words, when the owner ruled>"
```
