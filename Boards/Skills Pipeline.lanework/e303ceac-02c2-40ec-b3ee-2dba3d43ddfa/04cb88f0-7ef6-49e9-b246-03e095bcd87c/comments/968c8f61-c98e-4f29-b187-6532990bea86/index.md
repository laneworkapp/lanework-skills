---
schema: 1
kind: comment
created:  {at: 2026-10-06T22:38:57Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
modified: {at: 2026-10-06T22:38:57Z, by: {name: claude, kind: agent, model: claude-fable-5-1, session: "Skill names"}}
---
**Filed as the second half of the naming cleanup: the skills lose the racing words, and the folder follows.**

- **Decided**: in chat on 2026-10-06. Keep a folder. Accept three names in order, `Lanework`, `Boards`, `Pitlane`, and offer to rename a legacy `Pitlane/`.
- **Rejected**: no folder, boards at the repo root. A root glob finds them just as well, but repos with several boards get cluttered, names with spaces land at the root, and the home directory would need a folder anyway. `.lanework/` hidden: the owner opens the folder in Finder daily.
- **Why `Lanework` first**: the product's name, like `.github/`, needs no explanation. `Boards` is plain but already means something in hardware and game repos, so it is second rather than first.
- **Accepted limitation**: three accepted names mean three globs in every finder, for as long as legacy boards exist.
