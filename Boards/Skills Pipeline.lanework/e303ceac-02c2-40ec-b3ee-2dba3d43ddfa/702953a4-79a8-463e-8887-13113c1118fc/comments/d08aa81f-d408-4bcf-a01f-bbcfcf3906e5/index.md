---
schema: 1
kind: comment
in-reply-to: 776f738c-6943-43e5-b181-7060f298bce7
created:  {at: 2026-11-18T11:24:15Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Next on this card: one dotfiles commit, then it closes.**

- **Done**: the three `claude plugin` commands. The plugin list and the marketplace URL both check out (the record above).
- **Left**: commit `~/.claude/settings.json` to the dotfiles repo and push. The `dotfiles show --stat HEAD` posted above still shows the zellij commit of 11 November.
- **What goes in**: the `extraKnownMarketplaces` block and the `"lanework@lanework": true` line, nothing else.
- **What stays out**: the file's other uncommitted edits (permission entries, the `model` line, the `mattpocock-skills` line). So the staging is partial:

```sh
dotfiles add -p ~/.claude/settings.json
dotfiles commit -m "claude: install lanework from lanework-marketplace"
dotfiles push
```

- **Then**: `dotfiles show --stat HEAD` lists only `.claude/settings.json`, the card's done-when holds, and the card moves to Done.
- **Elsewhere on the board**, nothing an agent can build: two cards wait in Proposed, seven in Issues wait for triage, and the two cards in Active wait for the 0.9.0 release.
