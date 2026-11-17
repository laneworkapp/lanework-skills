---
schema: 1
kind: comment
created:  {at: 2026-11-17T21:46:33Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: the work order stakes the card an event names before anything decides it is the card to work, and nothing releases a lease the session staked and then did not work, so on an Approved queue the watch can hold a card for its whole life. `arm-pass.sh` itself is sound; 8 notes.

- **Stance**: adversarial; the arming pass now decides from card leases which cards a session picks up unasked (a wrong `arm` puts two sessions on one card, a wrong `held` or `stale` leaves approved work unpicked), and a START comment stops being a claim
- **Round**: 1
- **Card**: [watch: the session stakes a lease before working or handing off a card](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233)
- **Branch**: `watch-lease` at `478a726`

**Blocking**

1. `skills/watch/references/responding.md:18 @ 478a726` "**Stake first**: `lanework/scripts/lease.sh stake <board> <card-uuid> --model m`" with `:21` "**Release** when the card is handed to a gate or done": the stake comes before step 2 ("Read the card whole; act per the lane body"), which is where the session learns whether this card is the work. The only release is at a gate or done. Scenario: the owner drags a card into Approved below the top. `events.md` item 5 says an agent lane makes the move a work order: "stake, then act". The watch stakes the moved card (exit 0). The Approved lane body ("an agent takes the top card into Active unasked") then points it at a different card. The moved card never reaches a gate or Done through this session, so step 4 never fires, and its timer renews it for as long as the watch session lives. The same holds for a card found `waiting`, or put out of scope by its lane body, once it has been read. Measured on a fixture (`TMPDIR`, a stand-in session and `CLAUDE_PID`, `LEASE_TEST_POLL=0.5`, `LEASE_TEST_RENEW_EVERY=2`): `lease.sh stake` on the second Approved card, with no release, moved `until` 22:11:30Z → 22:11:33Z → 22:11:35Z, and `arm-pass.sh` printed `held  Approved  approved second  30m`. Every other session's arming pass reports that card `held` and never arms it. When it reaches the top, this watch's own re-arm (`SKILLS CHANGED`, `events.md` item 8) reads `held` = "Never worked, whoever holds it" (`arming.md:27`), so it goes unpicked until the session ends, then for 30 more minutes. Fix: stake only the card the lane body says to work (Approved: the top), after the `waiting` and lane-body checks. A card the session staked and then does not work is released at once: `writes.md` § Lease already says "given up", which `:21` narrows to gate or done. Moving step 5 ("Any other lane") above the stake fixes the order too.

**Questions for the lead**

1. On the live board, under the branch script, this card (Active, START only, no lease: the lead's START says none was staked) prints `arm  Skills Pipeline.lanework  9c5ee0c7-…  Active`. Once the plugin is released, a watch on Skills Pipeline would pick it up while it is in review. Stake it before release, or accept the risk the card body names ("A START-only card is now free")?

**Notes**

1. `skills/lanework/templates/pipeline-lanes.md:13 @ 478a726` "claiming it with a comment naming the session and branch": every new pipeline board's Active lane body still says a comment is the claim. The watch acts per lane bodies ("the board's own bodies win"), so a session can read a START-only Active card as claimed and not arm it. That errs safe, but it contradicts `companions.md` ("The lease is the claim"). It is outside this card (no `skills/lanework/` change), so file a card. `skills/plan/templates/lanes.md:8` "unclaimed" / "claim one" is generic wording and reads true under the plan lease: no contradiction.
2. `skills/watch/references/responding.md:16`, `arming.md:25-26`, `arm-pass.sh:14` "no valid lease": a lapsed lease is also "no valid lease", yet it is `stale`, not `arm`. On the event path, an owner's move of a lapsed card is a work order, and `stake` takes it over with the two-minute wait. That matches `writes.md`, but contrasts with "never taken over" in the `stale` row. Say "no lease (none, or voided by the clock guard)", and say that an owner's move of a stale card is the owner asking.
3. `skills/watch/references/responding.md:21 @ 478a726` "(`lead.md` § Dispatch: `--release`, else `lease.sh release`)": the repo form is `work/references/lead.md` and `lanework/scripts/lease.sh` from another skill. `check-refs.sh` does not flag it.
4. `skills/watch/references/arming.md:50` "\"Stop\" tears it down (TaskStop)": nothing says the session's own leases outlive the watch. They keep renewing while the session lives, which is right for a subagent still running (the session holds). A card the session drops at stop needs a release. One clause, linked to `writes.md` § Lease.
5. `tests/smoke.sh` does not pin the uuid join. A copy of `arm-pass.sh` joined by title (`$5 == u` with `u="$ct"`) passed the arm-pass block, 11 of 11. A fixture with two cards sharing a title, one leased, would catch it.
6. `skills/watch/scripts/arm-pass.sh:35 @ 478a726` "LEASES=$(bash \"$LEASE\" list \"$BOARD\" 2>/dev/null)": the stderr of `list` is dropped, so the arming report cannot say why it failed. Exit 1 is also what any other `set -e` failure in the script gives, while `arming.md:30` reads exit 1 as the `list` failure. Pass `list`'s stderr through.
7. Pre-existing, unchanged (`title_of`, same on main): a card title with a tab prints an 8-field line (measured: `held … Proposed  tab  title | pipe \"q\" …  -  19m`), and escaped quotes stay as `\"`. A pipe, quotes or another card's uuid in the title do not disturb the join.
8. A duplicate card uuid (an invalid board) makes the unleased copy borrow the other's lease (measured: `held  Active  dup no lease  19m`). `lease.sh` refuses such a card ("not exactly one card"), so the only harm is a missed `arm` on a board that already fails validation.

**Checked**

- **Context**: card body (frozen), the whole thread (shaper, reshape, the retire card landing, the lead's START, the fixer's START and FAIL-BEFORE records), the rulings under Source on Card Lease Discovery, and `writes.md` § Lease and `lease.sh` on the branch (unchanged by it). The fixer's decision on a failing `list` (`comment` only, stderr note, exit 1) is right: an `arm` without lease data is the double-dispatch the ruling forbids, and `arming.md:30` tells the session to report it and arm nothing.
- **Correctness vs done-when**: `arm-pass.sh` calls `lease.sh list` once per run (counted with a wrapper: 3 runs, 3 calls), with no session id and no `CLAUDE_PID` in its environment, and joins on column 1. Fixture matrix, all as ruled:
  - no lease → `arm`
  - flow-form lease (hand-written, and one written by a real `stake` with a short session id) → `held`
  - 3-line block form (hand-written, and one written by a real `stake` with a 48-character session id) → `held 29m`
  - lapsed → `stale 10m`
  - voided (+50 min), `claimed` with no `until`, and `claimed: garbage` → `arm`
  - no `session` with a valid `until` → `held`, as `lease.sh` reads it
  - 59 s left → `held 0m`; `until` = now → `stale 0m`
  - a lease in Ideas (a human lane) → `held`, no `arm`; a lease in Done → nothing; Done named on the command line → still nothing
  - Approved with the top held → no `arm` for the second, as the body asks ("Approved: top card only, as now") and as main does for a START-claimed top
  - a board path with spaces and a symlinked board → same lines
  - `list` exits 1 with partial output → `comment` only, stderr note, exit 1; `list` succeeds with zero rows → 12 `arm`, exit 0, so the two can be told apart
- **Live boards** (branch script vs main, read-only): Skills Pipeline, Card Lease Discovery and Board Runner Discovery checksummed before and after, identical. Exit 0, no stderr. `comment` lines byte-identical and in the same order (1, 21 and 0 lines). The only new line is this card's `arm`.
- **Project conduct**: no CHANGELOG, `plugin.json`, `skills/lanework/`, `skills/work/` or `skills/plan/` change. Bash 3.2 constructs only. No guide version under `skills/watch`. Lease rules are linked, not restated (`35 min` and `30 min` appear in none of the watch references). The farmed prompt is pointed at, not copied. No "assume Y" shapes.
- **Both paths**: `arm` from the arming pass and the owner's move from `events.md` item 5 both route to `responding.md` § A move. The second path is where blocking 1 lives. Nothing in `skills/watch` (scripts included: `watch-boards.sh` has no START or claim logic left) or in `companions.md` still reads START as the claim.
- **Fail-before**: FIXER RUN and OWN RUN agree. The branch's arm-pass smoke block was run against the merge-base `skills/` (`d9295e9`): the full-board line check and cases 1, 2, 3, 4 and 6 fail, as does the lease.sh-missing case. Cases 5 and 7 pass, as the fixer said: they are regression guards.
  - Mutations on a copy of `arm-pass.sh`, each caught by the arm-pass block: lapsed read as held, voided read as held, a held card armed, Done swept, START read as a claim again, a failing `list` ignored (with and without the exit 1). Only the title join survives (note 5).
- **Test adequacy**: the cases sit in the existing arm-pass block, named like their neighbours, with throwaway boards under the smoke scratch dir. Departures, all acceptable:
  - The README `watch` row is rewritten: its old "work claims that look abandoned" became false.
  - The prose check moved from `unclaimed` to `no valid lease`.
  - Cases 5 and 7 cannot fail before.
  - The fractional and offset fixtures went with the stale clock they tested; `row()` still drops fractions when ordering the thread.
- **Blast radius**: 7 files, all named by the body (watch's four files, `arm-pass.sh`, `tests/smoke.sh`, `README.md`). README § Sizes matches `wc -w` (182, 764, 521, 498; total 1,965). `check-sizes.sh` 57 rows 0 wrong, `check-refs.sh` 238 references 0 missing.
- **Population**: 3 live boards (every board under `Boards/`) plus a 16-card fixture covering every state × lane above, and 8 mutations. Full smoke in the fixer's worktree at `478a726`: `smoke: 238 passed`.

**Hypotheses**, written before reading [the fixer's FAIL-BEFORE record](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/9c5ee0c7-3421-4896-83d2-b44b7965c233/d3364b79-12d7-41f2-b722-e67885d88eab). 2 of 9 held.

1. A `list` column mismatch (minutes and state swapped, or `12m` printed as `12mm`): refuted. `$4 "\t" $3` and `%% *` match `list`'s "N min left" and state columns.
2. One malformed `claimed` makes `list` fail and silences every `arm` on the board: refuted. `list` classes it `voided` and exits 0.
3. `list` needs the session env or writes something: refuted, both measured.
4. START remnants elsewhere in watch: refuted in `skills/watch`. Confirmed outside it, in the pipeline Active lane body (note 1).
5. The stake call in the prose is wrong (flags, exit codes, `lead.md` § Dispatch `--release`): refuted. `--model m`, exit 1 and `post-comment.sh --release` all exist. The citation form is off (note 3).
6. Renewal while a subagent runs is left to the session: refuted. The timer renews while `CLAUDE_PID` lives, and "keep the lease" is enough.
7. The session's own leases at watch stop, or on a card it staked and dropped: confirmed (blocking 1, note 4).
8. A title with a tab breaks the join: refuted for the join (column 1). It does break the 7-field output, but that predates this branch (note 7).
9. Smoke passes with a wrong fix: confirmed only for the title join (note 5); the other seven mutations are caught.
