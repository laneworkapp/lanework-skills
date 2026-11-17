---
schema: 1
kind: comment
created:  {at: 2026-11-12T17:56:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
modified: {at: 2026-11-12T17:56:38Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Main"}}
---
**Evidence: the hand-rolled scripts, as sent by the Lanework Pitwall session on 2026-11-12.** All four are session-local and hardcode that board's path and that session's scratchpad. Reference for shaping, not code to copy.

Pitwall's notes on `succ-commit.sh`:

- After a commit through the private index, the real index still reflects the old HEAD. The closing `git reset -q -- paths` syncs only the named paths. Fine for board-only commits; a shipped version should say so.
- `merge --ff-only` updates the working tree, and refuses when one of the owner's uncommitted files overlaps an incoming change. The right stop, but the message should name the overlapping file.
- `update-ref HEAD~1` after a rejected push is safe only because the lock serialises commits. Keep the lock.
- The trailer is appended unconditionally, so a caller that also adds one gets it twice. Make it a parameter.

`post.sh` and `move.sh` share the defects in the card body (hardcoded `by`, no `order`); `move.sh` also uses `git mv`, and `post.sh` takes the first prefix match with no lint and no same-second guard.

The owner's word in that session, as Pitwall relayed it: "communicate these script suggestions to the skills session, let it sort those out." Relayed by a peer, so it is recorded here and not taken as the triage ruling.

````
===== succ-commit.sh
#!/bin/zsh
# usage: succ-commit.sh "<msg>" <path>...
# Board commit in the main checkout: holds main-git.lock, never stashes, never rebases.
# fetch + ff-only, private index, commit, push; on a rejected push it un-commits (ref only) and retries.
cd /Users/rzen/Indie/Apps/Lanework || exit 1
msg=$1; shift
S=<scratchpad>
L=$S/main-git.lock
until mkdir "$L" 2>/dev/null; do sleep 1; done
echo "succ-commit $$ $(date -u +%T)" > "$L/owner"
trap 'rm -rf "$L"' EXIT
stash_before=$(git stash list | wc -l)
ok=
for try in 1 2 3 4 5 6; do
  git fetch -q origin main
  if ! git merge -q --ff-only origin/main 2>/dev/null; then
    echo "ff-only to origin/main failed (local main diverged or dirty overlap); stopping"; exit 1
  fi
  idx=$(mktemp)
  GIT_INDEX_FILE=$idx git read-tree HEAD
  GIT_INDEX_FILE=$idx git add -A -- "$@" || { rm -f $idx; exit 1; }
  if GIT_INDEX_FILE=$idx git diff --cached --quiet; then echo "nothing to commit"; rm -f $idx; exit 0; fi
  GIT_INDEX_FILE=$idx git commit -q -m "$msg

Claude-Session: <session url>
  rm -f $idx
  if git push -q origin main 2>/dev/null; then ok=1; break; fi
  git update-ref refs/heads/main HEAD~1   # un-commit, files stay on disk; retry on fresh origin
  sleep 2
done
git reset -q -- "$@" 2>/dev/null
[[ $(git stash list | wc -l) -ne $stash_before ]] && echo "WARNING: stash count changed — tell the coordinator"
[[ -z $ok ]] && { echo "COMMIT/PUSH FAILED"; exit 1; }
git log --oneline -1 | cat
===== land-done.sh
#!/bin/zsh
# usage: land-done.sh <card8> <title-msg> <bodyfile>
SP=/private/tmp/claude-501/-Users-rzen-Indie-Apps-Lanework/fd84bd6f-f19c-4407-a1c4-adf9218838a5/scratchpad
cd /Users/rzen/Indie/Apps/Lanework || exit 1
B="Pitlane/Lanework Pipeline.lanework"
A=8b04eab5-d4e2-4200-bf84-9333c65397d7; D=11887032-bbbc-47c2-b65f-97c6fba409f5
card=$1; msg=$2; body=$3
src=$(ls -d "$B/$A/$card"*); name=${src:t}; dst="$B/$D/$name"
now=$(date -u +%FT%TZ); id=$(uuidgen | tr A-Z a-z)
mkdir -p "$src/comments/$id"
{ cat <<H
---
schema: 1
kind: comment
created: {at: $now, by: {name: lead, kind: agent, model: opus-5.5, session: "$card lead", role: lead}}
modified: {at: $now, by: {name: lead, kind: agent, model: opus-5.5, session: "$card lead", role: lead}}
---
H
cat "$body"; } > "$src/comments/$id/index.md"
python3 - "$src/index.md" "$now" <<'PY'
import sys,re
p,now=sys.argv[1:]
s=open(p).read()
s=re.sub(r'^modified: \{at: [^,}]*',f'modified: {{at: {now}',s,count=1,flags=re.M)
open(p,'w').write(s)
PY
mv "$src" "$dst" || exit 1
$SP/succ-commit.sh "$msg" "$src" "$dst"
===== post.sh
#!/bin/zsh
# usage: post.sh <card8> <bodyfile>  -> writes a record comment on the card wherever it is; prints path
B="/Users/rzen/Indie/Apps/Lanework/Pitlane/Lanework Pipeline.lanework"
c=$1; body=$2
d=$(ls -d "$B"/*/$c* | head -1)
id=$(uuidgen | tr A-Z a-z); t=$(date -u +%FT%TZ)
mkdir -p "$d/comments/$id"
{ echo "---"; echo "schema: 1"; echo "kind: comment"
  echo "created: {at: $t, by: {name: lead, kind: agent, model: opus-5.5, session: \"$c lead\", role: lead}}"
  echo "modified: {at: $t, by: {name: lead, kind: agent, model: opus-5.5, session: \"$c lead\", role: lead}}"
  echo "---"; cat "$body"; } > "$d/comments/$id/index.md"
echo "$d/comments/$id/index.md"
===== move.sh
#!/bin/zsh
# usage: move.sh <card8> <lane-id>  -> git mv the card, bumps modified
B="/Users/rzen/Indie/Apps/Lanework/Pitlane/Lanework Pipeline.lanework"
c=$1; lane=$2
d=$(ls -d "$B"/*/$c* | head -1); n=$(basename $d)
cd /Users/rzen/Indie/Apps/Lanework
git mv "$d" "$B/$lane/$n" || exit 1
t=$(date -u +%FT%TZ)
python3 - "$B/$lane/$n/index.md" "$t" "$c" <<'PY'
import sys,re
p,t,c=sys.argv[1:]
s=open(p).read()
s=re.sub(r'^modified: .*$', f'modified: {{at: {t}, by: {{name: lead, kind: agent, model: opus-5.5, session: "{c} lead", role: lead}}}}', s, count=1, flags=re.M)
open(p,'w').write(s)
PY
echo "$B/$lane/$n"
````
