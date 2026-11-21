#!/bin/bash
# Lint an ask comment before it lands.   Usage: lint-ask.sh <file> [<board dir>]
#   <file>   a comment index.md (frontmatter + body) or a bare body file
#   <board>  the .lanework folder; its CLAUDE.md names the human's handle, and on a guide v117+ board
#            `@anyone` is the human's handle too. Without it, the first @token outside code spans and URLs is taken as the handle.
# A body that mentions nobody is a record and passes untouched. A body is an ask for a handle when it names the
# human (the board's handle, or `@anyone` on v117+) anywhere, or starts its first line with anyone's handle; a mid-sentence
# mention of someone else stays a record. An ask must fit references/writing.md § The ask: handle on the first
# line (and every other @handle it names, outside code spans and URLs), under 80 words, one question, one clause per sentence (no em-dash, no semicolon),
# no hedging, a blank line after any list, every card it names linked (`lanework://<board-id>/<card-id>`
# somewhere in the body for each bare eight-hex id), and, when it lists options, the standing line
# `- Recap: Explain this in plain terms first` as the last of them (that line is left out of the word count). One line per violation on stdout and exit 1; silent exit 0
# when clean.
set -u
. "$(dirname "$0")/../../lanework/scripts/lib.sh"
[ $# -ge 1 ] || { echo "usage: lint-ask.sh <file> [<board dir>]" >&2; exit 2; }; f=$1; board=${2:-}
[ -r "$f" ] || { echo "no such file: $f"; exit 2; }
body=$(awk 'NR==1 && $0=="---" {fm=1; next} fm && $0=="---" {fm=0; next} !fm' "$f")
strip='s/`[^`]*`//g; s/\]\([^)]*\)/]/g; s#[[:alpha:]][[:alnum:]+.-]*://[^[:space:]>)]*##g'   # code spans, link targets, URLs
lead=$(printf '%s\n' "$body" | grep -v '^[[:space:]]*$' | head -1 | grep -o -E '^[[:space:]]*@[[:alnum:]_-]+' | sed 's/.*@//')   # a handle starting line 1 is an ask for that person
handle=""
[ -n "$board" ] && handle=$(owner_handle "$board" || true)
if [ -n "$board" ] && [ "$(ask_handle "$board" || true)" = anyone ] && printf '%s\n' "$body" | sed -E "$strip" | grep -q -i -E '(^|[^[:alnum:]_])@anyone([^[:alnum:]_-]|$)'; then handle=anyone; fi
# a leading handle wins: the ask is for that person (but below v117 `@anyone` is nobody's handle)
[ -z "$lead" ] || { [ "$lead" = anyone ] && [ -n "$board" ] && [ "$(ask_handle "$board" || true)" != anyone ]; } || handle=$lead
[ -n "$handle" ] || handle=$(printf '%s\n' "$body" | sed -E "$strip" | grep -o -E '(^|[^[:alnum:]_])@[[:alnum:]_-]+' | head -1 | sed 's/.*@//')
[ -n "$handle" ] || exit 0                                   # no mention anywhere: a record
mention="(^|[^[:alnum:]_])@$handle([^[:alnum:]_-]|$)"
printf '%s\n' "$body" | grep -q -i -E "$mention" || exit 0   # mentions someone else: not the human's ask
v=0; say() { echo "$1"; v=1; }
first=$(printf '%s\n' "$body" | grep -v '^[[:space:]]*$' | head -1)
printf '%s\n' "$first" | grep -q -i -E "$mention" || say "handle @$handle is not on the first line"
for h in $(printf '%s\n' "$body" | sed -E "$strip" | grep -o -E '(^|[^[:alnum:]_])@[[:alnum:]_-]+' | sed 's/.*@//' | sort -u -f); do   # several people: each on line 1
  [ "$(printf '%s' "$h" | tr 'A-Z' 'a-z')" = "$(printf '%s' "$handle" | tr 'A-Z' 'a-z')" ] && continue
  printf '%s\n' "$first" | grep -q -i -E "(^|[^[:alnum:]_])@$h([^[:alnum:]_-]|$)" || say "handle @$h is not on the first line"
done
recap='- Recap: Explain this in plain terms first'
lastopt=$(printf '%s\n' "$body" | grep -E '^[[:space:]]*- [A-Za-z][A-Za-z0-9 -]{0,20}: ' | tail -1)
[ -z "$lastopt" ] || [ "$lastopt" = "$recap" ] || say "options must end with the standing line: $recap"
words=$(printf '%s\n' "$body" | grep -v -x -F -e "$recap" | wc -w | tr -d ' ')
[ "$words" -le 80 ] || say "$words words; an ask stays under 80"
q=$(printf '%s\n' "$body" | grep -o '?' | wc -l | tr -d ' ')
[ "$q" -le 1 ] || say "$q question marks; two asks are two comments"
printf '%s\n' "$body" | grep -q -E '—|;' && say "a dash- or semicolon-chained sentence; one clause per sentence"
printf '%s\n' "$body" | grep -q -i -E 'worth (a|an|the|trying|checking|seeing)|might be (good|worth|nice)|a note (here )?on whether|if you get a chance|perhaps|maybe|would be (good|nice|great) to' && say "a hedged ask; say what you need"
printf '%s\n' "$body" | awk 'prev && $0 !~ /^[[:space:]]*$/ && $0 !~ /^[[:space:]]*- / && $0 !~ /^[[:space:]]/ {hit=1} {prev = ($0 ~ /^[[:space:]]*- /)} END {exit !hit}' && say "a list runs straight into the next line; leave a blank line after the list"
for id in $(printf '%s\n' "$body" | grep -o -E '(^|[^0-9a-f-])[0-9a-f]{8}([^0-9a-f-]|$)' | grep -o -E '[0-9a-f]{8}' | grep '[a-f]' | sort -u); do
  printf '%s\n' "$body" | grep -q -E "lanework://[0-9a-f-]{36}/$id" || say "card $id named without a lanework:// link"
done
exit $v
