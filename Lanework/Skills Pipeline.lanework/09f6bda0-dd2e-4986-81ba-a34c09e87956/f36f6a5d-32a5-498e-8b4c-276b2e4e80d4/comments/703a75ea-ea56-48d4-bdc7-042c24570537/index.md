---
schema: 1
kind: comment
created:  {at: 2026-10-25T01:48:48Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-25T01:48:48Z, by: {name: reviewer, kind: agent, model: opus}}
---
**Review: REQUEST-CHANGES on `dispatch-skill` at `84bdef4`. Three owner actions can still be dropped silently. Smoke is green, and the new cases catch 10 of 13 mutations.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer ran at opus; Phase-1 UNCERTAINTY not "none")
ROUND:   1

CARD:   Active/f36f6a5d "Dispatch skill: a flat-context watch session"
BRANCH: dispatch-skill at 84bdef4

BLOCKING: 3
  1. state.sh:53 @ 84bdef4 "then echo \"relay $(cut -f3 <<<\"$row\")\"" + routing.md:45 "SendMessage the line to that build lead":
     the receiving side doesn't exist. Nothing in handler.md, handler-prompt.md or work/references/lead.md
     says what a lead does with a relayed event line. The relayed event is also never queued.
     Owner comments on a card mid-build -> relayed -> the lead carries on with the build -> finish drains an
     empty queue and the card leaves the in-flight set -> the comment is never answered. That breaks the
     done-when ("no owner comment ... left unanswered").
     Fix direction: claim under a lead queues the event as well as printing relay. The follow-up handler's
     "answer each owner comment with no agent reply in-reply-to it yet" rule keeps that idempotent.
     Add one handler.md line for relayed events.
  2. classify-event.sh:101 @ 84bdef4 "if [ \"$w\" = self ]; then who=self": a self stamp beats MOVE_FRESH
     with no age check. That contradicts the header (lines 21-22: "the owner unless that stamp is under
     MOVE_FRESH seconds old") and the fixer's own Decided bullet ("older than the burst is a bare mv,
     which reads as the owner's").
     Reproduced: the card's last stamp is a handler's (session "board dispatch", 2026-10-01), then a bare mv
     Shaping -> Approved. Output: "self Approved agent". The router drops it silently, so the owner's
     go-ahead is lost (the guide: a bare folder move = the owner's move).
     Fix direction: gate self by the same FRESH window as agent. Add a smoke case.
  3. classify-event.sh:120 @ 84bdef4 "out body" + routing.md:37 "| `body` | any | drop": a card the owner
     creates straight into an agent lane is the unflagged second path to "a card arrives in an agent lane".
     It isn't listed in UNCERTAINTY.
     Reproduced: a new card in Approved with only its index.md path. Output: "body Approved owner". The
     router drops it: no handler, no user line. Under /watch, events.md item 5 ("a card appearing under
     another lane") and board-kinds Shaping ("the owner places a card here") make it a work order.
     Fix direction: no move, index.md in the burst, and created.at within FRESH -> class it as a move
     (or a new kind routed like move). Add a smoke case.

NOTES: 12
  - classify-event.sh:46 @ 84bdef4 "[ \"${k:-}\" = human ]": by: {} classes as agent, but
    watch/references/events.md item 4 says "by empty -> owner". Unlikely from the app.
  - classify-event.sh:49 @ 84bdef4 "date -j -u -f '%Y-%m-%dT%H:%M:%SZ'": a fractional-second or offset stamp
    -> epoch 0 -> a fresh agent move reads as the owner's. Benign: the handler finds the claim and no-ops.
  - The title column reuses strip_quotes: single-quoted titles keep their quotes ("'It''s: done'"), and
    double-quoted escapes stay raw. Only cosmetic, since a literal "\t" can't split the columns.
  - Smoke gaps (mutation runs): the title, board and paths columns are never asserted (a ct=WRONG mutant
    survived). Nothing covers a two-card burst with one card moved (a mutant that turned off grouping
    survived), or a handler's own move classed self.
  - The arming pass spawns one opus handler per Approved card, and all but the top one no-op. That costs
    N-1 opus spawns on a busy Approved lane.
  - The router finds agent lanes by board-kinds titles (fixer flagged it). A board whose own bodies add or
    rename an agent lane gets a user line instead of a handler.
  - handler.md:38 "On an `index.lock` error, wait 2s and retry": a new git rule outside writes.md § Git, with
    "--only" restated. Concurrent handler pushes (non-fast-forward) aren't addressed.
  - state.sh:35 lock: a SIGKILLed writer leaves .lock behind, and every state call then fails after 5s.
    The message says to remove it.
  - handler.md:14 "items 3–7" vs routing.md:12 "items 1–7": the two files cite events.md differently.
  - Deviations judged acceptable, none blocking: no guide read at arming (the watcher doesn't need it and
    the router writes nothing); arm/chat lines; ACTION: escalate (matches the tiers ruling); the excluded
    set learned from LANE reports (one handler per out-of-scope lane per session); by.name handler
    (companions.md:10, subagents stamp their role); the SKILLS CHANGED fingerprint skipping dispatch
    (documented).
  - f4c8385 (outside the card): justified. My own run at f0bb998 is red with "plugin validate: unexpected
    warning" on ICON_MISSING under "Plugin directory checks". The sed drops everything after that heading,
    so a real warning a future CLI prints below it would go uncounted.
  - The FAIL-BEFORE record names the merge-base as e4ba648. The branch is rebased on f0bb998, and my run
    there agrees.

CHECKED:
  correctness vs done-when: six classify cases + state round-trips are in smoke and pass. Real throwaway
                            boards ("Real Pipe.lanework", spaced name): owner, human-stamped, agent, bare
                            by, bare timestamp and dispatch-session comments; app move, bare mv, agent move;
                            trash; two-card burst; registry beside an owner comment; symlinked board path,
                            absolute and Monitor-format lines. The 3 BLOCKING items are the drops.
                            The trial and "no Read of a card in main" are post-merge / prose-only.
  project conduct:          telegraphic prose, cited files exist (check-refs green), BSD tools, sources
                            lib.sh by relative path, plugin.json/README/install lines updated, no guide
                            stamp under skills/, Decided (separate /dispatch, tiers as-is) honoured; watch
                            changed by one line only. Board Skill label value untouched (lead's).
  both paths:               a card reaching an agent lane: move handled, create-in-place not (BLOCKING 3).
                            Owner event on an idle vs lead-held card: the lead-held path has no receiver
                            (BLOCKING 1).
  fail-before:              OWN RUN agreed: branch tests/smoke.sh in the scratch worktree at f0bb998 stops
                            after "ok 57" on "skills/dispatch/scripts/state.sh: No such file or directory".
                            Missing-harness, REASONED as the fixer said. Mutation pass instead: 13 mutants,
                            10 killed (session self, travelling comments, MOVE_FRESH, registry, excluded,
                            human kind, finish drain, relay, prune, queue append).
  test adequacy:            one block beside the watch cases, ok-line style matches neighbours.
  blast radius:             Phase-2 matches Phase-1: skills/dispatch/, watch/SKILL.md +1 line, plugin.json,
                            README rows/sizes, smoke +11 cases + f4c8385 filter. No unexplained churn.
  population:               smoke 114 passed incl. 11 new; check-sizes 62 rows, 0 wrong.
  adversarial only:         hypotheses before reports: (a) self beats owner on a stale stamp: HELD (B2);
                            (b) new card in agent lane dropped as body: HELD (B3); (c) relay loses events:
                            HELD (B1); (d) move detection needs old paths: refuted, the snapshot diff emits
                            both; (e) concurrent state.sh writers lose rows: refuted, 20 parallel claims ->
                            1 spawn + 19 queued, 20 self rows; (f) tabs/quotes in titles split columns:
                            refuted for escaped tabs; (g) tests pass with a wrong classifier: partly (3
                            mutants survived, NOTE).

UNRESOLVED: none
```

My run of `tests/smoke.sh` in the fixer worktree at `84bdef4` exited 0: "check-sizes: 62 rows, 0 wrong", "smoke: 114 passed".
