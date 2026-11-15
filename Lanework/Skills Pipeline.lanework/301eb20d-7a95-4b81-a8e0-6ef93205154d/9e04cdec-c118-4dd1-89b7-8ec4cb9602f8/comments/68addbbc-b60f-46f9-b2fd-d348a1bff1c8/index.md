---
schema: 1
kind: comment
created:  {at: 2026-11-15T13:27:57Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**The app moved the guide to v118 on 2026-11-15. It adds one rule, which the skills already state, so this card's build stamps v118 and needs no extra file change.**

- **The change**, the whole diff from v117: "A comment that answers another comment carries `in-reply-to`, naming the one it answers, whoever wrote that one: a human's comment, another agent's, or your own. Not only an answer to an ask." The card window finds replies by this key alone, and an answer without it is hidden in the focused view.
- **In the skills today**: `lanework/references/writes.md` line 40, "Answering a specific comment → `in-reply-to: <its uuid>`". `post-comment.sh` and `comment_file` in `lib.sh` take it. `watch/references/responding.md` and `dispatch/references/handler.md` reply that way to owner comments.
- **Thin spot, for the builder to judge**: no page says the rule covers a reply to another agent's comment or to one's own. One clause in `writes.md` line 40 would close it.
- **For this card**: the stamp bump goes to v118, and the fixtures step re-copies from the v118 app writes. The spec is otherwise as written.
- **Seen on**: both boards' working-tree guides (Skills Pipeline and Card Lease Discovery) read v118. The schema is still v1. The app's guide files are not committed here.
