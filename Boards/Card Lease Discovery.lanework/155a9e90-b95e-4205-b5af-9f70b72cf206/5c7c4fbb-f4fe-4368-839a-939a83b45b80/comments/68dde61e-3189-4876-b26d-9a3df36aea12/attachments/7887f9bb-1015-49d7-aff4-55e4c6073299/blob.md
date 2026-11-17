# env in a Claude Code 2.1.321 session, names matching CLAUDE (token values left out)

```
CLAUDE_CODE_CHILD_SESSION=1
CLAUDE_CODE_ENTRYPOINT=cli
CLAUDE_CODE_SESSION_ID=<a uuid>
CLAUDE_PID=<a pid>
CLAUDECODE=1
```

# skills/lanework/scripts/lib.sh, by_of

```sh
# by_of <name> <model> [session]: the stamp's `by` mapping.
by_of() {
  if [ -n "${3:-}" ]; then printf '{name: %s, kind: agent, model: %s, session: "%s"}' "$1" "$2" "$3"
  else printf '{name: %s, kind: agent, model: %s}' "$1" "$2"; fi
}
```

# session values on stamps across this repo's boards

```
 474 session: "board watch"
 152 session: "board runner discovery"
  89 session: "board dispatch"
  63 session: "skills chat"
  20 session: "lanework-skills Pitwall"
  20 session: "Lanework Labels"
  14 session: "lanework-skills Main"
  13 session: "Skill names"
   9 session: "marketplace chat"
   6 session: "Palette Review"
   4 session: "plan skill"
   4 session: "Palette Labels"
```
