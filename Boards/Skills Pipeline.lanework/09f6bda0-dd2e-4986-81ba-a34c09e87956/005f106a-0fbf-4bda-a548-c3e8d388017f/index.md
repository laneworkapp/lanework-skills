---
schema: 1
kind: card
title: "settle-question.sh settles on a Recap click, against rounds.md"
order: 10240
labels: [{text: "discovery", kind: {type: "skill", text: "Skill"}}]
created:  {at: 2026-11-21T15:44:17Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-21T17:14:02Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
`settle-question.sh` stops treating an owner's `Recap:` click as the answer to a waiting question: with no `--record` it refuses and writes nothing, as `rounds.md` already says it does.

## Problem

`skills/discovery/references/rounds.md:34` says a `Recap:` click is not an owner answer. The script disagrees. Reproduced on a throwaway discovery board (`mktemp -d`): one question filed with `file-question.sh` (so `waiting` is set), one human comment `Recap: Explain this in plain terms first` after the ask, then `settle-question.sh <board> <card> --ruling r.md --model smoke` with no `--record`. Output: `settled 3bba40cc -> Settled (order 1024)`, exit 0. The card is settled on a click that asked for an explanation.

Cause: `settle-question.sh` stages the card without `waiting` and runs `work/scripts/lint-waiting-clears.sh` on it. That lint treats any human comment newer than the ask as an answer (the app's own clear rule), so the click counts and the lint is silent.

Not reproduced: the variant where `waiting` is already gone (the app clears it on any human comment, including the click) and the agent has not yet re-posted the ask. `settle-question.sh` skips the lint when `waiting` is absent (`settle-question.sh:61`, `:78`), so it settles. That path is deliberate for cards settled on an answer given on the board, and a script cannot tell it from a card cleared by a click without reading comments; see Risks.

## Change

The rule lives in `settle-question.sh`, not in the lint. The lint also serves the 0.9.0 trial count (`work/references/writing.md`, "agent clears"): a card the app cleared on a click is not an agent clear, and teaching the lint otherwise would list it as `NO-QUOTE` and spoil the count.

- `skills/discovery/scripts/settle-question.sh`: in the loop that copies comments into the lint's staging lane, skip a comment whose first non-blank body line starts `Recap:` and whose `created.by` is not `kind: agent` (a human click, or a comment with no `by`). The lint then sees an unanswered ask and returns `NO-QUOTE`, which the script already turns into exit 1, the `--record` message and nothing written. Real owner answers, before or after the click, still count. Add one header line: a `Recap:` click is not an owner answer. Comments on disk are untouched; only the lint's copy is filtered.
- `skills/discovery/references/rounds.md:34`: no change to the rule. Check the sentence still reads true (`a Recap: click is not one`); it now is.
- No change to `lint-waiting-clears.sh`, `writing.md` or `conduct.md`.

## Verified

Add to the discovery section of `tests/smoke.sh`, beside the existing refusal cases (around line 409), using `owner_comment`:

1. A waiting card whose only owner comment is `Recap: Explain this in plain terms first`: `settle-question.sh` with no `--record` exits 1, the message names `--record`, and the card checksum and comment count are unchanged. Fails today (exit 0, settled).
2. The same card after a second owner comment `A.`: it settles, exit 0. Guards against over-filtering.
3. The same card with `--record` quoting the owner, in reply to the ask, after only the click: it settles, exit 0.
4. A human comment `Recapitulate: A.` (not the `Recap:` prefix) still counts as an answer.

## Done when

- `tests/check-refs.sh` and the new cases in `tests/smoke.sh` pass (run the discovery section only on a throwaway tree, never against the Skills Pipeline board).
- On a throwaway discovery board, one ask plus one `Recap:` human comment: `settle-question.sh` without `--record` exits 1 and the card is byte-identical afterwards.
- `lint-waiting-clears.sh` output on a board with an app-cleared card and a `Recap:` click is unchanged from before.

## Risks

- A person who types a real answer that begins `Recap:` is read as a click. The prefix is the one the button posts and the one `writing.md` and `rounds.md` already name, so the risk is small; the agent can still settle with `--record` quoting them.
- The waiting-absent variant stays open: after a click the app clears `waiting`, and a settle before the re-asked question lands is not caught. Catching it would need the script to refuse any no-`waiting` settle whose newest comment is a click, which would also change cards settled with no ask at all. Left out here; file a follow-up if it bites.
- The filter lives in a script that stages comments by hand, so it must keep handling a comment with no `created.by` (treated as human) and CRLF line ends.

## Recommendation

Build it. The defect is real, reproduced, and the fix is a few lines in one script with no change to the lint or the trial count. Leave the waiting-absent variant as a noted follow-up.
