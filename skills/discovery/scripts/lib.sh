#!/bin/bash
# lib.sh: helpers shared by the discovery scripts. Source it; never run it.

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="$LIB_DIR/../templates"

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

# owner_handle <board>: from the guide's "human answers to `@handle`" line, else "human".
owner_handle() {
  local h=""
  [ -r "$1/CLAUDE.md" ] && h=$(grep -o 'human answers to `@[^`]*`' "$1/CLAUDE.md" | head -1 | sed 's/.*`@\([^`]*\)`/\1/')
  printf '%s' "${h:-human}"
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
