---
schema: 1
kind: comment
created:  {at: 2026-10-10T00:16:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
modified: {at: 2026-10-10T00:16:22Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
---
**Owner's idea: uniform label kinds across boards, starting from priority (closed, single) and component (open, single).**

- **Decided**: the guide already suggests exact definitions for `priority` and `component`. The catalog cites those rather than restating them, and adds only the new kinds.
- **Decided**: `type` as a kind identity reads close to the guide's `kind` key. Fine in YAML (`{type: type}`), but `work-type` is the fallback name if it confuses.
- **Rejected**: machine `default-labels` as the only home. It lives outside the board, so a board synced or cloned to another machine loses the kinds. Board `config.labels` travels with the board.
- **Noted**: this board's own `skill` kind is `component` in all but name, and multi-valued. A card spanning two skills is why.
