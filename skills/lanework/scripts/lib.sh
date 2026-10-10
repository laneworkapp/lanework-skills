#!/bin/bash
# lib.sh: board helpers shared by every skill's scripts. Source it; never run it.
# From a sibling skill: . "$(dirname "${BASH_SOURCE[0]}")/../../lanework/scripts/lib.sh"

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# flat_str <s>: a title on one line: each CRLF, CR and LF becomes one space. Markdown headings use it as is.
flat_str() { local s="${1//$'\r\n'/ }"; s="${s//$'\n'/ }"; printf '%s' "${s//$'\r'/ }"; }

# title_str <s>: a title's text for use inside double quotes (no outer quotes, so a prefix like "Q3: " can precede it):
# flat_str, then backslash and quote are escaped. Every title a script writes goes through it.
title_str() { local s; s="$(flat_str "$1")"; s="${s//\\/\\\\}"; printf '%s' "${s//\"/\\\"}"; }

# merge_kinds <list> <have> <new>: a repeated --labels. Appends <new>'s kinds to <list> (comma list; <have> non-empty once a --labels was given),
# skipping a kind an earlier flag already named. An empty name is kept, so found-board.sh rejects it.
merge_kinds() {
  local out="$1" have="$2" rest="$3," k
  while [ -n "$rest" ]; do
    k="${rest%%,*}"; rest="${rest#*,}"
    if [ -n "$k" ]; then case ",$1," in *",$k,"*) continue ;; esac; fi
    if [ -n "$have" ]; then out="$out,$k"; else out="$k"; have=1; fi
  done
  printf '%s' "$out"
}

# require_model <script> <usage>: MODEL from --model, else CLAUDE_MODEL; exit 2 with the usage line when neither. Never stamps a guess.
require_model() {
  MODEL="${MODEL:-${CLAUDE_MODEL:-}}"
  [ -n "$MODEL" ] || { printf '%s: no model: pass --model <your model> or set CLAUDE_MODEL\nusage: %s\n' "$1" "$2" >&2; exit 2; }
}

# fm_value <file> <key>: raw scalar of a top-level frontmatter key.
fm_value() {
  awk -v key="$2" '
    NR==1 && $0=="---" { fm=1; next }
    fm && $0=="---" { exit }
    fm { n = index($0, ":"); if (n && substr($0, 1, n-1) == key) { v = substr($0, n+1); sub(/^[ \t]+/, "", v); print v; exit } }
  ' "$1"
}

strip_quotes() { local s="$1"; s="${s%\"}"; s="${s#\"}"; printf '%s' "$s"; }

# lane_by_title <board> <title>: path of the lane with that title.
lane_by_title() {
  local d
  for d in "$1"/*/; do
    d="${d%/}"
    [ -f "$d/index.md" ] || continue
    [ "$(fm_value "$d/index.md" kind)" = lane ] || continue
    [ "$(strip_quotes "$(fm_value "$d/index.md" title)")" = "$2" ] && { printf '%s' "$d"; return 0; }
  done
  return 1
}

# next_order <lane>: bottom of the lane (max order + 1024, or 1024 when empty).
next_order() {
  local f o max=""
  for f in "$1"/*/index.md; do
    [ -f "$f" ] || continue
    o=$(fm_value "$f" order)
    case "$o" in ''|*[!0-9.-]*) continue ;; esac
    if [ -z "$max" ] || awk -v a="$o" -v b="$max" 'BEGIN{exit !(a>b)}'; then max="$o"; fi
  done
  if [ -z "$max" ]; then echo 1024; else awk -v m="$max" 'BEGIN{print m+1024}'; fi
}

# owner_handle <board>: from the guide's "human answers to `@handle`" line; empty + exit 1 if none.
owner_handle() {
  local h=""
  [ -r "$1/CLAUDE.md" ] && h=$(grep -o 'human answers to `@[^`]*`' "$1/CLAUDE.md" | head -1 | sed 's/.*`@\([^`]*\)`/\1/')
  printf '%s' "$h"; [ -n "$h" ]
}

# by_of <name> <model> [session]: the stamp's `by` mapping.
by_of() {
  if [ -n "${3:-}" ]; then printf '{name: %s, kind: agent, model: %s, session: "%s"}' "$1" "$2" "$3"
  else printf '{name: %s, kind: agent, model: %s}' "$1" "$2"; fi
}

uuid() { uuidgen | tr 'A-Z' 'a-z'; }
now_utc() { date -u ${1:+-v+${1}S} +%FT%TZ; }   # now_utc [seconds-ahead]

# render <template> key value ...: print the template with every {{key}} filled.
# Dies on a {{key}} left unfilled.
render() {
  perl -e '
    my $f = shift; my %v; while (@ARGV) { my $k = shift; $v{$k} = shift; }
    open my $fh, "<", $f or die "render: $f: $!\n"; local $/; my $t = <$fh>;
    $t =~ s/\{\{(\w+)\}\}/exists $v{$1} ? $v{$1} : die "render: {{$1}} unfilled in $f\n"/ge;
    print $t;
  ' "$@"
}

# frontmatter_of <file>: the frontmatter block, both --- lines included.
frontmatter_of() { awk 'NR==1 && $0=="---" {print; fm=1; next} fm {print} fm && $0=="---" {exit}' "$1"; }

# comment_file <path> <created-at> <by> [in-reply-to] < body: write a comment index.md.
comment_file() {
  {
    printf '%s\n' '---' 'schema: 1' 'kind: comment'
    [ -n "${4:-}" ] && printf 'in-reply-to: %s\n' "$4"
    printf 'created:  {at: %s, by: %s}\n' "$2" "$3"
    printf 'modified: {at: %s, by: %s}\n' "$2" "$3"
    printf '%s\n' '---'
    cat
  } > "$1"
}
