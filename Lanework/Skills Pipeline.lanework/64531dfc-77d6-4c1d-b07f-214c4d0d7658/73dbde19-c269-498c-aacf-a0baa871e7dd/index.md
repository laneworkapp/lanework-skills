---
schema: 1
title: "Cut reviewer verdicts down to what their readers use"
order: 1024
created: {at: 2026-11-07T02:58:36Z}
modified: {at: 2026-11-07T13:21:48Z, by: {name: claude, kind: agent, model: claude-opus-5-5}}
kind: card
labels: [{text: work, kind: {type: skill, text: Skill}}]
---
Reviewer verdicts become a short Markdown comment that opens with the result and carries only findings, questions and the evidence someone will cite. The full check walk leaves the thread.

## Problem

A verdict is the longest thing on a card and the hardest to read. The median runs 889 words, and over half of those are a CHECKED walk that later readers almost never cite. The template is one code fence, so nothing renders in it, links can't click, and its hard line breaks wrap again in a card-width column. Numbers and method are in the thread.

## Proposal

Replace the fence in `work/templates/review-verdict.md` with this order, in plain Markdown:

1. **Result**: `**Verdict: APPROVE.**` or `**Verdict: REQUEST-CHANGES.**`, then the round, the stance with its trigger, and the head and branch. No `CARD:` line, because the thread already says which card and a lane name goes stale.
2. **Blocking**: only when there is any. One item each: anchor, failure scenario, fix direction.
3. **Questions for the lead**: only when there are any, above the evidence so they can't be missed.
4. **Notes**: only something a person could act on, one line each. A check that came up clean isn't a note.
5. **Evidence**: the fail-before mark and its failure line, the gate's own line with its population, and any checklist item that failed, was skipped or was weaker than asked. Adversarial reviews add how many hypotheses were written first and which held.

Clean checklist items are not listed, because the verdict itself claims them. Target: about 150 words for a clean APPROVE, plus a line per finding. Cards named are links, and anchors sit in inline code.

The same verdict from the screenshot, 889 words before:

> **Verdict: APPROVE.** Round 1, adversarial (removes partial trees on disk). Head `89a78ecb4` on `card/65ff6238-staging-partial`.
>
> **Notes**
>
> - `ClipboardStore.swift:917 @ ad0da6c` "the sweep removes whole": not true of a partial in a copy the pasteboard still names. It costs disk only, and a paste still refuses. Doc-comment fix at most.
>
> **Evidence**
>
> - Fail-before: own run agrees with the fixer's, 5 issues, all in `aFailedCopyRefusesThePaste`.
> - Gate: 8306 tests in 1316 suites passed, on this head.
> - The base really pasted hollow: a rename mid-copy left `index.md` and 46 of 150 files at the destination.
> - Hypotheses: 10 written before the reports, none held.

## Scope

- **In**: reviewer verdicts on card threads, and the copy sent to the lead.
- **Out**: the review checklist and read order, the review stance rules, verdicts already posted.
- **Open call, the check walk**: A (recommended) attach it as a file on adversarial reviews, B a separate comment, C stop writing it.
- **Open call, the fixer's phase reports**: A (recommended) leave them out, B give them the same shape.

## Files

- `skills/work/templates/review-verdict.md`: the new shape.
- `skills/work/references/reviewer.md` § Verdict: the word target, what counts as a note, and the check-walk ruling.
- `README.md` § Sizes: the word counts.
- If the phase reports are ruled in: `skills/work/templates/fixer-phase1-report.md`, `skills/work/templates/fixer-phase2-report.md`, and `skills/work/references/fixer.md`.

## Risks

- A short report is easier to claim falsely than a long walk. The fail-before run, the population and the hypothesis count stay in it.
- Reviewers may pad back up. The word target is a target, and nothing enforces it.
- Smoke is red today on the guide gate until [2c29a34f](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2c29a34f-fde2-4a44-8a3b-94157a320609) lands.

## Verification

- `tests/smoke.sh`, with `check-refs.sh` and `check-sizes.sh` inside it. A prose change, so no new smoke case.
- Read the changed files through against the target guide's § Use the thread, and `work/references/writing.md` § The record.
- Rewrite three real verdicts in the new shape, one clean APPROVE, one REQUEST-CHANGES and one adversarial, as comments on a throwaway board. Validate them with its `lanework-validate.py`, then have the owner view one in the app at card width.

## Done when

- `review-verdict.md` has no fence around the verdict, and its order is the one above.
- Each of the three rewrites keeps every BLOCKING finding, every actionable note and the fail-before and gate lines of its original. The clean APPROVE comes in under 200 words, excluding any attached walk.
- `tests/smoke.sh` passes, or fails only on the guide gate, named as such in the closing comment.
- The owner has looked at a rewrite in the app and the thread records it.
