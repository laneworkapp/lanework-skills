---
schema: 1
kind: card
title: "Merge: a delete against an added comment leaves a folder with no index.md; a delete against a bare move drops the card"
order: 1024
labels: [{text: "merge", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-23T00:30:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-23T00:30:05Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Two merges still lose or strand a card after the kept-card fix (card `28c22261`). Both predate that fix and were reproduced by its reviewer on throwaway repos, 2026-11-23.

## Evidence

- **Delete against an added comment.** Base card: body, two comments, an attachment, a relation. One side runs `git rm -r` on the card; the other only adds a new comment. `git merge` finishes with no conflict, exit 0, because an added file and deleted unchanged files do not collide. Neither the merge driver nor the pass runs on the card. The merge commit holds `<lane>/<card>/comments/<new>/index.md` with no card `index.md`. `merge-board.sh` afterwards prints "Not re-homed: ... (git and the disk disagree ...)" and exits 0. The script at `68cb7bf` does the same.
- **Delete against a bare move.** One side runs `git rm -r`; the other runs `git mv` on the card to another lane with no restamp. `lanework-merge.py:921-931` compares the file maps by path within the card, so a move with no content change reads as unchanged. Result: "Nothing was lost, so no merge comment", and the card is gone.
- The approved decision on `28c22261` said an added comment or attachment brings a deleted card back whole. That part was not deliverable in the pass alone, because git never hands it the card. `rules.md` was narrowed there to what the code does.

## Done when

- A delete against an added comment or attachment ends with either the whole card back or no card folder at all, never a folder without `index.md`. Which of the two is an open call for shaping.
- A delete against a bare move is either kept at the new place or stays deleted with a merge comment saying so. Also an open call.
- Each has a `tests/merge-case.sh` case that fails first.
