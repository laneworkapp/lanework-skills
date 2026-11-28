---
schema: 1
kind: comment
in-reply-to: ac5d2167-e6fb-473d-9499-cb4864818cdc
created:  {at: 2026-11-28T12:22:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
modified: {at: 2026-11-28T12:22:02Z, by: {name: claude, kind: agent, model: claude-opus-5-5, session: "lanework-skills reviewer"}}
---
**Verdict: REQUEST-CHANGES.** One blocking finding: the missing-lease finding stays silent on the real eight-card case the card names, because those cards' start records never open with START. Six notes.

- **Stance**: adversarial (the lead's brief asked for it; the diff touches lease release and signal paths)
- **Round**: 1
- **Card**: [Starting a card stakes its lease in one step; a missing lease is reported](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b9a35b00-3855-47b2-b24d-b19e72c31d2d)
- **Branch**: `start-card` at `9110ea26`

**Blocking**

1. `skills/work/scripts/lint-leases.sh:174 @ 9110ea26` "`ck[c, j] == "START"`", and `skills/watch/scripts/arm-pass.sh:107 @ 9110ea26` "`[[ $first =~ $START_ERE ]]`": the done-when says "The lint reports the eight-card case above". It does not (measured). I took the app's pipeline board from its git history at `e146430ed` (8 cards in Active) and `90f4173e8` (9 cards), copied it to scratch, and ran the branch's scripts on the copy. 7 and 8 cards in Active carry no `claimed` and no `waiting`. Every one has agent comments stamped `session: "Lanework Pitwall"`. `lint-leases.sh` printed `no lease: 0`, and its only Active finding was the one card that does hold a (lapsed) lease. `arm-pass.sh` printed `arm` for each card and no `unstaked` line. The cause: the start records in that incident open with "Building.", "Building it as shaped.", "Building, in two halves.", never `START`. The fixture in `tests/smoke.sh` case 10 ("the eight-card shape, with three") writes `**START: one**`, so it tests a shape the incident never had. The fixer lists "a start record that doesn't open with START" as a false negative, but that is the incident itself. A session that skips `start-card.sh` is the session the lint exists to catch, and it is also the one least likely to follow `writing.md` § START. Fix: key the finding on what the incident did have. That is a card in a working lane with no `claimed` and no `waiting` whose latest agent comment (or any agent comment since it entered the lane) carries a session, rather than the latest START. Or record the narrower reading on the card as a ruling and change the done-when. Add the historical shape (agent comments, none opening with START) as a smoke case.

**Notes**

1. `skills/work/scripts/start-card.sh:48 @ 9110ea26` "`DEST=$(working_lane "$BOARD")`": there is no source-lane check, so a card at the owner's gate goes straight to Active, leased, with a START (measured: cards in Proposed, Ideas and Done each gave `rc=0 started <id> in Active`). The card says "Refuses a held card as `claim-ticket.sh` does", and `claim-ticket.sh` refuses a ticket not in Frontier. The fixer lists this under Not checked as "the caller's call". It now matters more because this is the one call the guides name for starting a card. Suggest refusing anything outside Approved and the working lane (a re-start), with exit 1 and nothing written.
2. A START can land with no lease when the move fails at its `mv` (measured). On a throwaway board I made the Active lane folder read-only: `start-card.sh` exited 1 with `the move failed (exit 1)`, and the card stayed in Approved with `claimed=0` and one START comment posted. `move-card.sh` posts `--comment` before its `mv` (`move-card.sh:130 @ 9110ea26` "`mv "$CARD" "$DEST/$CID"`"). The header's "a failed start leaves no lease" still holds, but the START stays behind, and a retry posts a second one. A process-group TERM landing between the comment and the `mv` would leave the same state (reasoned; my six timed tries missed that window). Suggest posting the START after the move, as `claim-ticket.sh` posts its Claimed after its move, or saying so in the header.
3. `skills/work/scripts/move-card.sh:131 @ 9110ea26` "`[ -z "$UNSTAKED" ] || echo "move-card.sh: note: ...`": with stderr closed, the exit code and stdout differ from before (measured). Run with `2>&-` on a never-held move into Active: the base gives `rc=0` with the new path on stdout; the branch gives `rc=1` with no stdout. The card has moved, but it is neither validated nor signed. In every other case I tried, stdout and exit match. Fix: `{ echo ... >&2; } 2>/dev/null || true`.
4. `skills/work/templates/farmed-prompt.md:13 @ 9110ea26` "START when you start (work/references/writing.md § START)" and `skills/work/references/companions.md:6 @ 9110ea26` "then the worker posts the plan (`writing.md` § START)": both still tell the worker to post a START. The fixer prompt is `farmed-prompt.md` plus `fixer.md`, so the fixer now gets two contradicting rules. A fixer that follows the template posts a second START under its own `--session` label, and the lint reports two STARTs. `fixer.md` and `lead.md` are coherent with each other and with the two-STARTs finding; these two files were missed. `claim-ticket.sh` posts **Claimed**, not START, so the plan skill is unaffected.
5. `skills/lanework/scripts/lib.sh:64 @ 9110ea26` "`WORKING_LANES=$'Active\nWorking'`": the lead's START ruled that the working lane is "the lane the board's own text names for work in progress, read the way move-card.sh and the arming pass already read lanes". The branch hard-codes two titles instead. The evidence record explains this under How it is recognised but does not list it under Done differently. Also, Working only ever holds plan tickets, and plan sessions never post START (`claim-ticket.sh` posts **Claimed**), so the missing-lease finding can never fire there (reasoned). The move note can.
6. The finding needs a stamped `--session` label. That is the `--session` flag, never `CLAUDE_CODE_SESSION_ID` (`lib.sh` `by_of`). The command `lead.md` § Dispatch shows has no `--session`, so a session that copies it and later loses its lease is never reported (measured: a START posted without `--session` gives `no lease: 0` after the release). Another reason to prefer the signal in Blocking 1, or to count any agent-stamped START. Minor: `START_ERE` takes `STARTLING news` as a START (measured, start-card accepted it), while the refusal message says "opens with START:". The rule is older than this branch.

**Checked**

- **Correctness vs done-when**: "leased with no separate step" holds (measured: free card leased, timer live, in Active, one START). "Lint reports the eight-card case" fails on the real case (Blocking 1). "Silent on a staked board and at a gate" holds (measured on copies of 17 real boards: no new findings). "Guides name the one script" holds in `lead.md`, `responding.md`, `arming.md` and `SKILL.md`, but two files contradict them (Note 4). "Tests cover held, never-held, lost" holds for all three scripts.
- **start-card.sh, odd inputs** (measured on throwaway boards):
  - A missing, empty or directory `--comment`, a lowercase `start:`, `START (shaping)`, an indented START, a body with front matter, an uppercase uuid or an 8-character prefix: exit 1 or 2, board unchanged.
  - An empty `--name`: exit 2. A name with braces and a session label with a quote: exit 0.
  - A datapoint board (no Active): exit 1, "no working lane". A board with both Active and Working: Active. A Working-only non-plan board: Working. An unquoted `title: Active`: works. A plan board: refused (smoke).
- **Release on failure, and signals** (measured):
  - A process-group TERM or HUP while the stake ran (claimed already written, `LEASE_TEST_STAKE_WAIT=2`): `rc=143` / `129`, no `claimed`, no lease row.
  - A parent-only TERM: bash 3.2 waits for the foreground child, then runs the EXIT trap (`rc=143`, trap after the child). So a move that lands is kept, and a stake that is still running is released after it.
  - Six group TERMs timed at the START landing: every card released and unmoved, or landed and leased.
  - I could not make it leave a lease behind, or move without one. The one gap found is the START left behind in Note 2.
- **Shared START_ERE / SHAPE_ERE / WORKING_LANES vs old behaviour**: I ran `lint-leases.sh` and `arm-pass.sh` from `23a53be3` and from `9110ea26` on scratch copies of 17 real boards. Stdout was identical apart from the new lines (0 new on every board), and exit codes matched (lint 1/1 on the app pipeline for its pre-existing two-STARTs lines; the rest 0/0). The tally gains `, no lease: N`, and no script or guide parses the tally.
- **move-card.sh note**: stdout and exit status are unchanged in every case I ran except a closed stderr (Note 3). The note is on stderr only, after the `mv`.
- **Timing commits**:
  - `38bbf046` only adds a `lease.sh release` after the start-card svcheck row. That svcheck still asserts the start's exit and validation before the release, so no assertion is weakened.
  - `4285633c` only raises `LEASE_TEST_RENEW_EVERY` from 1000 to 1000000 inside `start_card`. No case there tests renewal, so this removes a race and weakens nothing.
  - `eeb14043` only rewords header comment lines.
- **Sign** (`94104ef0`): `sign_board` runs after `LANDED=1` and is `|| true` internally, so it can neither fail nor undo the write. Mutation check: with that line removed, case 8's start-card row still passed and case 9's static check failed ("calls stamp_args_ok but never sign_board"). So the row in case 8 proves the sub-scripts sign; case 9 is what proves start-card's own call. The count is 14 (`9110ea26`).
- **Mutations** (scratch copies of the worktree, OWN RUN):
  - Release on failure dropped: `start_card` red at case 4.
  - Lint finding dropped: `lint_leases` red at case 10.
  - Move note dropped: `start_card` red at case 1.
  - `unstaked` line dropped: `arm_pass` red ("arm-pass.sh unstaked lines").
  - Own `sign_board` dropped: `signature` red at case 9.
- **Fail-before**: I did not rerun the fixer's FAIL-BEFORE at `23a53be3`. The mutation runs above stand in for it, as OWN RUN.
- **Project conduct**: no guide version string under `skills/` (smoke `versions` green). Citations follow `<skill>/<dir>/<file>`. Nothing about this repo's own process is under `skills/`. Agent text is telegraphic. Board writes and skill changes are in separate commits.
- **Gates** (measured, on the worktree, `env -u CLAUDE_CODE_SESSION_ID -u CLAUDE_PID bash tests/smoke.sh --only ...`):
  - (a) `braces`: `smoke: 19 passed (sections: braces)`, exit 0.
  - (b) `lease,start_card,lint_leases,arm_pass,watch`: `smoke: 117 passed (sections: lint_leases, watch, arm_pass, start_card, lease)`, exit 0.
  - (c) the 15 generic sections: `smoke: 177 passed (sections: static, plan, lint_symlinks, post_comment, lane_actors, label_kinds, versions, board_writes, commit_board, headers, release_gate, cite_as, usage_guard, plugin, signature)`, exit 0.

**Not checked**: the full smoke run; a SIGKILL during the stake (it strands the stake, as in `claim-ticket.sh`; the same session's next start recovers it); the takeover path over a lapsed lease with a real two-minute wait; the Phase-1 and Phase-2 reports (I had only the evidence record). My hypotheses were not written down before I read the evidence record.
