---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:42:52Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
modified: {at: 2026-11-12T01:42:52Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "board watch"}}
---
**REQUEST-CHANGES: one blocking finding. A valid owner stamp spelled `kind: 'human'` reads as an agent's, so arming never answers it. The rest meets done-when as far as a script run can show.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (Phase-1 UNCERTAINTY not "none"; 2c06a25 changed behaviour after Phase-1)
ROUND:   1

CARD:   Active/4ada828e-56a0-4f1a-9b8b-094b330c71b7 "Dispatch arming: answer waiting owner comments in every lane, flag stale claims"
BRANCH: dispatch-arming-4ada828e at 2c06a25b20086e7406e30b6dbf25cbf35fa3e04e

BLOCKING: 1
  skills/dispatch/scripts/arm-pass.sh:44 @ 2c06a25 "blk ~ /kind: *\"?human/": the owner test allows only an optional double quote. A schema-valid owner comment stamped created: {at: <2h ago>, by: {name: Bob, kind: 'human'}} in Ideas classes as agent, so no comment line is printed and the waiting owner is never answered at arming. classify-event.sh reads the same stamp with yq and gets owner, which the header at line 22 says arm-pass matches ("as classify-event.sh reads it"). Reproduced on a throwaway board. Fix: accept either quote (kind: *["']?human), or read the stamp the way classify-event.sh does. In the same change, give the fixture a comment line from an owner who has a by: the HUMAN stamp the app writes (kind: "human") plus a single-quoted one. Today every asserted comment line comes from a comment with no by, and a mutant that reads every by-stamped comment as an agent's still passes ok 1-3 (run).

NOTES: 5
  skills/dispatch/scripts/arm-pass.sh:43 @ 2c06a25 "at: *\"?[0-9T:Z-]+" with line 37 "date -j -u -f '%Y-%m-%dT%H:%M:%SZ'": timestamps the schema allows that are not plain Z (fractional .123Z, a -05:00 offset, a space separator) parse to epoch 0. A fresh START prints "stale ... 29907459m", and the thread order sorts the raw string. Agents and the app write Z, so this only adds report noise.
  skills/dispatch/scripts/arm-pass.sh:46 @ 2c06a25 "/^---[ \t]*$/": a CRLF comment file (the guide says keep a file's existing line endings) never finds its frontmatter. A CRLF owner comment prints no line, and a CRLF START reads as no claim. lib.sh fm_value has the same limit, so CRLF is unsupported across the skills, but lines 49-50 strip \r as if it were supported.
  skills/dispatch/scripts/arm-pass.sh:87 @ 2c06a25 "START*)": only a START counts as a claim. work/references/companions.md says "A START / plan comment is a claim", so a dead Plan-only claim is never flagged stale. The card ruled on START, so this holds. arm lines stay safe because the handler re-checks the claim.
  routing.md:21 @ 2c06a25 "the card's newest owner comment": only the newest owner comment decides. In a lane that isn't an agent lane, an older owner comment that was never answered, with a newer one that was, prints nothing (run). The card's Proposal says "newest" and its Direction says "an owner comment". The Proposal is the shaped text, so this is not blocking. In agent lanes the handler.md arm row covers the older comment.
  Thread: comments 9c181698, f064feb2 and 50d429a8 (the lint-stamps and clock-stamps build records for 360edc1c) and an empty 8bdc0bdd were posted on this card. They belong on 360edc1c's thread.

CHECKED:
  correctness vs done-when: the smoke fixture prints exactly the eight lines (lane, card, class, title, path, minutes band 110-129). On attack boards: no by, kind human, kind "human", flow form with odd spacing, block form, and by on the next line all read as owner. A bare by: Bob and a kind: agent named humane read as agent. Unanswered: an in-reply-to reply (quoted or bare) clears it. A later agent comment with no in-reply-to does not, matching handler.md. A button-click reply prints a comment line. Done, the board .trash and a lane-level .trash print nothing. Tasks and Issues print. Claims: 29m silent prints nothing, 31m prints stale. A future stamp is never flagged. A later owner comment freshens a claim, per the ruling. START, Merged, then a new START is claimed again. A receipt counts as no reply and no activity. Parsing: block-form waiting, relations/, comment attachments/, quoted lane title "Tasks", a card with no comments/ and a uuid folder with no index.md are all fine. The live trial (a dispatch arm answering an owner comment in a lane that isn't an agent lane) and the /clear and restart checks are still open; they are the lead's, not findings.
  project conduct:          awk and BSD date, macOS bash 3.2 (the replies array is guarded under set -u). The lanework/scripts/lib.sh relative source matches the siblings. Cites follow the convention. The SKILL.md hub table row is added. No "assume Y" shapes. The fixer's no-yq choice departs from classify-event.sh (yq); that departure is where the blocking finding comes from.
  both paths:               arm lines: a claim the script misses (Plan-only) still gets an arm line, and the handler re-checks the claim, so it is safe. A claim the script holds on to (a START closed in an unlisted shape) gets no arm line, the same result as the old any-START rule in watch/references/arming.md, and is flagged stale after 30 minutes. Nothing the old read-board.sh arming did is lost. stale is never routed: routing.md step 3 says "Never routed, never released" and step 5 only reports it. The line never reaches state.sh claim.
  fail-before:              OWN RUN agreed: the branch's case block at merge-base 2dc7b75 in the scratch worktree fails with "skills/dispatch/scripts/arm-pass.sh: No such file or directory" (exit 127 in my harness, 1 in the fixer's; same observable). With the branch's script: ok 1-3.
  test adequacy:            located with the dispatch cases, named like its neighbours. Mutants: flag every claim stale, print nothing in lanes that aren't agent lanes, ignore closing comments: each fails ok 1. Read a by-stamped owner as agent: passes (see BLOCKING).
  blast radius:             6 files, +156 -8. These are the card's Files list plus the SKILL.md hub row the one-topic rule needs. 2c06a25 touches only arm-pass.sh (+3 -1) and smoke.sh (+5 -1). No unexplained churn.
  population:               on a scratch copy of this board: 11 cards outside Done (6 Active, 4 Ideas, 1 Issues), giving 2 arm (both Active, claims closed by Landed and Merged), 2 comment (73dbde19 and this card: owner ruling 8b62f0c3 has no in-reply-to answer) and 0 stale (the three open claims had comments in the last 30 minutes). Run time 1.0 s. check-sizes 62 rows 0 wrong. check-refs 249 references 0 missing. bash -n clean.
  adversarial only:         the thread dump came with the card, so I saw the fixer's records early. I wrote my hypotheses from the diff before checking them against those records. Held: the quote-style owner misread (blocking), non-Z timestamps, CRLF, Plan claims. Did not hold: a stale line causing a release or a route; a receipt freshening a claim; Done leaking lines; the Approved top-card logic; a title with a colon or quotes breaking the fields.

UNRESOLVED: none
```
